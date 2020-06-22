--1. Добавить внешние ключи.
ALTER TABLE booking
ADD
FOREIGN KEY(id_client) REFERENCES client(id_client)

ALTER TABLE room_in_booking
ADD
FOREIGN KEY(id_room) REFERENCES room(id_room)

ALTER TABLE room_in_booking
ADD
FOREIGN KEY(id_booking) REFERENCES booking(id_booking)

ALTER TABLE room
ADD
FOREIGN KEY(id_room_category) REFERENCES room_category(id_room_category)

ALTER TABLE room
ADD
FOREIGN KEY(id_hotel) REFERENCES hotel(id_hotel)


--2. Выдать информацию о клиентах гостиницы “Космос”, проживающих в номерах категории “Люкс” на 1 апреля 2019г.
SELECT client.* FROM client
	LEFT JOIN booking ON client.id_client = booking.id_client
	LEFT JOIN room_in_booking ON room_in_booking.id_booking = booking.id_booking
	LEFT JOIN room ON room.id_room = room_in_booking.id_room
	LEFT JOIN room_category ON room_category.id_room_category = room.id_room_category
	LEFT JOIN hotel ON hotel.id_hotel = room.id_hotel
WHERE
	hotel.name = N'Космос' AND 
	room_category.name = N'Люкс' AND 
	(N'2019-04-01' >= room_in_booking.checkin_date AND N'2019-04-01' < room_in_booking.checkout_date);

-- 3. Дать список свободных номеров всех гостиниц на 22 апреля. 
SELECT room.* FROM room
LEFT JOIN 
	(SELECT id_room FROM room_in_booking 
		WHERE  N'2019-04-22' >= room_in_booking.checkin_date AND N'2019-04-22' < room_in_booking.checkout_date
	) AS room_in_booking
ON room_in_booking.id_room = room.id_room
WHERE room_in_booking.id_room IS NULL


-- 4. Дать количество проживающих в гостинице "Космос" на 23 марта по каждой категории номеров	
SELECT room_category.id_room_category, room_category.name, COUNT(*) 
FROM room_category 
	LEFT JOIN room ON room_category.id_room_category = room.id_room_category
	LEFT JOIN hotel ON hotel.id_hotel = room.id_hotel
	LEFT JOIN room_in_booking ON room.id_room = room_in_booking.id_room
WHERE
	hotel.name = N'Космос' AND 
	(N'2019-03-23' >= room_in_booking.checkin_date AND N'2019-03-23' < room_in_booking.checkout_date)
GROUP BY 
	room_category.id_room_category, room_category.name

--5. Дать список последних проживавших клиентов по всем комнатам гостиницы “Космос”, выехавшиx в апреле с указанием даты выезда.
SELECT client.*, room.id_room, room_in_booking.checkout_date
FROM client
	INNER JOIN booking ON client.id_client = booking.id_client
	INNER JOIN room_in_booking ON room_in_booking.id_booking = booking.id_booking
	INNER JOIN room ON room.id_room = room_in_booking.id_room
	INNER JOIN hotel ON hotel.id_hotel = room.id_hotel
	INNER JOIN (SELECT room_in_booking.id_room,  MAX(room_in_booking.checkout_date) AS last_checkout_date
					FROM (
						SELECT * FROM room_in_booking
						WHERE N'2019-04-01' <= checkout_date AND checkout_date < N'2019-05-01'
					) AS room_in_booking
				GROUP BY room_in_booking.id_room) AS b
				ON b.id_room =  room_in_booking.id_room
WHERE 
	b.last_checkout_date = room_in_booking.checkout_date AND 
	hotel.name = N'Космос'

--6. Продлить на 2 дня дату проживания в гостинице “Космос” всем клиентам комнат категории “Бизнес”, которые заселились 10 мая.
UPDATE room_in_booking 
SET checkout_date = DATEADD(day, 2, checkout_date)
FROM room
INNER JOIN room_in_booking ON room.id_room = room_in_booking.id_room
INNER JOIN hotel ON room.id_hotel = hotel.id_hotel
INNER JOIN room_category ON room.id_room_category = room_category.id_room_category
WHERE
	hotel.name = N'Космос' AND
	room_category.name = N'Бизнес' AND
	room_in_booking.checkin_date = N'2019-05-10' 

--7. Найти все "пересекающиеся" варианты проживания.
SELECT *
FROM room_in_booking b1
INNER JOIN room_in_booking AS b2 ON b1.id_room = b2.id_room
WHERE 
	b1.id_room_in_booking != b2.id_room_in_booking AND 
	b1.checkin_date <= b2.checkin_date AND b2.checkin_date < b1.checkout_date

--8. Создать бронирование в транзакции.
BEGIN TRANSACTION;  
	INSERT INTO booking VALUES(1, CONVERT (date, GETDATE()));  	
	INSERT room_in_booking VALUES (2003, 11, N'2019-10-10', N'2019-10-20')
ROLLBACK;  


-- 9. Добавить необходимые индексы для всех таблиц
CREATE NONCLUSTERED INDEX [IX_booking_id_client] ON booking
(
	id_client ASC
)
CREATE NONCLUSTERED INDEX [IX_hotel_name] ON hotel
(
	name ASC
)
CREATE NONCLUSTERED INDEX [IX_room_id_hotel] ON room
(
	id_hotel ASC
)
CREATE NONCLUSTERED INDEX [IX_room_id_room_category] ON room
(
	id_room_category ASC
)
CREATE NONCLUSTERED INDEX [IX_room_in_booking_id_room] ON room_in_booking
(
	id_room ASC
)
CREATE NONCLUSTERED INDEX [IX_room_in_booking_id_booking] ON room_in_booking
(
	id_booking ASC
)
CREATE NONCLUSTERED INDEX [IX_room_in_booking_checkin_date-checkout_date] ON room_in_booking
(
	checkin_date ASC,
	checkout_date ASC
)
CREATE NONCLUSTERED INDEX [IX_room_in_booking_checkout_date] ON room_in_booking
(
	checkout_date ASC
)
CREATE NONCLUSTERED INDEX [IX_room_category_id_room_category-name] ON room_category
(
	id_room_category ASC,
	name ASC
)
CREATE NONCLUSTERED INDEX [IX_room_category_name] ON room_category
(
	name ASC
)