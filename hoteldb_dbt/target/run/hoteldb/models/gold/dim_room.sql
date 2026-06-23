
  
    

        create or replace transient table hoteldb_prd.gold.dim_room
        copy grants as
        (-- Silver layer: room 테이블 정제 모델
-- Co-authored with CoCo
SELECT
    ROOM_ID,
    HOTEL_NAME,
    UPPER(ROOM_TYPE) AS ROOM_TYPE,
    ROOM_NO,
    TO_NUMBER(REPLACE(BASE_PRICE, ',', '')) AS BASE_PRICE,
    CURRENT_TIMESTAMP() AS CREATED_AT
FROM hoteldb_prd.silver.room
        );
      
  