CREATE DATABASE services_db
COLLATE Cyrillic_General_CI_AS


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

CREATE TABLE service (
id_service int NOT NULL IDENTITY,
name nvarchar(20) NOT NULL,
company nvarchar(20) NOT NULL,
PRIMARY KEY(id_service)
)
GO

CREATE TABLE service_in_flat (
id_service_in_flat int NOT NULL IDENTITY,
id_service int NOT NULL,
id_flat int NOT NULL,
start_date date NULL,
end_date date NULL,
PRIMARY KEY(id_service_in_flat)
)
GO

CREATE TABLE tariff (
id_tariff int NOT NULL IDENTITY,
id_service int NOT NULL,
price money NOT NULL,
unit nvarchar(20) NULL,
description nvarchar(100) NULL,
PRIMARY KEY(id_tariff)
)
GO

CREATE TABLE payment (
id_payment int NOT NULL IDENTITY,
id_service int NOT NULL,
date datetime NOT NULL,
cost money NOT NULL,
personal_account nvarchar(20) NULL,
PRIMARY KEY(id_payment)
)
GO

ALTER TABLE service_in_flat
ADD
FOREIGN KEY(id_service) REFERENCES service(id_service)
ON DELETE CASCADE

ALTER TABLE service_in_flat
ADD
FOREIGN KEY(id_flat) REFERENCES flat(id_flat)
ON DELETE CASCADE

ALTER TABLE flat
ADD
FOREIGN KEY(id_owner) REFERENCES owner(id_owner)
ON DELETE CASCADE

ALTER TABLE tariff
ADD
FOREIGN KEY(id_service) REFERENCES service(id_service)
ON DELETE CASCADE

ALTER TABLE payment
ADD
FOREIGN KEY(id_service) REFERENCES service(id_service)
ON DELETE CASCADE


---- 1. INSERT ----
-- 1. ��� �������� ������ �����
INSERT INTO owner
VALUES (N'���������', N'�������', N'TravelLine', N'562897');

INSERT INTO owner
VALUES (N'������', N'��������', N'iSpring', N'432615');

INSERT INTO owner
VALUES (N'������', N'������', N'OmegaR', N'731954');

INSERT INTO flat
VALUES (1, N'�������', N'8�', N'121', 100)

INSERT INTO flat
VALUES (1, N'�������', N'16', N'10�', 60)

INSERT INTO flat
VALUES (1, N'����������', N'82', N'36', 68)

INSERT INTO flat
VALUES (2, N'�������', N'10', N'14', 50)

INSERT INTO service
VALUES (N'����', N'���������')


-- 2. � ��������� ������ �����
INSERT INTO flat (street, house_number, flat_number, area, id_owner)
VALUES (N'����������', N'24', N'9', 72, 2)

INSERT INTO service_in_flat (id_service, id_flat, start_date, end_date)
VALUES (1, 2, N'2015-10-15', NULL)

INSERT INTO service_in_flat (id_service, id_flat, start_date, end_date)
VALUES (1, 1, N'2018-04-12', NULL)

INSERT INTO service_in_flat (id_service, id_flat, start_date, end_date)
VALUES (1, 3, N'2010-11-12', N'2014-11-12')

-- 3. � ������� �������� �� ������ �������
INSERT INTO service (name, company)
SELECT first_name, place_of_work FROM owner


---- 2. DELETE ----
-- 1. ���� �������
DELETE service

-- 2. �� �������
DELETE flat
WHERE 
	street = N'�������';

-- 3. �������� �������
TRUNCATE TABLE service_in_flat


---- 3. UPDATE ----
-- 1. ���� �������
UPDATE owner
SET place_of_work = N'Google'

-- 2. �� ������� �������� ���� �������
UPDATE owner
SET  first_name = N'�������'
WHERE last_name = N'�������';

-- 3. �� ������� �������� ��������� ���������
UPDATE flat 
SET area += 10
WHERE id_owner = 1;


---- 4. SELECT ----
-- 1. � ������������ ������� ����������� ��������� 
SELECT first_name, last_name FROM owner

-- 2. �� ����� ���������� (SELECT * FROM...)
SELECT * FROM flat

-- 3. � �������� �� �������� (SELECT * FROM ... WHERE atr1 = "")
SELECT * FROM flat
WHERE area < 80


---- 5. SELECT ORDER BY + TOP (LIMIT) ----
-- 1. � ����������� �� ����������� ASC + ����������� ������ ���������� �������
SELECT TOP 3 *
FROM flat
ORDER BY street ASC

-- 2. � ����������� �� �������� DESC
SELECT * 
FROM flat
ORDER BY area DESC

-- 3. � ����������� �� ���� ��������� + ����������� ������ ���������� �������
SELECT TOP 4 * 
FROM flat
ORDER BY street, area

-- 4. � ����������� �� ������� ��������, �� ������ �����������
SELECT street, house_number, area
FROM flat
ORDER BY 1


---- 6. ������ � ������. ----
-- 1. WHERE �� ����
SELECT *
FROM service_in_flat
WHERE start_date > N'2015-01-01'

-- 2. ������� �� ������� �� ��� ����, � ������ ���. 
SELECT id_service, id_flat, YEAR(start_date) AS start_date
FROM service_in_flat


---- 7. SELECT GROUP BY � ��������� ��������� ----
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
-- 1. �������� 3 ������ ������� � �������������� GROUP BY + HAVING
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
-- 1. LEFT JOIN ���� ������ � WHERE �� ������ �� ���������
SELECT * FROM flat
LEFT JOIN owner ON flat.id_owner = owner.id_owner
WHERE flat.area > 50

-- 2. RIGHT JOIN. �������� ����� �� �������, ��� � � 9.1
SELECT * FROM owner
RIGHT JOIN flat ON flat.id_owner = owner.id_owner
WHERE flat.area > 50

-- 3. LEFT JOIN ���� ������ + WHERE �� �������� �� ������ �������
SELECT * FROM owner
LEFT JOIN flat ON flat.id_owner = owner.id_owner
LEFT JOIN service_in_flat ON service_in_flat.id_flat = flat.id_flat
WHERE owner.place_of_work != N'OmegaR' AND flat.area > 60 AND service_in_flat.start_date > N'2015-01-01'

-- 4. FULL OUTER JOIN ���� ������
SELECT * FROM 
owner 
FULL OUTER JOIN flat
ON owner.id_owner = flat.id_owner


---- 10. ���������� ----
-- 1. �������� ������ � WHERE IN (���������)
SELECT * FROM owner
WHERE id_owner IN (SELECT id_owner FROM flat)

-- 2. �������� ������ SELECT atr1, atr2, (���������) FROM ...
SELECT 
	first_name,
	last_name,
	(SELECT MAX(flat.area) FROM flat WHERE owner.id_owner = flat.id_owner GROUP BY id_owner) AS max_area
FROM owner