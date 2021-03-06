CREATE TABLE Паспорт
(
	№_паспорта VARCHAR(10) NOT NULL PRIMARY KEY,
	Дата_выдачи DATE NOT NULL,
	Код_подразделения VARCHAR(6) NOT NULL
);

CREATE TABLE Сотрудники
(
	Табельный_№ SERIAL NOT NULL PRIMARY KEY,
	Фамилия VARCHAR(30) NOT NULL,
	Имя VARCHAR(30) NOT NULL,
	Отчество VARCHAR(30),
	Дата_рождения DATE NOT NULL,
	Пол VARCHAR(7),
	Телефон VARCHAR(14) UNIQUE,
	Email VARCHAR(50) UNIQUE,
	№_паспорта VARCHAR(10) NOT NULL REFERENCES Паспорт (№_паспорта) ON DELETE RESTRICT UNIQUE,
	ИНН VARCHAR(12) NOT NULL UNIQUE,
	Образование VARCHAR(8) NOT NULL,
	Дата_приёма DATE NOT NULL,
	Дата_уволнения DATE,
	CONSTRAINT Валидность_пола_сотрудника CHECK(LOWER(Пол) IN ('мужской', 'женский')),
	CONSTRAINT Валидность_образования CHECK(LOWER(Образование) IN ('высшее', 'спо', 'среднее', 'основное'))
);

