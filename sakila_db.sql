
-- 1a. Display the first and last names of all actors from the table actor.
USE sakila;

SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

SELECT * FROM actor;
SELECT CONCAT(first_name, ' ', last_name) AS 'Actor Name' FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 

SELECT * FROM actor;
SELECT actor_id, first_name, last_name 
FROM actor 
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:

SELECT * FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

SELECT * FROM actor;
SELECT last_name, first_name FROM actor
WHERE last_name LIKE '%LI%';
-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT * FROM country;
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh','China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

SELECT * FROM actor;
ALTER TABLE actor 
ADD COLUMN description BLOB NOT NULL;
SELECT * FROM actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.

ALTER TABLE actor 
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name FROM actor;
SELECT COUNT(last_name) AS frequency, last_name
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.

SELECT COUNT(last_name) AS frequency, last_name
FROM actor 
GROUP BY last_name
HAVING frequency >=2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

SET SQL_SAFE_UPDATES=0;
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

CREATE TABLE address; 


-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

SELECT a.first_name, a.last_name, b.address
FROM staff a 
INNER JOIN address b 
ON a.address_id = b.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

SELECT sum(b.amount) AS collected, a.first_name, a.last_name 
FROM staff a 
INNER JOIN payment b ON a.staff_id = b.staff_id
AND payment_date LIKE '2005-08%'
GROUP BY a.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT count(b.actor_id) AS 'number of actors', a.title
FROM film a 
INNER JOIN film_actor b ON a.film_id = b.film_id
GROUP BY a.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT * FROM inventory;
SELECT * FROM film;
SELECT COUNT(a.film_id) AS 'number of copies', b.title
FROM film b 
INNER JOIN inventory a ON a.film_id = b.film_id
WHERE b.title = 'Hunchback Impossible';
  
-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT * FROM payment;
SELECT * FROM customer;
SELECT b.first_name, b.last_name, SUM(a.amount) AS 'Total Amount Paid' 
FROM payment a 
INNER JOIN customer b ON a.customer_id = b. customer_id
GROUP BY b.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT * FROM sakila.language;
SELECT * FROM sakila.film;
SELECT a.title, b.name AS 'language'
FROM film a 
INNER JOIN language b ON a.language_id = b.language_id 
WHERE title LIKE 'K%' OR 'Q%' AND b.name = 'English';

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT * FROM sakila.film;
SELECT * FROM sakila.actor;
SELECT * FROM sakila.film_actor;
SELECT first_name, last_name
FROM actor 
WHERE actor_id in
  (
   SELECT actor_id
   FROM film_actor 
   WHERE film_id in
    (
     SELECT actor_id
     FROM film
     WHERE title = 'Alone Trip'
	)
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT * FROM sakila.customer;
SELECT * FROM sakila.address;
SELECT * FROM sakila.city;
SELECT * FROM sakila.country;
CREATE VIEW cnd_cust AS select first_name, last_name, email
FROM customer 
WHERE address_id IN
(
 SELECT address_id 
 FROM address
 WHERE city_id IN
  (
   SELECT city_id 
   FROM city 
   WHERE country_id IN
    (
     SELECT country_id 
     FROM country
     WHERE country ='Canada'
     )
	)
);

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT * FROM sakila.film;
SELECT * FROM sakila.film_category;
SELECT * FROM sakila.category;
SELECT title
FROM film 
WHERE film_id IN
  (
   SELECT film_id 
   FROM film_category
   WHERE category_id IN
    (
     SELECT category_id 
     FROM category
     WHERE name = 'Family'
     )
	);
    
-- 7e. Display the most frequently rented movies in descending order.

SELECT * FROM sakila.film;
SELECT title, rental_duration
FROM film
ORDER BY rental_duration DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT * FROM sakila.payment;
SELECT * FROM sakila.staff;
SELECT * FROM sakila.store;
SELECT * FROM sakila.sales_by_store;
SELECT SUM(payment.amount) AS sales, store.store_id
FROM payment 
JOIN staff
USING(staff_id)
JOIN store
USING(store_id)
GROUP BY store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT store.store_id, city.city, country.country
FROM store
JOIN address
USING(address_id) 
JOIN city
USING(city_id)
JOIN country 
USING(country_id);

-- 7h. List the top five genres in gross revenue in descending order.

SELECT * FROM sakila.category;
SELECT * FROM sakila.film_category;
SELECT * FROM sakila.inventory;
SELECT * FROM sakila.payment;
SELECT * FROM sakila.rental;
SELECT category.name AS genres, SUM(payment.amount) AS total
FROM payment
JOIN rental
USING(rental_id)
JOIN inventory
USING(inventory_id)
JOIN film_category
USING(film_id)
JOIN category
USING(category_id)
GROUP BY category.name
ORDER BY total DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.


SELECT * FROM sakila.category;
SELECT * FROM sakila.film_category;
SELECT * FROM sakila.inventory;
SELECT * FROM sakila.payment;
SELECT * FROM sakila.rental;
CREATE VIEW top_five AS select category.name AS genres, SUM(payment.amount) AS total
FROM payment
JOIN rental
USING(rental_id)
JOIN inventory
USING(inventory_id)
JOIN film_category
USING(film_id)
JOIN category
USING(category_id)
GROUP BY category.name
ORDER BY total DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?

SELECT * FROM sakila.top_five;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

DROP VIEW top_five;