/*--Find all the Information about the Departments-Table--*/

SELECT * FROM `departments`;

/*--Find all department's name--*/

SELECT name FROM `departments`
ORDER BY `department_id`;

/*--Find the salary of each employee--*/

SELECT `first_name`, `last_name`, `salary` FROM `employees`
ORDER BY `employee_id`;

/**--Find Full Name of each employee--*/

SELECT `first_name`, `last_name`, `middle_name` FROM `employees`
ORDER BY `employee_id`;

/*--Find Email addresses of Each Employee--*/

SELECT concat(first_name + '.' + last_name + '@softuni.bg') AS `full_email_address`
FROM `employees`;

/*--Find All Different Employee's Salaries--*/

SELECT `salary` FROM `employees`
ORDER BY `employee_id`;

/*--Find All Information about Employees--*/

SELECT * FROM `employees`
WHERE `job_title` = 'Sales Representative'
ORDER BY `employee_id`;

/*--Find Names of All Employees by salary in RANGE--*/

SELECT `first_name`, `last_name`, `job_title` FROM `employees`
WHERE `salary` BETWEEN 20000 AND 30000
ORDER BY `employee_id`;

/*--Find Names of All Employees--*/

SELECT concat(`first_name` + ' ' `middle_name` + ' ' `last_name`) AS `full_name`
WHERE `salary` IN (25000, 14000, 12500, 23600);

/*--Find All Employees Without Manager--*/

SELECT `first_name`, `last_name` FROM `employees`
WHERE `manager_id` IS NULL;

/*--Find All Employees with salary More Than 50000--*/

SELECT `first_name`, `last_name`, `salary` FROM `employees`
WHERE `salary` > 50000
ORDER BY `salary` DESC;

/*--Find 5 Best Paid Employees--*/

SELECT TOP(5) `first_name`, `last_name` FROM `employees`
ORDER BY `salary` DESC;

/*--Find ALl Employees Except Martketing--*/

SELECT `first_name`, `last_name` FROM `employees`
WHERE `department_id`!= 4; /* WHERE NOT (department_id = 4) */

/*--Sort Employees Table--*/

SELECT * FROM `employees`
ORDER BY `salary` DESC,
ORDER BY `first_name`,
ORDER BY `last_name` DESC,
ORDER BY `middle_name`;

/*--Create View Employees with Salaries--*/

CREATE VIEW `v_employees_salaries` AS
SELECT `first_name`, `last_name`, `salary` FROM `employees`;

/*--SELECT * FROM `v_employees_salaries`;--*/


/*--Create View Employees with Job Titles--*/

CREATE VIEW `v_employees_job_titles` AS
SELECT concat(`first_name` + ' ' + ISNULL(`middle_name`, '') + ' ' + `last_name`) AS `full_name`, `job_title` AS `Job Title`
FROM `employees`;

/**--SELECT * FROM `v_employees_job_titles`;--*/

/*--Distinct Job Titles--*/

DISTINCT `job_title` FROM `employees`;

/*--Find first 10 Started Projects--*/

SELECT TOP(10) * FROM `projects`
ORDER BY `start_date`, `name`;


/*--Last 7 Hired Employees--*/

SELECT TOP(7) `first_name`, `last_name`, `hire_date`
ORDER BY `hire_date` DESC;

/*--Increase Salaries--*/

UPDATE `employees`
SET `salary` *= 1.12;
WHERE `name` IN (`Engineering`, `Tool Design`, `Marketing`, `Information Services`);

SELECT `salary` FROM `employees`;

/*--All Mountain Peaks--* (database - geography)--*/

SELECT `peak_name` FROM `peaks`
ORDER BY `peak_name`;

/*--Biggest country by Population--* (database - geography)--*/

SELECT TOP(30) `country_name`,population FROM `countries`
ORDER BY `population` DESC, `country_name`;

/*--Countries and Currency (Euro / Not Euro)--*/

SELECT `country_name`, `country_code`, `currency` =
	CASE `currency_code`
		WHEN 'EUR' THEN 'EURO'
		ELSE 'Not Euro'
	END
FROM `countries`
ORDER BY `country_name`;
 
/*--All Diablo Charecters--*/

SELECT `name` FROM `characters`
ORDER BY `name`;