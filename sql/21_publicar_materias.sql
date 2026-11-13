BEGIN;

-- Publico los cambios del catálogo de materias.
CREATE PUBLICATION publicacion_materias
FOR TABLE public.materia
WITH (publish = 'insert, update, delete');

COMMIT;