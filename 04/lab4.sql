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
WHERE name = N'lab4'
) 
 DROP SCHEMA lab4
GO

CREATE SCHEMA lab4 
GO

IF OBJECT_ID('[Belyov].lab4.Tariffs', 'U') IS NOT NULL
  DROP TABLE  [Belyov].lab4.Tariffs
GO

CREATE TABLE lab4.Tariffs(
    TariffId INT IDENTITY(1,1),
    TariffName nvarchar(50),
    BasePayment smallmoney,
    IncludedTime int,
    OverCost smallmoney
)

INSERT INTO lab4.Tariffs VALUES
-- ('Без абонентской платы', 0, 0, 2),
-- ('XS', 150, 100, 3),
-- ('S', 250, 200, 3),
-- ('M', 400, 450, 4),
-- ('L', 700, 800, 5),
-- ('Безлимитный', 1000, 1200, 0)
('Безлимитный', 5, -1, 0),
('Детский', 2, 6, 1),
('Обычный',0, 0, 0.5)

SELECT * FROM lab4.Tariffs
GO

CREATE FUNCTION lab4.GetBestTariff(@usedMins float)
RETURNS @retResult TABLE(
    DesiredMinutes int,
    BestTariff nvarchar(50),
    Cost smallmoney
)
AS
BEGIN
    DECLARE @result nvarchar(50);
    INSERT INTO @retResult
    SELECT TOP(1) @usedMins, tariff.TariffName, tariff.TotalCost
    FROM (
        SELECT tariff.TariffName,
            CASE
                WHEN tariff.IncludedTime<0 THEN tariff.BasePayment
                WHEN @usedMins-tariff.IncludedTime<0 THEN tariff.BasePayment
                ELSE tariff.BasePayment+(@usedMins-tariff.IncludedTime)*tariff.OverCost
            END as TotalCost
        FROM lab4.Tariffs as tariff
    ) as tariff
    ORDER BY tariff.TotalCost
RETURN;
END
GO

SELECT
DesiredMinutes as 'Количество минут',
BestTariff as 'Выгодный тариф',
Cost as 'Стоимость'
FROM lab4.GetBestTariff(100)
GO

CREATE FUNCTION lab4.Division()
RETURNS @division TABLE(
    SegmentStart int not null,
    SegmentEnd int not null,
    BestTariff nvarchar(50) not null
)
AS
BEGIN
    DECLARE @monthInMinutes int = 43200;
    DECLARE @segmentStart int = 1;
    DECLARE @currentMinutes float = 1.5;
    DECLARE @currentBestTariff nvarchar(50) = (SELECT BestTariff FROM lab4.GetBestTariff(@currentMinutes))
    WHILE @currentMinutes<=@monthInMinutes
    BEGIN
        DECLARE @bestTariff nvarchar(50) = (SELECT BestTariff FROM lab4.GetBestTariff(@currentMinutes));
        IF @bestTariff!=@currentBestTariff
        BEGIN
            INSERT INTO @division VALUES
            (@segmentStart, ROUND(@currentMinutes-0.5,2,1), @currentBestTariff);
            SET @currentBestTariff=@bestTariff;
            SET @segmentStart=@currentMinutes;
        END
        SET @currentMinutes+=1
    END
    INSERT INTO @division VALUES
    (@segmentStart, @currentMinutes-1, @currentBestTariff);
    RETURN;
END
GO

CREATE FUNCTION lab4.GetTotalCost(@tariffId int, @minutes float)
RETURNS float
AS
BEGIN
DECLARE @tariff TABLE(BasePayment float, IncludedTime float, MinuteCost float)
INSERT INTO @tariff
    SELECT * FROM lab4.Tariffs
    WHERE Tariffs.TariffId=@tariffId
    IF @tariff.IncludedTime<0 RETURN @tariff.BasePayment;
    IF @usedMins-@tariff.IncludedTime<0 RETURN @tariff.BasePayment;
    RETURN @tariff.BasePayment+(@usedMins-@tariff.IncludedTime)*@tariff.OverCost;
END
GO

CREATE FUNCTION lab4.GetBestTariff2(@minutes float)
RETURNS nvarchar(100)
AS
BEGIN
DECLARE @result TABLE (tariffName nvarchar(100), cost float);
DECLARE @bestTariff nvarchar(100)
INSERT INTO @bestTariff 
SELECT TOP(1) tab.TariffName FROM (
    SELECT tariff.TariffName as Name,
        lab4.GetTotalCost(tariff.tariffId, @minutes) as totalCost
     FROM lab4.Tariffs as tariff
     ORDER BY totalCost
) as tab
RETURN @bestTariff;
END
GO

CREATE FUNCTION lab4.IntersectTariffs(@id1 int, @id2 int)
RETURNS @intersection TABLE(X float, Y float)
AS
BEGIN
    DECLARE @first TABLE(BasePayment float, IncludedTime float, MinuteCost float)
    DECLARE @second TABLE(BasePayment float, IncludedTime float, MinuteCost float)
    DECLARE @includedTime1 float;
    DECLARE @minuteCost1 float;
    DECLARE @basePayment2 float;
    DECLARE @includedTime2 float;
    DECLARE @minuteCost2 float;
    WITH first(basePayment, includedTime, minuteCost) AS (
        SELECT * FROM lab4.Tariffs as tariff WHERE tariff.TariffId=@id1
    ),
    second(basePayment, includedTime, minuteCost) AS (
        SELECT * FROM lab4.Tariffs as tariff WHERE tariff.TariffId=@id2
    ),
    intersectionInt(X) AS (
        SELECT (-second.includedTime*second.MinuteCost+second.BasePayment-first.BasePayment)/(-second.MinuteCost) WHERE second.MinuteCost>0
        UNION
        SELECT (-first.IncludedTime*first.MinuteCost+first.BasePayment-second.BasePayment)/(-first.MinuteCost) WHERE first.MinuteCost>0
        UNION
        SELECT (-second.IncludedTime*second.MinuteCost+second.BasePayment+first.IncludedTime*first.MinuteCost-first.BasePayment)/(first.MinuteCost-second.MinuteCost) WHERE first.MinuteCost!=second.MinuteCost
        UNION
        SELECT 0
    )
    INSERT @intersection
    SELECT intersectionInt.X, lab4.GetTotalCost(@id1, intersectionInt.X)
    RETURN;
    -- INSERT INTO @first SELECT * FROM lab4.Tariffs as tariff WHERE tariff.TariffId=@id1
    -- INSERT INTO @second SELECT * FROM lab4.Tariffs as tariff WHERE tariff.TariffId=@id2
-- RETURN
END
GO

CREATE FUNCTION lab4.GetIntersections()
RETURNS @result TABLE(
    FirstId int,
    SecondId int,
    X float,
    Y float
)
AS
BEGIN
    DECLARE @firstId INT
    DECLARE @secondId INT
    DECLARE iteratePairs CURSOR FOR
        SELECT first.TariffId,
        second.TariffId
        FROM lab5.Tariffs as first INNER JOIN
        lab5.Tariffs as second ON first.TariffId<second.TariffId 
    OPEN iteratePairs
    FETCH NEXT FROM iteratePairs INTO @firstId, @secondId
    WHILE (@@FETCH_STATUS = 0)
    BEGIN
        INSERT INTO @result
        SELECT 
    END
RETURN;
END

GO

SELECT 
    SegmentStart as 'Минимальное количество минут',
    SegmentEnd as 'Максимальное количество минут',
    BestTariff as 'Самый выгодный тариф'
FROM lab4.Division()
