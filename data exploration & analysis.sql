-- data exploration & analysis


-- listings table

-- looking at the first few rows
SELECT *
FROM listings
LIMIT 10;

-- checking for null values
SELECT
    COUNT(*) AS total_rows,
    COUNT(id) AS id_count,
    COUNT(name) AS name_count,
    COUNT(host_id) AS host_id_count,
    COUNT(host_name) AS host_name_count,
    COUNT(neighbourhood_group) AS neighbourhood_group_count,
    COUNT(neighbourhood) AS neighbourhood_count,
    COUNT(latitude) AS latitude_count,
    COUNT(longitude) AS longitude_count,
    COUNT(room_type) AS room_type_count,
    COUNT(price) AS price_count,
    COUNT(minimum_nights) AS minimum_nights_count,
    COUNT(number_of_reviews) AS number_of_reviews_count,
    COUNT(last_review) AS last_review_count,
    COUNT(reviews_per_month) AS reviews_per_month_count,
    COUNT(calculated_host_listings_count) AS calculated_host_listings_count,
    COUNT(availability_365) AS availability_365_count
FROM listings;

-- some basic statistics on price column
SELECT
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    AVG(price) AS avg_price
FROM listings;

-- stats on number of reviews column
SELECT
    MIN(number_of_reviews) AS min_reviews,
    MAX(number_of_reviews) AS max_reviews,
    AVG(number_of_reviews) AS avg_reviews
FROM listings;

-- distribution of room types
SELECT
    room_type, 
    COUNT(*) AS count
FROM listings
GROUP BY room_type 
ORDER BY count DESC;

-- average price by room type, ranked
SELECT
    room_type,
    AVG(price) AS avg_price,
    RANK() OVER (ORDER BY AVG(price) DESC) AS price_rank
FROM
    listings
GROUP BY
    room_type;

-- hosts with the most amount of listings
SELECT
    host_name,
    COUNT(CASE WHEN room_type = 'Entire home/apt' THEN 1 ELSE NULL END) AS entire_home_apt,
    COUNT(CASE WHEN room_type = 'Private room' THEN 1 ELSE NULL END) AS private_rooms,
    COUNT(CASE WHEN room_type = 'Shared room' THEN 1 ELSE NULL END) AS shared_rooms,
    COUNT(CASE WHEN room_type = 'Hotel room' THEN 1 ELSE NULL END) AS hotel_rooms,
    COUNT(*) AS total_listings
FROM listings
GROUP BY host_name
ORDER BY total_listings DESC;

-- location analysis, which boroughs have the most Airbnbs available?
SELECT
    neighbourhood_group AS borough, 
    COUNT(*) AS count
FROM listings
GROUP BY neighbourhood_group
ORDER BY count DESC;

-- average price of listings in each borough
SELECT
    neighbourhood_group AS borough, 
    AVG(price) AS avg_price
FROM listings
GROUP BY neighbourhood_group
ORDER BY avg_price DESC;

-- count of Airbnbs available vs average price of listings, is there a relation between number of Airbnbs listed and the average price in each borough?
SELECT
    neighbourhood_group AS borough,
	COUNT(*) AS count,
    AVG(price) AS avg_price
FROM listings
GROUP BY neighbourhood_group
ORDER BY avg_price DESC, count DESC;

-- neighborhoods with the highest average price
SELECT
    neighbourhood_group AS borough,
	neighbourhood,
    AVG(price) AS avg_price
FROM listings
WHERE price IS NOT NULL
GROUP BY neighbourhood_group, neighbourhood
ORDER BY avg_price DESC;

-- most expensive listings in each neighborhood, ranked
SELECT id,
       name, 
       neighbourhood_group,
       neighbourhood,
       price,
       RANK() OVER (PARTITION BY neighbourhood_group, neighbourhood ORDER BY price DESC) AS price_rank
FROM listings
WHERE price IS NOT NULL;

-- reviews analysis, listings with the most reviews per month
SELECT
    id,
    name,
	neighbourhood_group,
	neighbourhood,
    price,
    number_of_reviews,
    reviews_per_month
FROM listings
WHERE reviews_per_month > 4
ORDER BY reviews_per_month DESC;

-- listings with availability less than 100 in the next year, i.e. highly booked Airbnbs
SELECT
    id,
    name,
    neighbourhood_group,
    neighbourhood,
    room_type,
    price,
    availability_365,
	number_of_reviews,
    reviews_per_month
