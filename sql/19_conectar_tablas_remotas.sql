-- Conectamos desde Corrientes las tablas de Formosa y Posadas usando psql.
-- Los mapeos indican con qué usuario remoto se conecta ucp_admin.
-- Leo la contraseña del entorno del contenedor.
-- No hace falta escribirla en este archivo.
\getenv clave_remota POSTGRES_PASSWORD

BEGIN;

-- Configuro las credenciales para acceder a Formosa.
CREATE USER MAPPING FOR ucp_admin
SERVER servidor_formosa
OPTIONS (
    user 'ucp_admin',
    password :'clave_remota'
);

-- Configuro las credenciales para acceder a Posadas.
CREATE USER MAPPING FOR ucp_admin
SERVER servidor_posadas
OPTIONS (
    user 'ucp_admin',
    password :'clave_remota'
);

-- Creo referencias a las tablas de Formosa.
-- Se importa la definición de las tablas, no sus filas: los datos siguen en el nodo remoto.
IMPORT FOREIGN SCHEMA public
LIMIT TO (estudiante, comision, inscripcion)
FROM SERVER servidor_formosa
INTO remoto_formosa;

-- Creo referencias a las tablas de Posadas.
IMPORT FOREIGN SCHEMA public
LIMIT TO (estudiante, comision, inscripcion)
FROM SERVER servidor_posadas
INTO remoto_posadas;

COMMIT;

\unset clave_remota