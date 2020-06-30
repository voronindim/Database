--CREATE DATABASE services_db
--COLLATE Cyrillic_General_CI_AS


CREATE TABLE flat (
id_flat int NOT NULL IDENTITY,
id_owner int NOT NULL,
street nvarchar(50) NOT NULL,
house_number nvarchar(10) NOT NULL,
flat_number nvarchar(10) NOT NULL,
area int NOT NULL,
PRIMARY KEY(id_flat)
)
GO

CREATE TABLE owner (
id_owner int NOT NULL IDENTITY,
first_name nvarchar(20) NOT NULL,
last_name nvarchar(20) NOT NULL,
place_of_work nvarchar(50) NULL,
passport_data nvarchar(50) NOT NULL,
PRIMARY KEY(id_owner)
)
GO

CREATE TABLE service_in_flat (
id_service_in_flat int NOT NULL IDENTITY,
id_service_tariff int NOT NULL,
id_flat int NOT NULL,
start_date date NOT NULL,
end_date date NULL,
PRIMARY KEY(id_service_in_flat)
)
GO

CREATE TABLE service_tariff (
id_service_tariff int NOT NULL IDENTITY,
service_name nvarchar(20) NOT NULL,
price money NOT NULL,
unit nvarchar(20) NULL,
description nvarchar(100) NULL,
PRIMARY KEY(id_service_tariff)
)
GO

CREATE TABLE payment (
id_payment int NOT NULL IDENTITY,
id_service_in_flat int NOT NULL,
date datetime NOT NULL,
cost money NOT NULL,
PRIMARY KEY(id_payment)
)
GO

ALTER TABLE service_in_flat
ADD
FOREIGN KEY(id_service_tariff) REFERENCES service_tariff(id_service_tariff)
ON DELETE CASCADE

ALTER TABLE service_in_flat
ADD
FOREIGN KEY(id_flat) REFERENCES flat(id_flat)
ON DELETE CASCADE

ALTER TABLE flat
ADD
FOREIGN KEY(id_owner) REFERENCES owner(id_owner)
ON DELETE CASCADE

ALTER TABLE payment
ADD
FOREIGN KEY(id_service_in_flat) REFERENCES service_in_flat(id_service_in_flat)
ON DELETE CASCADE


---- 1. INSERT ----
-- 1. Без указания списка полей
INSERT INTO owner
VALUES (N'Александр', N'Королев', N'TravelLine', N'562897');

INSERT INTO owner
VALUES (N'Михаил', N'Воробьев', N'iSpring', N'432615');

INSERT INTO owner
VALUES (N'Виктор', N'Маслов', N'OmegaR', N'731954');

INSERT INTO flat
VALUES (1, N'Пушкина', N'8А', N'121', 100)

INSERT INTO flat
VALUES (1, N'Волкова', N'16', N'10Б', 60)

INSERT INTO flat
VALUES (1, N'Анциферова', N'82', N'36', 68)

INSERT INTO flat
VALUES (2, N'Пушкина', N'10', N'14', 50)

INSERT INTO service_tariff
VALUES (N'Вода', 25, N'куб.м.', NULL)


-- 2. С указанием списка полей
INSERT INTO flat (street, house_number, flat_number, area, id_owner)
VALUES (N'Строителей', N'24', N'9', 72, 2)

INSERT INTO service_in_flat (id_service_tariff, id_flat, start_date, end_date)
VALUES (1, 2, N'2015-10-15', NULL)

INSERT INTO service_in_flat (id_service_tariff, id_flat, start_date, end_date)
VALUES (1, 1, N'2018-04-12', NULL)

INSERT INTO service_in_flat (id_service_tariff, id_flat, start_date, end_date)
VALUES (1, 3, N'2010-11-12', N'2014-11-12')

-- 3. С чтением значения из другой таблицы
INSERT INTO owner (first_name, last_name, passport_data)
SELECT street, house_number, flat_number FROM flat


---- 2. DELETE ----
-- 1. Всех записей
DELETE service_tariff

-- 2. По условию
DELETE flat
WHERE 
	street = N'Пушкина';

-- 3. Очистить таблицу
TRUNCATE TABLE payment


---- 3. UPDATE ----
-- 1. Всех записей
UPDATE owner
SET place_of_work = N'Google'

-- 2. По условию обновляя один атрибут
UPDATE owner
SET  first_name = N'Алексей'
WHERE last_name = N'Королев';

