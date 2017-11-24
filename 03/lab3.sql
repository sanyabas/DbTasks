USE master
GO

IF  EXISTS (
	SELECT name
FROM sys.databases
WHERE name = N'Belyov'
)
ALTER DATABASE [Belyov] set single_user with rollback immediate
GO

IF  EXISTS (
	SELECT name
FROM sys.databases
WHERE name = N'Belyov'
)
DROP DATABASE [Belyov]
GO

CREATE DATABASE [Belyov]
GO

USE [Belyov]
GO

IF EXISTS(
  SELECT *
FROM sys.schemas
WHERE name = N'lab3'
) 
 DROP SCHEMA lab3
GO

CREATE SCHEMA lab3 
GO

IF OBJECT_ID('[Belyov].lab3.GamesResults', 'U') IS NOT NULL
  DROP TABLE  [Belyov].lab3.GamesResults
GO

CREATE TABLE lab3.GamesResults
(
    GameId int IDENTITY(1,1) NOT NULL,
    HostTeam NVARCHAR(40) NOT NULL,
    GuestTeam NVARCHAR(40) NOT NULL,
    GameDate DATETIME NOT NULL,
    Score NVARCHAR(10) NOT NULL,
    HostGoalAuth NVARCHAR(MAX) NOT NULL,
    GuestGoalAuth NVARCHAR(MAX) NOT NULL,
    HostGoalKeeper NVARCHAR(40) NOT NULL,
    GuestGoalKeeper NVARCHAR(40) NOT NULL
)

INSERT INTO lab3.GamesResults VALUES
('Спартак', 'Урал', '2017-11-24', '0-3', '', 'Иванов, Петров, Сидоров', 'Спартаквртр', 'Уралвртр')

SELECT * FROM lab3.GamesResults