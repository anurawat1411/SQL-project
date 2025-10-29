CREATE DATABASE IF NOT EXISTS music_store_database;
USE music_store_database;

SELECT * FROM artist;
SELECT * FROM customer;
SELECT * FROM employee;
SELECT * FROM genre;
SELECT * FROM invoice;
SELECT * FROM invoice_line;
SELECT * FROM media_type;
SELECT * FROM playlist;
SELECT * FROM playlist_track;
SELECT * FROM track;
SELECT * FROM album;


-- Who is the senior most employee in the job title?
SELECT * FROM employee 
ORDER BY levels DESC
LIMIT 1;

-- Which country have the most invoices?
SELECT COUNT(invoice_id) AS Invoice, billing_country
FROM invoice
GROUP BY billing_country
ORDER BY Invoice DESC;

-- What are the top 3 values of total invoice?
SELECT * FROM invoice
ORDER BY total DESC
LIMIT 3;

-- Which city has the best customers? 
-- We would like to throw a promotional Music Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals. 
-- Return both the city name & sum of all invoice totals.
SELECT billing_city, SUM(total) AS total_sum
FROM invoice 
GROUP BY billing_city
ORDER BY total_sum DESC
LIMIT 1;

-- Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money
SELECT c.customer_id, c.first_name, c.last_name, i.customer_id, SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i ON i.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC 
LIMIT 1;

-- Moderate question

-- Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A
SELECT DISTINCT c.email, c.first_name, c.last_name
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line i_l ON i.invoice_id = i_l.invoice_id
WHERE track_id IN(
        SELECT track_id FROM track
        JOIN genre g ON track.genre_id = g.genre_id
	    WHERE g.name LIKE 'Rock'
)
ORDER BY c.email ASC ; 
     
     
-- Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands.
SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id, artist.name
ORDER BY number_of_songs DESC
LIMIT 10;

-- Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
SELECT name,milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
ORDER BY milliseconds DESC;
SELECT * FROM track;

-- ADVANCE QUERY
-- Find how much amount spent by each customer on artists? 
-- Write a query to return customer name, artist name and total spent 

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist */

WITH best_selling_artist AS(
SELECT a.artist_id, a.name, SUM(il.unit_price*il.quantity) AS total_spent
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN album u ON u.album_id = t.album_id
JOIN artist a ON u.artist_id = a.artist_id
GROUP BY a.artist_id, a.name
ORDER BY total_spent DESC
LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.name,
SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album u ON u.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = u.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.name
ORDER BY amount_spent DESC;


/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

WITH popular_genre AS 
(
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


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

WITH Customter_with_country AS 
(
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1
