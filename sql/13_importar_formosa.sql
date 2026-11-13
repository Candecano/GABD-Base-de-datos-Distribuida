-- Importamos en Formosa el JSON preparado por el validador del Excel.
-- La carga y su registro se confirman juntos; una excepción revierte todo el lote.
BEGIN;

-- Evito que dos importaciones modifiquen estas tablas al mismo tiempo.
-- Para esta prueba pequeña, bloqueo las escrituras durante la carga.
LOCK TABLE estudiante, inscripcion, solicitud_importada
    IN SHARE ROW EXCLUSIVE MODE;

DO $$
DECLARE
    solicitudes jsonb;
    solicitud jsonb;
    datos_anteriores jsonb;
    estudiante_actual estudiante%ROWTYPE;
    nueva_inscripcion uuid;
    cantidad_importadas integer := 0;
    cantidad_omitidas integer := 0;
BEGIN
    -- Leo el archivo intermedio que copiamos al contenedor.
    -- pg_read_file lee dentro del contenedor, no desde la carpeta de la computadora.
    solicitudes := pg_read_file('/tmp/formosa_validas.json')::jsonb;

    IF jsonb_typeof(solicitudes) IS DISTINCT FROM 'array' THEN
        RAISE EXCEPTION 'El archivo debe contener una lista de solicitudes';
    END IF;

    FOR solicitud IN
        SELECT value FROM jsonb_array_elements(solicitudes)
    LOOP
        -- Compruebo que la solicitud corresponda a esta sede.
        IF solicitud->>'codigo_sede' IS DISTINCT FROM 'FOR'
           OR COALESCE(solicitud->>'legajo', '') !~ '^FOR-[0-9]+$'
           OR COALESCE(solicitud->>'solicitud', '') !~ '^FOR-SOL-[0-9]+$'
        THEN
            RAISE EXCEPTION 'Solicitud inválida para Formosa: %',
                solicitud->>'solicitud';
        END IF;

        -- Si ya se importó, comparo los datos recibidos.
        SELECT datos_origen
        INTO datos_anteriores
        FROM solicitud_importada
        WHERE origen = 'excel_formosa'
          AND codigo_solicitud = solicitud->>'solicitud';

        IF FOUND THEN
            IF datos_anteriores IS DISTINCT FROM solicitud THEN
                RAISE EXCEPTION
                    'La solicitud % ya fue importada con otros datos',
                    solicitud->>'solicitud';
            END IF;

            -- Solo omitimos una solicitud ya registrada si sus datos coinciden exactamente.
            cantidad_omitidas := cantidad_omitidas + 1;
            CONTINUE;
        END IF;

        -- Verifico que exista la comisión con esos datos.
        PERFORM 1
        FROM comision
        WHERE codigo_comision = solicitud->>'codigo_comision'
          AND codigo_materia = solicitud->>'codigo_materia'
          AND codigo_sede = solicitud->>'codigo_sede'
          AND periodo = solicitud->>'periodo';

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Comisión inexistente o incompatible: %',
                solicitud->>'codigo_comision';
        END IF;

        -- Compruebo los datos obligatorios del estudiante.
        IF COALESCE(trim(solicitud->>'nombre'), '') = ''
           OR COALESCE(trim(solicitud->>'apellido'), '') = ''
        THEN
            RAISE EXCEPTION 'Falta nombre o apellido en %',
                solicitud->>'solicitud';
        END IF;

        SELECT *
        INTO estudiante_actual
        FROM estudiante
        WHERE legajo = solicitud->>'legajo';

        IF FOUND THEN
            -- No sobrescribo un estudiante que tenga datos diferentes.
            IF estudiante_actual.nombre
                    IS DISTINCT FROM solicitud->>'nombre'
               OR estudiante_actual.apellido
                    IS DISTINCT FROM solicitud->>'apellido'
               OR estudiante_actual.codigo_sede
                    IS DISTINCT FROM solicitud->>'codigo_sede'
            THEN
                RAISE EXCEPTION 'Datos distintos para el legajo %',
                    solicitud->>'legajo';
            END IF;
        ELSE
            INSERT INTO estudiante (
                legajo, nombre, apellido, codigo_sede
            )
            VALUES (
                solicitud->>'legajo',
                solicitud->>'nombre',
                solicitud->>'apellido',
                solicitud->>'codigo_sede'
            );
        END IF;

        -- Las restricciones de la tabla comprueban las referencias
        -- e impiden otra inscripción activa en la misma materia.
        INSERT INTO inscripcion (
            legajo, codigo_comision, codigo_materia,
            codigo_sede, periodo
        )
        VALUES (
            solicitud->>'legajo',
            solicitud->>'codigo_comision',
            solicitud->>'codigo_materia',
            solicitud->>'codigo_sede',
            solicitud->>'periodo'
        )
        RETURNING codigo_inscripcion INTO nueva_inscripcion;

        -- Registro el origen dentro de la misma transacción.
        INSERT INTO solicitud_importada (
            origen, codigo_solicitud, codigo_inscripcion,
            fecha_solicitud, datos_origen
        )
        VALUES (
            'excel_formosa',
            solicitud->>'solicitud',
            nueva_inscripcion,
            (solicitud->>'fecha_solicitud')::date,
            solicitud
        );

        cantidad_importadas := cantidad_importadas + 1;
    END LOOP;

    -- El resumen distingue las altas nuevas de las solicitudes idénticas que ya estaban cargadas.
    RAISE NOTICE 'Solicitudes nuevas: %. Ya procesadas: %.',
        cantidad_importadas, cantidad_omitidas;
END;
$$;

COMMIT;