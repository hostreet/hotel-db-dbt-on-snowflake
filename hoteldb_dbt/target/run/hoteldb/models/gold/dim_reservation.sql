
  
    

        create or replace transient table hoteldb_prd.gold.dim_reservation
        copy grants as
        (-- Silver layer: reservation 테이블 정제 모델
-- Co-authored with CoCo
SELECT
    RESERVATION_ID,
    GUEST_ID,
    ROOM_ID,
    TO_DATE(REPLACE(CHECK_IN_DATE, '/', '-')) AS CHECK_IN_DATE,
    TO_DATE(REPLACE(CHECK_OUT_DATE, '/', '-')) AS CHECK_OUT_DATE,
    DATEDIFF(
        DAY,
        TO_DATE(REPLACE(CHECK_IN_DATE, '/', '-')),
        TO_DATE(REPLACE(CHECK_OUT_DATE, '/', '-'))
    ) AS NIGHTS_STAYED,
    TO_NUMBER(REPLACE(TOTAL_AMOUNT, ',', '')) AS TOTAL_AMOUNT,
    UPPER(CHANNEL) AS CHANNEL,
    UPPER(STATUS) AS STATUS,
    IFF(UPPER(STATUS) = 'CANCELLED', TRUE, FALSE) AS IS_CANCELLED,
    CURRENT_TIMESTAMP() AS CREATED_AT
FROM hoteldb_prd.silver.reservation
        );
      
  