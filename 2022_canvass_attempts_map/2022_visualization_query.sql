SELECT
	a.vb_reg_latitude AS latitude
	, a.vb_reg_longitude AS longitude
    , a.vb_vf_county_name AS county
    , a.vb_tsmart_city AS city
    , a.vb_vf_precinct_id AS precinct_id
  , CASE WHEN b.count_of_attempts >= 3 THEN '3+'
	       WHEN b.count_of_attempts IS NULL THEN '0' 
         ELSE b.count_of_attempts::varchar(1024) END AS count_of_attempts
FROM ts.ntl_current a
LEFT JOIN cpd_ngp_reporting_2021.c3_2021_attempts_map b ON a.vb_reg_latitude = b.vb_reg_latitude AND a.vb_reg_longitude = b.vb_reg_longitude
LEFT JOIN tmc_van.cpd_ngp_contact_attempts_summary_vf d ON d.vb_voterbase_id = a.vb_voterbase_id AND d.statecode = a.vb_vf_source_state
WHERE a.vb_vf_source_state = 'GA'
AND LEFT(a.vb_voterbase_id, 2) = 'GA' 
AND d.datecanvassed > '2022-01-01'
AND [county=county_]
AND [city=city_] 
AND [precinct_id=precinct_id] 
GROUP BY 1, 2, 3, 4, 5, 6