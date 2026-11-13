-- Damos de alta la inscripción de prueba en Corrientes.
-- La base valida las referencias y que no haya otra activa para esa materia, sede y período.
-- RETURNING muestra el registro creado, incluidos los valores que completa PostgreSQL.
INSERT INTO inscripcion (
    legajo,
    codigo_comision,
    codigo_materia,
    codigo_sede,
    periodo
)
VALUES (
    'COR-001',
    'COR-GABD-2026-2-A',
    'GABD',
    'COR',
    '2026-2'
)
RETURNING
    codigo_inscripcion,
    legajo,
    codigo_comision,
    fecha_inscripcion,
    estado;