/* For a given number of bird sightings 'X' what is the smallest radius required around a given GPS co-ordinate */
#Stony Brook : N40.92 W73.12
#Manhattan: N40.78 W73.96

set @X = 40.92;
set @Y = -73.12;

select obs_data, common_name, lat, lon, obs_number,
format(abs(sqrt(pow(lat-42.5084,2) + pow(lon+74.9754,2))),4) distance
from complete_ny_ebird_data
where obs_number is not null
having distance < 1
order by 6;


select obs_data, common_name, lat, lon, obs_number,
format(dist_gps(lat,lon,42.5084,-74.9754),4) distance
from complete_ny_ebird_data
where obs_number is not null
order by 6
limit 10;

-- SQL Server
select top 10 obs_data, common_name, lat, lon, obs_number, dbo.dist_gps(lat,lon,40.92,-73.12) distance
from complete_ny_ebird_data
where obs_number is not null
order by 6;

-- MASTER
DECLARE @NUMRECORDS INT = 1000;
DECLARE @X FLOAT = 40.92;
DECLARE @Y FLOAT = -73.12;
DECLARE @MONTHNUM int = 4;
DECLARE @DELTA int = 1;

SELECT DISTANCE FROM
(
select row_number() over (order by dbo.dist_gps(lat,lon,@X,@Y)) as R, dbo.dist_gps(lat,lon,@X,@Y) AS 'DISTANCE'
from complete_ny_ebird_data
where obs_number is not null
and month(obs_data) >= @MONTHNUM - @DELTA and month(obs_data) <= @MONTHNUM + @DELTA
) AS T1
WHERE R = @NUMRECORDS;

-- CHECK how many records in each month
select month(obs_data),count(obs_data)
from complete_ny_ebird_data
where YEAR(obs_data) = 2009
group by MONTH(obs_data)
order by 1;