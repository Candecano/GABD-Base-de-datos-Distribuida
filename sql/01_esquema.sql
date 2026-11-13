-- Creamos los catálogos de sedes y materias que usan las tablas de cada nodo.
-- Los códigos son claves primarias: identifican cada registro sin repetirse.
CREATE TABLE sede (
    codigo_sede text PRIMARY KEY,
    nombre text NOT NULL
);

-- El catálogo de materias será el que compartimos mediante replicación lógica.
CREATE TABLE materia (
    codigo_materia text PRIMARY KEY,
    nombre text NOT NULL
);