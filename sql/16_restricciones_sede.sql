-- Aplicamos la fragmentación horizontal: cada nodo acepta filas de su propia sede.
-- Al ejecutar con psql hay que pasar codigo_sede con COR, FOR o POS según el nodo.
-- Los CHECK también revisan las filas existentes; las tres restricciones se confirman juntas.
BEGIN;

-- Limito los estudiantes al fragmento de esta sede.
ALTER TABLE estudiante
ADD CONSTRAINT estudiante_sede_local
CHECK (codigo_sede = :'codigo_sede');

-- Limito las comisiones al fragmento de esta sede.
ALTER TABLE comision
ADD CONSTRAINT comision_sede_local
CHECK (codigo_sede = :'codigo_sede');

-- Limito las inscripciones al fragmento de esta sede.
ALTER TABLE inscripcion
ADD CONSTRAINT inscripcion_sede_local
CHECK (codigo_sede = :'codigo_sede');

COMMIT;