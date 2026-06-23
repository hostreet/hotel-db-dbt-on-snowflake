-- =============================================================================
-- Tasty Bytes dbt Demo: Environment Setup & Source Data
-- Source: https://docs.snowflake.com/en/user-guide/tutorials/dbt-projects-on-snowflake-getting-started-tutorial
--
-- This script sets up the complete environment for the Tasty Bytes dbt project:
--   1. Warehouse for executing workspace actions
--   2. Database and schemas for integrations and model materializations
--   3. Logging, tracing, and metrics for observability
--   4. GitHub secret and API integration for connecting to your repository
--   5. Network rule and external access integration for dbt dependencies
--   6. Source data: Tasty Bytes foundational data model (raw zone tables + data load)
--
-- NOTE: Before running this script in a workspace, comment out any CREATE statements
-- for objects you already created during the "Set up your environment" steps:
--   CREATE OR REPLACE WAREHOUSE ...
--   CREATE OR REPLACE API INTEGRATION ...
--   CREATE OR REPLACE NETWORK RULE ...
--   CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION ...
-- =============================================================================

USE ROLE ACCOUNTADMIN;

-- =============================================================================
-- STEP 1: Create a warehouse for executing workspace actions
-- A dedicated warehouse assigned to your workspace helps you log, trace,
-- and identify actions initiated from within that workspace.
-- The Tasty Bytes data model is fairly large, so an XL warehouse is recommended.
-- Alternatively, you can use an existing warehouse in your account.
-- =============================================================================

--CREATE WAREHOUSE tasty_bytes_dbt_wh WAREHOUSE_SIZE = XLARGE;

-- =============================================================================
-- STEP 2: Create a database and schemas for integrations and model materializations
-- The INTEGRATIONS schema stores objects Snowflake needs for GitHub integration.
-- The DEV and PROD schemas store materialized objects that your dbt project creates.
-- The RAW schema holds the Tasty Bytes foundational source data.
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS hoteldb_dev.bronze;
CREATE SCHEMA IF NOT EXISTS hoteldb_dev.silver;
CREATE SCHEMA IF NOT EXISTS hoteldb_dev.gold;


CREATE SCHEMA IF NOT EXISTS hoteldb_prd.bronze;
CREATE SCHEMA IF NOT EXISTS hoteldb_prd.silver;
CREATE SCHEMA IF NOT EXISTS hoteldb_prd.gold;


-- =============================================================================
-- STEP 3: Enable logging, tracing, and metrics
-- You can capture logging and tracing events for a dbt project object and for
-- the task that runs it on a schedule. These settings must be applied to the
-- schemas where the dbt project object and task are deployed.
-- See: https://docs.snowflake.com/en/user-guide/data-engineering/dbt-projects-on-snowflake-monitoring-observability
-- =============================================================================

ALTER SCHEMA hoteldb_dev.bronze SET LOG_LEVEL = 'INFO';
ALTER SCHEMA hoteldb_dev.silver SET TRACE_LEVEL = 'ALWAYS';
ALTER SCHEMA hoteldb_dev.gold SET METRIC_LEVEL = 'ALL';

ALTER SCHEMA hoteldb_prd.bronze SET LOG_LEVEL = 'INFO';
ALTER SCHEMA hoteldb_prd.silver SET TRACE_LEVEL = 'ALWAYS';
ALTER SCHEMA hoteldb_prd.gold SET METRIC_LEVEL = 'ALL';

-- =============================================================================
-- STEP 4: Create a GitHub secret and API integration
-- Snowflake needs an API integration to interact with GitHub.
-- If your repository is private, you must also create a secret to store GitHub
-- credentials. You then reference the secret in the API integration definition
-- and when creating the workspace for your dbt project.
--
-- Creating a secret requires a personal access token for your repository.
-- See: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens
--
-- Alternatively, your admin can set up one OAuth2 integration for the team instead of managing personal access tokens.
-- See: https://docs.snowflake.com/en/user-guide/ui-snowsight/workspaces-git
-- =============================================================================


-- =============================================================================
-- STEP 5: (Optional) Create a network rule and external access integration
-- If you plan to run 'dbt deps' in a workspace, dbt will need to access remote
-- URLs to download dependencies (e.g. packages from the dbt Package Hub or
-- from GitHub). Most dbt projects specify dependencies in their packages.yml
-- file, which must be installed in the workspace before other commands will work.
-- See: https://docs.snowflake.com/en/developer-guide/external-network-access/creating-using-external-network-access
-- =============================================================================

-- Create NETWORK RULE for external access integration
-- CREATE OR REPLACE NETWORK RULE dbt_network_rule
--   MODE = EGRESS
--   TYPE = HOST_PORT
--   -- Minimal URL allowlist that is required for dbt deps
--   VALUE_LIST = (
--     'hub.getdbt.com',
--     'codeload.github.com'
--     );

