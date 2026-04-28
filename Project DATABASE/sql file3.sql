SELECT *
FROM (
    SELECT 
        m.*,
        ROW_NUMBER() OVER (
            PARTITION BY user_id 
            ORDER BY match_score DESC
        ) AS rn
    FROM student_pg_matches m
) ranked
WHERE rn <= 5
ORDER BY user_id, match_score DESC;

