-- 1.One-To-One Relationship
CREATE DATABASE table_relations; USE table_relations;
CREATE TABLE passports (
	passport_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	passport_number VARCHAR(50) NOT NULL
	);
CREATE TABLE persons (
	person_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	first_name VARCHAR(50) NOT NULL,
	salary DECIMAL(10,2),
	passport_id INT UNIQUE,
	CONSTRAINT fk_persons_passports FOREIGN KEY (passport_id) REFERENCES passports(passport_id)
);

INSERT INTO passports (passport_id,passport_number) VALUES (101,'N34FG21B'),(102,'K65LO4R7'),(103,'ZE657QP2');

INSERT INTO persons
VALUES (1,'Roberto',43300.00,102),(2,'Tom',56100.00,103),
(3,'Yana',60200.00,101);


-- 2.One-To-Mony-Relationship
CREATE TABLE manufacturers (
	manufacturer_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(30) NOT NULL,
	established_on DATE
);

CREATE TABLE models (
	model_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(30) NOT NULL,
	manufacturer_id INT,
	CONSTRAINT fk_models_manufacturers
	FOREIGN KEY (manufacturer_id)
	REFERENCES manufacturers(manufacturer_id)
);

INSERT INTO manufacturers
VALUES (1,'BMW','1916-03-01'),
		 (2,'Tesla','2003-01-01'),
		 (3,'Lada','1966-05-01');

INSERT INTO models
VALUES 
	(101,'X1',1),
	(102,'i6',1),
	(103,'Model S',2),
	(104,'Model X',2),
	(105,'Model 3',2),
	(106,'Nova',3);

-- 3.Many-To-Many Relationship
CREATE TABLE students(
	student_id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	name VARCHAR(30)
);


CREATE TABLE exams(
	exam_id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	name VARCHAR(30)
);

CREATE TABLE students_exams(
	student_id INT,
	exam_id INT,
	
	CONSTRAINT pk_students_exams
	PRIMARY KEY(student_id,exam_id),
	
	CONSTRAINT fk_students_exams_students
	FOREIGN KEY(student_id)
	REFERENCES students(student_id),
	
	CONSTRAINT fk_students_exams_examstable_relationstable_relations
	FOREIGN KEY(exam_id)
	REFERENCES exams(exam_id));
	
INSERT INTO students 
VALUES  (1,'Mila'),(2,'Toni'),(3,'Ron');

INSERT INTO exams
VALUES (101,'Spring MVC'),(102,'Neo4j'),(103,'Oracle 11g');

INSERT INTO students_exams(student_id,exam_id) 
VALUES(1,101),(1,102),(2,101),(3,103),(2,102),(2,103);


-- 4.Self-Referencing
CREATE TABLE teachers(
	teacher_id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	name VARCHAR(30) NOT NULL,
	manager_id INT,
	CONSTRAINT fk_manager_id
	FOREIGN KEY(manager_id)
	REFERENCES teachers(teacher_id));

INSERT INTO teachers
VALUES   (101, 'John', NULL), 
		   (105, 'Mark', 101), 
			(106, 'Greta', 101), 
			(102, 'Maya', 106), 
			(103, 'Silvia', 106), 
			(104, 'Ted', 105);

-- 5.Online Store Database

CREATE TABLE cities (
	city_id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(50)
);

CREATE TABLE customers(
	customer_id INT(11)NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(50),
	birthday DATE,
	city_id INT(11),
	CONSTRAINT fk_customer_city
	FOREIGN KEY(city_id)
	REFERENCES cities(city_id)
);

CREATE TABLE orders (
	order_id INT(11)NOT NULL AUTO_INCREMENT PRIMARY KEY,
	customer_id INT(11),
	CONSTRAINT fk_order_customer
	FOREIGN KEY(customer_id)
	REFERENCES customers(customer_id)
);

CREATE TABLE item_types(
	item_type_id INT(11)NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(50)
);

CREATE TABLE items(
	item_id INT(11)NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	item_type_id INT(11) NOT NULL,
	CONSTRAINT fk_item_type
	FOREIGN KEY(item_type_id)
	REFERENCES item_types(item_type_id)
);

CREATE TABLE order_items(
	order_id INT(11) NOT NULL,
	item_id INT(11) NOT NULL,
	CONSTRAINT pk_order_items
	PRIMARY KEY(order_id,item_id),
	CONSTRAINT fk_order_id
	FOREIGN KEY(order_id)
	REFERENCES orders(order_id),
	CONSTRAINT fk_item_id
	FOREIGN KEY (item_id)
	REFERENCES items(item_id)
);


-- 6.University Database

CREATE TABLE subjects(
	subject_id INT(11)NOT NULL AUTO_INCREMENT PRIMARY KEY,
	subject_name VARCHAR(50) NOT NULL
);

CREATE TABLE majors(
	major_id INT(11)NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(50) NOT NULL
);

CREATE TABLE students(
	student_id INT(11)NOT NULL AUTO_INCREMENT PRIMARY KEY,
	student_number VARCHAR(12) NOT NULL,
	student_name VARCHAR(50) NOT NULL,
	major_id INT(11),
	CONSTRAINT fk_student_major
	FOREIGN KEY(major_id)
	REFERENCES majors(major_id)
);


CREATE TABLE payments(
	payment_id INT(11)NOT NULL AUTO_INCREMENT PRIMARY KEY,
	payment_date DATE,
	payment_amount DECIMAL(8,2),
	student_id INT(11),
	CONSTRAINT fk_payment_student
	FOREIGN KEY(student_id)
	REFERENCES students(student_id)
);

CREATE TABLE agenda(
	student_id INT(11) NOT NULL,
	subject_id INT(11) NOT NULL,
	
	CONSTRAINT pk_agenda
	PRIMARY KEY(student_id,subject_id),
	
	CONSTRAINT fk_student
	FOREIGN KEY(student_id)
	REFERENCES students(student_id),
	
	CONSTRAINT fk_subject
	FOREIGN KEY(subject_id)
	REFERENCES subjects(subject_id)
);

-- 9.SoftUni Design

use geography;

SELECT m.mountain_range,p.peak_name,p.elevation
FROM peaks AS p 
	JOIN mountains AS m
		ON p.mountain_id = m.id
			AND m.mountain_range = 'Rila'
ORDER BY p.elevation DESC;