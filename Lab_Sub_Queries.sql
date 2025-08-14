USE sakila;

-- 1 Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.

SELECT title, COUNT(*) AS film_in_inventory
FROM (SELECT film_id, title FROM film WHERE title = 'Hunchback Impossible') AS t
INNER JOIN inventory i 
ON i.film_id = t.film_id
GROUP BY title;

-- 2 List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT title, length
FROM film
WHERE length > (SELECT AVG(length) FROM film);
    
-- 3 Use a subquery to display all actors who appear in the film "Alone Trip"

SELECT t.film_id,title,fa.actor_id,first_name,last_name
FROM 
	(SELECT film_id, title 
    FROM film 
    WHERE title = 'Alone Trip') AS t
INNER JOIN film_actor fa 
ON fa.film_id = t.film_id
INNER JOIN actor a
ON a.actor_id = fa.actor_id;

-- 4 Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.
SELECT name, title 
FROM 
	(SELECT name, category_id 
    FROM category 
    WHERE name = 'family') AS t
INNER JOIN film_category fc
		ON fc.category_id = t.category_id
INNER JOIN film f
		ON f.film_id = fc.film_id;

-- 5 Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.
SELECT c.first_name, c.last_name, c.email
FROM customer c
WHERE EXISTS (
    SELECT 1
    FROM address a
    JOIN city ci    ON ci.city_id = a.city_id
    JOIN country co ON co.country_id = ci.country_id
    WHERE a.address_id = c.address_id
      AND co.country = 'Canada'
)
ORDER BY c.last_name, c.first_name;

    
-- 6 Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films.
-- First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
SELECT 
    a.actor_id,
    a.first_name,
    a.last_name,
    f.film_id,
    f.title
FROM actor a
JOIN film_actor fa ON fa.actor_id = a.actor_id
JOIN film f       ON f.film_id   = fa.film_id
WHERE a.actor_id IN (

    SELECT t.actor_id
    FROM (
        /* Subconsulta 1a: nº de películas por actor */
        SELECT fa2.actor_id, COUNT(*) AS film_count
        FROM film_actor fa2
        GROUP BY fa2.actor_id
    ) AS t
    WHERE t.film_count = (

        SELECT MAX(t2.film_count)
        FROM (
            SELECT fa3.actor_id, COUNT(*) AS film_count
            FROM film_actor fa3
            GROUP BY fa3.actor_id
        ) AS t2
    )
)
ORDER BY a.last_name, a.first_name, f.title;

		
-- 7 Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables 
-- to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
SELECT 
    f.film_id,
    f.title,
    c.customer_id,
    c.first_name,
    c.last_name
FROM customer c
JOIN rental r   ON r.customer_id = c.customer_id
JOIN inventory i ON i.inventory_id = r.inventory_id
JOIN film f     ON f.film_id = i.film_id
WHERE c.customer_id IN (
    SELECT customer_id
    FROM payment
    GROUP BY customer_id
    HAVING SUM(amount) = (
        SELECT MAX(total_amount)
        FROM (
            SELECT customer_id, SUM(amount) AS total_amount
            FROM payment
            GROUP BY customer_id
        ) AS sub
    )
)
ORDER BY f.title;


-- 8 Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. 
-- You can use subqueries to accomplish this.
SELECT customer_id,
       SUM(amount) AS total_amount_spent
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > (
    SELECT AVG(total_amount)
    FROM (
        SELECT customer_id, SUM(amount) AS total_amount
        FROM payment
        GROUP BY customer_id
    ) AS sub
);

		

