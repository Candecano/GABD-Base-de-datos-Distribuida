-- Obtengo la contraseña del entorno del contenedor.
\getenv clave_remota POSTGRES_PASSWORD

-- Preparo la conexión a Corrientes sin mostrar la contraseña.
SELECT
    'host=corrientes port=5432 dbname=ucp user=ucp_admin connect_timeout=5 password='
    || chr(39)
    || replace(
        replace(:'clave_remota', chr(92), chr(92) || chr(92)),
        chr(39), chr(92) || chr(39)
    )
    || chr(39) AS conexion
\gset

-- Cada sede tendrá su propia suscripción.
-- El catálogo inicial ya está cargado y coincide.
CREATE SUBSCRIPTION :"nombre_suscripcion"
CONNECTION :'conexion'
PUBLICATION publicacion_materias
WITH (copy_data = false);

\unset conexion
\unset clave_remota