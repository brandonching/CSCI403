/*
    CSCI 403 Lab 2: Make (1)
    
    Name: Brandon Ching
*/

-- do not put SET SEARCH_PATH in this file
-- add your statements after the appropriate Step item
-- it's fine to add additional comments as well

/* Step 1: Create the table */
DROP TABLE IF EXISTS schedule;
CREATE TABLE IF NOT EXISTS schedule
(
    department      TEXT,
    course          TEXT,
    title           TEXT,
    credits         NUMERIC(2,1),
    semester        TEXT,
    year            INTEGER
);

/* Step 2: Insert the data */
-- get data from public.cs_courses and insert into schedule
INSERT INTO schedule
SELECT department, course_number, course_title, semester_hours, 'Spring', 2024
FROM public.cs_courses
WHERE course_number IN (403, 358);

INSERT INTO schedule
VALUES ('MATH', '201', 'PROBABILITY & STATISTICS', 3.0, 'Spring', 2024),
         ('HASS', '309', 'LITERATURE AND SOCIETY', 3.0, 'Spring', 2024);

/* Step 3: Fix errors */
UPDATE schedule
SET title = 'DATABASE MANAGEMENT', credits = 3.0
WHERE department = 'CSCI' AND course = '403';

/* Step 4: Drop a class */
DELETE FROM schedule
WHERE department = 'HASS' AND course = '309';

/* Step 5: Plan ahead */
DROP TABLE IF EXISTS planning;
CREATE TABLE IF NOT EXISTS planning
    AS SELECT department, course_number, course_title, semester_hours, 'Fall' AS credits, 2024 AS year
FROM public.cs_courses
WHERE course_number IN (404, 406, 470, 446) AND department = 'CSCI';
