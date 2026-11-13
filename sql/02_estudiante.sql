-- Guardamos los estudiantes del nodo, identificados por un legajo único.
-- La clave foránea exige una sede existente y NOT NULL hace obligatorios sus datos.
CREATE TABLE estudiante (
    legajo text PRIMARY KEY,
    nombre text NOT NULL,
    apellido text NOT NULL,
    codigo_sede text NOT NULL REFERENCES sede (codigo_sede)
);