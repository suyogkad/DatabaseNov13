--csy 2038 group project
/*GROUP 19
RUPAK UPRETI-21421985
MIRAJ THAPA-21422038
SAKSHYAM ARYAL-
SUYOG KADARIYA-
 */


/* Creating Types*/

CREATE TYPE followUp_type AS OBJECT(
start_time VARCHAR2(50),
duration VARCHAR2(50),
start_date DATE
);
/
SHOW ERRORS

CREATE TYPE invoice_type AS OBJECT(
invoice_holder_name VARCHAR2(20),
amount NUMBER(10,2),
release_date DATE,
due_date DATE
);
/
SHOW ERRORS

CREATE OR REPLACE TYPE address_type AS OBJECT(
street VARCHAR2(50),
city VARCHAR2(50),
country VARCHAR2(50)
);
/
SHOW ERRORS

CREATE OR REPLACE TYPE room_type AS OBJECT(
room_number    VARCHAR2(4),
capacity       NUMBER(10),
description    VARCHAR2(100)
);
/
SHOW ERRORS

CREATE TYPE room_varray_type AS VARRAY(50) OF room_type;
/

--CHECKING TYPE
COLUMN object_name FORMAT A20;
SELECT object_name FROM user_objects WHERE object_type = 'TYPE';


--creating table

CREATE TABLE retreats (
retreat_id   NUMBER(6),
retreat_name VARCHAR2(30) NOT NULL,
invoice        invoice_type,
follow_up    followUp_type
);

CREATE TABLE addresses OF address_type;

CREATE TABLE settings (
setting_id        NUMBER(6),
setting_name        VARCHAR2(30)    NOT NULL,
address        REF address_type SCOPE IS addresses
);

CREATE TABLE retreat_settings (
retreat_setting_id        NUMBER(6),
setting_id        NUMBER(6)    NOT NULL,
retreat_id        NUMBER(6)    NOT NULL
);

CREATE TABLE reviews(
review_id                       NUMBER(6),
description              VARCHAR2(30)    NOT NULL,
rating                   NUMBER(30)    NOT NULL,
retreat_setting_id       NUMBER(6)
);

CREATE TABLE accomodation_styles(
accomodation_style_id        NUMBER(6),
accomodation_style_name        VARCHAR2(20)    NOT NULL
);

CREATE TABLE accomodations(
accomodation_id        NUMBER(6),
accomodation_name    VARCHAR2(50)    NOT NULL,
room        room_varray_type,
no_of_room    NUMBER(6),
description        VARCHAR2(100),
accomodation_style_id        NUMBER(6)    NOT NULL,
address        REF address_type SCOPE IS addresses
);

CREATE TABLE retreat_accomodations(
retreat_setting_id    NUMBER(6)    NOT NULL,
accomodation_id        NUMBER(6)    NOT NULL
);

--checking table
COLUMN tname FORMAT A20;
SELECT tname FROM TAB;

--sequence
CREATE SEQUENCE seq_retreats
MINVALUE 10000
MAXVALUE 999999999999999999999999999
START WITH 10000
INCREMENT BY 1
CACHE 30;

CREATE SEQUENCE seq_addresses
MINVALUE 20000
MAXVALUE 999999999999999999999999999
START WITH 20000
INCREMENT BY 1
CACHE 30;

CREATE SEQUENCE seq_settings
MINVALUE 30000
MAXVALUE 999999999999999999999999999
START WITH 30000
INCREMENT BY 1
CACHE 30;

CREATE SEQUENCE seq_retreat_settings
MINVALUE 40000
MAXVALUE 999999999999999999999999999
START WITH 40000
INCREMENT BY 1
CACHE 30;

CREATE SEQUENCE seq_reviews
MINVALUE 50000
MAXVALUE 999999999999999999999999999
START WITH 50000
INCREMENT BY 1
CACHE 30;

CREATE SEQUENCE seq_accomodation_styles
MINVALUE 60000
MAXVALUE 999999999999999999999999999
START WITH 60000
INCREMENT BY 1
CACHE 30;

CREATE SEQUENCE seq_accomodations
MINVALUE 70000
MAXVALUE 999999999999999999999999999
START WITH 70000
INCREMENT BY 1
CACHE 30;

CREATE SEQUENCE seq_retreat_accomodations
MINVALUE 80000
MAXVALUE 999999999999999999999999999
START WITH 80000
INCREMENT BY 1
CACHE 30;

COLUMN sequence_name FORMAT A20;
SELECT sequence_name FROM user_sequences;


