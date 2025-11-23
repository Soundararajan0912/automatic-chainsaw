-- Create databases
CREATE DATABASE openmetadata_db;
CREATE DATABASE airflow_db;

-- Create users
CREATE USER openmetadata_admin WITH PASSWORD 'OPD$0un5ar@2410';
CREATE USER airflow_admin WITH PASSWORD 'AIRF10w$Adm1n@2410';

-- Grant database-level permissions
GRANT ALL PRIVILEGES ON DATABASE openmetadata_db TO openmetadata_admin;
GRANT ALL PRIVILEGES ON DATABASE airflow_db TO airflow_admin;

-- Connect to openmetadata_db and set permissions
\c openmetadata_db

GRANT USAGE ON SCHEMA public TO openmetadata_admin;
GRANT CREATE ON SCHEMA public TO openmetadata_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO openmetadata_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO openmetadata_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO openmetadata_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO openmetadata_admin;

-- Connect to airflow_db and set permissions
\c airflow_db

GRANT USAGE ON SCHEMA public TO airflow_admin;
GRANT CREATE ON SCHEMA public TO airflow_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO airflow_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO airflow_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO airflow_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO airflow_admin;