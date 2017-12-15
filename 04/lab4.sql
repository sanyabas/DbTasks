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
    BasePayment int,
    IncludedTime int,
    OverCost int
)

INSERT INTO lab4.Tariffs VALUES
('Без абонентской платы', 0, 0, 2),
('XS', 150, 100, 3),
('S', 250, 200, 3),
('M', 400, 450, 4),
('L', 700, 800, 5),
('Безлимитный', 1000, 1200, 0)

SELECT * FROM lab4.Tariffs
GO

CREATE FUNCTION lab4.GetBestTariff(@usedMins int)
RETURNS nvarchar(50)
AS
BEGIN
    DECLARE @result nvarchar(100);
    SET @result=(SELECT TOP(1) tariff.TariffName
    FROM (
        SELECT tariff.TariffName,
            CASE
                WHEN @usedMins-tariff.IncludedTime<0 THEN tariff.BasePayment
                ELSE tariff.BasePayment+(@usedMins-tariff.IncludedTime)*tariff.OverCost
            END as TotalCost
        FROM lab4.Tariffs as tariff
    ) as tariff
    ORDER BY tariff.TotalCost)
RETURN 'Для '+CAST(@usedMins as nvarchar)+' минут выгоден тариф '+@result;
END
GO

SELECT lab4.GetBestTariff(150)