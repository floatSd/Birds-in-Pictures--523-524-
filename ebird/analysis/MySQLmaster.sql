/* For a given number of bird sightings 'X' what is the smallest radius required around a given GPS co-ordinate */

create function dist_gps (lat1 float, lon1 float, lat2 float, lon2 float)
returns float
begin
	declare rv float;
	declare dlat float;
	declare dlon float;
	declare a float;
	declare c float;
	declare earth_radius_miles float;

	set earth_radius_miles = 3956;
	set dlat = radians(lat2-lat1);
	set dlon = radians(lon2-lon1);

	set a = pow(sin(dlat/2.0),2) + cos(radians(lat1))*cos(radians(lat2))*pow(sin(dlon/2.0),2);
	set c = 2*atan2(sqrt(a),sqrt(1-a));
	set rv = earth_radius_miles * c;
	return rv;
end;

#Stony Brook : N40.92 W73.12
#Manhattan: N40.78 W73.96

set @X = 42.5084;
set @Y = -74.9754;

/* Find the minimum radius */
select obs_data, common_name, lat, lon, obs_number,
format(dist_gps(lat,lon,42.5084,-74.9754),4) distance
from complete_ny_ebird_data
where obs_number is not null
order by 6
limit 10;

set @X = 40.92;
set @Y = -73.12;
set @MONTHNUM = 5;
set @DELTA = 1;
set @RADIUS = 3;

/* Get a histogram */
select common_name as 'Bird', sum(obs_number) as 'Frequency'
from complete_ny_ebird_data
where obs_number is not null
and month(obs_data) >= @MONTHNUM - @DELTA and month(obs_data) <= @MONTHNUM + @DELTA
and dist_gps(lat,lon,@X,@Y) < @RADIUS
group by common_name
order by 2 desc
limit 10;