CREATE TABLE Адресная_книга
(
	Код_адреса SERIAL NOT NULL PRIMARY KEY,
	Адрес VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Отдел
(
	Код_отдела SERIAL NOT NULL PRIMARY KEY,
	Название VARCHAR(50) NOT NULL UNIQUE,
	Адрес INTEGER NOT NULL REFERENCES Адресная_книга (Код_адреса) ON DELETE RESTRICT
);

CREATE TABLE Единицы_измерения
(
	Сокращение VARCHAR(10) NOT NULL PRIMARY KEY,
	Полное_название VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE Должность
(
	Код_должности SERIAL NOT NULL PRIMARY KEY,
	Название VARCHAR(50) NOT NULL UNIQUE,
	Оклад NUMERIC(12, 2) NOT NULL,
	Валюта VARCHAR(10) NOT NULL REFERENCES Единицы_измерения (Сокращение) ON DELETE RESTRICT,
	CONSTRAINT Положительная_сумма_оклада CHECK(Оклад >= 0::NUMERIC)
);

CREATE TABLE Должность_Отдел
(
	Должность_отдел SERIAL NOT NULL PRIMARY KEY,
	Код_должности INTEGER NOT NULL REFERENCES Должность (Код_должности) ON DELETE CASCADE,
	Код_отдела INTEGER NOT NULL REFERENCES Отдел (Код_отдела) ON DELETE CASCADE,
	UNIQUE (Код_должности, Код_отдела)
);

CREATE TABLE Должность_сотрудника
(
	Табельный_№ INTEGER NOT NULL REFERENCES Сотрудники (Табельный_№) ON DELETE CASCADE,
	Должность_отдел INTEGER NOT NULL REFERENCES Должность_Отдел (Должность_отдел) ON DELETE RESTRICT,
	PRIMARY KEY (Табельный_№, Должность_отдел)
);

CREATE TABLE Доплаты
(
	Код_доплаты SERIAL NOT NULL PRIMARY KEY,
	Описание VARCHAR(50) NOT NULL
);

CREATE TABLE Доплаты_сотрудника
(
	Табельный_№ INTEGER NOT NULL REFERENCES Сотрудники (Табельный_№) ON DELETE CASCADE,
	Код_доплаты INTEGER NOT NULL REFERENCES Доплаты (Код_доплаты) ON DELETE CASCADE,
	Сумма NUMERIC(12, 2) NOT NULL,
	Валюта VARCHAR(10) NOT NULL REFERENCES Единицы_измерения (Сокращение) ON DELETE RESTRICT,
	PRIMARY KEY (Табельный_№, Код_доплаты),
	CONSTRAINT Положительная_сумма_доплаты CHECK(Сумма >= 0::NUMERIC)
);

CREATE TABLE Категория_товара
(
	Код_категории SERIAL NOT NULL PRIMARY KEY,
	Категория VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE Товары
(
	Артикул SERIAL NOT NULL PRIMARY KEY,
	Код_категории INTEGER NOT NULL REFERENCES Категория_товара (Код_категории) ON DELETE RESTRICT,
	Наименование VARCHAR(50) NOT NULL,
	Срок_обслуживания VARCHAR(15),
	Стоимость NUMERIC(12, 2) NOT NULL,
	Валюта VARCHAR(10) NOT NULL REFERENCES Единицы_измерения (Сокращение) ON DELETE RESTRICT,
	CONSTRAINT Положительная_стоимость_товара CHECK(Стоимость >= 0::NUMERIC)
);

CREATE TABLE Товары_на_складе
(
	Артикул INTEGER NOT NULL REFERENCES Товары (Артикул) ON DELETE RESTRICT,
	Код_отдела INTEGER NOT NULL REFERENCES Отдел (Код_отдела) ON DELETE RESTRICT,
	Количество INTEGER NOT NULL,
	Единица_измерения VARCHAR(10) NOT NULL REFERENCES Единицы_измерения (Сокращение) ON DELETE RESTRICT,
	PRIMARY KEY (Артикул, Код_отдела),
	CONSTRAINT Положительное_количество_товара CHECK(Количество >= 0::INTEGER)
);

CREATE TABLE Клиенты
(
	id_клиента SERIAL NOT NULL PRIMARY KEY,
	Компания VARCHAR(50) NOT NULL,
	ИНН VARCHAR(12) NOT NULL UNIQUE,
	КПП VARCHAR(9) NOT NULL,
	Адрес INTEGER NOT NULL REFERENCES Адресная_книга (Код_адреса) ON DELETE RESTRICT,
	Email VARCHAR(50) UNIQUE,
	Телефон VARCHAR(14) UNIQUE
);

CREATE TABLE Договор
(
	№_договора SERIAL NOT NULL PRIMARY KEY,
	id_клиента INTEGER NOT NULL REFERENCES Клиенты (id_клиента) ON DELETE RESTRICT,
	id_менеджера INTEGER NOT NULL REFERENCES Сотрудники (Табельный_№) ON DELETE RESTRICT,
	Дата_договара DATE NOT NULL,
	Сумма NUMERIC(12, 2) NOT NULL,
	Валюта VARCHAR(10) NOT NULL REFERENCES Единицы_измерения (Сокращение) ON DELETE RESTRICT,
	Статус_договора VARCHAR(14) NOT NULL,
	CONSTRAINT Положительная_сумма_договора CHECK(Сумма >= 0::NUMERIC),
	CONSTRAINT Валидность_статуса_договора CHECK(LOWER(Статус_договора) IN ('формируется', 'ожидает оплаты', 'оплачен'))
);

CREATE TABLE Товары_в_договоре
(
	№_договора INTEGER NOT NULL REFERENCES Договор (№_договора) ON DELETE CASCADE,
	Артикул INTEGER NOT NULL REFERENCES Товары (Артикул) ON DELETE RESTRICT,
	Количество INTEGER NOT NULL,
	Стоимость NUMERIC(12, 2) NOT NULL,
	Валюта VARCHAR(10) NOT NULL REFERENCES Единицы_измерения (Сокращение) ON DELETE RESTRICT,
	PRIMARY KEY (№_договора, Артикул),
	CONSTRAINT Положительное_количество_товара CHECK(Количество > 0::INTEGER),
	CONSTRAINT Положительная_стоимость_товара CHECK(Стоимость > 0::NUMERIC)
);

CREATE TABLE Установка 
(
	№_акта_выполненных_работ SERIAL NOT NULL PRIMARY KEY,
	№_договора INTEGER NOT NULL REFERENCES Договор (№_договора) ON DELETE CASCADE,
	Дата_установки DATE NOT NULL,
	Адрес INTEGER NOT NULL REFERENCES Адресная_книга (Код_адреса) ON DELETE RESTRICT
);

CREATE FUNCTION add_contract() RETURNS trigger AS $add_contract$
	BEGIN
		IF (TG_OP = 'INSERT') THEN
			IF (NEW.Статус_договора <> 'формируется') THEN
				RAISE EXCEPTION 'Добавление договора возможно только со статусом "формируется"';
			END IF;
			NEW.Сумма = 0::NUMERIC;
			NEW.Валюта = 'руб';
		END IF;
		IF (TG_OP = 'UPDATE') THEN
			IF (OLD.Статус_договора <> 'формируется') THEN
				RAISE EXCEPTION 'Изменение договора возможно только при статусе "формируется"';
			END IF;
		END IF;
		RETURN NEW;
	END;
$add_contract$ LANGUAGE plpgsql;

CREATE TRIGGER add_contract BEFORE INSERT OR UPDATE ON Договор
	FOR EACH ROW EXECUTE PROCEDURE add_contract();

CREATE FUNCTION add_product_in_contract() RETURNS trigger AS $add_product_in_contract$
	BEGIN
		DECLARE
			contract_status VARCHAR;
		BEGIN
			SELECT Статус_договора FROM Договор WHERE №_договора = NEW.№_договора INTO contract_status;
			IF (contract_status <> 'формируется') THEN
				RAISE EXCEPTION 'Добавление товара возможно только в договор со статусом "формируется"';
			END IF;
			IF (TG_OP = 'INSERT') THEN
				IF (NEW.Стоимость IS NULL) THEN
					SELECT Стоимость FROM Товары WHERE Артикул = NEW.Артикул INTO NEW.Стоимость;
				END IF;
				IF (NEW.Количество IS NULL) THEN
					RAISE EXCEPTION 'Количество товара должно быть задано';
				ELSE
					UPDATE Договор SET Сумма = Сумма + (NEW.Количество * NEW.Стоимость) WHERE №_договора = NEW.№_договора;
				END IF;
			ELSIF (TG_OP = 'UPDATE') THEN
				IF (OLD.№_договора <> NEW.№_договора OR OLD.Артикул <> NEW.Артикул) THEN
					RAISE EXCEPTION 'Для изменения номера договора или артикула товара необходимо провизвести удаление текущей записи и добавить новую';
				END IF;
				IF (OLD.Количество <> NEW.Количество OR OLD.Стоимость <> NEW.Стоимость) THEN
					UPDATE Договор SET Сумма = Сумма - (OLD.Количество * OLD.Стоимость) + (NEW.Количество * NEW.Стоимость) WHERE №_договора = NEW.№_договора;
				END IF;
			ELSIF (TG_OP = 'DELETE') THEN
				UPDATE Договор SET Сумма = Сумма - (OLD.Количество * OLD.Стоимость) WHERE №_договора = OLD.№_договора;
				RETURN OLD;
			END IF;
		END;
		RETURN NEW;
	END;
$add_product_in_contract$ LANGUAGE plpgsql;

CREATE TRIGGER add_product_in_contract BEFORE INSERT OR UPDATE OR DELETE ON Товары_в_договоре
	FOR EACH ROW EXECUTE PROCEDURE add_product_in_contract();

CREATE FUNCTION check_date_of_contract() RETURNS trigger AS $check_date_of_contract$
	BEGIN
		DECLARE
			contract_date DATE;
			contract_status VARCHAR;
		BEGIN
			SELECT Дата_договара, Статус_договора FROM Договор WHERE №_договора = NEW.№_договора INTO contract_date, contract_status;
			IF (NEW.Дата_установки < contract_date) THEN
				RAISE EXCEPTION 'Дата установочных работ (%) не может быть раньше даты заключения договора (%)', NEW.Дата_установки, contract_date;
			ELSIF (contract_status <> 'оплачен') THEN
				RAISE EXCEPTION 'Утановочные работы могут производиться только для договора со статусом "оплачен"';
			END IF;
		END;
		RETURN NEW;
	END;
$check_date_of_contract$ LANGUAGE plpgsql;

CREATE TRIGGER check_date_of_contract BEFORE INSERT OR UPDATE ON Установка
	FOR EACH ROW EXECUTE PROCEDURE check_date_of_contract();

INSERT INTO Паспорт (№_паспорта, Дата_выдачи, Код_подразделения) VALUES ('771264019', '2019-01-08', '077031'), ('770918955', '2015-03-25', '077067'), ('771823585', '2000-12-25', '077048'), ('770425899', '2006-11-21', '077057'), ('770219059', '2011-07-30', '077083');
INSERT INTO Паспорт (№_паспорта, Дата_выдачи, Код_подразделения) VALUES ('771178005', '1999-11-16', '077080'), ('770766674', '2012-05-12', '077097'), ('770370786', '2017-03-23', '077034'), ('771847637', '2007-02-14', '077084'), ('771071885', '2016-06-30', '077057');
INSERT INTO Паспорт (№_паспорта, Дата_выдачи, Код_подразделения) VALUES ('770725373', '2006-08-16', '077048'), ('770267795', '2006-06-23', '077097'), ('770951261', '2014-05-17', '077067'), ('770618798', '2008-10-15', '077083'), ('771904634', '2016-01-30', '077083');
INSERT INTO Паспорт (№_паспорта, Дата_выдачи, Код_подразделения) VALUES ('770084803', '2019-02-13', '077080'), ('770019239', '2003-12-12', '077034'), ('770027115', '2015-09-24', '077034'), ('770596570', '2008-04-19', '077084'), ('771319418', '2016-12-26', '077057');

INSERT INTO Сотрудники (Фамилия, Имя, Отчество, Дата_рождения, Пол, Телефон, Email, №_паспорта, ИНН, Образование, Дата_приёма) VALUES ('Иванов', 'Эрик', 'Романович', '1999-01-08', 'мужской', '+79282274641', 'hbenneton0@vkontakte.ru', '771264019', '770011567616', 'высшее', '2018-01-16');
INSERT INTO Сотрудники (Фамилия, Имя, Отчество, Дата_рождения, Пол, Телефон, Email, №_паспорта, ИНН, Образование, Дата_приёма) VALUES ('Хованский', 'Юлий', 'Юхимович', '1970-03-25', 'мужской', '+79929028917', 'ckeavy0@yellowpages.com', '770918955', '771223795445', 'высшее', '2018-10-02');
INSERT INTO Сотрудники (Фамилия, Имя, Отчество, Дата_рождения, Пол, Телефон, Email, №_паспорта, ИНН, Образование, Дата_приёма) VALUES ('Лановой', 'Лукиллиан', 'Андреевич', '1980-12-25', 'мужской', '+79580693531', 'mondrusek2@harvard.edu', '771823585', '770733350773', 'высшее', '2018-07-22');
INSERT INTO Сотрудники (Фамилия, Имя, Отчество, Дата_рождения, Пол, Телефон, Email, №_паспорта, ИНН, Образование, Дата_приёма) VALUES ('Петров', 'Владислав', 'Максимович', '1986-11-21', 'мужской', '+79251963834', 'pwolfit3@blogspot.com', '770425899', '770100825539', 'спо', '2018-11-14');
INSERT INTO Сотрудники (Фамилия, Имя, Отчество, Дата_рождения, Пол, Телефон, №_паспорта, ИНН, Образование, Дата_приёма) VALUES ('Гусев', 'Заур', 'Ярославович', '1991-07-30', 'мужской', '+79979643463', '770219059', '771153862460', 'спо', '2018-02-14');
INSERT INTO Сотрудники (Фамилия, Имя, Отчество, Дата_рождения, Пол, Телефон, Email, №_паспорта, ИНН, Образование, Дата_приёма) VALUES ('Павлов', 'Август', 'Брониславович', '1979-11-16', 'мужской', '+79977908030', 'bwanka7@liveinternet.ru', '771178005', '770684953425', 'высшее', '2018-10-16');
INSERT INTO Сотрудники (Фамилия, Имя, Отчество, Дата_рождения, Пол, Телефон, Email, №_паспорта, ИНН, Образование, Дата_приёма) VALUES ('Сыпченко', 'Ярослав', 'Михайлович', '1986-05-12', 'мужской', '+79393845706', 'rpaolucci8@tuttocitta.it', '770766674', '770260591221', 'высшее', '2018-11-21');
INSERT INTO Сотрудники (Фамилия, Имя, Отчество, Дата_рождения, Пол, Телефон, Email, №_паспорта, ИНН, Образование, Дата_приёма) VALUES ('Сазонов', 'Владислав', 'Львович', '1969-03-23', 'мужской', '+79625546482', 'mharnetty9@istockphoto.com', '770370786', '771267721974', 'высшее', '2018-05-06');
INSERT INTO Сотрудники (Фамилия, Имя, Отчество, Дата_рождения, Пол, Телефон, Email, №_паспорта, ИНН, Образование, Дата_приёма) VALUES ('Самсонов', 'Бронислав', 'Платонович', '1972-02-14', 'мужской', '+79908622373', 'jdymott0@ebay.co.uk', '771847637', '770060067646', 'высшее', '2018-08-13');
INSERT INTO Сотрудники (Фамилия, Имя, Отчество, Дата_рождения, Пол, Телефон, Email, №_паспорта, ИНН, Образование, Дата_приёма) VALUES ('Абрамов', 'Юлий', 'Валерьевич', '1996-06-30', 'мужской', '+79264017464', 'jfelton1@unesco.org', '771071885', '771334561798', 'высшее', '2018-04-10');
INSERT INTO Сотрудники (Фамилия, Имя, Отчество, Дата_рождения, Пол, Телефон, Email, №_паспорта, ИНН, Образование, Дата_приёма) VALUES ('Фёдорова', 'Ольга', 'Валерьевна', '1979-08-16', 'женский', '+79408135982', 'acromly0@google.it', '770725373', '770512715840', 'высшее', '2018-11-01');
INSERT INTO Сотрудники (Фамилия, Имя, Отчество, Дата_рождения, Пол, Телефон, Email, №_паспорта, ИНН, Образование, Дата_приёма) VALUES ('Бачей', 'Христина', 'Петровна', '1986-06-23', 'женский', '+79568079998', 'cwrates1@mtv.com', '770267795', '771756937138', 'высшее', '2018-04-30');
INSERT INTO Сотрудники (Фамилия, Имя, Отчество, Дата_рождения, Пол, Телефон, Email, №_паспорта, ИНН, Образование, Дата_приёма) VALUES ('Жукова', 'Элина', 'Ивановна', '1969-05-17', 'женский', '+79015492683', 'sswede2@github.com', '770951261', '771083385200', 'высшее', '2018-06-13');
INSERT INTO Сотрудники (Фамилия, Имя, Отчество, Дата_рождения, Пол, Телефон, Email, №_паспорта, ИНН, Образование, Дата_приёма) VALUES ('Ивановна', 'Ульяна', 'Васильевна', '1972-10-15', 'женский', '+79491302235', 'bkovnot3@twitpic.com', '770618798', '770202910794', 'высшее', '2018-03-23');
INSERT INTO Сотрудники (Фамилия, Имя, Отчество, Дата_рождения, Пол, Телефон, Email, №_паспорта, ИНН, Образование, Дата_приёма) VALUES ('Крылова', 'Богдана', 'Васильевна', '1996-01-30', 'женский', '+79351833615', 'swatsonbrown4@cnn.com', '771904634', '771737987674', 'высшее', '2018-04-14');
INSERT INTO Сотрудники (Фамилия, Имя, Отчество, Дата_рождения, Пол, Телефон, Email, №_паспорта, ИНН, Образование, Дата_приёма) VALUES ('Богданова', 'Эльга', 'Платоновна', '1979-02-13', 'женский', '+79789471750', 'rabbiss5@rediff.com', '770084803', '771571223011', 'высшее', '2018-09-09');
INSERT INTO Сотрудники (Фамилия, Имя, Отчество, Дата_рождения, Пол, Телефон, Email, №_паспорта, ИНН, Образование, Дата_приёма) VALUES ('Недбайло', 'Яна', 'Григорьевна', '1986-12-12', 'женский', '+79498514012', 'mhoodless6@arstechnica.com', '770019239', '771037827835', 'высшее', '2018-08-13');
INSERT INTO Сотрудники (Фамилия, Имя, Отчество, Дата_рождения, Пол, Телефон, Email, №_паспорта, ИНН, Образование, Дата_приёма) VALUES ('Афанасьева', 'Тамара', 'Вадимовна', '1969-09-24', 'женский', '+79926119685', 'ggreed7@ucoz.ru', '770027115', '770116659919', 'высшее', '2018-04-02');
INSERT INTO Сотрудники (Фамилия, Имя, Отчество, Дата_рождения, Пол, Телефон, Email, №_паспорта, ИНН, Образование, Дата_приёма) VALUES ('Гребневска', 'Искра', 'Ярославовна', '1972-04-19', 'женский', '+79085797371', 'sseif8@tiny.cc', '770596570', '771820273157', 'высшее', '2018-10-09');
INSERT INTO Сотрудники (Фамилия, Имя, Отчество, Дата_рождения, Пол, Телефон, Email, №_паспорта, ИНН, Образование, Дата_приёма) VALUES ('Анисимова', 'Татьяна', 'Валерьевна', '1996-12-26', 'женский', '+79732167060', 'dfrichley9@gizmodo.com', '771319418', '771024209287', 'высшее', '2018-12-21');

INSERT INTO Адресная_книга (Адрес) VALUES ('г. Москва ул. Симферопольский Проезд, дом 78'), ('г. Москва, ул. Алтуфьевское Шоссе, дом 75'), ('г. Москва  ул. Богучарский 1-й Переулок, дом 19'), ('г. Москва ул. Глебовский Переулок, дом 7'), ('г. Москва ул. Карьерная, дом 38'); 
INSERT INTO Адресная_книга (Адрес) VALUES ('г. Москва ул. Пехотный 1-й Переулок, дом 30'), ('г. Москва ул. Черняховского, дом 41'), ('г. Москва ул. Кировоградская, дом 43'), ('г. Москва ул. Волоколамский 1-й Проезд, дом 49'), ('г. Москва ул. Тетеринский Переулок, дом 73');
INSERT INTO Адресная_книга (Адрес) VALUES ('г. Одинцово ул. Боярский Переулок, дом 23'), ('г. Химки ул. Тульский 2-й Переулок, дом 70');
	
INSERT INTO Отдел (Название, Адрес) VALUES ('Отдел продаж', '1'), ('Отдел финансов', '1'), ('Отдел логистики', '1'), ('Инженерный отдел', '1'), ('Отдел разработки', '1'), ('Склад №1', '12');

INSERT INTO Единицы_измерения (Сокращение, Полное_название) VALUES ('шт', 'штуки'), ('м', 'метры'), ('руб', 'рубли');

INSERT INTO Должность (Название, Оклад, Валюта) VALUES ('Директор', '200000', 'руб'), ('Начальник отдела', '120000', 'руб'), ('Менеджер', '100000', 'руб'), ('Главный бухгалтер', '120000', 'руб'), ('Бухгалтер', '80000', 'руб');
INSERT INTO Должность (Название, Оклад, Валюта) VALUES ('Кассир', '80000', 'руб'), ('Грузчик', '50000', 'руб'), ('Логист', '90000', 'руб'), ('Инженер', '120000', 'руб'), ('Схемотехник', '90000', 'руб');
INSERT INTO Должность (Название, Оклад, Валюта) VALUES ('Разработчик', '80000', 'руб'), ('Старший разработчик', '120000', 'руб'), ('Инженер сопровождения', '80000', 'руб'), ('Установщик', '60000', 'руб');

INSERT INTO Должность_Отдел (Код_должности, Код_отдела) VALUES ('1', '2'), ('2', '1'), ('2', '2'), ('2', '3'), ('2', '4');
INSERT INTO Должность_Отдел (Код_должности, Код_отдела) VALUES ('2', '5'), ('2', '6'), ('3', '1'), ('4', '2'), ('5', '2');
INSERT INTO Должность_Отдел (Код_должности, Код_отдела) VALUES ('6', '2'), ('7', '6'), ('8', '3'), ('9', '4'), ('10', '4');
INSERT INTO Должность_Отдел (Код_должности, Код_отдела) VALUES ('11', '5'), ('12', '5'), ('13', '5'), ('14', '3');

INSERT INTO Должность_сотрудника (Табельный_№, Должность_отдел) VALUES ('1', '18'), ('2', '5'), ('3', '7'), ('4', '19'), ('5', '12');
INSERT INTO Должность_сотрудника (Табельный_№, Должность_отдел) VALUES ('6', '6'), ('7', '17'), ('8', '1'), ('9', '15'), ('10', '14');
INSERT INTO Должность_сотрудника (Табельный_№, Должность_отдел) VALUES ('11', '13'), ('12', '8'), ('13', '4'), ('14', '2'), ('15', '16');
INSERT INTO Должность_сотрудника (Табельный_№, Должность_отдел) VALUES ('16', '8'), ('17', '10'), ('18', '3'), ('19', '9'), ('20', '11');

INSERT INTO Доплаты (Описание) VALUES ('Компенсация питания'), ('Компенсация транспортных расходов');

INSERT INTO Доплаты_сотрудника (Табельный_№, Код_доплаты, Сумма, Валюта) VALUES ('4', '2', '3000', 'руб'), ('3', '1', '5000', 'руб'), ('5', '1', '5000', 'руб');

INSERT INTO Категория_товара (Категория) VALUES ('Программное обеспечение'), ('Маршрутизаторы'), ('Коммутаторы'), ('Сетевые адапторы'), ('Точки доступа'), ('Монтажное оборудование');

INSERT INTO Товары (Код_категории, Наименование, Срок_обслуживания, Стоимость, Валюта) VALUES ('1', 'Антивирус "Коловрат"', '1 год', '2990', 'руб'), ('1', 'Firewall "Стражник"', '1 год', '5490', 'руб'), ('1', 'SIEM-система "Воевода"', '1 год', '24990', 'руб');
INSERT INTO Товары (Код_категории, Наименование, Срок_обслуживания, Стоимость, Валюта) VALUES ('2', 'Маршрутизатор "Иван Сусанин"', '3 года', '32990', 'руб');
INSERT INTO Товары (Код_категории, Наименование, Срок_обслуживания, Стоимость, Валюта) VALUES ('3', 'Коммутатор 4 порта', '3 года', '6490', 'руб'), ('3', 'Коммутатор 6 портов', '3 года', '8990', 'руб'), ('3', 'Коммутатор 8 портов', '3 года', '11490', 'руб');
INSERT INTO Товары (Код_категории, Наименование, Срок_обслуживания, Стоимость, Валюта) VALUES ('4', 'Сетевая карта 2 порта', '2 года', '7990', 'руб'), ('4', 'Сетевая карта 4 порта', '2 года', '12490', 'руб');
INSERT INTO Товары (Код_категории, Наименование, Срок_обслуживания, Стоимость, Валюта) VALUES ('5', 'Точка доступа 2,4 Ghz', '5 лет', '6490', 'руб'), ('5', 'Точка доступа 2,4/5 Ghz', '5 лет', '10990', 'руб');
INSERT INTO Товары (Код_категории, Наименование, Стоимость, Валюта) VALUES ('6', 'Кабель 2х2,5 медный', '30', 'руб'), ('6', 'Кабель 4х1,5 медный', '35', 'руб'), ('6', 'Кабель оптоволоконный', '70', 'руб');

INSERT INTO Товары_на_складе (Артикул, Код_отдела, Количество, Единица_измерения) VALUES ('1', '6', '500', 'шт'), ('2', '6', '500', 'шт'), ('3', '6', '500', 'шт'), ('4', '6', '40', 'шт'), ('5', '6', '60', 'шт');
INSERT INTO Товары_на_складе (Артикул, Код_отдела, Количество, Единица_измерения) VALUES ('6', '6', '60', 'шт'), ('7', '6', '60', 'шт'), ('8', '6', '70', 'шт'), ('9', '6', '70', 'шт'), ('10', '6', '80', 'шт');
INSERT INTO Товары_на_складе (Артикул, Код_отдела, Количество, Единица_измерения) VALUES ('11', '6', '70', 'шт'), ('12', '6', '1600', 'м'), ('13', '6', '1300', 'м'), ('14', '6', '400', 'м');

INSERT INTO Клиенты (Компания, ИНН, КПП, Адрес, Email, Телефон) VALUES ('ООО "Инфосистемы"', '771364530431', '773043736', '2', 'idugue0@bloglovin.com', '4951550'), ('ООО "Ренесанс"', '779000399383', '773890852', '3', 'dabrahmson1@newsvine.com', '4952963');
INSERT INTO Клиенты (Компания, ИНН, КПП, Адрес, Email, Телефон) VALUES ('ООО "РемТех"', '770927288415', '770117828', '4', 'hcolchett2@fda.gov', '4953450'), ('ООО "Франкос"', '774354852745', '773907043', '5', 'mwalne6@nba.com', '4950151');
INSERT INTO Клиенты (Компания, ИНН, КПП, Адрес, Email, Телефон) VALUES ('ООО "Амальгама"', '775489967745', '776328941', '6', 'bdibner3@google.fr', '4950599'), ('ООО "Легион"', '778576071854', '777524461', '7', 'jwhatsize7@tumblr.com', '4956730');
INSERT INTO Клиенты (Компания, ИНН, КПП, Адрес, Email, Телефон) VALUES ('ООО "Индустриал"', '773744697864', '775032284', '8', 'bew4@altervista.org', '4950374'), ('ООО "Крылья"', '778593320088', '775877822', '9', 'gsleath8@narod.ru', '4950852');
INSERT INTO Клиенты (Компания, ИНН, КПП, Адрес, Email, Телефон) VALUES ('ООО "Вавилон"', '771462854733', '774352175', '10', 'mnorthover5@nba.com', '4956269'), ('ООО "Новые Технологии"', '772464489709', '778875660', '11', 'mocaine9@surveymonkey.com', '4950532');

INSERT INTO Договор (id_клиента, id_менеджера, Дата_договара, Статус_договора) VALUES ('1', '12', '2019-05-16', 'формируется'), ('2', '12', '2019-01-23', 'формируется'), ('3', '12', '2019-11-18', 'формируется'), ('4', '16', '2019-06-12', 'формируется'), ('5', '12', '2019-10-29', 'формируется');
INSERT INTO Договор (id_клиента, id_менеджера, Дата_договара, Статус_договора) VALUES ('6', '16', '2019-08-20', 'формируется'), ('7', '12', '2019-07-13', 'формируется'), ('8', '16', '2019-01-15', 'формируется'), ('9', '12', '2019-09-22', 'формируется'), ('10', '12', '2019-06-06', 'формируется');

INSERT INTO Товары_в_договоре (№_договора, Артикул, Валюта, Количество) VALUES ('1', '4', 'руб', '1'), ('1', '7', 'руб', '1');
INSERT INTO Товары_в_договоре (№_договора, Артикул, Валюта, Количество) VALUES ('2', '1', 'руб', '1'), ('2', '5', 'руб', '1'), ('2', '10', 'руб', '1');
INSERT INTO Товары_в_договоре (№_договора, Артикул, Валюта, Количество) VALUES ('3', '14', 'руб', '150');
INSERT INTO Товары_в_договоре (№_договора, Артикул, Валюта, Количество) VALUES ('4', '11', 'руб', '2'), ('4', '12', 'руб', '80');
INSERT INTO Товары_в_договоре (№_договора, Артикул, Валюта, Количество) VALUES ('5', '8', 'руб', '4'), ('5', '2', 'руб', '1');
INSERT INTO Товары_в_договоре (№_договора, Артикул, Валюта, Количество) VALUES ('6', '3', 'руб', '1');
INSERT INTO Товары_в_договоре (№_договора, Артикул, Валюта, Количество) VALUES ('7', '10', 'руб', '4'), ('7', '13', 'руб', '200');
INSERT INTO Товары_в_договоре (№_договора, Артикул, Валюта, Количество) VALUES ('8', '4', 'руб', '1'), ('8', '2', 'руб', '1');
INSERT INTO Товары_в_договоре (№_договора, Артикул, Валюта, Количество) VALUES ('9', '7', 'руб', '2'), ('9', '12', 'руб', '120');
INSERT INTO Товары_в_договоре (№_договора, Артикул, Валюта, Количество) VALUES ('10', '11', 'руб', '6'), ('10', '2', 'руб', '1'), ('10', '12', 'руб', '200');

UPDATE Договор SET Статус_договора = 'оплачен' WHERE №_договора = 1;
UPDATE Договор SET Статус_договора = 'оплачен' WHERE №_договора = 2;
UPDATE Договор SET Статус_договора = 'оплачен' WHERE №_договора = 3;
UPDATE Договор SET Статус_договора = 'оплачен' WHERE №_договора = 4;
UPDATE Договор SET Статус_договора = 'оплачен' WHERE №_договора = 5;
UPDATE Договор SET Статус_договора = 'оплачен' WHERE №_договора = 6;
UPDATE Договор SET Статус_договора = 'оплачен' WHERE №_договора = 7;
UPDATE Договор SET Статус_договора = 'оплачен' WHERE №_договора = 8;
UPDATE Договор SET Статус_договора = 'оплачен' WHERE №_договора = 9;
UPDATE Договор SET Статус_договора = 'оплачен' WHERE №_договора = 10;

INSERT INTO Установка (№_договора, Дата_установки, Адрес) VALUES ('2', '2019-01-24', '3'), ('4', '2019-06-15', '5'), ('7', '2019-07-14', '8'), ('10', '2019-06-09', '11');
