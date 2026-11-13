-- Debe rechazarse porque la estudiante ya tiene una
-- inscripción activa en esta materia, sede y período
BEGIN;

INSERT INTO inscripcion (
    legajo,
    codigo_comision,
    codigo_materia,
    codigo_sede,
    periodo
)
VALUES (
    'COR-001',
    'COR-GABD-2026-2-B',
    'GABD',
    'COR',
    '2026-2'
);

ROLLBACK;