--PK
ALTER TABLE retreats
ADD CONSTRAINT pk_retreat
PRIMARY KEY (retreat_id);

ALTER TABLE settings
ADD CONSTRAINT pk_setting
PRIMARY KEY (setting_id);

ALTER TABLE retreat_settings
ADD CONSTRAINT pk_retreat_setting
PRIMARY KEY (retreat_setting_id);

ALTER TABLE accomodation_styles
ADD CONSTRAINT pk_accomodation_style
PRIMARY KEY (accomodation_style_id);

ALTER TABLE accomodations
ADD CONSTRAINT pk_accomodation
PRIMARY KEY (accomodation_id);

--FK
ALTER TABLE retreat_settings
ADD CONSTRAINT fk_rs_retreat
FOREIGN KEY (retreat_id)
REFERENCES retreats(retreat_id);


ALTER TABLE retreat_settings
ADD CONSTRAINT fk_rs_setting
FOREIGN KEY (setting_id)
REFERENCES settings(setting_id);

ALTER TABLE reviews
ADD CONSTRAINT fk_s_setting_id
FOREIGN KEY (retreat_setting_id)
REFERENCES retreat_settings(retreat_setting_id);



ALTER TABLE accomodations
ADD CONSTRAINT fk_a_accomodation_style
FOREIGN KEY (accomodation_style_id)
REFERENCES accomodation_styles(accomodation_style_id);


ALTER TABLE retreat_accomodations
ADD CONSTRAINT fk_ra_retreat_setting_id
FOREIGN KEY (retreat_setting_id)
REFERENCES retreat_settings(retreat_setting_id);


ALTER TABLE retreat_accomodations
ADD CONSTRAINT fk_ra_accomodation_style
FOREIGN KEY (accomodation_id)
REFERENCES accomodations(accomodation_id);

--showing all pk and fk where P=primary key R=foreign key
COLUMN object_name FORMAT A20;
SELECT constraint_name 
FROM user_constraints 
WHERE constraint_type = 'P' OR constraint_type = 'R';

--FUNCTIONS
SET SERVEROUTPUT ON;




--PROCEDURES


/* procedure to add the retreats */

CREATE OR REPLACE PROCEDURE proc_add_retreat 
IS
V_RETREATID NUMBER(6);
V_NAME VARCHAR2(30);
V_INVOICE invoice_type;
V_FOLLOWUP followUp_type;

BEGIN
V_RETREATID := 100;
V_NAME := 'TESTING';
V_INVOICE := invoice_type('Simakant',400.00,TO_DATE('2022-12-09','YYYY-MM-DD'),TO_DATE('2022-12-09','YYYY-MM-DD'));
V_FOLLOWUP := followUp_type('6:30','10 minutes',TO_DATE('2022-10-06','YYYY-MM-DD'));

INSERT INTO retreats VALUES(V_RETREATID,V_NAME,V_INVOICE,V_FOLLOWUP);
COMMIT;
DBMS_OUTPUT.PUT_LINE('DATA INSERTED SUCCESSFULLY');
END proc_add_retreat;
/
SHOW ERRORS


/* procedure to list down all the retreat name with for loop */
CREATE OR REPLACE PROCEDURE proc_retreat_name
IS r_name retreats.retreat_name%TYPE;
BEGIN
FOR c IN(SELECT retreat_name INTO r_name FROM retreats)
LOOP
r_name:=c.retreat_name;
DBMS_OUTPUT.PUT_LINE(r_name);
END LOOP;
END proc_retreat_name;
/
SHOW ERRORS




/* PROCEDURE CREATED WITH CURSOR USED */
CREATE OR REPLACE PROCEDURE check_rating(in_rating NUMBER) IS
    CURSOR cur_reviews IS
    SELECT rating
    FROM reviews;

BEGIN 

    FOR rec_cur_reviews IN cur_reviews LOOP

    IF rec_cur_reviews.rating = in_rating

    THEN 
    DBMS_OUTPUT.PUT_LINE('USER EXISTS');
    END IF;

END LOOP;

EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END check_rating;
/
SHOW ERRORS





--trigger
--if setting name include number it shows error
CREATE OR REPLACE TRIGGER trig_setting_name_ck
BEFORE INSERT OR UPDATE OF setting_name ON settings
FOR EACH row
DECLARE
    vn_ck_setting_name NUMBER(3);
