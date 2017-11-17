USE master
GO

IF  EXISTS (
	SELECT name
FROM sys.databases
WHERE name = N'Belyov_lab2'
)
ALTER DATABASE [Belyov_lab2] set single_user with rollback immediate
GO

IF  EXISTS (
	SELECT name
FROM sys.databases
WHERE name = N'Belyov_lab2'
)
DROP DATABASE [Belyov_lab2]
GO

CREATE DATABASE [Belyov_lab2]
GO

USE [Belyov_lab2]
GO

IF EXISTS(
  SELECT *
FROM sys.schemas
WHERE name = N'lab2'
) 
 DROP SCHEMA lab2
GO

CREATE SCHEMA lab2 
GO

IF OBJECT_ID('[Belyov_lab2].lab2.MainRegions', 'U') IS NOT NULL
  DROP TABLE  [Belyov_lab2].lab2.MainRegions
GO

IF OBJECT_ID('[Belyov_lab2].lab2.SecondaryRegions', 'U') IS NOT NULL
  DROP TABLE  [Belyov_lab2].lab2.SecondaryRegions
GO

IF OBJECT_ID('[Belyov_lab2].lab2.Cars', 'U') IS NOT NULL
  DROP TABLE  Belyov_lab2.lab2.Cars
GO

IF OBJECT_ID('[Belyov_lab2].lab2.Directions', 'U') IS NOT NULL
  DROP TABLE  [Belyov_lab2].lab2.Directions
GO

IF OBJECT_ID('[Belyov_lab2].lab2.Passes', 'U') IS NOT NULL
  DROP TABLE  Belyov_lab2.lab2.Passes
GO

CREATE TABLE lab2.MainRegions
(
  RegionId INT NOT NULL,
  RegionName NVARCHAR(100) NOT NULL,
  CONSTRAINT PK_RegionID PRIMARY KEY(RegionId)
)
GO

INSERT INTO lab2.MainRegions
VALUES
  (1, 'Республика Адыгея'),
  (16, 'Республика Татарстан'),
  (23, 'Краснодарский край'),
  (48, 'Липецкая область'),
  (66, 'Свердловская область'),
  (77, 'Москва')

CREATE TABLE lab2.SecondaryRegions
(
  SecondaryRegId INT NOT NULL,
  PrimaryRegId INT NOT NULL,
  CONSTRAINT PK_SecondaryRegId PRIMARY KEY(SecondaryRegId),
  CONSTRAINT FK_PrimaryRegId FOREIGN KEY (PrimaryRegId)
  REFERENCES lab2.MainRegions(RegionId)
  ON UPDATE CASCADE
)
GO

INSERT INTO lab2.SecondaryRegions
VALUES
  (66, 66),
  (96, 66),
  (196, 66),
  (1, 1),
  (16, 16),
  (116, 16),
  (716, 16),
  (23, 23),
  (93, 23),
  (123, 23),
  (48, 48),
  (77, 77),
  (97, 77),
  (99, 77),
  (177, 77),
  (197, 77),
  (199, 77),
  (777, 77),
  (799, 77)
GO

CREATE TABLE lab2.Directions
(
  DirectionId TINYINT IDENTITY(0,1) NOT NULL,
  DirectionName nvarchar(10) NOT NULL,
  CONSTRAINT PK_DirectionId PRIMARY KEY(DirectionId)
)
GO

INSERT INTO lab2.Directions
VALUES
  (N'Выезд'),
  (N'Въезд')

CREATE TABLE lab2.Cars
(
  CarId int IDENTITY(1,1),
  CarNumber NVARCHAR(6) NOT NULL,
  CarRegionNum INT NOT NULL,
  CONSTRAINT PK_CarId PRIMARY KEY(CarId),
  CONSTRAINT FK_CarRegionNum FOREIGN KEY (CarRegionNum)
  REFERENCES lab2.SecondaryRegions(SecondaryRegId)
  ON UPDATE CASCADE
)
GO

CREATE FUNCTION lab2.LettersAreValid(@CarNumber NVARCHAR(6))
RETURNS BIT
AS
BEGIN
  DECLARE @letters NVARCHAR(3);
  SET @letters=SUBSTRING(@CarNumber, 1,1)+SUBSTRING(@CarNumber,5,2);
  DECLARE @counter tinyint;
  DECLARE @validLetters NVARCHAR(40);
  SET @validLetters=N'ETYOPAHKXCBMУКЕНХВАРОСМТ'
  SET @counter=1;
  WHILE @counter<=3
	BEGIN
    DECLARE @letter nvarchar(1);
    SET @letter=UPPER(SUBSTRING(@letters,@counter,1));
    IF CHARINDEX(@letter, @validLetters)=0
			RETURN(0);
    SET @counter=@counter+1;
  END
  RETURN(1);
