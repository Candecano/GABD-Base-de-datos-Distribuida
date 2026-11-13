-- Probamos la replicación insertando una materia nueva solo en Corrientes.
-- Después del COMMIT esperamos verla en Formosa y Posadas si las suscripciones están activas.
-- La llegada puede demorar; este archivo no consulta los otros nodos y deja la materia cargada.
BEGIN;

-- Agrego una materia en Corrientes para probar su replicación.
INSERT INTO public.materia (codigo_materia, nombre)
VALUES ('REP01', 'Desarrollo de Videojuegos');

COMMIT;