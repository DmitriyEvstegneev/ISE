CREATE DOMAIN NAME AS TEXT
	NOT NULL;

CREATE TABLE SUPPLIERS
(
	SN SERIAL NOT NULL PRIMARY KEY,
	SNAME NAME NOT NULL,
	STATUS INTEGER NOT NULL,
	CITY TEXT NOT NULL,
	CONSTRAINT status_value CHECK (STATUS >= 1 AND STATUS <= 100)
);

CREATE TABLE PARTS
(
	PN SERIAL NOT NULL PRIMARY KEY,
	PNAME NAME NOT NULL,
	COLOR TEXT NOT NULL,
	WEIGHT INTEGER NOT NULL,
	CITY TEXT NOT NULL
);

CREATE TABLE PROJECTS
(
	JN SERIAL NOT NULL PRIMARY KEY,
	JNAME NAME NOT NULL,
	CITY TEXT NOT NULL
);

CREATE TABLE SALES
(
	SN INTEGER NOT NULL REFERENCES SUPPLIERS (SN) ON DELETE CASCADE,
	PN INTEGER NOT NULL REFERENCES PARTS (PN) ON DELETE CASCADE,
	JN INTEGER NOT NULL REFERENCES PROJECTS (JN) ON DELETE CASCADE,
	QTY INTEGER NOT NULL,
	PRIMARY KEY (SN, PN, JN)
);

INSERT INTO SUPPLIERS (SN, SNAME, STATUS, CITY) VALUES ('1', 'Иванов', '20', 'Москва'), ('2', 'Алексеев', '10', 'С.Петербург'), ('3', 'Кузнецов', '30', 'Новосибирск'), ('4', 'Чернов', '20', 'Москва'), ('5', 'Петров', '30', 'Новосибирск');

INSERT INTO PARTS (PN, PNAME, COLOR, WEIGHT, CITY) VALUES ('1', 'Гайка', 'Красный', '12', 'Москва'), ('2', 'Болт', 'Зеленый', '17', 'С.Петербург'), ('3', 'Шайба', 'Синий', '17', 'Екатеринбург'), ('4', 'Шайба', 'Красный', '14', 'Москва'), ('5', 'Камера', 'Синий', '12', 'С.Петербург'), ('6', 'Прокладка', 'Красный', '19', 'Москва');

INSERT INTO PROJECTS (JN, JNAME, CITY) VALUES ('1', 'Sorter', 'С.Петербург'), ('2', 'Display', 'Челябинск'), ('3', 'OCR', 'Тольятти'), ('4', 'Console', 'Тольятти'), ('5', 'RAID', 'Москва'), ('6', 'EDS', 'Екатеринбург'), ('7', 'Tape', 'Москва');

INSERT INTO SALES (SN, PN, JN, QTY) VALUES ('1', '1', '1', '200'), ('1', '1', '4', '700'), ('2', '3', '1', '400'), ('2', '3', '2', '200'), ('2', '3', '3', '200');
INSERT INTO SALES (SN, PN, JN, QTY) VALUES ('2', '3', '4', '500'), ('2', '3', '5', '600'), ('2', '3', '6', '400'), ('2', '3', '7', '800'), ('2', '5', '2', '100');
INSERT INTO SALES (SN, PN, JN, QTY) VALUES ('3', '3', '1', '200'), ('3', '4', '2', '500'), ('4', '6', '3', '300'), ('4', '6', '7', '300');
INSERT INTO SALES (SN, PN, JN, QTY) VALUES ('5', '2', '2', '200'), ('5', '2', '4', '100'), ('5', '5', '5', '500'), ('5', '5', '7', '100'), ('5', '6', '2', '200');
INSERT INTO SALES (SN, PN, JN, QTY) VALUES ('5', '1', '4', '100'), ('5', '3', '4', '200'), ('5', '4', '4', '800'), ('5', '5', '4', '400'), ('5', '6', '4', '500');
