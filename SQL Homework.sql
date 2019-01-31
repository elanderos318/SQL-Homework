use sakila

select * from actor; 

-- 1a. Display the first and last names of all actors from the table actor.
select first_name as 'First Name', last_name as 'Last Name'
from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select CONCAT(first_name, ' ', last_name) as 'ACTOR NAME'
from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

select actor_id as 'ID', first_name as 'First Name', last_name as 'Last Name'
from actor
where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:

select actor_id as 'ID', first_name as 'First Name', last_name as 'Last Name'
from actor
where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

select actor_id as 'ID', first_name as 'First Name', last_name as 'Last Name'
from actor
where last_name like '%LI%'
order by last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:


select country_id as 'ID', country as 'Country'
from country
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

ALTER TABLE actor
add description BLOB;

select * from actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.

ALTER TABLE actor
DROP COLUMN description;

select * from actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT  last_name as 'Last Name', COUNT(last_name) as 'Count'
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT  last_name as 'Last Name', COUNT(last_name) as 'Count'
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

select * from staff;
select * from address;

select staff.first_name as 'First Name', staff.last_name as 'Last Name', address.address as 'Address'
from staff
inner join address
on (staff.address_id = address.address_id);

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

select * from staff;
select * from payment;

select s.first_name as 'First Name', s.last_name 'Last Name', SUM(p.amount) as 'Total Amount Rung Up'
from staff s
inner join payment p
on (s.staff_id = p.staff_id)
where p.payment_date like '%2005-08%'
group by p.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

select * from film_actor;
select * from film;

select f.title as "Title", COUNT(fa.actor_id) as "Number of Actors"
from film_actor fa
inner join film f
on (fa.film_id = f.film_id)
group by fa.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

select * from film;
select * from inventory;

select f.title as 'Title', COUNT(i.film_id) as 'Number of Copies'
from film f
inner join inventory i
on (f.film_id = i.film_id)
where f.title = 'HUNCHBACK IMPOSSIBLE';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

select * from payment;
select * from customer;

select c.first_name as "First Name", c.last_name as "Last Name", SUM(p.amount) as "Total Paid"
from payment p
inner join customer c
on (c.customer_id = p.customer_id)
group by p.customer_id
order by c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

select * from film;
select * from language;

select title as 'Title'
from film
where title like 'K%' or title like 'Q%' AND language_id IN
(
	select language_id
	from language
	where name = 'English'
);


-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

select * from film_actor;
select * from film;
select * from actor;


select first_name as 'FIRST NAME', last_name as 'LAST NAME'
FROM actor
where actor_id in
(
	select actor_id
	from film_actor
	where film_id in
	(
		select film_id
		from film
		where title = 'ALONE TRIP'
	)
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

select * from country;
select * from address;
select * from customer;
select * from city;

select email as 'EMAIL'
from customer
where address_id in
(
	select address_id
	from address
	where city_id in
	(
		select city_id
		from city
		where country_id in
		(
			select country_id
			from country
			where country = 'Canada'
		)
	)
);

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

select * from film;
select * from film_category;
select * from category;

select title as 'Title'
from film
where film_id in
(
	select film_id
	from film_category
	where category_id in
	(
		select category_id
		from category
		where name = 'Family'
	)
)

-- 7e. Display the most frequently rented movies in descending order.

select * from film;
select * from inventory;
select * from rental;

select f.title as "Title", COUNT(f.title) as "Number of times rented"
from rental r
join inventory i
on (r.inventory_id = i.inventory_id)
join film f
on (f.film_id = i.film_id)
group by f.title
order by count(f.title) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

select * from payment;
select * from staff;
select * from store;

select s.store_id, SUM(p.amount) as "Total Revenue Earned from Rentals"
from payment p
join staff f
on (p.staff_id = f.staff_id)
join store s
on (f.store_id = s.store_id)
group by s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

select * from store;
select * from city;
select * from address;
select * from country;

select s.store_id as 'Store ID', c.city as 'City', cy.country as 'Country'
from store s
join address a
on (s.address_id = a.address_id)
join city c
on (a.city_id = c.city_id)
join country cy
on (c.country_id = cy.country_id);


-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

select * from category;
select * from film_category;
select * from inventory;
select * from payment;
select * from rental;

select c.name as "Category", sum(p.amount) as "Gross Revenue"
from category c
join film_category fc
on (c.category_id = fc.category_id)
join inventory i
on (fc.film_id = i.film_id)
join rental r
on (i.inventory_id = r.inventory_id)
join payment p
on (r.rental_id = p.rental_id)
group by c.name
order by p.amount desc limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW topgenres as 

SELECT c.name as "Category", sum(p.amount) as "Gross Revenue"
	from category c
	join film_category fc
	on (c.category_id = fc.category_id)
	join inventory i
	on (fc.film_id = i.film_id)
	join rental r
	on (i.inventory_id = r.inventory_id)
	join payment p
	on (r.rental_id = p.rental_id)
	group by c.name
	order by p.amount desc limit 5;
    
    
-- 8b. How would you display the view that you created in 8a?

SELECT * from topgenres;


-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW topgenres;