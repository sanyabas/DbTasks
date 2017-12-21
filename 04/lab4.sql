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

SELECT 
    SegmentStart as 'Минимальное количество минут',
    SegmentEnd as 'Максимальное количество минут',
    BestTariff as 'Самый выгодный тариф'
FROM lab4.Division()
