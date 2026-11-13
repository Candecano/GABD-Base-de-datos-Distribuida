-- Ejecutamos en Corrientes después de aplicar el archivo 16 con codigo_sede=COR.
-- El rechazo esperado demuestra que el nodo no acepta filas de otro fragmento.
-- Si el cliente se detiene ante el error, hay que cerrar la transacción sin confirmarla.
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