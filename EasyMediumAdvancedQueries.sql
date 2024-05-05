--EQ1. WHO IS THE SENIORMOST EMPLOYEE BASED ON JOB TITLE?

SELECT first_name , last_name , levels FROM employee
ORDER BY levels DESC
LIMIT 1

--EQ2. WHICH COUNTRIES HAVE THE MOST INVOICES?

SELECT billing_country , COUNT(total) AS c FROM invoice
GROUP BY billing_country
ORDER BY c DESC

--EQ3. WHAT ARE TOP 3 VALLUES OF TOTAL INVOICE?

SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3

--EQ4. WHICH CITY HAS THE BEST CUSTOMERS?
--WE WOULD LIKE TO THROW A PROMOTIONAL MUSIC FESTIVAL IN THE CITY WE MADE THE MOST MONEY.
--WRITE A QUERY THAT RETURNS 1 CITY NAME AND SUM OF ALL INVOICE TOTALS

SELECT billing_city , SUM(total) FROM invoice
GROUP BY billing_city
ORDER BY billing_city

--EQ5. WHO IS THE BEST CUSTOMER?
--THE CUSTOMER WHO HAS SPENT MOST MONEY WILL BE DECLARED BEST CUSTOMER.
--WRITE A QUERY THAT RETURNS A PERSON WHO HAS SPENT MOST MONEY.

SELECT customer.customer_id , customer.first_name , customer.last_name , SUM(invoice.total) as total
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total DESC
LIMIT 1

--MQ1. WRITE QUERY TO RETURN EMAIL, FNMAE, LNAME & GENRE OF ALL ROCK MUSIC LISTERENERS.
--RETURN YOUR LIST ORDERED ALPHABETICALLY BY EMAIL STARTING WITH 'A'.

SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

--MQ2. LET'S INVITE THE ARTISTS WHO HAVE WRITTEN THE MOST ROCK MUSIC IN OUR DATASET.
--WRITE A QUERY THAT RETURNS ARTIST NAME AN TOTAL TRACK COUNT OF TOP 10 ROCK BANDS.

SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;

--MQ3. RETURN ALL THE TRACK NAMES THAT HAVE A SONG LENGTH LONGER THAN THE AVG SONG LENGTH.
-- RETURN THE NAME AND MS FOR EACH TRACK.
--ORDER BY THE SONG LENGTH WITH THE LONGEST SONG LISTED FIRST

SELECT track.name , milliseconds
FROM track
WHERE milliseconds > (SELECT  AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC

--AQ1. FIND HOW MUCH AMT SPENT BY EACH CUSTOMER ON ARTISTS?
-- WRITE A QUERY TO RETURN CUSTOMER NAME, ARTIST NAME AND TOTAL SPNENT

WITH best_selling_artist AS (
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

/* AQ2. WE WANT TO FIND OUT THE MOST PPOPULAR MUSIC GENRE FOR EACH COUNTRY.
WE DETERMINE THE MOST POPULAR GENRE AS THE GENRE WITH THE HIGHEST AMOUNT OF PURCHASES.
WRITE A QUERY THAT RETURNS EACH COUNTRY ALONGWITH THE TOP GENRE.
FOR COUNTRIES WHERE THE MAX NUMBER OF PURCHASES IS SHARED RETURN ALL GENRES.*/

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

SELECT * FROM genre

/* AQ3. WRITE A QUERY THAT DETERMINES A CUSTOMER THAT HAS SPENT MOST IN MUSIC FOR EACH COUNTRY.
WRITE A QUERY THAT RETURNS THE COUNTRY ALONGWITH TOP CUSTOMER AND HOW MUCH THEY SPENT.
FOR COUNTRIES WHERE THE TOP AMOUNT SPENT IS SHARED, PROVIDE ALL CUSTOMERS WHO SPENT THIS AMOUNT*/

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1