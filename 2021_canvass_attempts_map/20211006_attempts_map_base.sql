SELECT 
  k.*
FROM
(
SELECT
	ROW_NUMBER() OVER (
      PARTITION BY cd.date_canvassed::varchar(1024) || base_data.vb_reg_latitude::varchar(1024) || base_data.vb_reg_longitude::varchar(1024))
      row_num
	, base_data.vb_vf_county_name
    , base_data.vb_vf_municipal_district
    , base_data.vb_vf_city_council
    , base_data.vb_reg_latitude
    , base_data.vb_reg_longitude
    , cd.date_canvassed
FROM 
( 
SELECT
  tn.vb_vf_source_state
  , tn.vb_smartvan_id
  , tn.vb_vf_county_name
  , tn.vb_vf_municipal_district
  , tn.vb_vf_city_council
  , tn.vb_reg_latitude
  , tn.vb_reg_longitude
FROM ts.ntl_current tn
WHERE tn.vb_vf_source_state = 'GA'
) base_data
INNER JOIN
(
SELECT
  cam.statecode
  , cam.vanid
  , cam.contacttypename
  , cam.resultshortname
  , cam.datecanvassed::date AS date_canvassed
FROM tmc_van.cpd_ngp_contact_attempts_summary_vf cam
WHERE cam.contacttypename = 'Paid Walk'
) cd ON base_data.vb_vf_source_state = cd.statecode AND base_data.vb_smartvan_id = cd.vanid
) k
WHERE k.row_num = 1