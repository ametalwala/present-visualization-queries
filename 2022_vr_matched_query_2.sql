-- okay now cleaning post-match

alter table cpd_ngp_vr_2021.c3_vr_matched_20220512 add column vf_county varchar;
alter table cpd_ngp_vr_2021.c3_vr_matched_20220512 add column age int;
alter table cpd_ngp_vr_2021.c3_vr_matched_20220512 add column dor int;
alter table cpd_ngp_vr_2021.c3_vr_matched_20220512 add column reg_status varchar;
alter table cpd_ngp_vr_2021.c3_vr_matched_20220512 add column earliest_dor int;

update  cpd_ngp_vr_2021.c3_vr_matched_20220512 
set vf_county = t2.vb_vf_county_name,
    dor = t2.vb_vf_registration_date,
    earliest_dor = t2.vb_vf_earliest_registration_date,
    age = t2.vb_voterbase_age,
    reg_status = t2.vb_voterbase_registration_status
from ts.ntl_current t2 
where cpd_ngp_vr_2021.c3_vr_matched_20220512.vbvoterbase_id = t2.vb_voterbase_id
AND vb_vf_source_state= 'GA';

-- okay now adding county info
alter table cpd_ngp_vr_2021.c3_vr_matched_20220512 add column region varchar;
update cpd_ngp_vr_2021.c3_vr_matched_20220512 set region = (CASE WHEN
  upper(county) IN ('HOUSTON', 'BALDWIN', 'SUMTER', 'PEACH', 'BURKE', 'DECATUR', 'MITCHELL', 'WASHINGTON', 'JEFFERSON', 'MACON', 'TERRELL', 'EARLY', 'HANCOCK', 'DOOLY', 'TWIGGS', 'WARREN', 'WILKINSON', 'RANDOLPH', 
    'CALHOUN', 'STEWART', 'CHATTAHOOCHEE', 'BAKER', 'CLAY', 'WEBSTER', 'QUITMAN', 'TALIAFERRO', 'CLARKE', 'MERIWETHER', 'TROUP', 'NEWTON') THEN 'Black Belt'
  WHEN upper(county) IN ('FULTON', 'GWINNETT', 'CLAYTON', 'DEKALB', 'COBB', 'HENRY', 'ROCKDALE', 'DOUGLAS') THEN 'Atlanta'
  WHEN upper(county) IN ('BIBB', 'PEACH', 'HOUSTON', 'LAURENS') THEN 'Macon'
  WHEN upper(county) IN ('LIBERTY', 'CHATHAM', 'GLYNN') THEN 'Savannah'
  WHEN upper(county) = 'DOUGHERTY' THEN 'Albany'
  WHEN upper(county) IN ('COLUMBIA', 'RICHMOND') THEN 'Augusta'
  WHEN upper(county) = 'MUSCOGEE' THEN 'Columbus'
  ELSE 'Other' END);
  
alter table cpd_ngp_vr_2021.c3_vr_matched_20220512 add column vr_status varchar;
update cpd_ngp_vr_2021.c3_vr_matched_20220512 set vr_status = CASE
          
          -- New Registrant in GA: The registrant's earliest reg date is on or after the date the 
          -- organization collected the registration/pledge. 
          --Do we need a buffer here? I think we had discussed 5 days for VR?
          --NOTE: the buffer is to account for any lags from documenting a registration in house to the time the state in question requires the VR to be submitted
          WHEN left(vbvoterbase_id, 2) = 'GA'
              and dor = earliest_dor
              and date <= earliest_dor -- date collected = the date your program registered the voter, or logged the registration
              and vbvoterbase_id is not null
              and reg_status = 'Registered'
          THEN 'New Registrant'
  
          -- Other State
          -- How would the above q shift for other states?
          WHEN left(vbvoterbase_id, 2) != 'GA'
          THEN 'Other State'
  
          -- Re-registrant in GA: The registrant's earliest reg date falls before the date the 
          -- organization collected the registration/pledge.
          WHEN left(vbvoterbase_id, 2) = 'GA'
              and (dor != earliest_dor
                    or date >= dor)
              and reg_status = 'Registered'
          THEN 'Re-Registrant'

          -- Unregistered on File in GA
          -- Should this also use a date constraint? Latest regisration date?
          WHEN reg_status = 'Unregistered' 
              and left(vbvoterbase_id, 2) = 'GA' 
          THEN 'Unregistered on File'
  
          -- Unregistered on File - Other State
          WHEN reg_status = 'Unregistered' 
              and left(vbvoterbase_id, 2) != 'GA'
          THEN 'Unregistered on File - Other State'
  
          -- Unregistered Not On File: A registration status SHOULD be on file at this point so this should be a major flag.
          WHEN vbvoterbase_id is null
              and date < ( CURRENT_DATE - interval '28 days' )
          THEN 'Unregistered Not on File'
  
           -- Too Fresh: This is likely a new registrant. They didn't match, but not enough time has passed for a new registrant 
           -- to be added to the latest voter file.
          WHEN vbvoterbase_id is null
              and (date >= ( CURRENT_DATE - interval '28 days')
              or form_drop_date IS NULL)
          THEN 'Too Fresh'
  
          -- Unknown: This is to catch edge cases
          Else 'Unknown'
       END;
       
alter table cpd_ngp_vr_2021.c3_vr_matched_20220512 add column correct_match varchar;
update cpd_ngp_vr_2021.c3_vr_matched_20220512 set correct_match = 'Y' WHERE vr_status in ('Re-Registrant', 'New Registrant');

GRANT ALL ON TABLE cpd_ngp_vr_2021.c3_vr_matched_20220512 TO GROUP cpd_ngp;

drop table if exists cpd_ngp_vr_2021.c3_vr_matched_current; 
create table cpd_ngp_vr_2021.c3_vr_matched_current AS
  select * from cpd_ngp_vr_2021.c3_vr_matched_20220512
  UNION ALL
  SELECT  last_name, first_name, middle_or_maiden, suffix, address, apt::int, city, county, state, zip_code::int, phone, dob, gender, race, canvasser, location, date, actual_age, form_drop_date, issue_id, email_address, vr_form_error, ts__input_row, ts__row, tsmart_match_code, 
  vbvoterbase_id, vbtsmart_first_name, vbtsmart_middle_name, vbtsmart_last_name, vbtsmart_name_suffix, vbvoterbase_registration_status, vf_county, age, dor, reg_status, earliest_dor, region, vr_status, correct_match 
  FROM cpd_ngp_vr_2021.c3_vr_matched_20220126_2021;
GRANT ALL ON TABLE cpd_ngp_vr_2021.c3_vr_matched_current TO GROUP cpd_ngp;