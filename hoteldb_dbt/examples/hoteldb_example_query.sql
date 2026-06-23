-- What tables exist?
SHOW TABLES IN SCHEMA tb_101.raw_pos;

-- What is the scale of data? 
SELECT COUNT(*) FROM tb_101.raw_pos.order_header;

-- Understand a query that might be used in a mart
SELECT 
    cl.customer_id,
    cl.city,
    cl.country,
    cl.first_name,
    cl.last_name,
    cl.phone_number,
    cl.e_mail,
    SUM(oh.order_total) AS total_sales,
    ARRAY_AGG(DISTINCT oh.location_id) AS visited_location_ids_array
FROM tb_101.raw.customer_loyalty cl
JOIN tb_101.raw.order_header oh
ON cl.customer_id = oh.customer_id
GROUP BY cl.customer_id, cl.city, cl.country, cl.first_name,
cl.last_name, cl.phone_number, cl.e_mail;


select * from hoteldb_dev.bronze.guest_raw;
select * from hoteldb_dev.bronze.room_raw;
select * from hoteldb_dev.bronze.reservation_raw;


select * from hoteldb_dev.silver.guest;
select * from hoteldb_dev.silver.room;
select * from hoteldb_dev.silver.reservation;

select * from hoteldb_dev.gold.dim_guest;
select * from hoteldb_dev.gold.dim_room;
select * from hoteldb_dev.gold.dim_reservation;


select * from hoteldb_prd.bronze.guest_raw;
select * from hoteldb_prd.bronze.room_raw;
select * from hoteldb_prd.bronze.reservation_raw;


select * from hoteldb_prd.silver.guest;
select * from hoteldb_prd.silver.room;
select * from hoteldb_prd.silver.reservation;

select * from hoteldb_prd.gold.dim_guest;
select * from hoteldb_prd.gold.dim_room;
select * from hoteldb_prd.gold.dim_reservation;

 
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
 