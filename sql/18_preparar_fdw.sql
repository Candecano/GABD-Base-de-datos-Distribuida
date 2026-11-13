BEGIN;

-- Habilito el acceso a otros servidores PostgreSQL.
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- Creo espacios para las referencias a las tablas remotas.
CREATE SCHEMA IF NOT EXISTS remoto_formosa;
CREATE SCHEMA IF NOT EXISTS remoto_posadas;

-- Registro cómo localizar el nodo de Formosa.
CREATE SERVER servidor_formosa
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (
    host 'formosa',
    port '5432',
    dbname 'ucp',
    connect_timeout '5'
);

-- Registro cómo localizar el nodo de Posadas.
CREATE SERVER servidor_posadas
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (
    host 'posadas',
    port '5432',
    dbname 'ucp',
    connect_timeout '5'
);

COMMIT;