-- Definimos las comisiones disponibles para inscribirse en cada sede.
-- Las claves foráneas exigen que la materia y la sede estén cargadas.
CREATE TABLE comision (
    codigo_comision text PRIMARY KEY,
    codigo_materia text NOT NULL REFERENCES materia (codigo_materia),
    codigo_sede text NOT NULL REFERENCES sede (codigo_sede),
    periodo text NOT NULL,
    nombre_comision text NOT NULL,
    horario text,
    aula text,
    -- Esta combinación evita repetir la misma comisión de una materia, sede y período.
    UNIQUE (codigo_materia, codigo_sede, periodo, nombre_comision)
);