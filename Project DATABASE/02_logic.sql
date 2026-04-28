USE nexnest_db;

CREATE OR REPLACE VIEW student_pg_matches AS
SELECT 
    u.user_id AS student_id,
    u.full_name AS student_name,

    p.property_id,
    p.title AS pg_name,
    p.rent,
    p.room_type,
    p.has_wifi,
    p.has_ac,
    p.city,
    p.area,

    (
        -- Budget: 50 points
        (CASE WHEN p.rent <= sp.max_budget THEN 50 ELSE 0 END) +

        -- WiFi: 50 points
        (CASE 
            WHEN sp.needs_wifi = 0 THEN 50
            WHEN sp.needs_wifi = 1 AND p.has_wifi = 1 THEN 50
            ELSE 0
        END) +

        -- Room Type: 50 points
        (CASE 
            WHEN sp.preferred_room_type = p.room_type THEN 50
            ELSE 0
        END) +

        -- AC: 50 points
        (CASE
            WHEN sp.needs_ac = 0 THEN 50
            WHEN sp.needs_ac = 1 AND p.has_ac = 1 THEN 50
            ELSE 0
        END)
    ) AS match_score

FROM users u
JOIN student_preferences sp 
    ON u.user_id = sp.student_id
JOIN properties p ON 1=1

WHERE u.user_role = 'student';