-- Create EXTERNAL ACCESS INTEGRATION for dbt access to external dbt package locations
-- CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION dbt_ext_access
--   ALLOWED_NETWORK_RULES = (dbt_network_rule)
--   ENABLED = TRUE;

-- =============================================================================
-- STEP 6: Set up source data - Tasty Bytes foundational data model
-- The dbt project uses the foundational data model for the fictitious Tasty Bytes
-- food truck brand as its source data for transformations.
-- This section creates a file format and external stage pointing to S3, builds
-- the raw zone tables, and loads data into them.
-- =============================================================================

-- File format and external stage

-- CREATE OR REPLACE FILE FORMAT tasty_bytes_dbt_db.public.csv_ff 
-- type = 'csv';

-- CREATE OR REPLACE STAGE tasty_bytes_dbt_db.public.s3load
-- COMMENT = 'Quickstarts S3 Stage Connection'
-- url = 's3://sfquickstarts/frostbyte_tastybytes/'
-- file_format = tasty_bytes_dbt_db.public.csv_ff;

-- =============================================================================
--  Raw zone table builds
-- =============================================================================


-- bronze table (dev)
CREATE OR REPLACE TABLE hoteldb_dev.bronze.GUEST_RAW (
    GUEST_ID        VARCHAR,
    GUEST_NAME      VARCHAR,
    PHONE           VARCHAR,
    EMAIL           VARCHAR,
    COUNTRY         VARCHAR,
    LOAD_DT         TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE hoteldb_dev.bronze.ROOM_RAW (
    ROOM_ID         VARCHAR,
    HOTEL_NAME      VARCHAR,
    ROOM_TYPE       VARCHAR,
    ROOM_NO         VARCHAR,
    BASE_PRICE      VARCHAR,
    LOAD_DT         TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE hoteldb_dev.bronze.RESERVATION_RAW (
    RESERVATION_ID      VARCHAR,
    GUEST_ID            VARCHAR,
    ROOM_ID             VARCHAR,
    CHECK_IN_DATE       VARCHAR,
    CHECK_OUT_DATE      VARCHAR,
    TOTAL_AMOUNT        VARCHAR,
    CHANNEL             VARCHAR,
    STATUS              VARCHAR,
    LOAD_DT             TIMESTAMP_NTZ
);


-- silver table (dev)
CREATE OR REPLACE TABLE hoteldb_dev.silver.GUEST (
    GUEST_ID        VARCHAR,
    GUEST_NAME      VARCHAR,
    PHONE           VARCHAR,
    EMAIL           VARCHAR,
    COUNTRY_CODE    VARCHAR,
    CREATED_AT      TIMESTAMP_NTZ
);


CREATE OR REPLACE TABLE hoteldb_dev.silver.ROOM (
    ROOM_ID         VARCHAR,
    HOTEL_NAME      VARCHAR,
    ROOM_TYPE       VARCHAR,
    ROOM_NO         VARCHAR,
    BASE_PRICE      NUMBER(10,2),
    CREATED_AT      TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE hoteldb_dev.silver.RESERVATION (
    RESERVATION_ID      VARCHAR,
    GUEST_ID            VARCHAR,
    ROOM_ID             VARCHAR,
    CHECK_IN_DATE       DATE,
    CHECK_OUT_DATE      DATE,
    NIGHTS              NUMBER(3,0),
    TOTAL_AMOUNT        NUMBER(12,2),
    CHANNEL             VARCHAR,
    STATUS              VARCHAR,
    IS_CANCELLED        BOOLEAN,
    CREATED_AT          TIMESTAMP_NTZ
);




-- bronze table (prd)
CREATE OR REPLACE TABLE hoteldb_prd.bronze.GUEST_RAW (
    GUEST_ID        VARCHAR,
    GUEST_NAME      VARCHAR,
    PHONE           VARCHAR,
    EMAIL           VARCHAR,
    COUNTRY         VARCHAR,
    LOAD_DT         TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE hoteldb_prd.bronze.ROOM_RAW (
    ROOM_ID         VARCHAR,
    HOTEL_NAME      VARCHAR,
    ROOM_TYPE       VARCHAR,
    ROOM_NO         VARCHAR,
    BASE_PRICE      VARCHAR,
    LOAD_DT         TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE hoteldb_prd.bronze.RESERVATION_RAW (
    RESERVATION_ID      VARCHAR,
    GUEST_ID            VARCHAR,
    ROOM_ID             VARCHAR,
    CHECK_IN_DATE       VARCHAR,
    CHECK_OUT_DATE      VARCHAR,
    TOTAL_AMOUNT        VARCHAR,
    CHANNEL             VARCHAR,
    STATUS              VARCHAR,
    LOAD_DT             TIMESTAMP_NTZ
);




-- BRONZE_GUEST_RAW
INSERT INTO hoteldb_dev.bronze.GUEST_RAW
(GUEST_ID, GUEST_NAME, PHONE, EMAIL, COUNTRY, LOAD_DT)
VALUES
('G001', '김민지', '010-1111-1111', 'minji@test.com', 'KR', CURRENT_TIMESTAMP()),
('G002', 'John Smith', '+1-555-1234', 'john@test.com', 'US', CURRENT_TIMESTAMP()),
('G003', '박서준', '010-2222-2222', 'sjpark@test.com', 'KR', CURRENT_TIMESTAMP());

-- BRONZE_ROOM_RAW
INSERT INTO hoteldb_dev.bronze.ROOM_RAW
(ROOM_ID, HOTEL_NAME, ROOM_TYPE, ROOM_NO, BASE_PRICE, LOAD_DT)
VALUES
('R101', '서울 리버 호텔', 'Deluxe', '1001', '160000', CURRENT_TIMESTAMP()),
('R102', '서울 리버 호텔', 'Standard', '805', '120000', CURRENT_TIMESTAMP()),
('R103', '부산 오션 스테이', 'Suite', '1502', '250000', CURRENT_TIMESTAMP());

-- BRONZE_RESERVATION_RAW
INSERT INTO hoteldb_dev.bronze.RESERVATION_RAW
(RESERVATION_ID, GUEST_ID, ROOM_ID, CHECK_IN_DATE, CHECK_OUT_DATE, TOTAL_AMOUNT, CHANNEL, STATUS, LOAD_DT)
VALUES
('RES001', 'G001', 'R101', '2026-07-01', '2026-07-03', '320000', 'OTA', 'CONFIRMED', CURRENT_TIMESTAMP()),
('RES002', 'G002', 'R102', '2026/07/05', '2026/07/06', '120,000', 'DIRECT', 'CANCELLED', CURRENT_TIMESTAMP()),
('RES003', 'G003', 'R103', '2026-08-10', '2026-08-13', '750000', 'OTA', 'CONFIRMED', CURRENT_TIMESTAMP());





-- BRONZE_GUEST_RAW
INSERT INTO hoteldb_prd.bronze.GUEST_RAW
(GUEST_ID, GUEST_NAME, PHONE, EMAIL, COUNTRY, LOAD_DT)
VALUES
('G001', '김민지', '010-1111-1111', 'minji@test.com', 'KR', CURRENT_TIMESTAMP()),
('G002', 'John Smith', '+1-555-1234', 'john@test.com', 'US', CURRENT_TIMESTAMP()),
('G003', '박서준', '010-2222-2222', 'sjpark@test.com', 'KR', CURRENT_TIMESTAMP());

-- BRONZE_ROOM_RAW
INSERT INTO hoteldb_prd.bronze.ROOM_RAW
(ROOM_ID, HOTEL_NAME, ROOM_TYPE, ROOM_NO, BASE_PRICE, LOAD_DT)
VALUES
('R101', '서울 리버 호텔', 'Deluxe', '1001', '160000', CURRENT_TIMESTAMP()),
('R102', '서울 리버 호텔', 'Standard', '805', '120000', CURRENT_TIMESTAMP()),
('R103', '부산 오션 스테이', 'Suite', '1502', '250000', CURRENT_TIMESTAMP());

-- BRONZE_RESERVATION_RAW
INSERT INTO hoteldb_prd.bronze.RESERVATION_RAW
(RESERVATION_ID, GUEST_ID, ROOM_ID, CHECK_IN_DATE, CHECK_OUT_DATE, TOTAL_AMOUNT, CHANNEL, STATUS, LOAD_DT)
VALUES
('RES001', 'G001', 'R101', '2026-07-01', '2026-07-03', '320000', 'OTA', 'CONFIRMED', CURRENT_TIMESTAMP()),
('RES002', 'G002', 'R102', '2026/07/05', '2026/07/06', '120,000', 'DIRECT', 'CANCELLED', CURRENT_TIMESTAMP()),
('RES003', 'G003', 'R103', '2026-08-10', '2026-08-13', '750000', 'OTA', 'CONFIRMED', CURRENT_TIMESTAMP());



-- =============================================================================
-- Setup complete
-- =============================================================================

SELECT 'tasty_bytes_dbt_db setup is now complete' AS note;


select * from hoteldb_dev.bronze.GUEST_RAW;
select * from hoteldb_dev.bronze.ROOM_RAW;
select * from hoteldb_dev.bronze.RESERVATION_RAW;



select * from hoteldb_prd.bronze.GUEST_RAW;
select * from hoteldb_prd.bronze.ROOM_RAW;
select * from hoteldb_prd.bronze.RESERVATION_RAW;


 
 
-- dbt 관련 쿼리만 필터
SELECT
    QUERY_ID,
    QUERY_TAG,
    QUERY_TEXT,
    TOTAL_ELAPSED_TIME,
    START_TIME
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE QUERY_TAG LIKE '%app=dbt%'
ORDER BY START_TIME DESC
LIMIT 50;