-- Preparamos en Posadas la comisión que debe existir antes de importar el TXT.
-- Requiere los catálogos cargados; si el código ya existe, no se vuelve a insertar.
-- Comisión de prueba para las solicitudes del TXT de Posadas.
INSERT INTO comision (
    codigo_comision,
    codigo_materia,
    codigo_sede,
    periodo,
    nombre_comision
)
VALUES (
    'POS-GABD-2026-2-A',
    'GABD',
    'POS',
    '2026-2',
    'A'
)
ON CONFLICT (codigo_comision) DO NOTHING;