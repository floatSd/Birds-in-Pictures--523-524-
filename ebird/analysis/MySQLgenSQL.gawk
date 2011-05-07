#!/usr/bin/gawk -f
#
# To create insert SQL statements from source data available from Avian Knowledge Network
# Author: Nikhil Patwardhan
#
# Usage: ./genSQL.gawk < /media/Windows7_OS/Users/Nikhil/Documents/Big\ Files/eBird\ Data/Extracted/10.csv > results.sql
# County(27), Observation Date(106), Genus(14), Species(15), Common Name(114), Observation Count Alteast(104), Latitude-Longitude(33,34), Observation Count(103)
# The db name can be set according to the source/target of the data

BEGIN {FS="\t";OFS=",";dbname="complete_ny_ebird_data";}
$3=="Observation" && $25=="United States" && $26=="New York" && $37>=2009 {
	county_name=$27;
	common_name=$114;
	obs_count=$104;
	rep_count=$103;

	# Is County null?
	if ($27 ~ /^[ ]*$/)
		county_name="null";
	else county_name="'"$27"'";

	# Is obs_count null?
	if ($104 ~ /^[ ]*$/)
		obs_count="null";
	else obs_count=$104;

	# Is rep_count null?
	if ($104 ~ /^[ ]*$/)
		rep_count="null";
	else rep_count=$104;
	
	# Does common name have a ' character?
	if (match(common_name,/'/))
		sub(/'/,"\\'",common_name);

		print "insert into "dbname" values("county_name",str_to_date('"$106"','%d-%M-%Y'),'"$14"','"$15"','"common_name"',"obs_count","$33","$34","rep_count");";
}
