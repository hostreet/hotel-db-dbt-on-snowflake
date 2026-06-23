
    
    

select
    GUEST_ID as unique_field,
    count(*) as n_records

from hoteldb_dev.gold.dim_guest
where GUEST_ID is not null
group by GUEST_ID
having count(*) > 1


