
    
    

select
    ROOM_ID as unique_field,
    count(*) as n_records

from hoteldb_dev.gold.dim_room
where ROOM_ID is not null
group by ROOM_ID
having count(*) > 1


