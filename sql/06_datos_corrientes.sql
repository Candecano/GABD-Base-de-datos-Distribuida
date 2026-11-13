-- Cargamos la estudiante y las dos comisiones para probar el ABM en Corrientes.
-- Se confirma todo junto; si un código ya existe, se conserva el registro anterior.
BEGIN;

INSERT INTO estudiante (legajo, nombre, apellido, codigo_sede)
VALUES ('COR-001', 'Lucía', 'Ríos', 'COR')
ON CONFLICT (legajo) DO NOTHING;

INSERT INTO comision (
    codigo_comision, codigo_materia, codigo_sede,
    periodo, nombre_comision, horario, aula
)
VALUES
    ('COR-GABD-2026-2-A', 'GABD', 'COR', '2026-2', 'A', 'Lunes 18:00', '101'),
    ('COR-GABD-2026-2-B', 'GABD', 'COR', '2026-2', 'B', 'Martes 18:00', '102')
ON CONFLICT (codigo_comision) DO NOTHING;

COMMIT;