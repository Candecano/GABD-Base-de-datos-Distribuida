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