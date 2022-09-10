SELECT
	a.vb_reg_latitude AS latitude
	, a.vb_reg_longitude AS longitude
    , a.vb_vf_county_name AS county
    , a.vb_vf_municipal_district AS municipality
    , a.vb_vf_city_council AS city_council
  , CASE WHEN b.count_of_attempts >= 3 THEN '3+'
	       WHEN b.count_of_attempts IS NULL THEN '0' 
         ELSE b.count_of_attempts::varchar(1024) END AS count_of_attempts
FROM ts.ntl_current a
LEFT JOIN cpd_ngp_reporting_2021.c3_2021_attempts_map b ON a.vb_reg_latitude = b.vb_reg_latitude AND a.vb_reg_longitude = b.vb_reg_longitude
WHERE a.vb_smartvan_id IN (SELECT vb_smartvan_id FROM cpd_ngp_universes_2021.uni_2021_municipal_20210929_v01_vanids_filtered_by_van_trimmed)
AND a.vb_vf_source_state = 'GA'
AND [municipality=municipal_district]
AND [county=county_]
AND [city_council=City_Council_] 
GROUP BY 1, 2, 3, 4, 5, 6