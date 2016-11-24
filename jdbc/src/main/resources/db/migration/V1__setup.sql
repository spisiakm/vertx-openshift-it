-- Used for query with params test

CREATE TABLE PERSON (
  ID   BIGSERIAL    NOT NULL PRIMARY KEY,
  NAME VARCHAR(100) NOT NULL
);

INSERT INTO PERSON (NAME) VALUES ('toto');
INSERT INTO PERSON (NAME) VALUES ('titi');
INSERT INTO PERSON (NAME) VALUES ('tata');

-- Used for CRUD test

CREATE TABLE SHIP (
  ID   BIGSERIAL    NOT NULL PRIMARY KEY,
  NAME VARCHAR(100) NOT NULL
);

INSERT INTO SHIP (NAME) VALUES ('titanic');
INSERT INTO SHIP (NAME) VALUES ('france');
INSERT INTO SHIP (NAME) VALUES ('queen mary');

-- Used for update with params test

CREATE TABLE CAR (
  ID   BIGSERIAL    NOT NULL PRIMARY KEY,
  NAME VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO CAR (NAME) VALUES ('flash');
INSERT INTO CAR (NAME) VALUES ('martin');
INSERT INTO CAR (NAME) VALUES ('sally');
