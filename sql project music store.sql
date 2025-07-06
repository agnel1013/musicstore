--Q1 who is the senior most employee based on job title?

SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1

-- Q2 Which country have the most invoices?

SELECT COUNT(*) as c, billing_country
FROM invoice
GROUP BY billing_country
ORDER BY c desc 

-- Q3 what are the top 3 values of total invoices?

SELECT total 
FROM invoice
ORDER BY total DESC
LIMIT 3

---Q4 Which city has the best customer? which city has the highest sum of invoice totals? return
-- both the city and sum of all invoices total?

SELECT SUM(total) as invoice_total, billing_city
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC

-- who is the best customer? best customer will be who spent most money? 
-- find the customer who has spent most money?

SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) as total
FROM customer as c
JOIN invoice AS i ON c.customer_id = i.customer_id 
GROUP BY c.customer_id
ORDER BY total DESC
LIMIT 1

-- Q find the email, first name, last name & genre of all rock music listner.
-- return your list alphabetically by email  starting with A.

SELECT DISTINCT email, first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
       SELECT track_id FROM track
	   JOIN genre ON track.genre_id = genre.genre_id
	   WHERE genre.name LIKE 'Rock'
	   
)

 ORDER BY email;


 
-- lets invite the artist who have written the most rock music in our dataset
-- find artist name and total track count of the top 10 rock bands

SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;

--Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name, milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
ORDER BY milliseconds DESC;

---Find how much amount spent by each customer on artists? 
---Write a query to return customer name, artist name and total spent


    best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

---We want to find out the most popular music Genre for each country. 
---We determine the most popular genre as the genre with the highest amount of purchases. 
---Write a query that returns each country along with the top Genre. For countries where 
--the maximum number of purchases is shared return all Genres.

 WITH popular_genre AS(
    
	SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1
















