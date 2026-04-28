-- =========================
-- 1) Create Database
-- =========================
CREATE DATABASE IF NOT EXISTS nexnest_db;
USE nexnest_db;

-- =========================
-- 2) Drop old tables safely
-- =========================
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS student_preferences;
DROP TABLE IF EXISTS properties;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

-- =========================
-- 3) Create Tables
-- =========================

-- Table for all users
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role ENUM('student', 'owner') NOT NULL
);

-- Table for PG listings
CREATE TABLE properties (
    property_id INT PRIMARY KEY AUTO_INCREMENT,
    owner_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    rent DECIMAL(10,2) NOT NULL,
    room_type VARCHAR(10) NOT NULL,  -- e.g., '1R', '2R'
    has_wifi BOOLEAN NOT NULL,
    has_ac BOOLEAN NOT NULL,
    FOREIGN KEY (owner_id) REFERENCES users(user_id)
);

-- Table for Student needs (UPDATED for room + AC)
CREATE TABLE student_preferences (
    pref_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT UNIQUE NOT NULL,
    max_budget DECIMAL(10,2) NOT NULL,
    needs_wifi BOOLEAN NOT NULL,
    preferred_room_type VARCHAR(10) NOT NULL,
    needs_ac BOOLEAN NOT NULL,
    FOREIGN KEY (student_id) REFERENCES users(user_id)
);

-- =========================
-- 4) Insert Demo Data
-- =========================

-- Insert Owners + Students
INSERT INTO users (full_name, email, role) VALUES
('Rajesh Kumar', 'rajesh@owner.com', 'owner'),
('Amit Verma', 'amit@owner.com', 'owner'),
('Rohit Singh', 'rohit@owner.com', 'owner'),
('Sneha Kapoor', 'sneha@student.com', 'student'),
('Arjun Mehta', 'arjun@student.com', 'student');

-- Insert Properties (linked to owners 1,2,3)
INSERT INTO properties (owner_id, title, rent, room_type, has_wifi, has_ac) VALUES
(1, 'Sunshine Residency', 8000.00, '2R', TRUE,  FALSE),
(1, 'Green Nest PG',      9000.00, '2R', FALSE, TRUE),

(2, 'Royal Residency',    5000.00, '1R', TRUE,  TRUE),
(2, 'City Stay PG',       7000.00, '1R', TRUE,  TRUE),

(3, 'Metro PG',           4000.00, '1R', TRUE,  FALSE),
(3, 'Budget Boys PG',     3500.00, '1R', FALSE, FALSE);

-- Insert Student Preferences (students are 4 and 5)
INSERT INTO student_preferences (student_id, max_budget, needs_wifi, preferred_room_type, needs_ac) VALUES
(4, 9000.00, TRUE,  '2R', FALSE),  -- Sneha
(5, 6000.00, TRUE,  '1R', TRUE);   -- Arjun

-- =========================
-- 5) Create Smarter Matching View (200 points)
-- =========================

CREATE OR REPLACE VIEW student_pg_matches AS
SELECT 
    u.user_id,
    p.property_id,
    p.title AS pg_name,

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
CROSS JOIN properties p;

-- =========================
-- 6) Top 5 PG Matches per Student (MySQL 8+)
-- =========================

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
