/*
    Lab 1 - SQL Select Statements (queries)
    
    Name: Brandon Ching
 */
 
-- don't forget to set your search path; this sets it for the current session:
SET search_path = history;

-- windows psql needs the following line uncommented
-- \encoding utf-8

-- add other environment changes here (pager, etc.)

-- add your SQL query to provide the answer to each question 
-- after the comment containing the question; for example:

/*
   0. What do we know about pioneers born before 1900?
 */
SELECT * 
FROM pioneer 
WHERE birth < 1900;

/*
    1. What is the pioneer Ray Boyce known for? Provide only the relevant column. (1 row) 
*/

SELECT known_for
FROM pioneer
WHERE first = 'Ray' AND last = 'Boyce';

/* 
    2. Which pioneer's last name started with 'S' whose first name did not start with 'P' and what were they known for? (1 row)
*/
 
SELECT first, last, known_for
FROM pioneer
WHERE last LIKE 'S%' AND first NOT LIKE 'P%';

/* 
    3. Which pioneers are living (or are presumed to be, given the data)?  Provide their names and birth years. (11 rows)
*/

SELECT first, last
FROM pioneer
WHERE death IS NULL;

/*
    4. For the pioneers whose last names start with the letter 'S', return their name in a single column (first and last, separated with a space). (2 rows)
*/

SELECT first || ' ' || last AS name
FROM pioneer
WHERE last LIKE 'S%';

/*
    5. Return all of the pioneer's names (in 2 columns) sorted by last name and then first name. (16 rows) 
*/

SELECT first, last
FROM pioneer
ORDER BY last, first;

/*
    6. Provide the names of pioneers and what they are known for where the "known_for" column includes the word ‘promoting’ in it, in any case (upper, lower, or mixed case). (3 rows) 
*/

SELECT first, last, known_for
FROM pioneer
WHERE known_for ILIKE '%promoting%';


/*
    7. List all of the known birth years of our pioneers, without duplicates. (11 rows)
*/

SELECT DISTINCT birth
FROM pioneer
WHERE birth IS NOT NULL;

/*
    8. Give the names and founding dates of the organizations which were founded between 1890 and 1920. (3 rows) 
*/

SELECT name, founded
FROM organization
WHERE founded BETWEEN 1890 AND 1920;

/*
    9. For the pioneers who are known to have died, provide first name, last name, and age at death (approximate to within one year). (5 rows)
*/

SELECT first, last, death - birth AS age_at_death
FROM pioneer
WHERE death IS NOT NULL;

/*
    10. For all pioneers, provide the first initial followed by a period, last name, and age (approximate to within one year); use their age at death if they are dead, otherwise use their current age.  Do not hard code the current year!  Sort the result by last name. (16 rows)  Hint: you might need to use the COALESCE function or a CASE expression.

    Example row: (your output should include this!)
    D. Axmark        62
*/

SELECT left(first,1) || '. ' || last AS name,
    CASE WHEN death IS NOT NULL THEN death - birth
    ELSE EXTRACT(YEAR FROM CURRENT_DATE) - birth END AS age
FROM pioneer
ORDER BY last;