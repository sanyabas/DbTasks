USE master
GO

IF  EXISTS (
	SELECT name
FROM sys.databases
WHERE name = N'Belyov_lab1'
)
ALTER DATABASE [Belyov_lab1] set single_user with rollback immediate
GO

IF  EXISTS (
	SELECT name
FROM sys.databases
WHERE name = N'Belyov_lab1'
)
DROP DATABASE [Belyov_lab1]
GO

CREATE DATABASE [Belyov_lab1]
GO

USE [Belyov_lab1]
GO

IF EXISTS(
  SELECT *
FROM sys.schemas
WHERE name = N'lab1'
) 
 DROP SCHEMA lab1
GO

CREATE SCHEMA lab1 
GO

IF OBJECT_ID('[Belyov_lab1].lab1.Stations', 'U') IS NOT NULL
  DROP TABLE  [Belyov_lab1].Фамилия.Stations
GO

IF OBJECT_ID('[Belyov_lab1].lab1.Units', 'U') IS NOT NULL
  DROP TABLE  Belyov_lab1.lab1.Units
GO

IF OBJECT_ID('[Belyov_lab1].lab1.Measurements', 'U') IS NOT NULL
  DROP TABLE  Belyov_lab1.Фамилия.Measurements
GO

CREATE TABLE [Belyov_lab1].lab1.Stations
(
	StationID tinyint IDENTITY(1,1),
	Name nvarchar(40) NOT NULL,
	City nvarchar(40) NOT NULL,
	CONSTRAINT PK_StationID PRIMARY KEY(StationID)
)
GO

CREATE TABLE [Belyov_lab1].lab1.Units
(
	UnitID tinyint IDENTITY(1,1),
	Name nvarchar(40) NOT NULL,
	Unit nvarchar(10) NOT NULL,
	CONSTRAINT PK_UnitID PRIMARY KEY(UnitID)
)
GO

CREATE TABLE [Belyov_lab1].lab1.Measurements
(
	MeasurementID int IDENTITY(1,1),
	StationID tinyint NOT NULL,
	UnitID tinyint NOT NULL,
	MeasureDate date NOT NULL,
	Result float NOT NULL,
	CONSTRAINT PK_MeasurementID PRIMARY KEY(MeasurementID),
	CONSTRAINT FK_StationID FOREIGN KEY (StationID) 
	REFERENCES Belyov_lab1.lab1.Stations(StationID)
	ON UPDATE CASCADE,
	CONSTRAINT FK_UnitID FOREIGN KEY (UnitID) 
	REFERENCES Belyov_lab1.lab1.Units(UnitID)
	ON UPDATE CASCADE
)
GO

INSERT INTO Belyov_lab1.lab1.Units
VALUES
	(N'Температура', N'°С')
 ,
	(N'Атмосферное давление', N'мм.рт.ст.')
 ,
	(N'Влажность', N'%')
 ,
	(N'Количество осадков', N'мм')
 ,
	(N'Скорость ветра', N'м/с')

--SELECT * FROM Belyov_lab1.lab1.Units

INSERT INTO Belyov_lab1.lab1.Stations
VALUES
	(N'Мирный', N'Мирный')
	,
	(N'Ленинградская', N'Антарктида')
	,
	(N'Дабады', N'Дабады')
	,
	(N'ВДНХ', N'Москва')
	,
	(N'Тушино', N'Москва')

--SELECT * FROM Belyov_lab1.lab1.Stations
--GO

INSERT INTO Belyov_lab1.lab1.Measurements
VALUES
	(1, 1, '2015-11-1', -15)
	,
	(1, 2, '2015-11-1', 740)
	,
	(1, 3, '2015-11-1', 40)
	,
	(1, 4, '2015-11-1', 10)
	,
	(1, 5, '2015-11-1', 4)
	,
	(1, 1, '2015-11-1', -13)
	,
	(1, 2, '2015-11-1', 745)
	,
	(1, 3, '2015-11-1', 47)
	,
	(1, 4, '2015-11-1', 15)
	,
	(1, 5, '2015-11-1', 2)
	,
	(5, 1, '2015-11-1', +8)
	,
	(5, 2, '2015-11-1', 750)
	,
	(5, 3, '2015-11-1', 63)
	,
	(5, 4, '2015-11-1', 0)
	,
	(5, 5, '2015-11-1', 8)	
	,
	(5, 1, '2015-11-2', +15)
	,
	(5, 2, '2015-11-2', 748)
	,
	(5, 3, '2015-11-2', 59)
	,
	(5, 4, '2015-11-2', 2)
	,
	(5, 5, '2015-11-2', 1)	
GO

SELECT lab1.Stations.Name as N'Станция'
, FORMAT(lab1.Measurements.MeasureDate,N'D','ru-RU') as N'Дата'
, lab1.Units.Name as N'Тип измерения'
, AVG(lab1.Measurements.Result) as N'Среднее значение'
, lab1.Units.Unit as N'Единицы измерения'
FROM Belyov_lab1.lab1.Measurements INNER JOIN
	lab1.Units on lab1.Measurements.UnitID=lab1.Units.UnitID INNER JOIN
	lab1.Stations on lab1.Measurements.StationID=lab1.Stations.StationID
GROUP BY lab1.Stations.Name, lab1.Measurements.MeasureDate ,lab1.Units.Name, lab1.Units.Unit
GO

SELECT FORMAT(lab1.Measurements.MeasureDate,N'D','ru-RU') as N'Дата'
, lab1.Units.Name as N'Тип измерения'
, FORMAT(AVG(lab1.Measurements.Result),'###.#','ru-RU') as N'Среднее значение'
, lab1.Units.Unit as N'Единицы измерения'
FROM Belyov_lab1.lab1.Measurements INNER JOIN
	lab1.Units on lab1.Measurements.UnitID=lab1.Units.UnitID INNER JOIN
	lab1.Stations on lab1.Measurements.StationID=lab1.Stations.StationID
WHERE lab1.Measurements.UnitID=1
GROUP BY lab1.Measurements.MeasureDate ,lab1.Units.Name, lab1.Units.Unit
GO

