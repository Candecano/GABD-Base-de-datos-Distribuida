-- Preparamos en Formosa la comisión que debe existir antes de importar el Excel.
-- Requiere los catálogos cargados; si el código ya existe, no se vuelve a insertar.
-- Comisión de prueba para las solicitudes del Excel de Formosa.
INSERT INTO comision (
    codigo_comision,
    codigo_materia,
    codigo_sede,
    periodo,
    nombre_comision
)
VALUES (
    'FOR-GABD-2026-2-A',
    'GABD',
    'FOR',
    '2026-2',
    'A'
)
ON CONFLICT (codigo_comision) DO NOTHING;