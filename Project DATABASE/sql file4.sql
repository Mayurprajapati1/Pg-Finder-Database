USE nexnest_db;

-- Add an Owner and a Student
INSERT INTO users (full_name, email, role) VALUES 
('Rajesh Kumar', 'rajesh@owner.com', 'owner'),
('Sneha Kapoor', 'sneha@student.com', 'student');

-- Add a Property (linked to Rajesh)
INSERT INTO properties (owner_id, title, rent, room_type, has_wifi, has_ac) VALUES 
(1, 'Sunshine Residency', 8000.00, '2R', TRUE, FALSE),
(2, 'Royal Residency', 5000.00, '1R', TRUE, FALSE),
(3, 'Metro PG', 4000.00, '1R', TRUE, FALSE);

-- Add Sneha's Preferences
INSERT INTO student_preferences (student_id, max_budget, needs_wifi) VALUES 
(2, 9000.00, TRUE);