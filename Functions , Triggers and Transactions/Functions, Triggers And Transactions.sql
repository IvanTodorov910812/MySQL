-- 1.Employees with Salary Above 35000
DELIMITER $$
CREATE PROCEDURE usp_get_employees_salary_above_35000()
	BEGIN
		SELECT e.first_name,e.last_name
		FROM employees AS e 
		WHERE e.salary > 35000
		ORDER BY e.first_name,e.last_name;
	END$$
	
CALL usp_get_employees_salary_above_35000();

-- 2.Employees with Salary Above Number

DELIMITER $$
CREATE PROCEDURE usp_get_employees_salary_above(min_salary DECIMAL(19,4))
	BEGIN 
		SELECT e.first_name,e.last_name
		FROM employees AS e
		WHERE e.salary >= min_salary
		ORDER BY e.first_name,e.last_name;
	END$$

CALL usp_get_employees_salary_above(30000);

-- 3.Town Names Starting With
DROP PROCEDURE usp_get_towns_starting_with;
DELIMITER $$
CREATE PROCEDURE usp_get_towns_starting_with(part VARCHAR(10))
BEGIN
	SELECT t.name AS 'town_name'
	FROM towns AS t
	WHERE t.name LIKE CONCAT(part,'%')
	ORDER BY t.name;
END$$

CALL usp_get_towns_starting_with('Be');


-- 4.Employees From Town

DELIMITER $$
CREATE PROCEDURE usp_get_employees_from_town(town VARCHAR(20))
BEGIN 
	SELECT e.first_name,e.last_name
	FROM employees AS e 
	INNER JOIN addresses AS a
	ON e.address_id = a.address_id
	INNER JOIN towns AS t
	ON a.town_id = t.town_id
	AND t.name = town
	ORDER BY e.first_name,e.last_name;
END$$

CALL usp_get_employees_from_town('Sofia');
DROP FUNCTION udf_get_salary_level;

-- 5.Salary Level Function
DELIMITER $$
CREATE FUNCTION udf_get_salary_level(salary DECIMAL(19,4))
RETURNS VARCHAR(20)
BEGIN 
	DECLARE result VARCHAR(20);
	IF(salary< 30000) 
		THEN SET result := 'Low';
	ELSEIF(salary <= 50000)
		THEN  SET result := 'Average';
	ELSE
		SET result := 'High';
	END IF;
	RETURN result;
END$$
DELIMITER ;

SELECT e.salary,udf_get_salary_level(e.salary) AS 'salary_level'
FROM employees AS e;


-- 6.Employees by Salary Level
DROP PROCEDURE usp_get_employees_by_salary_level;
DELIMITER $$
CREATE PROCEDURE usp_get_employees_by_salary_level(salary_level_input VARCHAR(10))
	BEGIN
		SELECT a.first_name,a.last_name
		FROM employees as a
		INNER JOIN
			(SELECT e.employee_id,
				CASE 
					WHEN e.salary< 30000 THEN 'Low'
					WHEN e.salary < 50000 THEN 'Average'
					WHEN e.salary >50000 THEN 'High'
					END AS 'salary_level' 
			FROM employees AS e) AS b
			ON a.employee_id = b.employee_id
			AND b.salary_level = salary_level_input
			ORDER BY a.first_name DESC,a.last_name DESC;
	END$$

CALL usp_get_employees_by_salary_level('High');

-- 7.Define Function
DROP FUNCTION ufn_is_word_comprised;
DELIMITER $$
CREATE FUNCTION ufn_is_word_comprised(set_of_chars VARCHAR(30), word VARCHAR(200))
RETURNS BOOL
BEGIN
	DECLARE len INT DEFAULT CHAR_LENGTH(word);
	DECLARE idx INT DEFAULT 1;
		
	WHILE idx <= len
		DO
			IF LOCATE(SUBSTRING(word,idx,1),set_of_chars) < 1
			THEN 
				RETURN FALSE;
			END IF;
			SET idx = idx + 1;
	END WHILE;
	RETURN TRUE;
END;$$


-- 8.Some Other Task

DELETE FROM employees_projects 
WHERE employees_projects.employee_id IN
	(SELECT e.employee_id  
		FROM employees AS e
		INNER JOIN departments AS d
		ON e.department_id = d.department_id
		AND d.name IN ("Production","Production Control")); 
        

UPDATE employees AS e
SET e.manager_id = NULL
WHERE e.department_id IN (SELECT d.department_id 
		 FROM departments AS d
		 WHERE d.name IN("Production","Production Control"));

ALTER TABLE departments 
MODIFY COLUMN manager_id INT NULL;

ALTER TABLE departments
DROP FOREIGN KEY fk_departments_employees;

ALTER TABLE employees
DROP FOREIGN KEY fk_employees_employees;

DELETE FROM employees 
 WHERE employees.department_id IN (
 		SELECT d.department_id 
		 FROM departments AS d
		 WHERE d.name IN("Production","Production Control"));
         
DELETE FROM departments 
WHERE departments.name IN ("Production","Production Control");

-- 9.Find Full Name

DELIMITER $$
CREATE PROCEDURE usp_get_holders_full_name()
BEGIN
	SELECT CONCAT(a.first_name,' ',a.last_name) AS 'full_name'
    FROM account_holders AS a
    ORDER BY `full_name`;
END$$

CALL usp_get_holders_full_name();

-- 10.People With Balance Higher Than
USE bank_db;

DROP PROCEDURE usp_get_holders_with_balance_higher_than;