END;
GO

CREATE FUNCTION lab2.NumberIsValid(@CarNumber NVARCHAR(6))
RETURNS BIT
AS
BEGIN
  DECLARE @Result BIT;
  SET @Result=1;
  IF NOT (LEN(@CarNumber)=6)
    RETURN(0);
  DECLARE @NumPart int;
  SET @NumPart=SUBSTRING(@CarNumber, 2, 3);
  IF ISNUMERIC(@NumPart)=0 OR CONVERT(int, @NumPart)<1 OR CONVERT(int, @NumPart)>999
    RETURN(0);
  RETURN(lab2.LettersAreValid(@CarNumber));
END
GO

ALTER TABLE lab2.Cars ADD CONSTRAINT NumberValidity
  CHECK (lab2.NumberIsValid(CarNumber)=1)
GO

CREATE TRIGGER lab2.RegionIsValid
ON lab2.Cars
AFTER INSERT
AS
BEGIN
  IF EXISTS(SELECT *
  FROM lab2.Cars
  WHERE (LEN(CarRegionNum)>3) OR (LEN(CarRegionNum)=3 AND SUBSTRING(CONVERT(varchar,CarRegionNum),1,1) NOT LIKE '[127]'))
  BEGIN
    RAISERROR(15600,-1,-1,'Некорректный формат региона');
    ROLLBACK TRANSACTION;
    RETURN
  END
END
GO

INSERT INTO lab2.Cars
VALUES
  ('а123аа', 66),
  ('а123аа', 96),
  ('м754он', 777),
  ('p001ec', 01),
  ('х965кр', 23),
  ('н983уе', 196)
-- ,
-- ('a000cc',23)
-- ,
-- ('б343йщ',196)
-- ,
-- ('м453но',650)
GO

SELECT *
FROM lab2.Cars
GO

CREATE TABLE lab2.Passes
(
  PassId int IDENTITY(1,1) NOT NULL,
  PassTime TIME NOT NULL,
  CarId int NOT NULL,
  PostId int NOT NULL,
  DirectionId TINYINT NOT NULL,
  CONSTRAINT FK_CarId FOREIGN KEY (CarId)
  REFERENCES lab2.Cars(CarId)
  ON UPDATE CASCADE,
  CONSTRAINT FK_DirectionId FOREIGN KEY (DirectionId)
  REFERENCES lab2.Directions(DirectionId)
  ON UPDATE CASCADE
)
GO

CREATE FUNCTION lab2.DirectionIsValid(@CarId int, @PostId tinyint, @DirectionId tinyint)
RETURNS bit
AS
BEGIN
  DECLARE @sameDirsCount int;
  SET @sameDirsCount=(SELECT COUNT(*)
  FROM lab2.Passes
  WHERE CarId=@CarId AND DirectionId=@DirectionId);
  IF @sameDirsCount=1
    RETURN(1);
  DECLARE @lastIn int;
  SET @lastIn=(SELECT TOP 1
    t.passId
  FROM (SELECT TOP 2 Passes.PassId
    FROM lab2.Passes
    WHERE CarId=@CarId AND DirectionId=@DirectionId
    ORDER BY PassId DESC) as t
  ORDER BY PassId);
  DECLARE @outs int;
  SET @outs=(SELECT COUNT(*)
  FROM lab2.Passes
  WHERE CarId=@CarId AND NOT DirectionId=@DirectionId);
  IF (@lastIn>@outs)
    RETURN(0);
  RETURN(1);
END
GO

ALTER TABLE lab2.Passes ADD CONSTRAINT DirectionValidity
  CHECK (lab2.DirectionIsValid(CarId, PostId, DirectionId)=1)
GO

INSERT INTO lab2.Passes
VALUES
  -- Транзитные для 66
  ('10:30:00', 3, 2, 1),
  ('12:00:00', 3, 3, 0),
  ('21:45:23', 4, 1, 1),
  ('23:59:59', 4, 4, 0),
  -- Местные для 66
  ('10:00:00', 1, 1, 0),
  ('10:01:00', 1 , 1, 1),
  ('14:37:32', 2, 3, 0),
  ('23:01:00', 2, 2, 1),
  --Иногородние
  ('15:00:00', 5, 2, 1),
  ('21:00:00', 5, 2, 0),
  -- Прочие
  ('11:00:01', 6 , 3, 1),
  ('15:00:15', 6, 2, 0)

