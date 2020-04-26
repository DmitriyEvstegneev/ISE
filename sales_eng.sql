CREATE DOMAIN NAME AS TEXT
	NOT NULL;

CREATE TABLE S
(
	SN SERIAL NOT NULL PRIMARY KEY,
	SNAME NAME NOT NULL,
	STATUS INTEGER NOT NULL,
	CITY TEXT NOT NULL,
	CONSTRAINT status_value CHECK (STATUS >= 1 AND STATUS <= 100)
);

CREATE TABLE P
(
	PN SERIAL NOT NULL PRIMARY KEY,
	PNAME NAME NOT NULL,
	COLOR TEXT NOT NULL,
	WEIGHT INTEGER NOT NULL,
	CITY TEXT NOT NULL
);

CREATE TABLE J
(
	JN SERIAL NOT NULL PRIMARY KEY,
	JNAME NAME NOT NULL,
	CITY TEXT NOT NULL
);

CREATE TABLE SPJ
(
	SN INTEGER NOT NULL REFERENCES S (SN) ON DELETE CASCADE,
	PN INTEGER NOT NULL REFERENCES P (PN) ON DELETE CASCADE,
	JN INTEGER NOT NULL REFERENCES J (JN) ON DELETE CASCADE,
	QTY INTEGER NOT NULL,
	PRIMARY KEY (SN, PN, JN)
);

INSERT INTO S (SN, SNAME, STATUS, CITY) VALUES ('1', 'Smith', '20', 'London'), ('2', 'Jones', '10', 'Paris'), ('3', 'Blake', '30', 'Paris'), ('4', 'Clark', '20', 'London'), ('5', 'Adams', '30', 'Athens');

INSERT INTO P (PN, PNAME, COLOR, WEIGHT, CITY) VALUES ('1', 'Nut', 'Red', '12', 'London'), ('2', 'Bolt', 'Green', '17', 'Paris'), ('3', 'Screw', 'Blue', '17', 'Oslo'), ('4', 'Screw', 'Red', '14', 'London'), ('5', 'Cam', 'Blue', '12', 'Paris'), ('6', 'Cog', 'Red', '19', 'London');

INSERT INTO J (JN, JNAME, CITY) VALUES ('1', 'Sorter', 'Paris'), ('2', 'Display', 'Rome'), ('3', 'OCR', 'Athens'), ('4', 'Console', 'Athens'), ('5', 'RAID', 'London'), ('6', 'EDS', 'Oslo'), ('7', 'Tape', 'London');

INSERT INTO SPJ (SN, PN, JN, QTY) VALUES ('1', '1', '1', '200'), ('1', '1', '4', '700'), ('2', '3', '1', '400'), ('2', '3', '2', '200'), ('2', '3', '3', '200');
INSERT INTO SPJ (SN, PN, JN, QTY) VALUES ('2', '3', '4', '500'), ('2', '3', '5', '600'), ('2', '3', '6', '400'), ('2', '3', '7', '800'), ('2', '5', '2', '100');
INSERT INTO SPJ (SN, PN, JN, QTY) VALUES ('3', '3', '1', '200'), ('3', '4', '2', '500'), ('4', '6', '3', '300'), ('4', '6', '7', '300');
INSERT INTO SPJ (SN, PN, JN, QTY) VALUES ('5', '2', '2', '200'), ('5', '2', '4', '100'), ('5', '5', '5', '500'), ('5', '5', '7', '100'), ('5', '6', '2', '200');
INSERT INTO SPJ (SN, PN, JN, QTY) VALUES ('5', '1', '4', '100'), ('5', '3', '4', '200'), ('5', '4', '4', '800'), ('5', '5', '4', '400'), ('5', '6', '4', '500');
