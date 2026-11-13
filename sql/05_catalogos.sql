-- Cargamos las sedes y la materia inicial en cada nodo dentro de una transacción.
-- ON CONFLICT evita repetir esos códigos al volver a ejecutar la carga; no actualiza sus datos.
BEGIN;

-- Las tres sedes comparten los mismos códigos.
INSERT INTO sede (codigo_sede, nombre)
VALUES
    ('COR', 'Corrientes'),
    ('FOR', 'Formosa'),
    ('POS', 'Posadas')
ON CONFLICT (codigo_sede) DO NOTHING;

-- Materia que vamos a usar para probar las inscripciones.
INSERT INTO materia (codigo_materia, nombre)
VALUES ('GABD', 'Gestión Avanzada de Bases de Datos')
ON CONFLICT (codigo_materia) DO NOTHING;

COMMIT;