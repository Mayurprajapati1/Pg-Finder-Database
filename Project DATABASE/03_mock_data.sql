-- =========================================================
-- NEXNEST DATABASE (FULL WORKING SQL)
-- =========================================================

DROP DATABASE IF EXISTS nexnest_db;
CREATE DATABASE nexnest_db;
USE nexnest_db;

-- =========================================================
-- 1 USERS TABLE
-- =========================================================
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    user_role ENUM('student', 'owner', 'admin') NOT NULL,
    phone VARCHAR(15),
    profile_pic_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================================================
-- 2 STUDENT PREFERENCES TABLE
-- =========================================================
CREATE TABLE student_preferences (
    preference_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT UNIQUE NOT NULL,

    max_budget DECIMAL(10,2) NOT NULL DEFAULT 0,
    preferred_room_type ENUM('1R', '2R', '3R', '1BHK', '2BHK') NOT NULL DEFAULT '1R',

    needs_wifi BOOLEAN NOT NULL DEFAULT FALSE,
    needs_ac BOOLEAN NOT NULL DEFAULT FALSE,
    needs_food BOOLEAN NOT NULL DEFAULT FALSE,

    preferred_city VARCHAR(100),
    preferred_area VARCHAR(100),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_student_pref_user
        FOREIGN KEY (student_id) REFERENCES users(user_id)
        ON DELETE CASCADE
);

-- =========================================================
-- 3 PROPERTIES TABLE
-- =========================================================
CREATE TABLE properties (
    property_id INT PRIMARY KEY AUTO_INCREMENT,
    owner_id INT NOT NULL,

    title VARCHAR(150) NOT NULL,
    description TEXT,

    rent DECIMAL(10,2) NOT NULL,
    room_type ENUM('1R', '2R', '3R', '1BHK', '2BHK') NOT NULL,

    has_wifi BOOLEAN NOT NULL DEFAULT FALSE,
    has_ac BOOLEAN NOT NULL DEFAULT FALSE,
    has_food BOOLEAN NOT NULL DEFAULT FALSE,

    city VARCHAR(100) NOT NULL,
    area VARCHAR(100) NOT NULL,
    address TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_properties_owner
        FOREIGN KEY (owner_id) REFERENCES users(user_id)
        ON DELETE CASCADE
);

-- =========================================================
-- 4 MATCHING VIEW (SCORE BASED)
-- =========================================================
DROP VIEW IF EXISTS student_pg_matches;

CREATE VIEW student_pg_matches AS
SELECT 
    u.user_id AS student_id,
    u.full_name AS student_name,

    p.property_id,
    p.title AS pg_name,
    p.rent,
    p.room_type,
    p.has_wifi,
    p.has_ac,
    p.has_food,
    p.city,
    p.area,

    (
        (CASE WHEN p.rent <= sp.max_budget THEN 30 ELSE 0 END) +
        (CASE WHEN p.room_type = sp.preferred_room_type THEN 25 ELSE 0 END) +
        (CASE WHEN sp.needs_wifi = 0 OR p.has_wifi = 1 THEN 15 ELSE 0 END) +
        (CASE WHEN sp.needs_ac = 0 OR p.has_ac = 1 THEN 15 ELSE 0 END) +
        (CASE WHEN sp.needs_food = 0 OR p.has_food = 1 THEN 15 ELSE 0 END)
    ) AS match_score

FROM users u
JOIN student_preferences sp ON u.user_id = sp.student_id
JOIN properties p
WHERE u.user_role = 'student'
  AND (sp.preferred_city IS NULL OR sp.preferred_city = p.city)
  AND (sp.preferred_area IS NULL OR sp.preferred_area = p.area);

-- =========================================================
-- 5 SAMPLE USERS
-- =========================================================
INSERT INTO users (full_name, email, password_hash, user_role, phone)
VALUES
('Amit Verma', 'amit_new@owner1.com', 'hashedpass1', 'owner', '9999999991'),
('Rohit Singh', 'rohit_new@owner2.com', 'hashedpass2', 'owner', '9999999992'),
('Neha Sharma', 'neha_new@owner3.com', 'hashedpass3', 'owner', '9999999993'),
('Sneha Kapoor', 'sneha_new@student.com', 'hashedpass4', 'student', '9999999994');

-- =========================================================
-- 6 SAMPLE PROPERTIES
-- =========================================================
INSERT INTO properties (owner_id, title, rent, room_type, has_wifi, has_ac, has_food, city, area, address)
VALUES
(1, 'Sunshine Residency', 8000.00, '2R', TRUE, FALSE, TRUE, 'Lucknow', 'Aliganj', 'Near ABC Mall'),
(1, 'Royal Residency', 5000.00, '1R', TRUE, FALSE, FALSE, 'Lucknow', 'Gomti Nagar', 'Near XYZ Park'),
(1, 'Metro PG', 4000.00, '1R', TRUE, FALSE, TRUE, 'Lucknow', 'Charbagh', 'Near Railway Station'),
(2, 'Green Comfort PG', 7000.00, '2R', TRUE, TRUE, TRUE, 'Lucknow', 'Hazratganj', 'Main Road'),
(3, 'Budget Stay PG', 3500.00, '1R', TRUE, FALSE, FALSE, 'Lucknow', 'Alambagh', 'Bus Stand Area');

-- =========================================================
-- 7 SAMPLE STUDENT PREFERENCES
-- =========================================================
INSERT INTO student_preferences
(student_id, max_budget, preferred_room_type, needs_wifi, needs_ac, needs_food, preferred_city, preferred_area)
VALUES
(4, 9000.00, '2R', TRUE, FALSE, TRUE, 'Lucknow', 'Aliganj');

-- =========================================================
-- 8 TEST QUERY (TOP 5 MATCHES FOR SNEHA)
-- =========================================================
SELECT 
    pg_name,
    rent,
    room_type,
    has_wifi,
    has_ac,
    has_food,
    city,
    area,
    match_score
FROM student_pg_matches
WHERE student_id = 4
ORDER BY match_score DESC
LIMIT 5;
