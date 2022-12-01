drop table if exists cpd_ngp_vr_2021.vr_matched_totals;

create table cpd_ngp_vr_2021.vr_matched_totals as
select voterbase_id, first, last, address, apt, city, state, zip, phone, email, year, county, dob, race, gender from 
(select voterbase_id, first, last, address, apt, city, state, zip, phone, email, year, county, dob, race, gender
 	from cpd_ngp_vr_2021.c3_vr_matched_20210519
UNION ALL
 select voterbase_id, first, last, address, apt, city, state, zip, phone, email, year, county, dob, race, gender 
 	from cpd_ngp_vr_2021.c4_vr_matched_20210519_v03
UNION ALL
 select vbvoterbase_id, first_name, last_name, address, cast(apt as varchar), city, state, cast(zip_code as varchar), phone, column_20, 2021 as year, county, to_date(dob,'DD/MM/YY'), race, gender
  from cpd_ngp_vr_2021.c3_vr_matched_current );

alter table cpd_ngp_vr_2021.vr_matched_totals add column reg_status varchar;
alter table cpd_ngp_vr_2021.vr_matched_totals add column HD varchar;
alter table cpd_ngp_vr_2021.vr_matched_totals add column SD varchar;
alter table cpd_ngp_vr_2021.vr_matched_totals add column CD varchar;
alter table cpd_ngp_vr_2021.vr_matched_totals add column vf_county varchar;
alter table cpd_ngp_vr_2021.vr_matched_totals add column GA_resident varchar;

update  cpd_ngp_vr_2021.vr_matched_totals
set reg_status = t2.vb_voterbase_registration_status,
    HD = t2.vb_vf_hd ,
    SD = t2.vb_vf_sd ,
    CD = t2.vb_vf_cd ,
    vf_county = t2.vb_vf_county_name 
from ts.ntl_current t2 
where cpd_ngp_vr_2021.vr_matched_totals.voterbase_id = t2.vb_voterbase_id
AND vb_vf_source_state= 'GA';

update cpd_ngp_vr_2021.vr_matched_totals set GA_resident = 'N';
update cpd_ngp_vr_2021.vr_matched_totals set GA_resident = 'Y' where left(voterbase_id, 2) = 'GA' OR voterbase_id is null;

GRANT SELECT ON TABLE cpd_ngp_vr_2021.vr_matched_totals TO GROUP cpd_ngp;