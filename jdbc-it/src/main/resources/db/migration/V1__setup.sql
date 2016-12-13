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

-- Used for stored procedure test

CREATE TABLE ANIMAL (
  ID     BIGSERIAL    NOT NULL PRIMARY KEY,
  NAME   VARCHAR(100) NOT NULL UNIQUE,
  IS_PET BOOLEAN      NOT NULL
);

INSERT INTO ANIMAL (IS_PET, NAME) VALUES (TRUE, 'dog');
INSERT INTO ANIMAL (IS_PET, NAME) VALUES (TRUE, 'cat');
INSERT INTO ANIMAL (IS_PET, NAME) VALUES (FALSE, 'cow');

CREATE FUNCTION animal_stats(is_pet BOOLEAN, OUT count BIGINT, OUT perc REAL) AS $$
BEGIN
  count:= (SELECT count(*)
           FROM ANIMAL);
  perc:= (SELECT 100 * CAST(count(*) AS REAL) / count
          FROM ANIMAL
          WHERE ANIMAL.IS_PET = animal_stats.is_pet);
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION load_animals(is_pet BOOLEAN)
  RETURNS TABLE(ID BIGINT, NAME VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT
                 ANIMAL.ID,
                 ANIMAL.NAME
               FROM ANIMAL
               WHERE ANIMAL.IS_PET = load_animals.is_pet;
END;
$$ LANGUAGE plpgsql;

-- Used for batch updates test

CREATE TABLE CITY (
  ID            BIGSERIAL    NOT NULL PRIMARY KEY,
  NAME          VARCHAR(100) NOT NULL UNIQUE,
  MEMBERS_COUNT INT          NOT NULL
);

-- Used for streaming results test

CREATE TABLE RANDOM_STRING (
  VALUE VARCHAR(100) NOT NULL
);

-- Used for transactions test

CREATE TABLE CAKE (
  ID   BIGSERIAL    NOT NULL PRIMARY KEY,
  NAME VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO CAKE (NAME) VALUES ('opera');
INSERT INTO CAKE (NAME) VALUES ('black forest');
INSERT INTO CAKE (NAME) VALUES ('strawberry cream');

-- Used for DDL test

CREATE TABLE DEFINITION (
  ID   BIGSERIAL    NOT NULL PRIMARY KEY,
  NAME VARCHAR(100) NOT NULL
);

-- Used for special datatypes test

CREATE TABLE ITEM (
  ID         BIGSERIAL                NOT NULL PRIMARY KEY,
  CID        UUID                     NOT NULL UNIQUE,
  NAME       VARCHAR(100)             NOT NULL UNIQUE,
  CREATED_ON DATE                     NOT NULL,
  CREATED_AT TIME                     NOT NULL,
  CREATED    TIMESTAMP WITH TIME ZONE NOT NULL
);
