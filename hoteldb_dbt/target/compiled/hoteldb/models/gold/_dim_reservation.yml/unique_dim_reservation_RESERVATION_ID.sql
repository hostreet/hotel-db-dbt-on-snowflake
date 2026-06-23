
    
    

select
    RESERVATION_ID as unique_field,
    count(*) as n_records

from hoteldb_dev.gold.dim_reservation
where RESERVATION_ID is not null
group by RESERVATION_ID
having count(*) > 1


