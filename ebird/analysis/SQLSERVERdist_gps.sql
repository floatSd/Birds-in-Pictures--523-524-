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
