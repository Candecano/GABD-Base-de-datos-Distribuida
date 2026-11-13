BEGIN;

-- Reúno los estudiantes de las tres sedes.
CREATE OR REPLACE VIEW public.estudiante_global AS
SELECT legajo, nombre, apellido, codigo_sede
FROM public.estudiante
UNION ALL
SELECT legajo, nombre, apellido, codigo_sede
FROM remoto_formosa.estudiante
UNION ALL
SELECT legajo, nombre, apellido, codigo_sede
FROM remoto_posadas.estudiante;

-- Reúno las inscripciones, incluidas las canceladas.
CREATE OR REPLACE VIEW public.inscripcion_global AS
SELECT codigo_inscripcion, legajo, codigo_comision,
       codigo_materia, codigo_sede, periodo,
       fecha_inscripcion, estado
FROM public.inscripcion
UNION ALL
SELECT codigo_inscripcion, legajo, codigo_comision,
       codigo_materia, codigo_sede, periodo,
       fecha_inscripcion, estado
FROM remoto_formosa.inscripcion
UNION ALL
SELECT codigo_inscripcion, legajo, codigo_comision,
       codigo_materia, codigo_sede, periodo,
       fecha_inscripcion, estado
FROM remoto_posadas.inscripcion;

COMMIT;