FROM listings
WHERE availability_365 < 100
ORDER BY availability_365 DESC;


-- reviews table

-- looking at the first few rows with additional information from the listings table
SELECT
    r.listing_id,
	r.date,
    l.name,
	l.neighbourhood_group,
    l.neighbourhood,
    l.room_type
FROM reviews r
JOIN listings l ON r.listing_id = l.id
LIMIT 100;

-- Airbnbs with the most reviews
SELECT
    r.listing_id,
    l.name,
    COUNT(*) AS review_count
FROM reviews r
JOIN listings l ON r.listing_id = l.id
GROUP BY r.listing_id, l.name
ORDER BY review_count DESC
LIMIT 100;

-- review activity over time by room type
SELECT
    DATE_TRUNC('month', r.date) AS month,
    l.room_type,
    COUNT(*) AS review_count
FROM reviews r
JOIN listings l ON r.listing_id = l.id
GROUP BY month, l.room_type
ORDER BY month;

-- most recent reviews
SELECT
    r.listing_id,
    l.name,
	l.neighbourhood_group,
    l.neighbourhood,
    MAX(r.date) AS last_review_date
FROM reviews r
JOIN listings l ON r.listing_id = l.id
GROUP BY r.listing_id, l.name, l.neighbourhood_group, l.neighbourhood
ORDER BY last_review_date DESC
LIMIT 100;

-- Airbnbs with the most reviews in the last few months, along with their price range
SELECT
    r.listing_id, 
    l.name, 
    l.price,
    COUNT(*) AS recent_review_count
FROM reviews r
JOIN listings l ON r.listing_id = l.id
WHERE r.date > CURRENT_DATE - INTERVAL '3 months'
GROUP BY r.listing_id, l.name, l.price
ORDER BY recent_review_count DESC
LIMIT 100;

-- average number of reviews per room type
SELECT
    l.room_type, 
    AVG(sub.review_count) AS avg_reviews
FROM (
    SELECT 
        r.listing_id, 
        COUNT(*) AS review_count
    FROM reviews r
    GROUP BY r.listing_id
) AS sub
JOIN listings l ON sub.listing_id = l.id
GROUP BY l.room_type;

-- running total of reviews for each listing
SELECT DISTINCT
    l.id AS listing_id,
    l.name AS listing_name,
    COUNT(r.date) OVER(PARTITION BY l.id) AS total_reviews
FROM
    listings l
JOIN
    reviews r ON l.id = r.listing_id
ORDER BY l.id;

-- using a subquery
WITH LatestReview AS (
    SELECT
        l.id AS listing_id,
        l.name AS listing_name,
        COUNT(r.date) AS total_reviews
    FROM listings l
    JOIN reviews r ON l.id = r.listing_id
    GROUP BY l.id, l.name
)
SELECT
    listing_id,
    listing_name,
    total_reviews
FROM LatestReview
ORDER BY listing_id;


-- neighbourhoods table

-- looking at the first few rows
SELECT *
FROM neighbourhoods
LIMIT 20;

-- top neighbourhoods by number of listings available
SELECT
    n.neighbourhood, 
    COUNT(l.id) AS listings_count
FROM neighbourhoods n
JOIN listings l ON n.neighbourhood = l.neighbourhood
GROUP BY n.neighbourhood
ORDER BY listings_count DESC;

-- top neighborhoods by number of reviews
SELECT
    n.neighbourhood, 
    COUNT(r.listing_id) AS total_reviews
FROM neighbourhoods n
JOIN listings l ON n.neighbourhood = l.neighbourhood
JOIN reviews r ON l.id = r.listing_id
GROUP BY n.neighbourhood
ORDER BY total_reviews DESC
LIMIT 20;


-- calendar table

-- looking at the first few rows
SELECT *
FROM calendar
LIMIT 20;

-- average price by month
SELECT
    DATE_TRUNC('month', date) AS month,
    AVG(price) AS avg_price
FROM calendar
GROUP BY month
ORDER BY month;

-- availability by month for the next year
SELECT
    DATE_TRUNC('month', date) AS month,
    SUM(CASE WHEN available = 't' THEN 1 ELSE 0 END) AS available_days
FROM Calendar
GROUP BY month
ORDER BY month;