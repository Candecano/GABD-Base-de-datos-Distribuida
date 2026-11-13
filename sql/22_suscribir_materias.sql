-- Ejecutamos con psql en Formosa y Posadas, cada una con su nombre_suscripcion.
-- La tabla materia debe existir y tener el mismo catálogo inicial que Corrientes.
-- Obtengo la contraseña del entorno del contenedor.
\getenv clave_remota POSTGRES_PASSWORD

-- Preparo la conexión a Corrientes sin mostrar la contraseña.
-- Escapamos comillas y barras de la contraseña para armar la cadena de conexión.
-- La orden gset guarda el resultado en una variable de psql.
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
-- copy_data=false evita copiar las filas iniciales; se reciben los cambios posteriores.
-- La recepción es asincrónica: puede haber una demora hasta verlos en cada sede.
-- Se ejecuta fuera de un BEGIN porque crea un slot de replicación en Corrientes.
CREATE SUBSCRIPTION :"nombre_suscripcion"
CONNECTION :'conexion'
PUBLICATION publicacion_materias
WITH (copy_data = false);

\unset conexion
\unset clave_remota