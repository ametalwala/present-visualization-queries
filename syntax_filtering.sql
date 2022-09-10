example of syntax for filtering 

SELECT
region
, COUNT(*) AS count
, COUNT(*) AS perc
from (
SELECT *, 
  CASE WHEN date >= '2022-01-01' THEN '2022'
       WHEN date <= '2021-12-31' THEN '2021'
       ELSE NULL END AS "Year" 
  FROM cpd_ngp_vr_2021.c3_vr_matched_current
where [county=VR_County]
AND [Year=Year])
WHERE vr_status IN ('New Registrant', 'Re-Registrant')
GROUP BY 1
ORDER BY 1 ASC; 

-- p2g volmems filter add-on query phones 
(
SELECT *, 
  CASE WHEN day_date <= '2022-05-25' THEN 'Primary'
       WHEN day_date >= '2022-05-26' THEN 'Runoff' 
       ELSE NULL END AS "Election_Phase" 
  FROM cpd_ngp_reporting_2021.c3_volmems_call_p2g_2022
WHERE [Election_Phase=Election_Phase]);
 
(
SELECT *, 
  CASE WHEN date <= '2022-05-25' THEN 'Primary'
       WHEN date >= '2022-05-26' THEN 'Runoff' 
       ELSE NULL END AS "Election_Phase" 
  FROM cpd_ngp_reporting_2021.c3_volmems_txt_20220520
WHERE [Election_Phase=Election_Phase]); 