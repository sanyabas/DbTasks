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

IF OBJECT_ID('[Belyov].lab3.Teams', 'U') IS NOT NULL
  DROP TABLE  [Belyov].lab3.Teams
GO

IF OBJECT_ID('[Belyov].lab3.Players', 'U') IS NOT NULL
  DROP TABLE  [Belyov].lab3.Players
GO

IF OBJECT_ID('[Belyov].lab3.GamesResults', 'U') IS NOT NULL
  DROP TABLE  [Belyov].lab3.GamesResults
GO

IF OBJECT_ID('[Belyov].lab3.Goals', 'U') IS NOT NULL
  DROP TABLE  [Belyov].lab3.Goals
GO

CREATE TABLE lab3.Teams
(
  TeamId int IDENTITY(1,1) NOT NULL,
  TeamName nvarchar(40) not null,
  CONSTRAINT PK_TeamId PRIMARY KEY(TeamId)
)

INSERT INTO lab3.Teams
VALUES
  ('Спартак'),
  ('Урал')

CREATE TABLE lab3.Players
(
  PlayerId int IDENTITY(1,1) not null,
  TeamId int not null,
  PlayerSurname nvarchar(40) not null,
  PlayerRole nvarchar(15) not null,
  CONSTRAINT PK_PlayerId PRIMARY KEY(PlayerId),
  CONSTRAINT FK_TeamId FOREIGN KEY (TeamId)
  REFERENCES lab3.Teams(TeamId)
  ON UPDATE CASCADE
)

INSERT INTO lab3.Players
VALUES
  (1, 'Давыдов', 'Нападающий'),
  (1, 'Адриано', 'Нападающий'),
  (1, 'Ребров', 'Вратарь'),
  (2, 'Ильин', 'Нападающий'),
  (2, 'Арапов', 'Вратарь')


CREATE TABLE lab3.GamesResults
(
  GameId int IDENTITY(1,1) NOT NULL,
  HostTeamId int NOT NULL,
  GuestTeamId int NOT NULL,
  GameDate DATETIME NOT NULL,
  HostScore tinyint not null,
  GuestScore tinyint not null,
  CONSTRAINT PK_GameId PRIMARY KEY(GameId),
  CONSTRAINT FK_HostTeamId FOREIGN KEY (HostTeamId)
    REFERENCES lab3.Teams(TeamId)
    ON UPDATE NO ACTION,
  CONSTRAINT FK_GuestTeamId FOREIGN KEY (GuestTeamId)
    REFERENCES lab3.Teams(TeamId)
    ON UPDATE NO ACTION
)

INSERT INTO lab3.GamesResults
VALUES
  (1, 2, '2017-11-10', 3, 0),
  (2, 1, '2017-11-11', 2, 1)

CREATE TABLE lab3.Goals
(
  GameId int not null,
  PlayerId int not null,
  CONSTRAINT FK_GameId FOREIGN KEY (GameId)
  REFERENCES lab3.GamesResults(GameId)
  ON UPDATE CASCADE,
  CONSTRAINT FK_PlayerId FOREIGN KEY (PlayerId)
  REFERENCES lab3.Players(PlayerId)
  ON UPDATE CASCADE
)

INSERT INTO lab3.Goals
VALUES
  (1, 1),
  (1, 2),
  (1, 2),
  (2, 4),
  (2, 4),
  (2, 1)


SELECT *
FROM lab3.GamesResults
GO

CREATE FUNCTION lab3.TournamentResults(@inpDate DATETIME)
RETURNS @retResults TABLE
(
  Place INT,
  Name nvarchar(40),
  Points int,
  Goals int,
  LosesGoals int
)
AS
BEGIN
  RETURN;
END
GO