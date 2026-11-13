BEGIN;

-- Agrego una materia en Corrientes para probar su replicación.
INSERT INTO public.materia (codigo_materia, nombre)
VALUES ('REP01', 'Desarrollo de Videojuegos');

COMMIT;