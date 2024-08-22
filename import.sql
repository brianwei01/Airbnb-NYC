-- import listings.csv

CREATE TABLE public."listings"(id bigint, name varchar(500), host_id int, host_name varchar(100), neighbourhood_group varchar(100), neighbourhood varchar(100), 
	latitude decimal, longitude decimal, room_type varchar(100), price int, minimum_nights int, number_of_reviews int, last_review date, 
	reviews_per_month decimal, calculated_host_listings_count int, availability_365 int, number_of_reviews_ltm int, license varchar(100))

COPY listings FROM 'C:\Users\Brian\OneDrive\Documents\Projects\Inside Airbnb NYC\listings.csv' DELIMITER ',' CSV HEADER;

SELECT *
FROM listings



-- import reviews.csv

CREATE TABLE public."reviews"(listing_id bigint, "date" date)

COPY reviews FROM 'C:\Users\Brian\OneDrive\Documents\Projects\Inside Airbnb NYC\reviews.csv' DELIMITER ',' CSV HEADER;

SELECT *
FROM reviews



-- import neighbourhoods.csv

CREATE TABLE public."neighbourhoods"(neighbourhood_group varchar(100), neighbourhood varchar(100))

COPY neighbourhoods FROM 'C:\Users\Brian\OneDrive\Documents\Projects\Inside Airbnb NYC\neighbourhoods.csv' DELIMITER ',' CSV HEADER;

SELECT *
FROM neighbourhoods



-- import calendar.csv

CREATE TABLE public."calendar"(listing_id bigint, "date" date, available boolean, price text, adjusted_price text, minimum_nights int, maximum_nights int)

COPY calendar FROM 'C:\Users\Brian\OneDrive\Documents\Projects\Inside Airbnb NYC\calendar.csv' DELIMITER ',' CSV HEADER;

-- clean price column
UPDATE calendar
SET price = REPLACE(price, '$', '')

UPDATE calendar
SET price = REPLACE(price, ',', '')

ALTER TABLE calendar ALTER COLUMN price TYPE decimal USING price::decimal

SELECT *
FROM calendar