-- 1.Section - Data Definition Language(DDL)

-- First Create New Database Manuell ( with utf_general_8)

USE the_nerd_herd;

CREATE TABLE locations(
	id INT PRIMARY KEY AUTO_INCREMENT,
	latitude FLOAT NOT NULL,
	longitude FLOAT NOT NULL
);

CREATE TABLE credentials(
	id INT PRIMARY KEY AUTO_INCREMENT,
	email VARCHAR(30) NOT NULL,
	password VARCHAR(20) NOT NULL
);

CREATE TABLE chats(
	id INT PRIMARY KEY AUTO_INCREMENT,
	title VARCHAR(32) NOT NULL,
	start_date DATE,
	is_active BIT
);

CREATE TABLE users(
	id INT PRIMARY KEY AUTO_INCREMENT,
	nickname VARCHAR(25) NOT NULL,
	gender CHAR(1),
	age INT NOT NULL,
	location_id INT,
	CONSTRAINT fk_location_id
	FOREIGN KEY(location_id) REFERENCES locations(id),
	credential_id INT UNIQUE,
	CONSTRAINT fk_credential_id
	FOREIGN KEY(credential_id) REFERENCES credentials(id)
);


CREATE TABLE messages(
	id INT PRIMARY KEY AUTO_INCREMENT,
	content VARCHAR(200) NOT NULL,
	sent_on DATE,
	chat_id INT,
	CONSTRAINT fk_chat_id
	FOREIGN KEY(chat_id) REFERENCES chats(id),
	user_id INT,
	CONSTRAINT fk_user_id_m
	FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE TABLE users_chats(
	user_id INT UNIQUE,
	CONSTRAINT fk_uc_user_id
	FOREIGN KEY (user_id) REFERENCES users(id),
	chat_id INT UNIQUE,
	CONSTRAINT fk_uc_chat_id
	FOREIGN KEY(chat_id) REFERENCES chats(id)
);

-- 2.Section - Data Manipulation Language(DML)

-- If the data cannot be inserted, use for start 
-> SET FOREIGN_KEY_CHECKS = 0; 
-> and on the end SET FOREIGN_KEY_CHECKS = 1;

-- 02.Insert

INSERT INTO `messages`(`content`, `sent_on`, `chat_id`, `user_id`)

SELECT 
CONCAT(`u`.age, '-', `u`.gender, '-', `l`.latitude, '-', `l`.longitude) AS `content`,
'2016-12-15' AS `sent_on`,
	(CASE
		WHEN `u`.gender = 'M' THEN ROUND(POW(`u`.age / 18, 3), 0)
		WHEN `u`.gender = 'F' THEN CEIL(SQRT(`u`.age * 2))
	END) AS `chat_id`,
`u`.id AS `user_id`
FROM `users` AS `u`
JOIN `locations` AS `l` ON `u`.location_id = `l`.id	
WHERE `u`.id >= 10 AND `u`.id <= 20;

-- 3.Update

UPDATE `chats` AS `c`
JOIN `messages` AS `m` ON `m`.chat_id = `c`.id AND `sent_on` < `start_date`
SET `c`.start_date = `m`.sent_on

-- 4.Delete

DELETE `l`
	FROM `locations` AS `l`
	LEFT JOIN `users` AS `u` ON `u`.location_id = `l`.id
	WHERE `u`.id IS NULL;


/* After Section 2 I've to DROP and Reload the DATABASE new */
-- 5.Age Range

SELECT `nickname`, `gender` , `age`
FROM `user` AS `u`
WHERE `u`.age >= 22 AND `u`.age <= 37
ORDER BY `u`.id ASC;

-- 6.Messages

SELECT `content`, `sent_on`
FROM `messages` AS `m`
WHERE `sent_on` > '2014-05-12' AND `u`.content LIKE '%just%'
ORDER BY `m`.id DESC;

-- 7.Chats

SELECT `title`, `is_active`
FROM `chats` AS `c`
WHERE (`is_active` = 0 AND CHAR_LENGTH(`c`.title) < 5)
OR SUBSTRING(`title`, 3, 2) = 'tl'
ORDER BY `c`.title DESC;

-- 8.Chat Messages

SELECT `c`.id, `c`.title, `m`.id
FROM `chats` AS `c`
JOIN `messages` AS `m` ON `m`.chat_id = `c`.id
WHERE `m`.sent_on < '2012-03-26' AND SUBSTRING(`c`.title, -1, 1) = 'x'
ORDER BY `c`.id, `m`.id;

-- 9.Message Count

SELECT `c`.id, COUNT(`m`.id) AS `total_messages`
FROM `chats` AS `c`
JOIN `messages` AS `m` ON `m`.chat_id = `c`.id AND `m`.id < 90
GROUP BY `c`.id
ORDER BY `total_messages` DESC, c.id
LIMIT 5;

-- 10.Credentials

SELECT `nickname`, `email`, `password`
FROM `users` AS `u`
JOIN `credentials` AS `c` ON `u`.credential_id = `c`.id
WHERE SUBSTRING(`email`, -5, 5) = 'co.uk' /* WHERE `email` LIKE '%co.uk' */
ORDER BY `email` ASC;

-- 11.Locations

SELECT `id`, `nickname`, `age`
FROM `users` AS `u`
WHERE `location_id` IS NULL
ORDER BY `id`;

-- 12.Left Users

SELECT `m`.id, `m`.chat_id, `m`.user_id
FROM `messages` AS `m`
	LEFT JOIN `users_chats` AS `uc` ON `uc`.user_id = `m`.id 
	AND `uc`.chat_id = `m`.chat_id
WHERE `uc`.user_id IS NULL AND `m`.chat_id = 17
ORDER BY `m`.id DESC

-- 13.Users In Bulgaria

SELECT `nickname`, `c`.title, `latitude`, `longitude`
FROM `users` AS `u`
JOIN `locations` AS `l` ON `l`.id = `u`.location_id
JOIN `users_chats` AS `uc` ON `uc`.user_id = `u`.id
JOIN `chats` AS `c` ON `c`.id = `uc`.chat_id
WHERE `latitude` >= 41.139999 AND `latitude` <= 44.12999
	AND `longitude` BETWEEN 22.209999 AND 28.35999
ORDER BY `c`.title;

-- 14.Last Chat

SELECT `c`.title, `m`.content
FROM `chats` AS `c`
LEFT JOIN `messages` AS `m` ON `c`.id = `m`.chat_id
WHERE `c`.start_date = (SELECT MAX(`c`.start_date) FROM `chats` AS `c`)
ORDER BY `m`.sent_on, `m`.id

-- Section 4 - Programmability

-- 15.Radians

DELIMITER $$

DROP FUNCTION IF EXISTS udf_get_radians;
CREATE FUNCTION udf_get_radians(`degrees` FLOAT)
RETURNS FLOAT
BEGIN
	return (`degrees` * PI()) / 180;
END $$

SELECT udf_get_radians(22.12);

-- 16.Change Password
DELIMITER $$

DROP PROCEDURE IF EXISTS udp_change_password;
CREATE PROCEDURE udp_change_password(`user_email` VARCHAR(30), `new_password` VARCHAR(20))
BEGIN
	IF (SELECT `id` FROM `credentials` WHERE `email` = `user_email`) IS NULL THEN
	SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'The email does\'t exist!';
	ELSE
		UPDATE `credentials` SET `password` = `new_password` WHERE `email` = `user_email`;
	END IF;
END $$

CALL udp_change_password('wkelly21@hud.gov', 'asdasd');


-- 17.Send Message

DELIMITER $$

DROP PROCEDURE IF EXISTS udp_send_message;
CREATE PROCEDURE udp_send_message(`u_id` INT, `c_id` INT, `chat_msg` VARCHAR(200))
BEGIN
	IF (SELECT `user_id` FROM `users_chats` 
	WHERE `user_id` = `u_id` AND `chat_id` = `c_id`) IS NULL THEN
	SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'There is no chat with that user!';
	ELSE
		INSERT INTO `messages` (`content`, `sent_on`, `chat_id`, `user_id`)
		VALUES (`chat_msg`, '2016-12-15', `c_id`, `u_id`);
	END IF;
END $$

CALL udp_change_password(1, 28, 'ala bala');


-- 18.Log Messages

DELIMITER $$

CREATE TRIGGER del_msg
AFTER DELETE
ON `messages`
FOR EACH ROW
BEGIN
	INSERT INTO `messages_log` VALUES (OLD.id, OLD.content, OLD.sent_on, OLD.chat_id, OLD.user_id);
END $$

-- 19.Delete Users

DELIMITER $$

CREATE TRIGGER del_usr
BEFORE DELETE
ON `users`
FOR EACH ROW
BEGIN
	DELETE FROM `credentials` WHERE `id` = OLD.credential_id;
	DELETE FROM `messages` WHERE `user_id` = OLD.id;
	DELETE FROM `users_chats` WHERE `user_id` = OLD.id;
END $$