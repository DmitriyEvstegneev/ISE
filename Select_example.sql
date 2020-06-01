# 1. Получить список сотрудников отдела разработки. Отсортировать вывод по дате приёма в штат.
SELECT Сотрудники.Табельный_№, Фамилия, Имя, Отчество, Дата_приёма FROM Сотрудники
		JOIN Должность_сотрудника ON Сотрудники.Табельный_№ = Должность_сотрудника.Табельный_№
		JOIN Должность_Отдел ON Должность_сотрудника.Должность_отдел = Должность_Отдел.Должность_отдел
		JOIN Отдел ON Отдел.Код_отдела = Должность_Отдел.Код_отдела
		WHERE Отдел.Название = 'Отдел разработки'
		ORDER BY Сотрудники.Дата_приёма;

# 2. Получить данные о расходах на ФОТ (фонд оплаты труда) для каждого отдела компании.
WITH pay_1 AS (SELECT Отдел.Код_отдела, Отдел.Название, SUM(Оклад) AS Оклад FROM Должность_сотрудника
		JOIN Должность_Отдел ON Должность_сотрудника.Должность_отдел = Должность_Отдел.Должность_отдел
		JOIN Должность ON Должность.Код_должности = Должность_Отдел.Код_должности
		JOIN Отдел ON Отдел.Код_отдела = Должность_Отдел.Код_отдела
		GROUP BY Отдел.Код_отдела),
	pay_2 AS (SELECT Должность_Отдел.Код_отдела, SUM(Сумма) AS Доплаты FROM Доплаты_сотрудника
		JOIN Должность_сотрудника ON Должность_сотрудника.Табельный_№ = Доплаты_сотрудника.Табельный_№
		JOIN Должность_Отдел ON Должность_сотрудника.Должность_отдел = Должность_Отдел.Должность_отдел
		GROUP BY Должность_Отдел.Код_отдела)
	SELECT Название, Оклад + COALESCE(Доплаты, 0) AS ФОТ FROM pay_1 LEFT JOIN pay_2 ON pay_1.Код_отдела = pay_2.Код_отдела;

# 3. Получить данные об остатке на складе товара с артикулом = 2.
SELECT Код_отдела, SUM(Количество) AS Количество
	FROM Товары_на_складе WHERE Артикул = 2
	GROUP BY ROLLUP(Код_отдела);

# 4. Получить перечень и количество товаров в договоре с номером 4.
SELECT Товары.Артикул, Наименование, Количество FROM Товары_в_договоре
	JOIN Товары ON Товары_в_договоре.Артикул = Товары.Артикул
	WHERE №_договора = 4;

# 5. Получить перечень клиентов, для которых суммарная стоимость приобретенных товаров за всё время составила более 30 000 рублей, отсортировать по сумме.
WITH contracts AS (SELECT id_клиента, SUM(Сумма) AS Сумма FROM Договор
		WHERE (Статус_договора = 'оплачен' AND Сумма > 30000) GROUP BY id_клиента)
	SELECT contracts.id_клиента, Компания, Сумма FROM contracts JOIN Клиенты
		ON contracts.id_клиента = Клиенты.id_клиента ORDER BY Сумма;

# 6. Получить перечень договоров с именами клиентов и суммами за 4 квартал 2019 года.
SELECT №_договора, Компания, Дата_договара, Сумма FROM Договор
	JOIN Клиенты ON Договор.id_клиента = Клиенты.id_клиента
	WHERE Дата_договара >= '2019-10-01'::DATE AND Дата_договара <= '2019-12-31'::DATE
	ORDER BY Дата_договара;
