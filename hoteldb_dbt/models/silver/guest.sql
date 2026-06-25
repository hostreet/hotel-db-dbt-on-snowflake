-- Silver layer: guest 테이블 정제 모델
-- Co-authored with CoCo
SELECT
    GUEST_ID,
    TRIM(GUEST_NAME) || '_nickname' AS GUEST_NAME,
    PHONE,
    LOWER(EMAIL) AS EMAIL,
    UPPER(COUNTRY) AS COUNTRY_CODE,
    CURRENT_TIMESTAMP() AS CREATED_AT
FROM {{ source('hoteldb_raw', 'guest_raw') }}