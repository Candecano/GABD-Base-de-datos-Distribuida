-- Registro las solicitudes importadas correctamente.
CREATE TABLE solicitud_importada (
    origen text NOT NULL,
    codigo_solicitud text NOT NULL,
    codigo_inscripcion uuid NOT NULL
        REFERENCES inscripcion (codigo_inscripcion),
    fecha_solicitud date NOT NULL,
    fecha_importacion timestamptz NOT NULL
        DEFAULT CURRENT_TIMESTAMP,
    datos_origen jsonb NOT NULL,

    PRIMARY KEY (origen, codigo_solicitud)
);