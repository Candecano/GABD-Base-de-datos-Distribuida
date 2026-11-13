BEGIN;

-- Cancelo la inscripción y conservo su registro.
UPDATE inscripcion
SET estado = 'cancelada'
WHERE legajo = 'COR-001'
  AND codigo_comision = 'COR-GABD-2026-2-B'
  AND estado = 'activa'
RETURNING codigo_inscripcion, legajo, codigo_comision, estado;

COMMIT;