DELIMITER $$
CREATE PROCEDURE usp_get_holders_with_balance_higher_than(min_balance DECIMAL(19,4))
BEGIN
	SELECT ah.first_name,ah.last_name
		FROM account_holders AS ah
		INNER JOIN 
		(SELECT a.id ,a.account_holder_id, SUM(a.balance) AS 'total_balance'
		FROM accounts AS a
		GROUP BY a.account_holder_id) AS a
		ON a.account_holder_id = ah.id
		AND a.total_balance > min_balance
		ORDER BY a.id;
END$$

CALL usp_get_holders_with_balance_higher_than(70000);

-- 11.Future Value Function

SELECT ROUND(0.00,0) AS 'BB';

DROP FUNCTION ufn_calculate_future_value;

DELIMITER $$
CREATE FUNCTION ufn_calculate_future_value(initial_sum DECIMAL(19,2), interest_rate DECIMAL(19,4), years INT)
RETURNS DECIMAL(19,2)
BEGIN
	DECLARE future_value DECIMAL(19,2);
	SET future_value := initial_sum * (POW((1 + interest_rate), years));
	RETURN future_value;
END$$
	
SELECT ufn_calculate_future_value(1000,0.1,5) AS 'output';

-- 12.Calculating Interest
DROP PROCEDURE usp_calculate_future_value_for_account;

DELIMITER $$
CREATE PROCEDURE usp_calculate_future_value_for_account(account_id INT,interest_rate DECIMAL(19,4))
BEGIN
	DECLARE future_value DECIMAL(19,4);
	DECLARE balance DECIMAL(19,4);
	
	SET balance := (SELECT a.balance FROM accounts AS a WHERE a.id = account_id);
	SET future_value := balance * (POW((1 + interest_rate), 5));
	
	SELECT a.id,ah.first_name,ah.last_name,a.balance, future_value
	FROM accounts AS a
	INNER JOIN account_holders AS ah
	ON a.account_holder_ibank_dbd = ah.id
	AND a.id = account_id;
END$$

CALL usp_calculate_future_value_for_account(1,0.1);


-- 13.Deposit Money
DELIMITER $$
CREATE PROCEDURE usp_deposit_money (account_id INT, money_amount DECIMAL(19,4))
BEGIN
	DECLARE balance DECIMAL(19,4);
	SET balance := (SELECT a.balance FROM accounts AS a WHERE a.id = account_id);

	START TRANSACTION;
	UPDATE accounts 
	SET accounts.balance = accounts.balance+money_amount
	WHERE accounts.id = account_id;	

  IF money_amount < 0
  THEN 
  	ROLLBACK;
  ELSE
 COMMIT;	
 END IF;
END$$

CALL usp_deposit_money(1,5000.50);

-- 14.Withdraw Money
DROP PROCEDURE usp_withdraw_money;

DELIMITER $$
CREATE PROCEDURE usp_withdraw_money(account_id INT, money_amount DECIMAL(19,4))
BEGIN
	DECLARE balance DECIMAL(19,4);
	SET balance := (SELECT a.balance FROM accounts AS a WHERE a.id = account_id);
	SET balance := balance - money_amount;
	START TRANSACTION;
			UPDATE accounts 
        	SET accounts.balance = accounts.balance-money_amount
	      WHERE accounts.id = account_id;

	IF money_amount < 0
	THEN ROLLBACK;
	ELSEIF balance < 0 
	THEN ROLLBACK;
	END IF;
	COMMIT;
END$$

CALL usp_withdraw_money(4,10.00);


-- 15.Money Transfer
DROP PROCEDURE usp_transfer_money;
DELIMITER $$
CREATE PROCEDURE usp_transfer_money(IN from_account_id INT,IN to_account_id INT ,IN amount DECIMAL(19,4))
BEGIN
	START TRANSACTION;
	UPDATE accounts 
	  	SET accounts.balance = accounts.balance-amount
		WHERE accounts.id = from_account_id;
		
		UPDATE accounts 
	  	SET accounts.balance = accounts.balance+amount
		WHERE accounts.id = to_account_id;
		
		IF((SELECT COUNT(*) FROM accounts AS a
		   WHERE a.id = from_account_id) != 1)
		   THEN ROLLBACK;
		   
		ELSEIF((SELECT COUNT(*) FROM accounts AS a
		   WHERE a.id = to_account_id) != 1)
		   THEN ROLLBACK;
		   
		ELSEIF from_account_id = to_account_id
			THEN ROLLBACK;
		ELSEIF amount <= 0 
			THEN ROLLBACK;
		ELSEIF((SELECT a.balance FROM accounts AS a WHERE a.id = from_account_id) < amount)
		THEN ROLLBACK;
	
		ELSE 
			COMMIT;
		END IF;

END$$ 

CALL usp_transfer_money(10,10,10);


-- 17.Log Accounts Trigger

CREATE TABLE logs(
	log_id INT AUTO_INCREMENT PRIMARY KEY,
	account_id INT,
	old_sum DECIMAL(19,4),
	new_sum DECIMAL(19,4)
);
DELIMITER $$
CREATE TRIGGER `after_accounts_update`
AFTER UPDATE
ON accounts
FOR EACH ROW
BEGIN 
	INSERT INTO logs(account_id, old_sum, new_sum)
	VALUES(old.id,old.balance,new.balance);
END$$


-- 18.Emails Trigger

CREATE TABLE logs(
	log_id INT AUTO_INCREMENT PRIMARY KEY,
	account_id INT,
	old_sum DECIMAL(19,4),
	new_sum DECIMAL(19,4)
);

CREATE TABLE notification_emails(
		id INT AUTO_INCREMENT PRIMARY KEY,
		recipient INT NOT NULL,
		subject VARCHAR(200), 
		body TEXT); 

UPDATE accounts
	SET balance = balance + 5000
WHERE id = 4;