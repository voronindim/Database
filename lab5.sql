-- 1 Добавить внешние ключи.
ALTER TABLE production ADD
FOREIGN KEY(id_company) REFERENCES company(id_company)

ALTER TABLE production ADD
FOREIGN KEY(id_medicine) REFERENCES medicine(id_medicine)

ALTER TABLE dealer ADD
FOREIGN KEY(id_company) REFERENCES company(id_company)

ALTER TABLE [order] ADD
FOREIGN KEY(id_production) REFERENCES production(id_production)

ALTER TABLE [order] ADD
FOREIGN KEY(id_dealer) REFERENCES dealer(id_dealer)

ALTER TABLE [order] ADD
FOREIGN KEY(id_pharmacy) REFERENCES pharmacy(id_pharmacy)


-- 2 Выдать информацию по всем заказам лекарства “Кордерон” компании “Аргус” с указанием названий аптек, дат, объема заказов.
SELECT pharmacy.name, [order].date, [order].quantity
FROM [order]
INNER JOIN production ON production.id_production = [order].id_production
INNER JOIN company ON company.id_company = production.id_company
INNER JOIN pharmacy ON pharmacy.id_pharmacy = [order].id_pharmacy
INNER JOIN medicine ON medicine.id_medicine = production.id_medicine
WHERE medicine.name = N'Кордерон' AND company.name = N'Аргус'


-- 3 Дать список лекарств компании “Фарма”, на которые не были сделаны заказы до 25 января.
SELECT DISTINCT medicine.name
FROM medicine
LEFT JOIN production ON production.id_medicine = medicine.id_medicine
LEFT JOIN company ON company.id_company = production.id_company
LEFT JOIN [order] ON [order].id_production = production.id_production
WHERE company.name = N'Фарма' AND production.id_production NOT IN (
		SELECT [order].id_production
		FROM [order]
		WHERE [order].date < N'2019-01-25'
	)


-- 4 Дать минимальный и максимальный баллы лекарств каждой фирмы, которая оформила не менее 120 заказов.
SELECT company.id_company, company.name, MIN(production.rating) AS min_rating, MAX(production.rating) AS max_rating
FROM production
INNER JOIN [order] ON [order].id_production = production.id_production
INNER JOIN company ON company.id_company = production.id_company
GROUP BY company.id_company, company.name
HAVING COUNT(id_order) >= 120


-- 5 Дать списки сделавших заказы аптек по всем дилерам компании “AstraZeneca”. 
--   Если у дилера нет заказов, в названии аптеки проставить NULL.
SELECT dealer.name, pharmacy.name
FROM dealer
LEFT JOIN company ON company.id_company = dealer.id_company
LEFT JOIN [order] ON [order].id_dealer = dealer.id_dealer
LEFT JOIN pharmacy ON pharmacy.id_pharmacy = [order].id_pharmacy
WHERE company.name = N'AstraZeneca'


-- 6 Уменьшить на 20% стоимость всех лекарств, если она превышает 3000, а длительность лечения не более 7 дней.
UPDATE production
SET production.price = production.price * 0.8
WHERE production.price > 3000 AND production.id_medicine IN
	(
		SELECT medicine.id_medicine 
		FROM medicine 
		WHERE medicine.cure_duration <= 7
	)


-- 7 Добавить необходимые индексы.
CREATE NONCLUSTERED INDEX [IX_medicine_name-id_medicine] ON medicine
(
	name ASC,
	id_medicine ASC
)
CREATE NONCLUSTERED INDEX [IX_production_id_medicine-id_company-id_production] ON production
(
	id_medicine ASC,
	id_company ASC,
	id_production ASC
)
CREATE NONCLUSTERED INDEX [IX_company_name-id_company] ON company 
(
	name ASC,
	id_company ASC
)
CREATE NONCLUSTERED INDEX [IX_order_id_production-id_pharmacy] ON [order]
(
	id_production ASC,
	id_pharmacy ASC
)
INCLUDE(date, quantity)

CREATE NONCLUSTERED INDEX [IX_pharmacy_id_pharmacy] ON pharmacy
(
	id_pharmacy ASC
)
INCLUDE(name)


CREATE NONCLUSTERED INDEX [IX_order_id_production-date] ON [order]
(
	id_production ASC,
	date ASC
)


CREATE NONCLUSTERED INDEX [IX_production_id_production-id_company] ON production
(
	id_production ASC,
	id_company ASC
)
INCLUDE(rating)


CREATE NONCLUSTERED INDEX [IX_dealer_id_company-id_dealer] ON dealer
(
	id_company ASC,
	id_dealer ASC	
)
INCLUDE(name)

CREATE NONCLUSTERED INDEX [IX_order_id_dealer-id_pharmacy] ON [order]
(
	id_dealer ASC,
	id_pharmacy ASC
)


CREATE NONCLUSTERED INDEX [IX_production_id_medicine-price] ON production
(
	id_medicine ASC,
	price ASC
)
CREATE NONCLUSTERED INDEX [IX_medicine_cure_duration] ON medicine
(
	cure_duration ASC
)
INCLUDE(id_medicine)