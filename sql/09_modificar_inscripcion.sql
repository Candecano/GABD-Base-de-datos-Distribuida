-- Probamos la modificación del ABM en Corrientes después del alta.
-- El filtro elige la inscripción activa en A; la clave foránea valida la comisión B.
-- RETURNING permite ver el cambio; si no coincide ninguna fila, no se modifica nada.
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