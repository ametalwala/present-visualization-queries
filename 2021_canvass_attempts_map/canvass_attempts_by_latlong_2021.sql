WITH attempt_counts AS (
SELECT
	l.lat
	, l.long
	, COUNT(l.*) count_of_attempts
FROM l
GROUP BY 1, 2
)
SELECT
	a.lat
	, a.long
	, SUM(count_of_attempts) AS count_of_attmpets
FROM ts.ntl_current a
LEFT JOIN attempt_counts b ON a.lat = b.lat AND a.long = b.long
WHERE a.vb_smartvan_id IN (SELECT vb_smartvan_id FROM cpd_ngp_universes_2021.whatever_the_current_universe_table_is)
GROUP BY 1, 2