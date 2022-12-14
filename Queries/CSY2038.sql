--csy 2038 group project
/*GROUP 19
RUPAK UPRETI-21421985
MIRAJ THAPA-21422038
SAKSHYAM ARYAL-
SUYOG KADARIYA-
 */

--@C:\Users\acer\Desktop\dbpull\DatabaseNov13\Queries\CSY2038.sql
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
/*  FUNCTION -----------------*/



/* to get the average rating from the accomodations review */
-- here we have use AVG inbuilt function to get the average
CREATE OR REPLACE FUNCTION func_avg_rating RETURN NUMBER IS
vn_number_average NUMBER(5);
BEGIN 
    SELECT AVG(rating)
    INTO vn_number_average
    FROM reviews;
RETURN vn_number_average;
END func_avg_rating;
/
SHOW ERRORS;





/* function to get the total sum of the invoice amount */

CREATE OR REPLACE FUNCTION func_total_amount
RETURN NUMBER IS
	total_sum NUMBER(5);
BEGIN
	SELECT SUM(i.invoice.amount) INTO total_sum
     	FROM retreats i;
	RETURN total_sum;
END; 
/
SHOW ERRORS;

/* function to convert the string to the number */

CREATE FUNCTION func_number_ho(p_string IN VARCHAR2)
   RETURN INT
IS
   v_new_num NUMBER;
BEGIN
   v_new_num := TO_NUMBER(p_string);
   RETURN 1;
EXCEPTION
WHEN VALUE_ERROR THEN
   RETURN 0;
END func_number_ho;
/
SHOW ERRORS;

--PROCEDURES

/* procedure to insert into the retreats */
-- variables are declared and then inserted the data into the table
CREATE OR REPLACE PROCEDURE proc_add_retreat 
IS
V_RETREATID NUMBER(6);
V_NAME VARCHAR2(30);
V_INVOICE invoice_type;
V_FOLLOWUP followUp_type;

BEGIN
V_RETREATID := 149;
V_NAME := 'TESTING';
V_INVOICE := invoice_type('Simakant',400.00,TO_DATE('2022-12-09','YYYY-MM-DD'),TO_DATE('2022-12-09','YYYY-MM-DD'));
V_FOLLOWUP := followUp_type('6:30','10 minutes',TO_DATE('2022-10-06','YYYY-MM-DD'));

INSERT INTO retreats VALUES(V_RETREATID,V_NAME,V_INVOICE,V_FOLLOWUP);

COMMIT;
DBMS_OUTPUT.PUT_LINE('DATA INSERTED SUCCESSFULLY');
END proc_add_retreat;
/

SHOW ERRORS;



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

SHOW ERRORS;

