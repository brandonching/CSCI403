/*
    Lab 3 - Joins & Aliasing
    
    Name:
 */
 
-- don't forget to set your search path; this sets it for the current session:
SET search_path = history;

-- windows psql needs the following line uncommented
-- \encoding utf-8

-- add other environment changes here (pager, etc.)

-- add your SQL query to provide the answer to each question 
-- after the comment containing the question

/*
    1. Which pioneers won turing awards? Provide their first name, last name, and why they received
       the award. (3 columns, 3 rows)
*/


/*
    2. What organizations did Charles Bachman work for and what were his roles?  (2 columns, 4 rows)
*/


/* 
   3. Which pioneers have 'Computer Scientist' in their role? Provide only their first name and last
      name, but order them by birth year. (2 columns, 2 rows)
*/


/* 
   4. Which organization founder or co-founder was oldest at the time they founded their organization?
      Provide only their first and last name. (2 columns, 1 row)
 */


/*
    5. Which pioneer is not associated with any organization(s)? Give all of their information and their
       role. Do not type out all the column names for pioneer. Use a left or right join. (7 columns, 1 row)
*/


/*
    6. Rewrite your query from question 5 using the other type of join (i.e., if you used a left join above,
       then use a right join here). Return the same information. (7 columns, 1 row).
*/


/*
    7. Find all pioneers and all organizations they've worked for. If they don't work for an organization,
       then give their organization as 'No Organization'. Give their first name, last name, and the name of
       the organization. Name the organization name 'organization'. (3 columns, 24 rows)
*/


/*
    8. Find the names of all pioneers, all organizations, and the year the pioneer won a turing award if
       they received one. Give the first name, last name, organization name, and year the turing award was
       given. Rename the year awarded to year. Order by last name then their organization. (4 columns, 25 rows)
*/


/*
    CHALLENGE QUESTION
    9. We're having a party for database pioneers, but we are only inviting pairs of pioneers who share the
       same first initial.  For our invitation list, provide a query that prints each pioneer who shares a first
       initial with another pioneer (first, last) as well as the pioneer they are paired with (first, last).

       NOTE: do NOT print a pioneer with themselves.  E.g., your output should include rows:
           (Edgar, Codd, Eugene, Wong)
           (Eugene, Wong, Edgar, Codd)
       but should not include 
           (Edgar, Codd, Edgar, Codd).

       HINT: try to accomplish as much of this query as possible using your join conditions.
       (4 columns, 10 rows)
*/

