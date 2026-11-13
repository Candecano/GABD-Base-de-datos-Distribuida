-- Cambiamos la comisión de la inscripción existente.
UPDATE inscripcion
SET codigo_comision = 'COR-GABD-2026-2-B'
WHERE legajo = 'COR-001'
  AND codigo_comision = 'COR-GABD-2026-2-A'
  AND estado = 'activa'
RETURNING
    codigo_inscripcion,
    legajo,
    codigo_comision,
    periodo,
    estado;