BEGIN
    vn_ck_setting_name:= func_check_string_num(:NEW.setting_name);

    CASE vn_ck_setting_name
        WHEN 0 THEN DBMS_OUTPUT.PUT_LINE('VALID FIRSTNAME');
        WHEN 1 THEN RAISE_APPLICATION_ERROR (-20001,'ERROR! INVALID SETTING NAME! NAME CANNOT CONTAIN NUMBERS');
        ELSE DBMS_OUTPUT.PUT_LINE('SOMETHING WENT WRONG');
    END CASE;


END trig_dob_ck;
/




/*  TRIGGER CREATED */
--while deleting the retreat it shows the message

CREATE OR REPLACE TRIGGER trig_del_retreat_name
AFTER DELETE ON retreats
FOR EACH row
BEGIN
    DBMS_OUTPUT.PUT_LINE('YOU DELETED THE RETREAT '||:OLD.retreat_name );
END trig_del_retreat_name;
/


--inserting

--retreats
INSERT INTO retreats(retreat_id,retreat_name,invoice,follow_up)
VALUES (1,'SQUATS',invoice_type('RAMAKANT',200.00,TO_DATE('1989-12-09','YYYY-MM-DD'),TO_DATE('1989-12-09','YYYY-MM-DD')),followUp_type('6:30','5 MINUTES',TO_DATE('1989-12-09','YYYY-MM-DD')));

INSERT INTO retreats(retreat_id,retreat_name,invoice,follow_up)
VALUES (112,'PUSH UP',invoice_type('JOY',500,TO_DATE('2022-10-02','YYYY-MM-DD'),TO_DATE('2022-11-02','YYYY-MM-DD')),followUp_type('6:30','5 MINUTES',TO_DATE('2022-10-03','YYYY-MM-DD')));

INSERT INTO retreats(retreat_id,retreat_name,invoice,follow_up)
VALUES (113,'ABDOMINAL CRUNCHES',invoice_type('ADAM SMITH',1200,TO_DATE('2022-10-04','YYYY-MM-DD'),TO_DATE('2022-11-05','YYYY-MM-DD')),followUp_type('6:30','10 MINUTES',TO_DATE('2022-10-05','YYYY-MM-DD')));

INSERT INTO retreats(retreat_id,retreat_name,invoice,follow_up)
VALUES (114,'SQUATS',invoice_type('REDI BLAKE',300,TO_DATE('2022-11-02','YYYY-MM-DD'),TO_DATE('2022-12-02','YYYY-MM-DD')),followUp_type('6:30','15 MINUTES',TO_DATE('2022-11-02','YYYY-MM-DD')));

INSERT INTO retreats(retreat_id,retreat_name,invoice,follow_up)
VALUES (115,'BURPEES',invoice_type('ARUSH',300,TO_DATE('2022-10-08','YYYY-MM-DD'),TO_DATE('2022-11-08','YYYY-MM-DD')),followUp_type('6:30','15 MINUTES',TO_DATE('2022-10-08','YYYY-MM-DD')));

COLUMN invoice FORMAT A25;
COLUMN retreat_setting_id FORMAT A30;
SELECT retreat_id,retreat_name,invoice FROM retreats;

-- addresses

INSERT INTO addresses (street, city, country)
VALUES ('BANEPA ROAD', 'BANEPA', 'NEPAL');

INSERT INTO addresses (street, city, country)
VALUES ('PANAUTI ROAD', 'PANAUTI', 'NEPAL');

INSERT INTO addresses (street, city, country)
VALUES ('114 CHABHAIL ROAD', 'KATHMANDU', 'NEPAL');

INSERT INTO addresses (street, city, country)
VALUES ('165 PRAKSHPUR', 'JHAPA', 'NEPAL');

INSERT INTO addresses (street, city, country)
VALUES ('93 DEVKOTA STREET', 'BIRATNAGAR', 'NEPAL');

COLUMN street FORMAT A25;
COLUMN city FORMAT A25;
COLUMN country FORMAT A25;
SELECT street, city,country FROM addresses;

-- addded address

INSERT INTO addresses (street, city, country)
VALUES ('BIHAR ROAD', 'BIHAR', 'INDIA');

INSERT INTO addresses (street, city, country)
VALUES ('KANPUR ROAD', 'KANPUR', 'INDIA');



-- settings

INSERT INTO settings(setting_id,setting_name)
VALUES(45,'WOODLAND');

UPDATE settings SET address = 
(select ref(a) FROM addresses a
WHERE a.street=' 114 CHABHAIL ROAD')
WHERE setting_id =45;


INSERT INTO settings(setting_id,setting_name)
VALUES(47,'LAKESIDE');

