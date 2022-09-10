SELECT 
	geo_level.*
    , lat_long.*
FROM 
(
SELECT 
	fr.vb_vf_county_name
    , fr.vb_vf_municipal_district
    , fr.vb_vf_city_council
    , fr.unique_people_contacts_via_walk
    , fr.penetration_rate
    , fr.total_walk_contacts
    , fr.total_walk_attempts
FROM cpd_ngp_reporting_2021.c3_field_geo_level_results_v01 fr
ORDER BY total_walk_attempts DESC
) geo_level
LEFT JOIN 
(
SELECT 
  un.county
  , un.municipality
  , un.city_council_district
  , un.latitude
  , un.longitude
FROM cpd_ngp_fguilbert_2021.uni_2021_municipal_20210726_v01_contacts_filtered_by_van_lat_long un 
) lat_long ON geo_level.vb_vf_city_council = lat_long.city_council_district AND geo_level.vb_vf_municipal_district = lat_long.municipality