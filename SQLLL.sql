/* =======================================================
   PART A: SQL BASICS
   ======================================================= */

/* Q1. Create a table called employees with constraints */
CREATE database EMPLOYEE;
USE EMPLOYEE;
CREATE TABLE employees (
    emp_id INT PRIMARY KEY NOT NULL,
    emp_name VARCHAR(100) NOT NULL,
    age INT CHECK (age >= 18),
    email VARCHAR(100) UNIQUE,
    salary DECIMAL(10,2) DEFAULT 30000
);

/* Q2. Purpose of constraints
   - NOT NULL → ensures column is not empty
   - PRIMARY KEY → unique identification of row
   - FOREIGN KEY → maintains relationship between tables
   - UNIQUE → no duplicate values
   - CHECK → validates condition
   - DEFAULT → assigns default value automatically */

/* Q3. Why NOT NULL? Can PK contain NULL?
   - NOT NULL ensures data is always present
   - Primary Key can NEVER have NULL values, because it must uniquely identify rows */

/* Q4. Add and Remove constraints */
ALTER TABLE employees ADD CONSTRAINT chk_age CHECK (age >= 18);
ALTER TABLE employees DROP CONSTRAINT chk_age;

/* Q5. Constraint violation consequence
   Example: Insert with age < 18 will throw error
   INSERT INTO employees VALUES (1,'Ravi',15,'ravi@mail.com',25000);
   → ERROR: CHECK constraint failed */

/* Q6. Modify products table */
ALTER TABLE products ADD PRIMARY KEY (product_id);
ALTER TABLE products ALTER COLUMN price SET DEFAULT 50.00;


/* =======================================================
   PART B: SQL COMMANDS (MAVENMOVIES DB)
   ======================================================= */

/* Q2. List all details of actors */
SELECT * FROM actor;

/* Q3. List all customer information */
SELECT * FROM customer;

/* Q4. List different countries */
SELECT DISTINCT country FROM country;

/* Q5. Display all active customers */
SELECT * FROM customer WHERE active = 1;

/* Q6. Rental IDs for customer ID = 1 */
SELECT rental_id FROM rental WHERE customer_id = 1;

/* Q7. Films with rental duration > 5 */
SELECT * FROM film WHERE rental_duration > 5;

/* Q8. Number of films with replacement cost between 15 and 20 */
SELECT COUNT(*) FROM film
WHERE replacement_cost > 15 AND replacement_cost < 20;

/* Q9. Count of unique first names of actors */
SELECT COUNT(DISTINCT first_name) FROM actor;

/* Q10. First 10 records from customer */
SELECT * FROM customer LIMIT 10;

/* Q11. First 3 customers whose name starts with 'B' */
SELECT * FROM customer WHERE first_name LIKE 'B%' LIMIT 3;

/* Q12. First 5 movies rated as 'G' */
SELECT title FROM film WHERE rating = 'G' LIMIT 5;

/* Q13. Customers whose first name starts with 'a' */
SELECT * FROM customer WHERE first_name LIKE 'a%';

/* Q14. Customers whose first name ends with 'a' */
SELECT * FROM customer WHERE first_name LIKE '%a';

/* Q15. First 4 cities that start and end with 'a' */
SELECT city FROM city WHERE city LIKE 'a%a' LIMIT 4;

/* Q16. Customers whose first name has 'NI' anywhere */
SELECT * FROM customer WHERE first_name LIKE '%NI%';

/* Q17. Customers whose first name has 'r' at 2nd position */
SELECT * FROM customer WHERE first_name LIKE '_r%';

/* Q18. Customers whose first name starts with 'a' and length >= 5 */
SELECT * FROM customer WHERE first_name LIKE 'a%' AND LENGTH(first_name) >= 5;

/* Q19. Customers whose first name starts with 'a' and ends with 'o' */
SELECT * FROM customer WHERE first_name LIKE 'a%o';

/* Q20. Films with PG or PG-13 rating */
SELECT * FROM film WHERE rating IN ('PG','PG-13');

/* Q21. Films with length between 50 and 100 */
SELECT * FROM film WHERE length BETWEEN 50 AND 100;

/* Q22. Top 50 actors */
SELECT * FROM actor LIMIT 50;

/* Q23. Distinct film IDs from inventory */
SELECT DISTINCT film_id FROM inventory;


/* =======================================================
   PART C: FUNCTIONS
   ======================================================= */

/* Q1. Total rentals made */
SELECT COUNT(*) FROM rental;

/* Q2. Average rental duration */
SELECT AVG(rental_duration) FROM film;

/* Q3. Customer names in uppercase */
SELECT UPPER(first_name), UPPER(last_name) FROM customer;

/* Q4. Extract month from rental date */
SELECT rental_id, MONTH(rental_date) AS rental_month FROM rental;

/* Q5. Count of rentals per customer */
SELECT customer_id, COUNT(*) AS rental_count
FROM rental GROUP BY customer_id;

/* Q6. Total revenue by store */
SELECT store_id, SUM(amount) AS total_revenue
FROM payment GROUP BY store_id;

/* Q7. Rentals per category */
SELECT c.name, COUNT(r.rental_id) AS rental_count
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON f.film_id = fc.film_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
GROUP BY c.name;

/* Q8. Average rental rate by language */
SELECT l.name, AVG(f.rental_rate) AS avg_rate
FROM film f
JOIN language l ON f.language_id = l.language_id
GROUP BY l.name;


/* =======================================================
   PART D: JOINS
   ======================================================= */

/* Q9. Movie title + customer name who rented it */
SELECT f.title, c.first_name, c.last_name
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN customer c ON r.customer_id = c.customer_id;

