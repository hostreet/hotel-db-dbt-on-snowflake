
  
    

        create or replace transient table hoteldb_prd.bronze.reservation_raw
        copy grants as
        (SELECT *
FROM hoteldb_prd.bronze.reservation_raw
        );
      
  