/*
    Lab 4 - Query (3) - Grouping & aggregation, subqueries, etc.
    
    Name: Brandon Ching
 */
 
-- don't forget to set your search path; this sets it for the current session:
SET search_path = history;

-- windows psql needs the following line uncommented
-- \encoding utf-8

-- add other environment changes here (pager, etc.)

-- add your SQL query to provide the answer to each question 
-- after the comment containing the question

/***************************************************************************
    SUBQUERIES - each answer in this question must include a subquery!
    You may not use joins for any question in this section.
****************************************************************************/
/*
    1. Which pioneers (first name, last name) won Turing Awards before the
    year 2000? (2 columns, 2 rows)
*/

SELECT first, last
FROM pioneer
WHERE id IN (
    SELECT pioneer_id
    FROM turing_award
    WHERE year_awarded < 2000
);

/*
    2. Which pioneers (first name, last name) did not win a Turing Award? 
    (2 columns, 13 rows)
*/

SELECT first, last
FROM pioneer
WHERE id NOT IN (
    SELECT pioneer_id
    FROM turing_award
);

/* 
   3. Which organizations (name only) have no associated pioneer?  
   (1 column, 1 row)
*/

SELECT name
FROM organization
WHERE id NOT IN (
    SELECT organization_id
    FROM pioneer_org_xref
);

/* 
   4. For this question, you may not use IN or EXISTS.  
      Which pioneer (first, last) won a Turing award in 2014?  
      (2 columns, 1 row)
 */

SELECT first, last
FROM pioneer
WHERE id = (
    SELECT pioneer_id
    FROM turing_award
    WHERE year_awarded = 2014
);

/*
    5. Which pioneers (first, last) are associated with the organization
    "MySQL AB"? (2 columns, 3 rows)
*/

SELECT first, last
FROM pioneer
WHERE id IN (
    SELECT pioneer_id
    FROM pioneer_org_xref
    WHERE organization_id = (
        SELECT id
        FROM organization
        WHERE name = 'MySQL AB'
    )
);

/*
    6. Which pioneers (first, last) founded organizations (i.e., have "Co-founder" in their role) between 1970 and 1990? (2 columns, 3 rows)
*/

SELECT first, last
FROM pioneer
WHERE id IN (
    SELECT pioneer_id
    FROM pioneer_org_xref
    WHERE role LIKE '%Co-founder%'
    AND organization_id IN (
        SELECT id
        FROM organization
        WHERE founded BETWEEN 1970 AND 1990
    )
);

/***************************************************************************
    GROUPING AND AGGREGATION.  You may use any other techniques (e.g. joins,
    subqueries) as needed.
****************************************************************************/

/*
    7. What is the average known birth year for our pioneers?  Cast the 
    result to an integer.  (1 column, 1 row)
*/

SELECT CAST(AVG(birth) AS INTEGER)
FROM pioneer;


/*
    8. How many pioneers were born in each year after 1940?  Give the birth
    year and the count, and order by birth year.  (2 columns, 6 rows)
*/

SELECT birth, COUNT(*)
FROM pioneer
WHERE birth > 1940
GROUP BY birth
ORDER BY birth;

/*
    9. Which pioneers are associated with more than one organization?  Give 
    the first and last name of the pioneer and the number of organizations 
    they are associated with.  (3 columns, 4 rows)
*/

SELECT first, last, COUNT(*)
FROM pioneer
JOIN pioneer_org_xref ON pioneer.id = pioneer_id
GROUP BY first, last
HAVING COUNT(*) > 1;

/*
    10. Which organizations are associated with more than one pioneer who are 
    now deceased?  Give the organization name and the number of associated 
    deceased pioneers. (2 columns, 1 row)
*/

SELECT name, COUNT(*)
FROM organization
JOIN pioneer_org_xref ON organization.id = organization_id
JOIN pioneer ON pioneer.id = pioneer_id
WHERE death IS NOT NULL
GROUP BY name
HAVING COUNT(*) > 1;

/***************************************************************************
    SET OPERATIONS.  While these can be answered in other ways, 
    you must use set union, intersection, or difference for each of these.
****************************************************************************/

/*
    11. Which pioneers (first, last) won a Turing award or were born before
    1930? (2 columns, 5 rows)
*/

SELECT first, last
FROM pioneer
WHERE id IN (
    SELECT pioneer_id
    FROM turing_award
)
UNION
SELECT first, last
FROM pioneer
WHERE birth < 1930;

/*
    12. Which pioneers (first, last) were associated with University of California - Berkeley and won a Turing award? (2 columns, 1 row)
*/

SELECT first, last
FROM pioneer
WHERE id IN (
    SELECT pioneer_id
    FROM pioneer_org_xref
    WHERE organization_id = (
        SELECT id
        FROM organization
        WHERE name = 'University of California - Berkeley'
    )
)
INTERSECT
SELECT first, last
FROM pioneer
WHERE id IN (
    SELECT pioneer_id
    FROM turing_award
);

/***************************************************************************
    CHALLENGE QUESTIONS.  You may use any techniques, including subqueries,
    grouping and aggregation, set operations, common table expressions, and
    window functions, except you may not use LIMIT.
****************************************************************************/

/*
    13. Of the deceased pioneers, who was the oldest at death?  Give first, 
    last and approximate age at death. (3 columns, 1 row)
*/

SELECT first, last, death - birth AS age_at_death
FROM pioneer
WHERE death IS NOT NULL AND (death - birth) = (
    SELECT MAX(death - birth)
    FROM pioneer
    WHERE death IS NOT NULL
);

/*
    14. Provide a list of pioneers (first, last) who won Turing awards, along 
    with the number of organizations they were associated with, and the names 
    of any organizations they were associated with.  This question can be 
    answered a couple of different ways; most ways yield 4 columns and 8 
    rows.  If you prefer, there is an aggregate function that will let you 
    give 4 columns and 3 rows such that all organizations are listed in the 
    same column.
*/

SELECT first, last, COUNT(*), STRING_AGG(name, ', ')
FROM pioneer
JOIN pioneer_org_xref ON pioneer.id = pioneer_id
JOIN organization ON organization.id = organization_id
WHERE pioneer.id IN (
    SELECT pioneer_id
    FROM turing_award
)
GROUP BY first, last;
