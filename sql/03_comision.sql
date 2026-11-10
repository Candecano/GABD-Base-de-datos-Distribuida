CREATE TABLE comision (
    codigo_comision text PRIMARY KEY,
    codigo_materia text NOT NULL REFERENCES materia (codigo_materia),
    codigo_sede text NOT NULL REFERENCES sede (codigo_sede),
    periodo text NOT NULL,
    nombre_comision text NOT NULL,
    horario text,
    aula text,
    UNIQUE (codigo_materia, codigo_sede, periodo, nombre_comision)
);