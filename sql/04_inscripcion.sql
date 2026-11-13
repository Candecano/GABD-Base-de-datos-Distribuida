-- Creamos las inscripciones y sus controles en una sola transacción.
-- Si falla algún paso, no se confirma una estructura a medio crear.
BEGIN;

-- Permite comprobar que la comisión corresponde a la materia, sede y período indicados.
ALTER TABLE comision
    ADD CONSTRAINT comision_referencia_inscripcion
    UNIQUE (codigo_comision, codigo_materia, codigo_sede, periodo);

-- El UUID identifica cada inscripción y se genera sin un contador compartido entre nodos.
-- El legajo debe existir; la fecha y el estado inicial se completan si no se informan.
CREATE TABLE inscripcion (
    codigo_inscripcion uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    legajo text NOT NULL REFERENCES estudiante (legajo),
    codigo_comision text NOT NULL,
    codigo_materia text NOT NULL,
    codigo_sede text NOT NULL,
    periodo text NOT NULL,
    fecha_inscripcion date NOT NULL DEFAULT CURRENT_DATE,
    -- Solo admitimos estados que el sistema sabe manejar.
    estado text NOT NULL DEFAULT 'activa'
        CHECK (estado IN ('activa', 'cancelada')),

    -- La referencia conjunta impide mezclar una comisión con otra materia, sede o período.
    FOREIGN KEY (codigo_comision, codigo_materia, codigo_sede, periodo)
        REFERENCES comision (codigo_comision, codigo_materia, codigo_sede, periodo)
);

-- Cada estudiante puede tener una sola inscripción activa por materia, sede y período.
-- Las canceladas quedan fuera del índice, así se conserva el historial y se permite otra alta.
CREATE UNIQUE INDEX inscripcion_activa_por_materia
    ON inscripcion (legajo, codigo_materia, codigo_sede, periodo)
    WHERE estado = 'activa';

COMMIT;