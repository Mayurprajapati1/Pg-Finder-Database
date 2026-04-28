-- 1. Create the Database
CREATE DATABASE nexnest_db;
USE nexnest_db;

-- 2. User Table (Foundation)
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