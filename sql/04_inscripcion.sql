BEGIN;

-- Permite comprobar que la comisión corresponde a la materia, sede y período indicados.
ALTER TABLE comision
    ADD CONSTRAINT comision_referencia_inscripcion
    UNIQUE (codigo_comision, codigo_materia, codigo_sede, periodo);

CREATE TABLE inscripcion (
    codigo_inscripcion uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    legajo text NOT NULL REFERENCES estudiante (legajo),
    codigo_comision text NOT NULL,
    codigo_materia text NOT NULL,
    codigo_sede text NOT NULL,
    periodo text NOT NULL,
    fecha_inscripcion date NOT NULL DEFAULT CURRENT_DATE,
    estado text NOT NULL DEFAULT 'activa'
        CHECK (estado IN ('activa', 'cancelada')),

    FOREIGN KEY (codigo_comision, codigo_materia, codigo_sede, periodo)
        REFERENCES comision (codigo_comision, codigo_materia, codigo_sede, periodo)
);

-- Cada estudiante puede tener una sola inscripción activa por materia, sede y período.
CREATE UNIQUE INDEX inscripcion_activa_por_materia
    ON inscripcion (legajo, codigo_materia, codigo_sede, periodo)
    WHERE estado = 'activa';

COMMIT;