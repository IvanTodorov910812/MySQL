-- 1.Section: Data Definition Language(DDL)
DROP DATABASE `ams_db`;
CREATE DATABASE `ams_db`;
USE `ams_db`;

CREATE TABLE towns(
	town_id INT PRIMARY KEY AUTO_INCREMENT,
	town_name VARCHAR(30) NOT NULL
);

CREATE TABLE airports(
	airport_id INT PRIMARY KEY AUTO_INCREMENT,
	airport_name VARCHAR(50) NOT NULL,
	town_id INT,
	CONSTRAINT fk_airport_town_id
	FOREIGN KEY(`town_id`) REFERENCES towns(`town_id`)
);

CREATE TABLE airlines(
	airline_id INT PRIMARY KEY AUTO_INCREMENT,
	airline_name VARCHAR(30) NOT NULL,
	nationality VARCHAR(30) NOT NULL,
	rating INT DEFAULT 0	
);

CREATE TABLE customers(
	customer_id INT PRIMARY KEY AUTO_INCREMENT,
	first_name VARCHAR(20) NOT NULL,
	last_name VARCHAR(20) NOT NULL,
	date_of_birth DATE NOT NULL,
	gender VARCHAR(1),
	home_town_id INT,
	CONSTRAINT fk_c_home_town_id
	FOREIGN KEY(`home_town_id`) REFERENCES towns(`town_id`)
);

CREATE TABLE flights(
	flight_id INT PRIMARY KEY AUTO_INCREMENT,
	departure_time DATETIME NOT NULL,
	arrival_time DATETIME NOT NULL,
	status VARCHAR(9),
	origin_airport_id INT,
	CONSTRAINT fk_flights_origin_airport_id
	FOREIGN KEY(`origin_airport_id`) REFERENCES airports(`airport_id`),
	destination_airport_id INT,
	CONSTRAINT fk_destination_id
	FOREIGN KEY(`destination_airport_id`) REFERENCES airports(`airport_id`),
	airline_id INT,
	CONSTRAINT fk_airline_id
	FOREIGN KEY(`airline_id`) REFERENCES airlines(`airline_id`)
);

CREATE TABLE tickets(
	ticket_id INT PRIMARY KEY AUTO_INCREMENT,
	price DECIMAL(8,2) NOT NULL,
	class VARCHAR(6) NOT NULL,
	seat VARCHAR(5) NOT NULL,
	customer_id INT,
	CONSTRAINT fk_customer_id
	FOREIGN KEY(`customer_id`) REFERENCES customers(`customer_id`),
	flight_id INT,
	CONSTRAINT fk_flight_id
	FOREIGN KEY(`flight_id`) REFERENCES flights(`flight_id`)
);

-- 2.Section: Data Manipulation Language(DML)

-- 02.Data Insertion

INSERT INTO `flights`(`departure_time`, `arrival_time`, `status`, 
`origin_airport_id`, `destination_airport_id`, `airline_id`)
SELECT '2017-06-19 14:00:00' AS `departure_time`,
	'2017-06-21 11:00:00' AS `arrival_time`,
	(CASE
		WHEN a.airline_id % 4 = 0 THEN 'Departing'
		WHEN a.airline_id % 4 = 1 THEN 'Delaved'
		WHEN a.airline_id % 4 = 2 THEN 'Arrived'
		WHEN a.airline_id % 4 = 3 THEN 'Canceled'
	END) AS `status`,
	CEIL(SQRT(CHAR_LENGTH(a.`airline_name`))) AS `origin_airport_id`,
	CEIL(SQRT(CHAR_LENGTH(a.`nationality`))) AS `destination_airport_id`,
	`airline_id` AS `airline_id`
	FROM `airlines` AS a
	WHERE `airline_id` BETWEEN  1 and 10;

-- 03.Update Arrived Flights

UPDATE `flights`
SET airline_id = 1
WHERE `status` = 'Arrived';

-- 04.Update Tickets

UPDATE tickets AS t
JOIN `flights` AS f ON `t`.flight_id = `f`.flight_id
JOIN `airlines` AS a ON `f`.airline_id = `a`.airline_id
SET price = price * 0.5 + price
WHERE `a`.rating =
(SELECT MAX(`rating`) FROM `airlines`);

-- 05.Tickets

SELECT `ticket_id`, `price`, `class` , `seat`
FROM tickets AS t
ORDER BY `ticket_id`;

-- 06.Customers

SELECT `customer_id`, CONCAT(`first_name`, ' ', `last_name`) AS `full_name` , `gender`
FROM `customers` AS c
ORDER BY `full_name`, `customer_id` ASC;

-- 07.Flights

SELECT `flight_id`, `depature_time`, `arrival_time`
FROM flights AS f
WHERE `f`.status = 'Delayed'
ORDER BY f.`flight_id` ASC;

-- 08.Top 5 Airlines

SELECT `airline_id`, `airline_name`, `nationality`, `rating`
FROM `airlines` AS a
WHERE (SELECT COUNT(flight_id) FROM `flights` AS f WHERE f.airline_id = a.airline_id) > 0
ORDER BY `a`.rating DESC
LIMIT 5;

-- 09. 'First Class' Tickets

SELECT t.`ticket_id`, a.`airport_name`, 
CONCAT(`first_name`, ' ', `last_name`) AS `full_name` 
FROM tickets AS t
	JOIN `flights` AS f ON `t`.flight_id = `f`.flight_id
	JOIN `airports` AS a ON `f`.destination_airport_id = `a`.airport_id
	JOIN `customers` AS c ON `t`.customer_id = `c`.customer_id
	WHERE `t`.price < 5000 AND `t`.class = 'First'
