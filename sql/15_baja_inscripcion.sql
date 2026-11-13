-- Probamos la baja lógica en Corrientes después de pasar la inscripción a la comisión B.
-- No borramos la fila: al cancelarla conserva el historial y deja de ocupar la unicidad de activas.
-- RETURNING muestra las filas afectadas y COMMIT confirma la baja.
BEGIN;

-- Cancelo la inscripción y conservo su registro.
UPDATE inscripcion
SET estado = 'cancelada'
WHERE legajo = 'COR-001'
  AND codigo_comision = 'COR-GABD-2026-2-B'
  AND estado = 'activa'
RETURNING codigo_inscripcion, legajo, codigo_comision, estado;

COMMIT;