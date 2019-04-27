/* Student: Rafael Santos 
   Data Analytics and Visualization Cohort 3
*/
use sakila;

-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;

/* 1b. Display the first and last name of each actor in a single column in upper case letters. 
Name the column Actor Name.
*/

select actor_id, first_name, last_name, concat(first_name, " ", last_name) as "Actor Name" from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?

select actor_id, first_name, last_name from actor where first_name like 'Joe';
-- 2b. Find all actors whose last name contain the letters GEN:

select first_name, last_name from actor where last_name like '%GEN%';

/*-- 2c. Find all actors whose last names contain the letters LI. 
This time, order the rows by last name and first name, in that order:
*/

select first_name, last_name from actor where last_name like '%LI%'
ORDER BY last_name, first_name ASC; 

/*-- 2d. Using IN, display the country_id and country columns of the following countries: 
Afghanistan, Bangladesh, and China:
*/

select country_id, country from country where country In ('Afghanistan', 'Bangladesh', 'China') ;

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

alter table actor
add column description BLOB;

SELECT * FROM actor;  

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.

alter table actor
drop column description;
SELECT * FROM actor;  

-- 4a. List the last names of actors, as well as how many actors have that last name.

select last_name, count(*) as "Count of Last Names" from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(*) as "Count of Last Names" from actor
group by last_name
having count(*) > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

-- just checking the Actor ID in order to double check results later
select actor_id, first_name, last_name from actor where (first_name = 'GROUCHO' and last_name = "WILLIAMS");
select actor_id, first_name, last_name from actor where actor_id = 172;

-- ANSWER:
update actor SET first_name = "HARPO" WHERE (first_name = 'GROUCHO' and last_name = "WILLIAMS" and actor_id <> 0);

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
-- It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, 
-- change it to GROUCHO.

-- ANSWER:
update actor SET first_name = "GROUCHO" WHERE (first_name = 'HARPO' and actor_id <> 0);
-- double checking answer
select actor_id, first_name, last_name from actor where actor_id = 172;

/*5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
*/

show create table address;
CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select first_name, last_name,address_id from staff;
select address_id,address, address2, district, city_id, postal_code from address;

select staff.first_name, staff.last_name, staff.address_id, address.address, address.address2, address.district, address.city_id, address.postal_code
from staff
inner join address on
staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

select * from payment;

select staff.staff_id, staff.first_name, staff.last_name, sum(payment.amount) as 'total amount'
from staff
inner join payment on
staff.staff_id = payment.staff_id
group by payment.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

select film.film_id, film.title, count(film_actor.film_id) as 'number of actors'
from film_actor
inner join film on
film_actor.film_id = film.film_id
group by film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select * from inventory;

select film.film_id, film.title, count(inventory.film_id) as 'count of inventory'
from film
inner join inventory on
film.film_id = inventory.film_id
group by film_id
having film.title = "Hunchback Impossible";



-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:

select customer.customer_id, customer.first_name, customer.last_name, sum(payment.amount) as 'total amount'
from customer
inner join payment on
customer.customer_id = payment.customer_id
group by payment.customer_id
Order by last_name ASC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

select * from language;

select film.film_id, film.title from film where language_id in
	(select language_id from language where name = "English")
    having (film.title like "Q%" or film.title like "K%");

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

select actor.actor_id, actor.first_name, actor.last_name from actor where actor_id in
	(select actor_id from film_actor where film_actor.film_id in
		(select film_id from film where title = "Alone Trip")
    );


-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

select address.address_id, address.city_id
from address
where (city_id = 179 or city_id = 196 or city_id = 300 or city_id = 313 or city_id = 383 or city_id = 430 or city_id = 565);

select city.city_id, city.city, city.country_id
from city
where country_id = 20;

select country.country_id, country.country
from country
where country = "Canada";

select customer.customer_id, customer.first_name, customer.last_name, customer.email, customer.address_id
from customer
inner join address on
customer.address_id = address.address_id
where address.address_id in
	(select city.city_id from city where country_id in
		(select country_id from country where country = "Canada")
        )
Order by address_id ASC;


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.

select film_id, title from film where film_id in
	(select film_id from film_category where category_id in
		(select category_id from category where name = "Family")
    );
    

-- 7e. Display the most frequently rented movies in descending order.

select film.film_id, film.title, 
		(select count(*) from rental where inventory_id in
			(select inventory_id from inventory where inventory.film_id = film.film_id)
		) as Number_of_rentals
from film 
order by Number_of_rentals DESC;


-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT store_id, 
				(SELECT sum(payment.amount) FROM payment where staff_id in
					(select staff_id from staff where staff.store_id=store.store_id)
				) AS 'Total revenue'
FROM store;

-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT store.store_id,
				(SELECT city FROM city where city_id in
					(select city_id from address where address.address_id = store.address_id)
				) AS 'City',
                (SELECT country FROM country where country_id in
					(select country_id from city where city_id in
						(select city_id from address where address.address_id = store.address_id)
                    )
				) as 'Country'
FROM store;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT category_id, name,
				(SELECT sum(amount) FROM payment where rental_id in
					(select rental_id from rental where inventory_id in
						(select inventory_id from inventory where film_id in
							(select film_id from film_category where film_category.category_id = category.category_id)
                        )
                    ) 
				) as Total_Revenue
FROM category
order by Total_Revenue DESC
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW Top_Five_Genres AS 
	SELECT category_id, name,
				(SELECT sum(amount) FROM payment where rental_id in
					(select rental_id from rental where inventory_id in
						(select inventory_id from inventory where film_id in
							(select film_id from film_category where film_category.category_id = category.category_id)
						)
					) 
				) as Total_Revenue
FROM category
order by Total_Revenue DESC
limit 5;


-- 8b. How would you display the view that you created in 8a?

select * from Top_Five_Genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

drop view Top_Five_Genres;