USE grigotts;

-- 1. Record's Count
SELECT COUNT(*) FROM `wizzard_deposits`;

-- 2. Longest Magic Wand
SELECT MAX(`magic_wand_size`) AS `longest_magic_wand`
FROM `wizzard_deposits`;

-- 3. Longest Magic Group per Deposit Groups
SELECT `deposit_group`, MAX(`magic_wand_size`) AS `longest_magic_wand`
FROM `wizzard_deposits`
GROUP BY `deposit_group`
ORDER BY `longest_magic_wand` ASC, `deposit_group` ASC;

-- 4.Smallest Deposit Group per Magic Wand Size
SELECT `deposit_group`
FROM `wizzard_deposits`
GROUP BY `deposit_group`
ORDER BY AVG(`magic_wand_size`)
LIMIT 1;

-- 5.Deposits Sum
SELECT `deposit_group`, SUM(`deposit_amount`) AS `Total sum`
FROM `wizzard_deposits`
GROUP BY `deposit_group`
ORDER BY `Total sum`;

-- 6.Deposits Sum for Ollivander family
SELECT `deposit_group`, SUM(`deposit_amount`)  AS `Total Sum`
FROM `wizzard_deposits`
WHERE `magic_wand_creator` = 'Ollivander family'
GROUP BY `deposit_group`
ORDER BY `deposit_group` ASC;

-- 7.Deposits Filter
SELECT `deposit_group`, SUM(`deposit_amount`)  AS `Total Sum`
FROM `wizzard_deposits`
WHERE `magic_wand_creator` = 'Ollivander family'
GROUP BY `deposit_group`
HAVING `Total Sum` < 150000
ORDER BY `Total Sum` ASC;

-- 8.Deposit charge
SELECT `deposit_group`, `magic_wand_creator`, MIN(`deposit_charge`) 
FROM `wizzard_deposits`
GROUP BY `magic_wand_creator`, `deposit_group`
ORDER BY `magic_wand_creator` ASC, `deposit_group`;

-- 9.Age Groups
SELECT 

CASE
	WHEN `age` BETWEEN 0 and 10 THEN '[0-10]' 
	WHEN `age` BETWEEN 11 and 20 THEN '[11-20]'
	WHEN `age` BETWEEN 21 and 30 THEN '[21-30]'
	WHEN `age` BETWEEN 31 and 40 THEN '[31-40]' 
	WHEN `age` BETWEEN 41 and 50 THEN '[41-50]' 
	WHEN `age` BETWEEN 51 and 60 THEN '[51-60]'
	WHEN `age` > 60 THEN '[61+]'
END AS `age_group`,
COUNT(*) AS `wizzard_count`
FROM `wizzard_deposits`
GROUP BY `age_group`;

-- 11.Average Interest
SELECT w.deposit_group, w.is_deposit_expired, AVG(w.deposit_interest) AS 'average_interest'
FROM wizzard_deposits AS w
WHERE w.deposit_start_date > '1985-01-01'
GROUP BY w.deposit_group,w.is_deposit_expired
ORDER BY w.deposit_group DESC,w.is_deposit_expired ASC;

-- 12.Rich Wizzard, Poop Wizzard
SELECT sum(a.host_wizzard_deposit - a.guest_wizzard_deposit) as 'sum_difference' FROM
(SELECT w1.first_name AS 'host_wizzard', w1.deposit_amount AS 'host_wizzard_deposit',
 w2.first_name AS 'guest_wizzard', w2.deposit_amount AS 'guest_wizzard_deposit'
FROM wizzard_deposits AS w1, wizzard_deposits AS w2
WHERE w1.id +1 = w2.id) AS `a`;

use soft_uni;
-- 13.Employees Minimum Salaries

SELECT e.department_id, MIN(e.salary) as 'minimum_salary'
FROM employees AS e
WHERE e.department_id IN (2,5,7) AND e.hire_date > '2000-01-01'
GROUP BY e.department_id
ORDER BY e.department_id;


-- 14.Employees Average Salaries
CREATE TEMPORARY TABLE IF NOT EXISTS `emp` AS(
SELECT *
FROM `employees`
WHERE `salary` > 30000);
DELETE FROM `emp` WHERE `manager_id` = 42;
UPDATE `emp` SET `salary` = `salary` + 5000 WHERE `department_id` = 1;
SELECT `department_id`, AVG(`salary`) AS `avg_salary`
FROM `emp` 
GROUP BY `department_id`
ORDER BY `department_id`;

-- 15.Employees Maximum Salaries
SELECT e.department_id, MAX(e.salary) AS 'max_salary'
FROM employees AS e
GROUP BY e.department_id
HAVING `max_salary` NOT BETWEEN 30000 AND 70000;


-- 16.Employees Count Salaries
SELECT COUNT(*) AS 'count'
FROM employees AS e
WHERE e.manager_id IS NULL;

-- 17.3rd Highest Salary
SELECT e.department_id,MAX(e.salary) as 'third_highest_salary'
FROM employees AS e,
	(SELECT e.department_id,MAX(e.salary) as 'max'
	FROM employees AS e,
		(SELECT e.department_id, MAX(e.salary) as 'max'
		FROM employees AS e
		GROUP BY e.department_id) as max_1
	WHERE e.department_id = max_1.department_id
		AND e.salary < max_1.`max`
		GROUP BY e.department_id) as max_2
	WHERE e.department_id = max_2.department_id
	AND e.salary < max_2.`max`
GROUP BY e.department_id;


-- 18.Salary Challenge
SELECT `first_name`, `last_name`, `department_id`
FROM `employees` AS `e`
WHERE `salary` >= 
(SELECT AVG(`salary`) FROM `employees` AS `e1` WHERE`e1`.`department_id` = `e`.`department_id`)
ORDER BY `department_id`
LIMIT 10;

-- 19.Departments Total Salaries
SELECT `department_id`, SUM(`salary`) AS `total_salary`
FROM `employees`
GROUP BY `department_id`
ORDER BY `department_id`