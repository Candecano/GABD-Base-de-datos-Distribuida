CREATE TABLE estudiante (
    legajo text PRIMARY KEY,
    nombre text NOT NULL,
    apellido text NOT NULL,
    codigo_sede text NOT NULL REFERENCES sede (codigo_sede)
);