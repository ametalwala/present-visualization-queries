--------------Daily Call Totals/Unique ppl called per day/total contacts
**Really just need progress to goal right now, we can add other stuff later if its needs**

SELECT 
    tt.day_date
    , ROUND(tt.goal) AS daily_goal
    , COUNT(DISTINCT tt.call_result_id) AS total_calls
    , COUNT(DISTINCT tt.voter_id) AS unique_people_called
    , COUNT(CASE WHEN tt.result = 'Talked to Correct Person' THEN tt.voter_id END) AS total_contacts
    , (total_calls::float) / (daily_goal::float)::float AS progress_to_goal
FROM
(
SELECT * 
FROM tmc_thrutalk.cpd_ngp_call_results_summary t
LEFT JOIN cpd_ngp_reporting_2021."2022_c3_vol_mems_call_goals" v ON t.date_called = v.day_date
WHERE t.campaign_name = 'ngp-c3-volunteer-team'
AND t.date_called >= '2022-03-07'
) tt
WHERE metric = 'Calls'
GROUP BY 1, 2
ORDER BY 1 ASC

-------------------Demographics: 

--Race
SELECT 
	a.civis_race AS Race
	, COUNT(tt.call_result_id) AS attempted
	, COUNT(CASE WHEN tt.result = 'Talked to Correct Person' THEN tt.voter_id END) AS total_contacts
FROM
( 
SELECT * 
FROM tmc_thrutalk.cpd_ngp_call_results_summary tt
WHERE campaign_name = 'ngp-c3-volunteer-team'
AND date_called >= '2022-03-07'
AND LEFT(voterbase_id, 2) = 'GA'
) tt
LEFT JOIN 
(
SELECT * 
FROM ts.ntl_current p
WHERE LEFT(vb_voterbase_id, 2) = 'GA'
AND vb_vf_source_state = 'GA'
) a ON tt.voterbase_id = a.vb_voterbase_id
WHERE a.civis_race IS NOT NULL
GROUP BY 1
;

-- age

SELECT 
	CASE WHEN a.vb_voterbase_age < '35' THEN '18-34'
		 WHEN a.vb_voterbase_age >= '35' AND a.vb_voterbase_age < 50 THEN '35 - 49'
		 WHEN a.vb_voterbase_age >= '50' THEN '50+' 
		 ELSE 'Unknown' END AS Age
	, COUNT(*) AS total
FROM (
SELECT * 
FROM tmc_thrutalk.cpd_ngp_call_results_summary tt 
WHERE campaign_name = 'ngp-c3-volunteer-team'
AND date_called >= '2022-03-07'
) tt
LEFT JOIN 
(
SELECT * 
FROM ts.ntl_current p
WHERE LEFT(vb_voterbase_id, 2) = 'GA'
AND vb_vf_source_state = 'GA'
) a ON tt.voterbase_id = a.vb_voterbase_id
GROUP BY 1
;


-- calls per Region by County & Muni 
SELECT
	a.vb_vf_county_name AS county
	, a.vb_tsmart_municipal_district as muni
	, COUNT(tt.call_result_id) AS total_calls
	, COUNT(CASE WHEN tt.result = 'Talked to Correct Person' THEN tt.voter_id END) AS total_contacts
FROM 
(
SELECT * 
FROM tmc_thrutalk.cpd_ngp_call_results_summary tt
WHERE tt.campaign_name = 'ngp-c3-volunteer-team'
AND tt.date_called >= '2022-03-07'
) tt
LEFT JOIN 
( 
SELECT * 
FROM ts.ntl_current p 
WHERE p.vb_vf_source_state = 'GA'
AND LEFT(p.vb_voterbase_id, 2) = 'GA'
) a ON tt.voterbase_id = a.vb_voterbase_id
GROUP BY 1, 2 
ORDER BY total_calls DESC
;
-------------------progress to goal 


-- how many called vs how many left to reach goal -- add this to the daily calls table 

SELECT
	a.total_calls
	, (a.total_calls::float) / (350000::float)::float AS progress_to_goal
FROM
(
SELECT
	COUNT(t.call_result_id) AS total_calls
FROM tmc_thrutalk.cpd_ngp_call_results_summary t
WHERE campaign_name = 'ngp-c3-volunteer-team'
AND date_called >= '2022-03-07'
) a
; 

-- Progress to goal percentage
SELECT 
	(a.total_calls::float) / (350000::float)::float AS progress_to_goal
FROM
(
SELECT
	COUNT(t.call_result_id) AS total_calls
FROM tmc_thrutalk.cpd_ngp_call_results_summary t
WHERE campaign_name = 'ngp-c3-volunteer-team'
AND date_called >= '2022-03-07'
) a
; 

