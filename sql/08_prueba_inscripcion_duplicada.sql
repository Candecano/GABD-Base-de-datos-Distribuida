-- Ejecutamos esta prueba en Corrientes después del alta del archivo 07.
-- Aunque elegimos otra comisión, esperamos un error del índice inscripcion_activa_por_materia.
-- La transacción se revierte: si el cliente se detiene ante el error, debe cerrar la transacción.
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