-- 3. По условию обновляя несколько атрибутов
UPDATE flat 
SET area += 10, street = N'Анциферова'
WHERE id_owner = 1;


---- 4. SELECT ----
-- 1. С определенным набором извлекаемых атрибутов 
SELECT first_name, last_name FROM owner

-- 2. Со всеми атрибутами (SELECT * FROM...)
SELECT * FROM flat

-- 3. С условием по атрибуту (SELECT * FROM ... WHERE atr1 = "")
SELECT * FROM flat
WHERE area < 80


---- 5. SELECT ORDER BY + TOP (LIMIT) ----
-- 1. С сортировкой по возрастанию ASC + ограничение вывода количества записей
SELECT  * FROM flat
ORDER BY street ASC

-- 2. С сортировкой по убыванию DESC
SELECT * 
FROM flat
ORDER BY area DESC

-- 3. С сортировкой по двум атрибутам + ограничение вывода количества записей
SELECT TOP 4 * 
FROM flat
ORDER BY street, area

-- 4. С сортировкой по первому атрибуту, из списка извлекаемых
SELECT street, house_number, area
FROM flat
ORDER BY 1


---- 6. Работа с датами. ----
-- 1. WHERE по дате
SELECT *
FROM service_in_flat
WHERE start_date > N'2015-01-01'

-- 2. Извлечь из таблицы не всю дату, а только год. 
SELECT id_service_in_flat, id_flat, YEAR(start_date) AS start_date
FROM service_in_flat


---- 7. SELECT GROUP BY с функциями агрегации ----
-- 1. MIN
SELECT id_owner, MIN(area) AS area
FROM flat
GROUP BY id_owner

-- 2. MAX
SELECT id_owner, MAX(area) AS area
FROM flat
GROUP BY id_owner

-- 3. AVG
SELECT id_owner, AVG(area) AS area
FROM flat
GROUP BY id_owner

-- 4. SUM
SELECT id_owner, SUM(area) AS area
FROM flat
GROUP BY id_owner

-- 5. COUNT
SELECT id_owner, COUNT(*) AS number_of_flats
FROM flat
GROUP BY id_owner


---- 8. SELECT GROUP BY + HAVING ----
-- 1. Написать 3 разных запроса с использованием GROUP BY + HAVING
SELECT id_owner, MAX(area) AS area
FROM flat
GROUP BY id_owner
HAVING MAX(area) > 80

SELECT id_owner, COUNT(*) AS number_of_flats
FROM flat
GROUP BY id_owner
HAVING COUNT(*) < 3

SELECT id_owner, AVG(area) AS area
FROM flat
GROUP BY id_owner
HAVING AVG(area) > 60


---- 9. SELECT JOIN ----
-- 1. LEFT JOIN двух таблиц и WHERE по одному из атрибутов
SELECT * FROM flat 
LEFT JOIN owner ON flat.id_owner = owner.id_owner
WHERE flat.area > 50

-- 2. RIGHT JOIN. Получить такую же выборку, как и в 9.1
SELECT * FROM owner
RIGHT JOIN flat ON flat.id_owner = owner.id_owner
WHERE flat.area > 50

-- 3. LEFT JOIN трех таблиц + WHERE по атрибуту из каждой таблицы
SELECT * FROM owner
LEFT JOIN flat ON flat.id_owner = owner.id_owner
LEFT JOIN service_in_flat ON service_in_flat.id_flat = flat.id_flat
WHERE owner.place_of_work != N'OmegaR' AND flat.area > 60 AND service_in_flat.start_date > N'2015-01-01'

-- 4. FULL OUTER JOIN двух таблиц
SELECT * FROM owner 
FULL OUTER JOIN flat
ON owner.id_owner = flat.id_owner


---- 10. Подзапросы ----
-- 1. Написать запрос с WHERE IN (подзапрос)
SELECT * FROM owner
WHERE id_owner IN (SELECT id_owner FROM flat)

-- 2. Написать запрос SELECT atr1, atr2, (подзапрос) FROM ...
SELECT 
	first_name,
	last_name,
	(SELECT MAX(flat.area) FROM flat WHERE owner.id_owner = flat.id_owner GROUP BY id_owner) AS max_area
FROM owner

SELECT 
	first_name,
	last_name,
	(SELECT MAX(flat.area) FROM flat WHERE owner.id_owner = flat.id_owner GROUP BY id_owner) AS max_area
FROM owner