/* --IMPLICIT CURSOR USED  run*/
CREATE OR REPLACE PROCEDURE proc_cur_del_address(in_city VARCHAR2) IS
BEGIN
-- delete query after checking to the city
    DELETE FROM addresses WHERE city= in_city;
    IF SQL%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('CITY ||"in_city"||  WAS DELETED!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('CITY NOT FOUND!');
    END IF;
END proc_cur_del_address;
/
SHOW ERRORS





/* --IMPLICIT CURSOR USED run*/

CREATE OR REPLACE PROCEDURE check_rating(in_rating NUMBER) IS
    CURSOR cur_reviews IS
    SELECT rating
    FROM reviews;

BEGIN 

    FOR rec_cur_reviews IN cur_reviews LOOP

    IF rec_cur_reviews.rating = in_rating

    THEN 
    DBMS_OUTPUT.PUT_LINE('RATING EXISTS');
    END IF;

END LOOP;

EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END check_rating;
/

SHOW ERRORS;

/*........CURSOR-------------------------------------------------------------*/
DECLARE 
   cur_retreat_id retreats.retreat_id %type; 
   cur_retreat_name retreats.retreat_name%type; 

   CURSOR cur_retreats is 
      SELECT retreat_id, retreat_name FROM retreats; 
BEGIN 
   OPEN cur_retreats; 
   LOOP 
   FETCH cur_retreats into cur_retreat_id, cur_retreat_name; 
      EXIT WHEN cur_retreats%notfound; 
     DBMS_OUTPUT.PUT_LINE(cur_retreat_id  ||  '  '  ||  cur_retreat_name);
   END LOOP; 
   CLOSE cur_retreats; 
END; 
/
SHOW ERRORS;


--trigger

--1 
/* To check if the name of setting contains error and to throw error if the name contains number */
CREATE OR REPLACE TRIGGER trig_setting_name_ck
BEFORE INSERT OR UPDATE OF setting_name ON settings
FOR EACH row
DECLARE
    vn_ck_setting_name NUMBER(3);
BEGIN
    vn_ck_setting_name:= func_number_ho(:NEW.setting_name);

    CASE vn_ck_setting_name
        WHEN 0 THEN DBMS_OUTPUT.PUT_LINE('VALID FIRSTNAME');
        WHEN 1 THEN RAISE_APPLICATION_ERROR (-20001,'ERROR! INVALID SETTING NAME! NAME CANNOT CONTAIN NUMBERS');
        ELSE DBMS_OUTPUT.PUT_LINE('SOMETHING WENT WRONG');
    END CASE;


END trig_setting_name_ck;
/


SHOW ERRORS;
--2
/*  To throw the message that the retreat is deleted after the retreat is deleted */

CREATE OR REPLACE TRIGGER trig_del_retreat_name
AFTER DELETE ON retreats
FOR EACH row
BEGIN
    DBMS_OUTPUT.PUT_LINE('YOU DELETED THE RETREAT '||:OLD.retreat_name );
END trig_del_retreat_name;
/

SHOW ERRORS;
--3
/*To throw message that no duplicate accommodation id, name can be created */
CREATE OR REPLACE TRIGGER trig_duplicate_no_insert
BEFORE INSERT
ON accomodations
FOR EACH ROW
DECLARE
    CURSOR accomodation_cursor IS
    SELECT accomodation_id, accomodation_name, room, no_of_room, description, accomodation_style_id, address
    FROM accomodations;
    accomodation_row accomodation_cursor%rowtype;
BEGIN
    FOR accomodation_row IN accomodation_cursor
    LOOP
        IF :new.accomodation_id = accomodation_row.accomodation_id 
            and :new.accomodation_name = accomodation_row.accomodation_name
            and :new.accomodation_style_id = accomodation_row.accomodation_style_id THEN

            raise_application_error(-20000, 'cannot create duplicate version of accomodation');
        END IF;
    END LOOP;
END;
/

SHOW ERRORS;




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
COLUMN review_id HEADING ???REVIEW???
COLUMN ROUND(rating) HEADING 'ROUND'
COLUMN FLOOR(rating) HEADING 'FLOOR'
COLUMN CEIL(rating) HEADING 'CEIL'
SELECT review_id, ROUND(rating), FLOOR(rating),CEIL(rating) , rating
FROM reviews  
WHERE rating = (
	SELECT MAX(rating)
	FROM reviews
);



COLUMN settting_id HEADING ???SettingId???
COLUMN address.street HEADING 'Street' FORMAT A30
COLUMN address.city HEADING 'City' FORMAT A20
COLUMN address.country HEADING 'Country' FORMAT A15
SELECT s.setting_id,s.address.street, s.address.city, s.address.country
FROM settings s
WHERE s.address.city IN (
	SELECT a.address.city
	FROM accomodations a
	WHERE a.address.country = ???NEPAL???
);




COLUMN accomodation_style_id HEADING ???AccomodationStyleID'
COLUMN accomodation_style_name HEADING ???AccomodationStyleName???
COLUMN accomodation_description HEADING ???AccomodationDescription???
SELECT a.accomodation_style_id,a.accomodation_style_name,r.description
FROM accomodation_styles a
JOIN accomodations r
ON a.accomodation_style_id = r.accomodation_style_id
WHERE a.accomodation_style_id=11;


COLUMN accomodation_style_id HEADING ???AccomodationStyleID'
COLUMN accomodation_style_name HEADING ???AccomodationStyleName???
COLUMN accomodation_description HEADING ???AccomodationDescription???
SELECT a.accomodation_style_id,a.accomodation_style_name,r.description
FROM accomodation_styles a
JOIN accomodations r
ON a.accomodation_style_id = r.accomodation_style_id;



COLUMN setting_name HEADING ???SettingName???
COLUMN DEREF(address) HEADING 'AddressTYPE???
SELECT setting_name, DEREF(address) 
FROM settings;


COLUMN accomodation_id HEADING ???AccomodationID'
COLUMN accomodation_name HEADING ???AccomodationName???
COLUMN description HEADING ???Description???
COLUMN room_number HEADING ???RoomNo???
SELECT a.accomodation_id, a.accomodation_name, a.description, r.room_number, r.description
FROM accomodations a, TABLE(a.room) r
WHERE r.room_number = 501;



EXEC proc_add_retreat ;
EXEC proc_retreat_name;
EXEC proc_cur_del_address('JHAPA');
EXEC check_rating(in_rating NUMBER);


--TRIGGER TESTING trig_setting_name_ck

INSERT INTO settings(setting_id,setting_name)
VALUES(900,22);
--putting setting name as 22 to fire the trigger
DELETE FROM settings WHERE setting_id=900;
--deleteing the  insert
--AS THE SETTING NAME IS ALPHANUMERIC BUT AS PER OUR TRIGGER SETTING NAME SHOULD NOT CONTAIN NUMBER
--IT SHOULD FIRE THE TRIGGER
---20001,'ERROR! INVALID SETTING NAME! NAME CANNOT CONTAIN NUMBERS'


--TRIGGER TESTING trig_del_retreat_name

INSERT INTO retreats(retreat_id,retreat_name)
VALUES (77,'BEND OVER ROW');

DELETE FROM retreats WHERE retreat_name='BEND OVER ROW';
--inserting to dleete 
--shows you deleted the retreat

--TRIGGER TESTING trig_duplicate_no_insert
INSERT INTO accomodations(accomodation_id,accomodation_name,accomodation_style_id) 
VALUES(4,'SNG',11);
--trigger fired
--after inserting the same value which was stored it throws error
---20000, 'cannot create duplicate version of accomodation'


--DROP

--TRIGGERS
DROP TRIGGER trig_setting_name_ck;
DROP TRIGGER trig_del_retreat_name;
DROP TRIGGER trig_duplicate_no_insert;

--PROCEDURES
DROP PROCEDURE proc_add_retreat;
DROP PROCEDURE proc_retreat_name;

--FUNCTIONS

DROP FUNCTION  func_avg_rating;
DROP FUNCTION func_total_amount;
DROP FUNCTION func_number_ho;

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

--VARRAY TYPE
DROP TYPE room_varray_type;

--TABLE TYPE
DROP TYPE followUp_type;
DROP TYPE invoice_type;
DROP TYPE address_type; 
DROP TYPE room_type ;


--purging
PURGE RECYCLEBIN;
