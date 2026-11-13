-- Ejecutamos en Corrientes para publicar las altas, modificaciones y bajas de materia.
-- Las otras sedes las reciben al suscribirse; la clave primaria identifica qué fila cambiar.
-- La publicación comparte datos de esta tabla, no crea su estructura en los otros nodos.
BEGIN;

-- Publico los cambios del catálogo de materias.
CREATE PUBLICATION publicacion_materias
FOR TABLE public.materia
WITH (publish = 'insert, update, delete');

COMMIT;