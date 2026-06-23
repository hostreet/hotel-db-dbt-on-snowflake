
  
    

        create or replace transient table hoteldb_prd.bronze.guest_raw
        copy grants as
        (SELECT *
FROM hoteldb_prd.bronze.guest_raw
        );
      
  