--------- Survery Question Responses
--Issue question 
SELECT 
    l.question
    , SUM(CASE WHEN l.answer = 'Police Brutality' THEN 1 ELSE 0 END) AS police_brutality
    , SUM(CASE WHEN l.answer = 'Economy' THEN 1 ELSE 0 END) AS Economy
	, SUM(CASE WHEN l.answer = 'Healthcare' THEN 1 ELSE 0 END) AS healthcare
    , SUM(CASE WHEN l.answer = 'Pandemic' THEN 1 ELSE 0 END) AS pandemic
    , SUM(CASE WHEN l.answer = 'Racism' THEN 1 ELSE 0 END) AS racism
FROM
(
SELECT *
FROM tmc_thrutalk.cpd_ngp_call_results_summary tt
WHERE tt.campaign_name = 'ngp-c3-volunteer-team'
AND tt.date_called >= '2022-03-07'
) tt
LEFT JOIN 
( 
SELECT * 
FROM tmc_thrutalk.cpd_ngp_survey_results_summary l
WHERE l.campaign_name = 'ngp-c3-volunteer-team'
AND l.date_called >= '2022-03-07'
) l ON tt.voterbase_id = l.voterbase_id 
WHERE l.question = 'SQ 1 Issue ID'
GROUP BY 1 
; 

--- plan to vote question 
SELECT 
    l.question
    , SUM(CASE WHEN l.answer LIKE 'I%' THEN 1 ELSE 0 END) AS In_Person_EDay
    , SUM(CASE WHEN l.answer = 'Unsure/Not Voting' THEN 1 ELSE 0 END) AS Unsure_Not_Voting
	, SUM(CASE WHEN l.answer = 'Already Voted' THEN 1 ELSE 0 END) AS Already_Voted
    , SUM(CASE WHEN l.answer = 'By Mail' THEN 1 ELSE 0 END) AS By_Mail
    , SUM(CASE WHEN l.answer LIKE 'E%' THEN 1 ELSE 0 END) AS Early_In_Person
FROM
(
SELECT *
FROM tmc_thrutalk.cpd_ngp_call_results_summary tt
WHERE tt.campaign_name = 'ngp-c3-volunteer-team'
AND tt.date_called >= '2022-03-07'
) tt
LEFT JOIN 
( 
SELECT * 
FROM tmc_thrutalk.cpd_ngp_survey_results_summary l
WHERE l.campaign_name = 'ngp-c3-volunteer-team'
AND l.date_called >= '2022-03-07'
) l ON tt.voterbase_id = l.voterbase_id 
WHERE l.question = 'SQ 2 PLAN TO VOTE'
GROUP BY 1
;

-- rides to the polls question 
SELECT 
    l.question
    , SUM(CASE WHEN l.answer = 'Yes' THEN 1 ELSE 0 END) AS YES
    , SUM(CASE WHEN l.answer = 'No' THEN 1 ELSE 0 END) AS NO
FROM
(
SELECT *
FROM tmc_thrutalk.cpd_ngp_call_results_summary tt
WHERE tt.campaign_name = 'ngp-c3-volunteer-team'
AND tt.date_called >= '2022-03-07'
) tt
LEFT JOIN 
( 
SELECT * 
FROM tmc_thrutalk.cpd_ngp_survey_results_summary l
WHERE l.campaign_name = 'ngp-c3-volunteer-team'
AND l.date_called >= '2022-03-07'
) l ON tt.voterbase_id = l.voterbase_id 
WHERE l.question = 'RIDES TO POLLS QUESTION'
GROUP BY 1
;

--PLedge to Vote Question 
SELECT 
    l.question
    , SUM(CASE WHEN l.answer = 'Yes' THEN 1 ELSE 0 END) AS YES
    , SUM(CASE WHEN l.answer = 'No' THEN 1 ELSE 0 END) AS NO
    , SUM(CASE WHEN l.answer = 'Unsure' THEN 1 ELSE 0 END) AS Unsure
FROM
(
SELECT *
FROM tmc_thrutalk.cpd_ngp_call_results_summary tt
WHERE tt.campaign_name = 'ngp-c3-volunteer-team'
AND tt.date_called >= '2022-03-07'
) tt
LEFT JOIN 
( 
SELECT * 
FROM tmc_thrutalk.cpd_ngp_survey_results_summary l
WHERE l.campaign_name = 'ngp-c3-volunteer-team'
AND l.date_called >= '2022-03-07'
) l ON tt.voterbase_id = l.voterbase_id 
WHERE l.question = 'PLEDGE TO VOTE'
GROUP BY 1
;
