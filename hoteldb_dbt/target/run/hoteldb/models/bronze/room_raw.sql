
  
    

        create or replace transient table hoteldb_prd.bronze.room_raw
        copy grants as
        (SELECT *
FROM hoteldb_prd.bronze.room_raw
        );
      
  