UPDATE settings SET address = 
(select ref(a) FROM addresses a
WHERE a.street='93 DEVKOTA STREET')
WHERE setting_id =47;

INSERT INTO settings(setting_id,setting_name)
VALUES(48,'COSTAL');

UPDATE settings SET address = 
(select ref(a) FROM addresses a
WHERE a.street='165 PRAKSHPUR')
WHERE setting_id =48;

INSERT INTO settings(setting_id,setting_name)
VALUES(49,'WINTER WONDERLAND');

UPDATE settings SET address = 
(select ref(a) FROM addresses a
WHERE a.street='BANEPA ROAD')
WHERE setting_id =49;

INSERT INTO settings(setting_id,setting_name)
VALUES(50,'PLANETARY LEY LINES');

UPDATE settings SET address = 
(select ref(a) FROM addresses a
WHERE a.street='PANAUTI ROAD')
WHERE setting_id =50;

COLUMN setting_name FORMAT A15;
SELECT setting_id,setting_name FROM settings;

-- retreat settings

INSERT INTO retreat_settings(retreat_setting_id,setting_id,retreat_id )
VALUES(1,45,1);

INSERT INTO retreat_settings(retreat_setting_id,setting_id,retreat_id )
VALUES(2,47,112);

INSERT INTO retreat_settings(retreat_setting_id,setting_id,retreat_id )
VALUES(3,48,113);

INSERT INTO retreat_settings(retreat_setting_id,setting_id,retreat_id )
VALUES(4,49,114);

INSERT INTO retreat_settings(retreat_setting_id,setting_id,retreat_id )
VALUES(5,50,115);


COLUMN retreat_setting_id FORMAT A15;
SELECT retreat_setting_id FROM retreat_settings;

-- reviews
INSERT INTO reviews(review_id,description,rating,retreat_setting_id)
VALUES(1,'SUCH A GOOD GESTURE',3,1);

INSERT INTO reviews(review_id,description,rating,retreat_setting_id)
VALUES(2,'LOVING AND ENJOYED A LOT',4,2);

INSERT INTO reviews(review_id,description,rating,retreat_setting_id)
VALUES(3,'WAS NICE BEING HERE',2,3);

INSERT INTO reviews(review_id,description,rating,retreat_setting_id)
VALUES(4,'WAS JUST AVERAGE',4,4);

INSERT INTO reviews(review_id,description,rating,retreat_setting_id)
VALUES(5,'DIDNT ENJOY MUCH',5,5);


COLUMN rating FORMAT A20;
SELECT review_id,rating,description FROM reviews;

-- accomondation style

INSERT INTO accomodation_styles(accomodation_style_id, accomodation_style_name)
VALUES(10,'LUXUARY');

INSERT INTO accomodation_styles(accomodation_style_id, accomodation_style_name)
VALUES(11,'TREEHOUSE');

INSERT INTO accomodation_styles(accomodation_style_id, accomodation_style_name)
VALUES(12,'CABIN');

INSERT INTO accomodation_styles(accomodation_style_id,accomodation_style_name )
VALUES(13,'TEEPEE');

INSERT INTO accomodation_styles(accomodation_style_id,accomodation_style_name )
VALUES(14,'RUSTIC');


COLUMN accomodation_style_name FORMAT A25;
SELECT accomodation_style_name FROM accomodation_styles;


-- accomodation

INSERT INTO accomodations(accomodation_id,accomodation_name,room,no_of_room,description,accomodation_style_id) 
VALUES(1,'SOLTI',
room_varray_type(room_type(101,6,'WELL ORGANIZED'),
room_type(102,8,'ORGANIZED NICELY'),
room_type(103,35,'ORGANIZED NICELY AND GOOD SERVICE')),
3,'LUXUARY HOTEL OF KANPUR',10);


UPDATE accomodations SET address = 
(select ref(a) FROM addresses a
WHERE a.street='KANPUR ROAD')
WHERE accomodation_id =1;


INSERT INTO accomodations(accomodation_id,accomodation_name,room,no_of_room,description,accomodation_style_id) 
VALUES(2,'MY TREE HOME',
room_varray_type(room_type(111,4,'GOOD'),
room_type(112,3,'ORGANIZED NICELY'),
room_type(113,3,'WELL CLEANED'),
room_type(114,3,'GOOD ROOM SERVICE')),
4,'ONE AND ONLY TREE ACCOMODATION IN BIHAR',11);


