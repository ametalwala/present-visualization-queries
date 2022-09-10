-- SCRIPT RESPONSE QUESTIONS - 2 query options 
--implement drop table if exists 
SELECT 
    l.question
    , SUM(CASE WHEN l.answer = 'Police Brutality' THEN 1 ELSE 0 END) AS police_brutality
    , SUM(CASE WHEN l.answer = 'Economy' THEN 1 ELSE 0 END) AS Economy
	, SUM(CASE WHEN l.answer = 'Healthcare' THEN 1 ELSE 0 END) AS healthcare
    , SUM(CASE WHEN l.answer = 'Pandemic' THEN 1 ELSE 0 END) AS pandemic
    , SUM(CASE WHEN l.answer = 'Racism' THEN 1 ELSE 0 END) AS racism
    , SUM(CASE WHEN l.answer LIKE 'I%' THEN 1 ELSE 0 END) AS In_Person_EDay
    , SUM(CASE WHEN l.answer = 'Unsure/Not Voting' THEN 1 ELSE 0 END) AS Unsure_Not_Voting
	, SUM(CASE WHEN l.answer = 'Already Voted' THEN 1 ELSE 0 END) AS Already_Voted
    , SUM(CASE WHEN l.answer = 'By Mail' THEN 1 ELSE 0 END) AS By_Mail
    , SUM(CASE WHEN l.answer LIKE 'Early%' THEN 1 ELSE 0 END) AS Early_In_Person
    , SUM(CASE WHEN l.answer = 'Yes' THEN 1 ELSE 0 END) AS YES
    , SUM(CASE WHEN l.answer = 'No' THEN 1 ELSE 0 END) AS NO
    , SUM(CASE WHEN l.answer = 'Unsure' THEN 1 ELSE 0 END) AS Unsure
FROM
(
SELECT * 
FROM tmc_thrutalk.cpd_ngp_survey_results_summary l
WHERE l.campaign_name = 'ngp-c3-volunteer-team'
AND l.date_called >= '2022-03-07'
) l ON tt.voterbase_id = l.voterbase_id 
WHERE l.question IN ('SQ 1 Issue ID', 'RIDES TO POLLS QUESTION', 'PLEDGE TO VOTE', 'SQ 2 PLAN TO VOTE')
GROUP BY 1 
; 

--Updated daily calls / progress to goal 
-- add in weeks as well 
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
; 

-- consolidate script responses into the p2g table 
-- in count for goals (CASE WHEN metric = calls THEN call_goal &
-- CASE WHEN metric = shift THEN shift goal)


SELECT
    tt.reporting_week
    , tt.day_date
    , l.question
    , (CASE WHEN tt.metric = 'Shifts Recruited' THEN tt.goal END) AS shift_goal
    , (CASE WHEN tt.metric = 'Calls' THEN ROUND(tt.goal) END) AS call_goal
    , COUNT(DISTINCT tt.call_result_id) AS total_calls
    , COUNT(DISTINCT tt.voter_id) AS unique_people_called
    , COUNT(CASE WHEN tt.result = 'Talked to Correct Person' THEN tt.voter_id END) AS total_contacts
    , (total_calls::float) / (call_goal::float)::float AS progress_to_goal
    , SUM(CASE WHEN l.answer = 'Police Brutality' THEN 1 ELSE 0 END) AS police_brutality
    , SUM(CASE WHEN l.answer = 'Economy' THEN 1 ELSE 0 END) AS Economy
    , SUM(CASE WHEN l.answer = 'Healthcare' THEN 1 ELSE 0 END) AS healthcare
    , SUM(CASE WHEN l.answer = 'Pandemic' THEN 1 ELSE 0 END) AS pandemic
    , SUM(CASE WHEN l.answer = 'Racism' THEN 1 ELSE 0 END) AS racism
    , SUM(CASE WHEN l.answer LIKE 'I%' THEN 1 ELSE 0 END) AS In_Person_EDay
    , SUM(CASE WHEN l.answer = 'Unsure/Not Voting' THEN 1 ELSE 0 END) AS Unsure_Not_Voting
    , SUM(CASE WHEN l.answer = 'Already Voted' THEN 1 ELSE 0 END) AS Already_Voted
    , SUM(CASE WHEN l.answer = 'By Mail' THEN 1 ELSE 0 END) AS By_Mail
    , SUM(CASE WHEN l.answer LIKE 'Early%' THEN 1 ELSE 0 END) AS Early_In_Person
    , SUM(CASE WHEN l.answer = 'Yes' THEN 1 ELSE 0 END) AS YES
    , SUM(CASE WHEN l.answer = 'No' THEN 1 ELSE 0 END) AS NO
    , SUM(CASE WHEN l.answer = 'Unsure' THEN 1 ELSE 0 END) AS Unsure
FROM
(
SELECT 
    * 
FROM tmc_thrutalk.cpd_ngp_call_results_summary t
LEFT JOIN cpd_ngp_reporting_2021."2022_c3_vol_mems_call_goals" v ON t.date_called = v.day_date
WHERE t.campaign_name = 'ngp-c3-volunteer-team'
AND t.date_called >= '2022-03-07'
) tt
LEFT JOIN
(
SELECT * 
FROM tmc_thrutalk.cpd_ngp_survey_results_summary l
WHERE l.campaign_name = 'ngp-c3-volunteer-team'
AND l.date_called >= '2022-03-07'
) l ON tt.voterbase_id = l.voterbase_id 
GROUP BY 1, 2, 3, 4, 5
ORDER BY 2 ASC
; 



