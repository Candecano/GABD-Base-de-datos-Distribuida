BEGIN;

-- Intento guardar un estudiante de Formosa en Corrientes.
-- Espero que la restricción estudiante_sede_local lo rechace.
INSERT INTO estudiante (
    legajo, nombre, apellido, codigo_sede
)
VALUES (
    'FOR-999', 'Estudiante', 'Prueba', 'FOR'
);

-- Si la inserción llegara a aceptarse, tampoco conservo la prueba.
ROLLBACK;