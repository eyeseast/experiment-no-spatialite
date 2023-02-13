select
    cannabis.*
from
    districts,
    cannabis
where
    districts.DISTRICT = cast(:district as numeric)
    and contains(districts.geometry, cannabis.geometry)