/* Q10. Actors in film "Gone with the Wind" */
SELECT a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON f.film_id = fa.film_id
WHERE f.title = 'Gone with the Wind';

/* Q11. Customer names + total amount spent */
SELECT c.first_name, c.last_name, SUM(p.amount) AS total_spent
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id;

/* Q12. Movies rented by each customer in London */
SELECT c.first_name, c.last_name, f.title
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE ci.city = 'London'
GROUP BY c.first_name, c.last_name, f.title;


/* =======================================================
   PART E: ADVANCED JOINS & GROUP BY
   ======================================================= */

/* Q13. Top 5 rented movies */
SELECT f.title, COUNT(r.rental_id) AS times_rented
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY times_rented DESC
LIMIT 5;

/* Q14. Customers who rented from both stores */
SELECT customer_id
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
GROUP BY customer_id
HAVING COUNT(DISTINCT i.store_id) = 2;


/* =======================================================
   PART F: WINDOW FUNCTIONS
   ======================================================= */

/* 1. Rank customers by total amount spent */
SELECT c.customer_id, c.first_name, c.last_name,
       SUM(p.amount) AS total_spent,
       RANK() OVER (ORDER BY SUM(p.amount) DESC) AS ranking
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id;

/* 2. Cumulative revenue by film */
SELECT f.title, SUM(p.amount) OVER (PARTITION BY f.title ORDER BY r.rental_date) AS cumulative_revenue
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id;

/* =======================================================
   PART G: NORMALIZATION
   ======================================================= */

/* Q1. First Normal Form (1NF)
   Identify a table in Sakila/Mavenmovies that violates 1NF.
   Example: If a table stores multiple phone numbers in one column.
   Solution: Split into separate rows or create child table for phone numbers.
*/

/* Q2. Second Normal Form (2NF)
   Rule: All non-key columns must depend on full Primary Key.
   Example: In a table with composite PK (rental_id, customer_id),
   if "customer_name" depends only on customer_id → violates 2NF.
   Solution: Move customer_name into customer table.
*/

/* Q3. Third Normal Form (3NF)
   Rule: No transitive dependency.
   Example: If 'city_id' determines 'city_name' but both are in Customer table,
   then dependency is transitive.
   Solution: Keep city_name in City table, not in Customer.
*/

/* Q4. Normalization Process
   Start: Unnormalized table (with repeating groups).
   Step 1 → Convert to 1NF (atomic values).
   Step 2 → Ensure full functional dependency (2NF).
   Step 3 → Remove transitive dependency (3NF).
*/


/* =======================================================
   PART G: CTE (Common Table Expressions)
   ======================================================= */

/* Q5. CTE Basics:
   Distinct actor names and number of films they acted in */
WITH actor_films AS (
    SELECT a.actor_id, CONCAT(a.first_name,' ',a.last_name) AS actor_name,
           COUNT(fa.film_id) AS film_count
    FROM actor a
    JOIN film_actor fa ON a.actor_id = fa.actor_id
    GROUP BY a.actor_id
)
SELECT * FROM actor_films;

/* Q6. CTE with Joins:
   Combine film and language tables */
WITH film_lang AS (
    SELECT f.title, l.name AS language_name, f.rental_rate
    FROM film f
    JOIN language l ON f.language_id = l.language_id
)
SELECT * FROM film_lang;

/* Q7. CTE for Aggregation:
   Total revenue per customer */
WITH customer_revenue AS (
    SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS total_revenue
    FROM customer c
    JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id
)
SELECT * FROM customer_revenue;

/* Q8. CTE with Window Functions:
   Rank films by rental duration */
WITH film_rank AS (
    SELECT title, rental_duration,
           RANK() OVER (ORDER BY rental_duration DESC) AS duration_rank
    FROM film
)
SELECT * FROM film_rank;

/* Q9. CTE with Filtering:
   Customers who made more than 2 rentals */
WITH active_customers AS (
    SELECT customer_id, COUNT(*) AS rentals
    FROM rental
    GROUP BY customer_id
    HAVING COUNT(*) > 2
)
SELECT c.customer_id, c.first_name, c.last_name
FROM customer c
JOIN active_customers ac ON c.customer_id = ac.customer_id;

/* Q10. CTE for Date Calculations:
   Rentals per month */
WITH monthly_rentals AS (
    SELECT MONTH(rental_date) AS rental_month, COUNT(*) AS rentals
    FROM rental
    GROUP BY MONTH(rental_date)
)
SELECT * FROM monthly_rentals;

/* Q11. CTE with Self-Join:
   Pairs of actors who acted in same film */
WITH actor_pairs AS (
    SELECT fa1.film_id, fa1.actor_id AS actor1, fa2.actor_id AS actor2
    FROM film_actor fa1
    JOIN film_actor fa2 ON fa1.film_id = fa2.film_id AND fa1.actor_id < fa2.actor_id
)
SELECT a1.first_name AS actor1_first, a1.last_name AS actor1_last,
       a2.first_name AS actor2_first, a2.last_name AS actor2_last,
       ap.film_id
FROM actor_pairs ap
JOIN actor a1 ON ap.actor1 = a1.actor_id
JOIN actor a2 ON ap.actor2 = a2.actor_id;

/* Q12. Recursive CTE:
   Find employees reporting to a specific manager */
WITH RECURSIVE staff_hierarchy AS (
    SELECT staff_id, first_name, last_name, reports_to
    FROM staff
    WHERE staff_id = 1   -- starting manager (example)

    UNION ALL

    SELECT s.staff_id, s.first_name, s.last_name, s.reports_to
    FROM staff s
    INNER JOIN staff_hierarchy sh ON s.reports_to = sh.staff_id
)
SELECT * FROM staff_hierarchy;



