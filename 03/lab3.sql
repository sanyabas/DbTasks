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
  ('Урал'),
  ('Зенит')

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
  (2, 'Арапов', 'Вратарь'),
  (3, 'Дзюба', 'Нападющий'),
  (3, 'Лодыгин', 'Вратарь')


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
  (1, 2, '2017-11-10', 0, 3),
  (2, 3, '2017-11-11', 2, 1),
  (3, 1, '2017-11-12', 1, 1)

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
  (2, 1),
  (3, 1),
  (3, 6)
GO

CREATE FUNCTION lab3.TournamentResults(@inpDate DATETIME)
RETURNS @retResults TABLE
(
  Place INT IDENTITY(1,1),
  Name nvarchar(40),
  Points int,
  Goals int,
  LosesGoals int,
  Difference int
)
AS
BEGIN
  WITH
    HostPoints(HostTeamId, Goals, Loses, Wins, Draws)
    AS
    (
      SELECT games.HostTeamId as HostTeamId,
        SUM(games.HostScore) as Goals,
        SUM(games.GuestScore) as Loses,
        COUNT(CASE 
      WHEN games.HostScore>games.GuestScore THEN 1
      ELSE NULL
      END) as Wins,
        COUNT (CASE 
      WHEN games.HostScore=games.GuestScore THEN 1
      ELSE NULL
      END) as Draws
      FROM lab3.GamesResults as games
      WHERE games.GameDate<@inpDate
      GROUP BY HostTeamId
    ),
    GuestPoints(GuestTeamId, Goals, Loses, Wins, Draws)
    AS
    (
      SELECT games.GuestTeamId as GuestTeamId,
        SUM(games.GuestScore) as Goals,
        SUM(games.HostScore) as Loses,
        COUNT(CASE
      WHEN games.HostScore<games.GuestScore THEN 1
      ELSE NULL
      END) as Wins,
        COUNT (CASE 
      WHEN games.HostScore=games.GuestScore THEN 1
      ELSE NULL
      END) as Draws
      FROM lab3.GamesResults as games
      WHERE games.GameDate<@inpDate
      GROUP BY GuestTeamId
    )
  INSERT @retResults
  SELECT team.TeamName as 'Команда',
    (host.Wins+guest.Wins)*3+host.Draws+guest.Draws as 'Очки',
    host.Goals+guest.Goals as 'Забито',
    host.Loses+guest.Loses as 'Пропущено',
    host.Goals+guest.Goals-host.Loses-guest.Loses as Difference
  FROM lab3.Teams as team INNER JOIN
    HostPoints as host ON host.HostTeamId=team.TeamId INNER JOIN
    GuestPoints as guest ON guest.GuestTeamId=team.TeamId
    ORDER BY [Очки] DESC, [Забито] DESC, Difference DESC
  RETURN;
END;
GO

SELECT
  Place as 'Место',
  Name as 'Команда',
  Points as 'Очки',
  Goals as 'Забито',
  LosesGoals as 'Пропущено'
FROM lab3.TournamentResults('2017-11-13')

CREATE TABLE #temp(
  Team1 NVARCHAR(40),
  Team2 NVARCHAR(40),
  Score NVARCHAR(10)
)

INSERT INTO #temp
SELECT team1.TeamName as Team1,
team2.TeamName as Team2,
CONCAT(games.HostScore, ':', games.GuestScore)
FROM lab3.Teams as team1 INNER JOIN
lab3.GamesResults as games ON games.HostTeamId=team1.TeamId INNER JOIN
lab3.Teams as team2 ON games.GuestTeamId=team2.TeamId
WHERE team1.TeamId!=team2.TeamId
UNION
SELECT team1.TeamName as Team1,
team2.TeamName as Team2,
CONCAT(games.GuestScore, ':', games.HostScore)
FROM lab3.Teams as team1 INNER JOIN
lab3.GamesResults as games ON games.GuestTeamId=team1.TeamId INNER JOIN
lab3.Teams as team2 ON games.HostTeamId=team2.TeamId
WHERE team1.TeamId!=team2.TeamId

DECLARE @teamNames NVARCHAR(max)
SET @teamNames =
SUBSTRING((SELECT ','+team.TeamName AS [text()]
FROM lab3.Teams as team
ORDER BY team.TeamName
FOR XML PATH ('')), 2, 1000)

DECLARE @query NVARCHAR(MAX)
SET @query = 'SELECT * FROM #temp PIVOT(
  MAX(Score) FOR Team2 in('+@teamNames+')) p'
EXEC(@query)

-- DROP TABLE #temp
GO

IF OBJECT_ID('lab3.PlayersWithGoals', 'V') IS NOT NULL
    DROP VIEW lab3.PlayersWithGoals
GO

CREATE VIEW lab3.PlayersWithGoals
AS
SELECT team.TeamName as 'Команда',
 player.PlayerSurname as 'Фамилия',
  player.PlayerRole as 'Роль',
  COUNT(goals.GameId) as 'Количество голов'
  FROM lab3.Goals as goals INNER JOIN
  lab3.Players as player ON goals.PlayerId=player.PlayerId INNER JOIN
  lab3.Teams as team ON player.TeamId=team.TeamId
  GROUP BY team.TeamName, player.PlayerSurname, player.PlayerRole;
GO

SELECT * FROM lab3.PlayersWithGoals
GO

IF OBJECT_ID('lab3.GoalKeepers', 'V') IS NOT NULL
    DROP VIEW lab3.GoalKeepers
GO

CREATE VIEW lab3.GoalKeepers
AS
SELECT team.TeamName as 'Команда',
  player.PlayerSurname as 'Вратарь'
  FROM lab3.Players as player INNER JOIN
  lab3.Teams as team ON player.TeamId=team.TeamId
  WHERE player.PlayerRole='Вратарь'
  GROUP BY team.TeamName, player.PlayerSurname
GO

SELECT * FROM lab3.GoalKeepers
GO