SELECT *
FROM lab2.Passes
GO

-- Транзитные
DECLARE @CurRegion int
SET @CurRegion=66

SELECT (car.CarNumber+FORMAT(car.CarRegionNum, '0#')) as 'Номер',
  region.RegionName as 'Регион',
  FORMAT(this.PassTime, 'hh\:mm') as 'Время въезда',
  this.PostId as 'Пост',
  FORMAT(other.PassTime, 'hh\:mm') as 'Время выезда',
  other.PostId as 'Пост'
FROM lab2.Passes as this
  INNER JOIN lab2.Cars as car
  ON car.CarId=this.CarId
  INNER JOIN lab2.SecondaryRegions as secRegion
  ON car.CarRegionNum=secRegion.SecondaryRegId
  INNER JOIN lab2.MainRegions as region
  ON secRegion.PrimaryRegId=region.RegionId,
  lab2.Passes as other
WHERE this.CarId=other.CarId AND this.PostId!=other.PostId
  AND this.DirectionId>other.DirectionId AND region.RegionId!=@CurRegion
GO

-- Иногородние
SELECT (car.CarNumber+FORMAT(car.CarRegionNum, '0#')) as 'Номер',
  region.RegionName as 'Регион',
  FORMAT(this.PassTime, 'hh\:mm') as 'Время въезда',
  this.PostId as 'Пост',
  FORMAT(other.PassTime, 'hh\:mm') as 'Время выезда',
  other.PostId as 'Пост'
FROM lab2.Passes as this
  INNER JOIN lab2.Cars as car
  ON car.CarId=this.CarId
  INNER JOIN lab2.SecondaryRegions as secRegion
  ON car.CarRegionNum=secRegion.SecondaryRegId
  INNER JOIN lab2.MainRegions as region
  ON secRegion.PrimaryRegId=region.RegionId,
  lab2.Passes as other
WHERE this.CarId=other.CarId AND this.PostId=other.PostId
  AND this.DirectionId>other.DirectionId AND this.PassId<other.PassId
GO

-- Местные
DECLARE @CurRegion int
SET @CurRegion=66

SELECT (car.CarNumber+FORMAT(car.CarRegionNum, '0#')) as 'Номер',
  region.RegionName as 'Регион',
  FORMAT(this.PassTime, 'hh\:mm') as 'Время выезда',
  FORMAT(other.PassTime, 'hh\:mm') as 'Время въезда'
FROM lab2.Passes as this
  INNER JOIN lab2.Cars as car
  ON car.CarId=this.CarId
  INNER JOIN lab2.SecondaryRegions as secRegion
  ON car.CarRegionNum=secRegion.SecondaryRegId
  INNER JOIN lab2.MainRegions as region
  ON secRegion.PrimaryRegId=region.RegionId,
  lab2.Passes as other
WHERE this.CarId=other.CarId AND this.DirectionId<other.DirectionId AND
  this.PassTime<other.PassTime AND region.RegionId=@CurRegion
GO

-- Прочие
DECLARE @CurRegion int
SET @CurRegion=66

SELECT (car.CarNumber+FORMAT(car.CarRegionNum, '0#')) as 'Номер',
  region.RegionName as 'Регион',
  FORMAT(this.PassTime, 'hh\:mm') as 'Время 1',
  this.PostId as 'Пост',
  thisDir.DirectionName as 'Направление',
  FORMAT(other.PassTime, 'hh\:mm') as 'Время 2',
  this.PostId as 'Пост',
  otherDir.DirectionName as 'Направление'
FROM lab2.Passes as this
  INNER JOIN lab2.Cars as car
  ON car.CarId=this.CarId
  INNER JOIN lab2.SecondaryRegions as secRegion
  ON car.CarRegionNum=secRegion.SecondaryRegId
  INNER JOIN lab2.MainRegions as region
  ON secRegion.PrimaryRegId=region.RegionId
  INNER JOIN lab2.Directions as thisDir
  ON this.DirectionId=thisDir.DirectionId,
  lab2.Passes as other
  INNER JOIN lab2.Directions as otherDir
  ON other.DirectionId=otherDir.DirectionId
WHERE NOT ((this.PostId!=other.PostId
    AND this.DirectionId>other.DirectionId AND region.RegionId!=@CurRegion) OR (this.PostId=other.PostId
    AND this.DirectionId>other.DirectionId AND this.PassId<other.PassId) OR (this.DirectionId<other.DirectionId AND
    this.PassTime<other.PassTime AND region.RegionId=@CurRegion)) AND this.PassTime<other.PassTime AND this.CarId=other.CarId