UPDATE accomodations SET address = 
(select ref(a) FROM addresses a
WHERE a.street='BIHAR ROAD')
WHERE accomodation_id =2;


INSERT INTO accomodations(accomodation_id,accomodation_name,room,no_of_room,description,accomodation_style_id) 
VALUES(3,'DWARIKA',
room_varray_type(room_type(10,4,'GOOD'),
room_type(12,3,'ORGANIZED NICELY'),
room_type(11,3,'GOOD ROOM SERVICE')),
3,'ONE AND ONLY TREE ACCOMODATION IN BIHAR',11);


UPDATE accomodations SET address = 
(select ref(a) FROM addresses a
WHERE a.street='93 DEVKOTA STREET')
WHERE accomodation_id =3;


INSERT INTO accomodations(accomodation_id,accomodation_name,room,no_of_room,description,accomodation_style_id) 
VALUES(4,'SNG',
room_varray_type(room_type(501,2,'WELL ORGANIZED'),
room_type(502,2,'GOOD SERVICE'),
room_type(503,2,'GOOD ROOMS')),
3,'GET GOOD SERVICE HERE',11);


UPDATE accomodations SET address = 
(select ref(a) FROM addresses a
WHERE a.street='101 NAGARKOT STREET')
WHERE accomodation_id =4;

COLUMN room FORMAT A15;
COLUMN accomodation_name FORMAT A25;
SELECT accomodation_id,accomodation_name,room,no_of_room FROM accomodations;

--RETREAT ACCOMODATIONS
INSERT INTO retreat_accomodations(retreat_setting_id,accomodation_id)
VALUES(1,1);

INSERT INTO retreat_accomodations(retreat_setting_id,accomodation_id)
VALUES(2,2);

INSERT INTO retreat_accomodations(retreat_setting_id,accomodation_id)
VALUES(3,3);

INSERT INTO retreat_accomodations(retreat_setting_id,accomodation_id)
VALUES(4,4);

SELECT retreat_setting_id,accomodation_id FROM retreat_accomodations;


--QUERY AND TESTING

--DROP


--TRIGGERS
DROP TRIGGER trig_setting_name_ck;
DROP TRIGGER trig_del_retreat_name;

--PROCEDURES
DROP PROCEDURE proc_add_retreat;
DROP PROCEDURE proc_retreat_name;
DROP PROCEDURE check_rating;

--FUNCTIONS

DROP FUNCTION 
DROP FUNCTION 
DROP FUNCTION 

--FOREIGN KEY

ALTER TABLE retreat_settings
DROP CONSTRAINT fk_rs_retreat;

ALTER TABLE retreat_settings
DROP CONSTRAINT fk_rs_setting;

ALTER TABLE reviews
DROP CONSTRAINT fk_s_setting_id;

ALTER TABLE accomodations
DROP CONSTRAINT fk_a_accomodation_style;

ALTER TABLE retreat_accomodations
DROP CONSTRAINT fk_ra_retreat_setting_id;

ALTER TABLE retreat_accomodations
DROP CONSTRAINT fk_ra_accomodation_style;

--PRIMARY KEY

ALTER TABLE retreats
DROP CONSTRAINT pk_retreat;


ALTER TABLE settings
DROP CONSTRAINT pk_setting;


ALTER TABLE retreat_settings
DROP CONSTRAINT pk_retreat_setting;


ALTER TABLE accomodation_styles
DROP CONSTRAINT pk_accomodation_style;


ALTER TABLE accomodations
DROP CONSTRAINT pk_accomodation;

--TABLES

DROP TABLE retreats;
DROP TABLE addresses;
DROP TABLE settings;
DROP TABLE retreat_settings;
DROP TABLE reviews;
DROP TABLE accomodation_styles;
DROP TABLE accomodations;
DROP TABLE retreat_accomodations;

--SEQUENCES
DROP SEQUENCE seq_retreats;
DROP SEQUENCE seq_addresses;
DROP SEQUENCE seq_settings;
DROP SEQUENCE seq_retreat_settings;
DROP SEQUENCE seq_reviews;
DROP SEQUENCE seq_accomodation_styles;
DROP SEQUENCE seq_accomodations;
DROP SEQUENCE seq_retreat_accomodations;


--OBJECT TABLE
DROP TABLE addresses;

--VARRAY TYPE
DROP TYPE room_varray_type;

--TABLE TYPE
DROP TYPE followUp_type;
DROP TYPE invoice_type;
DROP TYPE address_type; 
DROP TYPE room_type ;


--purging
PURGE RECYCLEBIN;