ORDER BY `t`.ticket_id ASC;

-- 10.Home Town Customers

SELECT DISTINCT c.`customer_id`,
CONCAT(c.`first_name`, ' ', c.`last_name`) AS `full_name`,
t.`town_name` FROM `customers` AS c
	JOIN `towns` AS t ON `c`.home_town_id = `t`.town_id
	JOIN `tickets` AS ti ON `ti`.customer_id = `c`.customer_id
	JOIN `flights` AS f ON `ti`.flight_id = `f`.flight_id
	JOIN `airports` AS a ON `a`.airport_id = `f`.origin_airport_id
	WHERE `f`.status = 'Departing' AND `a`.town_id = `c`.home_town_id
ORDER BY `c`.customer_id ASC;

-- 11.Flying Customers

SELECT DISTINCT `c`.customer_id,
CONCAT(`c`.first_name, ' ', `c`.last_name) AS `full_name`,
TIMESTAMPDIFF(YEAR, `c`.date_of_birth, '2016-12-31') AS `age`
FROM `customers` AS c
	JOIN `tickets` AS t ON `t`.customer_id = `c`.customer_id
	JOIN `flights` AS f ON `f`.flight_id = `t`.flight_id
WHERE `f`.status = 'Departing'
ORDER BY `age` ASC, `customer_id` ASC;

-- 12.Delayed Customers

SELECT DISTINCT `c`.customer_id,
CONCAT(`c`.first_name, ' ', `c`.last_name) AS `full_name`,
`price`, `airport_name` FROM `customers` AS c
	JOIN `tickets` AS t ON `t`.customer_id = `c`.customer_id
	JOIN `flights` AS f ON `t`.flight_id = `f`.flight_id
	JOIN `airports` AS a ON `f`.destination_airport_id = `a`.airport_id
WHERE `f`.status = 'Delayed'
ORDER BY `t`.price DESC, `c`.customer_id ASC
LIMIT 3;

-- 13.Last Departing Flights

SELECT `flight_id`, `departure_time`, `arrival_time`, `o`.airport_name AS `origin`, `d`.airport_name AS `destination`
FROM `flights` AS f
	JOIN `airports` AS o ON `o`.airport_id = `f`.origin_airport_id
	JOIN `airports` AS d ON `d`.airport_id = `f`.destination_airport_id 
WHERE `f`.status = 'Departing'
ORDER BY `f`.departure_time ASC, `flight_id` ASC
LIMIT 5;

-- 14.Flying Children

SELECT DISTINCT `c`.customer_id, 
CONCAT(`c`.first_name, ' ', `c`.last_name), TIMESTAMPDIFF(YEAR, `c`.date_of_birth, '2016-12-31') AS `age`
FROM `customers` AS c
	JOIN `tickets` AS t ON t.customer_id = c.customer_id
	JOIN `flights` AS f ON t.flight_id = f.flight_id
WHERE `f`.status = 'Arrived' AND TIMESTAMPDIFF(YEAR, `c`.date_of_birth, '2016-12-31') < 21
ORDER BY `age` DESC, `customer_id` ASC; 

-- 15.Airports and Passengers

SELECT airport_id, airport_name, COUNT(ticket_id) AS `passengers`
FROM airports AS a
	JOIN `flights` AS f ON `f`.origin_airport_id = a.airport_id
	JOIN `tickets` AS t ON `t`.flight_id = `f`.flight_id
WHERE `f`.status = 'Departing'
GROUP BY airport_id, airport_name; 
ORDER BY airport_id ASC;


-- 4.Section Programmability (The new Tables download from judge)

-- 16.Submit Review

DELIMITER $$
CREATE PROCEDURE udp_submit_review(customer_id INT, review_content VARCHAR(255),
review_grade INT, airline_name VARCHAR(30)) 
BEGIN
	DECLARE airline_id INT;
	SET airline_id := (SELECT a.airline_id FROM airlines AS a WHERE a.airline_name = airline_name);
	IF(airline_id IS NULL) THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Airline does not exist.';
	END IF;
	INSERT INTO customer_reviews(review_content, review_grade, airline_id, customer_id) 
	VALUES(review_content, review_grade, airline_id, customer_id);
END $$

-- 17.Purchase Ticket ( IF i have to make some operation with Money, *Transaction*)

DELIMITER $$
CREATE PROCEDURE udp_purchase_ticket(customer_id INT, flight_id INT,
ticket_price DECIMAL(8,2), class VARCHAR(6), seat VARCHAR(5))
BEGIN
	DECLARE customer_balance DECIMAL;
	SET customer_balance := (SELECT cba.balance 
	FROM customer_bank_accounts AS cba WHERE cba.customer_id = customer_id);
	START TRANSACTION;
		IF(customer_balance < ticket_price) THEN
		ROLLBACK;
	END IF;
	UPDATE customer_bank_accounts
	SET balance = balance - ticket_price;
	INSERT INTO tickets(price, class, seat, customer_id, flight_id)
	VALUES(ticket_price, class, seat, customer_id, flight_id);
	COMMIT;

END $$

-- 18.Update Trigger

CREATE TRIGGER t_updated_arrivals
ON UPDATE flights
FOR EACH ROW
BEGIN 
	DECLARE passengers INT;
	SET passengers := (SELECT COUNT(ticket_id) 
	FROM tickets AS t
		JOIN flights AS f On )
	INSERT INTO arrived_flights(flight_id, arrival_time, origin, destination, passengers)
	VALUES(new.fligth_id, new.arrival_time, new.origin, new.destination) 
END