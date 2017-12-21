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
WHERE name = N'lab5'
) 
 DROP SCHEMA lab5
GO

CREATE SCHEMA lab5 
GO

IF OBJECT_ID('[Belyov].lab5.Deputies', 'U') IS NOT NULL
  DROP TABLE  [Belyov].lab5.Deputies
GO

CREATE TABLE lab5.Deputies
(
    DeputyId INT IDENTITY(1,1) NOT NULL,
    Surname nvarchar(50) NOT NULL,
    DeputyName nvarchar(50) not null,
    FatherName nvarchar(50) not null,
    Address nvarchar(100) not null,
    HomePhone nvarchar(15) not null,
    WorkPhone nvarchar(15) not null,
    CONSTRAINT PK_DeputyId PRIMARY KEY(DeputyId)
)

IF OBJECT_ID('[Belyov].lab5.Comissions', 'U') IS NOT NULL
  DROP TABLE  [Belyov].lab5.Comissions
GO

CREATE TABLE lab5.Comissions
(
    ComissionId int identity(1,1) not null,
    Subject nvarchar(50) not null,
    CONSTRAINT PK_ComissionId PRIMARY KEY(ComissionId)
)

IF OBJECT_ID('[Belyov].lab5.ComissionMembers', 'U') IS NOT NULL
  DROP TABLE  [Belyov].lab5.ComissionMembers
GO

CREATE TABLE lab5.ComissionMembers
(
    ComissionId int not null,
    MemberId int not null,
    InDate date not null,
    OutDate date,
    IsPresent bit not null,
    IsChairman bit not null,
    CONSTRAINT FK_ComissionId FOREIGN KEY (ComissionId)
        REFERENCES lab5.Comissions(ComissionId)
        ON UPDATE CASCADE,
    CONSTRAINT FK_MemberId FOREIGN KEY (MemberId)
        REFERENCES lab5.Deputies(DeputyId)
        ON UPDATE CASCADE
)

IF OBJECT_ID('[Belyov].lab5.Conferences', 'U') IS NOT NULL
  DROP TABLE  [Belyov].lab5.Conferences
GO

CREATE TABLE lab5.Conferences
(
    ConfId INT IDENTITY(1,1) NOT NULL,
    ComissionId int not null,
    Place nvarchar(100) NOT NULL,
    ConfTime datetime not null,
    CONSTRAINT PK_ConfId PRIMARY KEY(ConfId),
    CONSTRAINT FK_ConfComisionId FOREIGN KEY(ComissionId)
        REFERENCES lab5.Comissions(ComissionId)
        ON UPDATE CASCADE
)

IF OBJECT_ID('[Belyov].lab5.ConferenceAttendance', 'U') IS NOT NULL
  DROP TABLE  [Belyov].lab5.ConferenceAttendance
GO

CREATE TABLE lab5.ConferenceAttendance
(
    ConferenceId int not null,
    MemberId int not null,
    CONSTRAINT FK_ConferenceId FOREIGN KEY(ConferenceId)
        REFERENCES lab5.Conferences(ConfId)
        ON UPDATE CASCADE,
    CONSTRAINT FK_ConfMemberId FOREIGN KEY(MemberId)
        REFERENCES lab5.Deputies
        ON UPDATE CASCADE
)

INSERT INTO lab5.Deputies
VALUES
    ('Иванов', 'Иван', 'Иванович', 'ул. Комсомольская, 35, 21', '314-23-54', '221-96-15'),
    ('Сидоров', 'Андрей', 'Константинович', 'ул. Ленина, 54, 15', '345-12-12', '221-96-10'),
    ('Петров', 'Александр', 'Сергеевич', 'ул. Пушкина, 3, 7', '345-75-43', '221-96-34'),
    ('Попов', 'Павел', 'Игоревич', 'ул. Советская, 62, 132', '314-45-93', '221-67-23'),
    ('Стрелков', 'Михаил', 'Юрьевич', 'ул. Первомайская, 43, 98', '314-19-37', '221-67-52'),
    ('Мамонова', 'Екатерина', 'Олеговна', 'ул. Пехотинцев, 97, 84', '289-97-98', '221-10-64'),
    ('Коверко', 'Юлия', 'Сергеевна', 'пр. Космонавтов, 145, 273', '146-11-27', '221-78-51'),
    ('Щепина', 'Екатерина', 'Геннадьевна', 'ул. Стачек, 55, 280', '264-77-15', '221-95-56'),
    ('Палешев', 'Артём', 'Андреевич', 'ул. Уральская, 87, 13', '314-87-51', '221-57-14'),
    ('Буньков', 'Алексей', 'Дмитриевич', 'ул. Крылова, 21, 15', '168-98-78', '221-24-57'),
    ('Бахтеев', 'Владислав', 'Викторович', 'ул. Восточная, 45, 97', '314-24-56', '221-62-15'),
    ('Кудунов', 'Артём', 'Владимирович', 'ул. Ильича, 45, 75', '314-45-27', '221-78-43'),
    ('Рязанова', 'Ксения', 'Дмитриевна', 'ул. Московская, 241, 451', '356-54-89', '221-16-87')
GO

SELECT *
FROM lab5.Deputies

INSERT INTO lab5.Comissions
VALUES
    ('Образование'),
    ('ЖКХ'),
    ('Общественный транспорт'),
    ('Медицина'),
    ('Культура'),
    ('Управление'),
    ('Дороги'),
    ('Благоустройство'),
    ('Строительство'),
    ('Сельское хозяйство')
GO

INSERT INTO lab5.ComissionMembers
VALUES
    (1, 1, '2017-04-15', null, 1, 1),
    (1, 2, '2017-04-15', null, 1, 0),
    (1, 3, '2017-04-18', null, 1, 0),
    (1, 7, '2017-04-21', null, 1, 0),
    (1, 9, '2017-05-4', '2017-10-09', 0, 0),
    (1, 11, '2016-12-11', '2017-04-14', 0, 1),
    (2, 5, '2017-06-22', null, 1, 1),
    (2, 8, '2017-08-24', '2017-11-20', 0, 0),
    (2, 13, '2017-09-10', null, 1, 0),
    (2, 7, '2017-07-18', null, 1, 0),
    (3, 12, '2016-06-15', null, 1, 1),
    (3, 6, '2016-07-11', null, 1, 0),
    (3, 4, '2016-12-23', '2017-10-12', 0, 0)
GO

INSERT INTO lab5.Conferences
VALUES
    (1, 'каб. 150', '2017-10-11'),
    (1, 'каб. 340', '2016-12-15'),
    (1, 'каб. 451', '2017-04-20'),
    (1, 'каб. 300', '2017-10-10'),
    (2, 'каб. 340', '2017-10-11'),
    (2, 'каб. 300', '2017-08-10'),
    (2, 'каб. 500', '2017-08-30'),
    (3, 'каб. 100', '2016-11-15'),
    (3, 'каб. 245', '2017-10-10')
GO

CREATE TRIGGER lab5.AttendanceValid
ON lab5.ConferenceAttendance
AFTER INSERT
AS
BEGIN
    IF EXISTS(
        SELECT *
    FROM inserted as first INNER JOIN
        lab5.Conferences first_conf ON first.ConferenceId=first_conf.ConfId,
        inserted as second INNER JOIN
        lab5.Conferences second_conf ON second.ConferenceId=second_conf.ConfId
    WHERE first.MemberId=second.MemberId AND
        first.ConferenceId!=second.ConferenceId AND
        first_conf.ConfTime=second_conf.ConfTime
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 51000, 'Депутат находится на двух комиссиях одновременно', 1;
        RETURN;
    END
END
GO

INSERT INTO lab5.ConferenceAttendance
VALUES
    (1, 1),
    (1, 2),
    (1, 3),
    (1, 7),
    (2, 11),
    (3, 1),
    (3, 2),
    (4, 1),
    (4, 3),
    (4, 7),
    (5, 5),
    (5, 8),
    (5, 13),
    -- (5, 7),
    -- (5,1),
    (6, 13),
    (6, 7),
    (7, 7),
    (7, 13),
    (7, 8),
    (8, 6),
    (8, 12),
    (9, 4),
    (9, 6),
    (9, 12)

--Показать список комиссий, для каждой – ее состав и председателя.
SELECT coms1.Subject as 'Комиссия',
    dep1.Surname+' '+dep1.DeputyName+' '+dep1.FatherName as 'Председатель',
    dep2.Surname+' '+dep2.DeputyName+' '+dep2.FatherName as 'Депутат'
FROM lab5.Comissions as coms1 INNER JOIN
    lab5.ComissionMembers as members1 ON coms1.ComissionId=members1.ComissionId AND members1.IsChairman=1 INNER JOIN
    lab5.Deputies dep1 ON members1.MemberId=dep1.DeputyId,
    lab5.Comissions as coms2 INNER JOIN
    lab5.ComissionMembers as members2 ON coms2.ComissionId=members2.ComissionId AND members2.IsChairman=0 INNER JOIN
    lab5.Deputies dep2 ON members2.MemberId=dep2.DeputyId
WHERE members1.IsPresent=1 AND members2.IsPresent=1

--показать в хронологическом порядке всех председателей комиссии
DECLARE @startDate date='2016-10-10'
DECLARE @endDate date='2018-01-01'
DECLARE @comission nvarchar(50)='Образование'
SELECT Comissions.Subject as 'Комиссия',
    deps.Surname+' '+deps.DeputyName+' '+deps.FatherName as 'Председатель'
FROM lab5.Comissions INNER JOIN
    lab5.ComissionMembers as members ON members.ComissionId=Comissions.ComissionId INNER JOIN
    lab5.Deputies as deps on members.MemberId=deps.DeputyId
WHERE Comissions.Subject=@comission AND
    members.IsChairman=1 AND
    members.InDate>@startDate AND
    (members.OutDate<@endDate OR
    members.OutDate IS NULL)
ORDER BY members.InDate

--Показать список членов Думы, для каждого из них – список комиссий, в которых он участвовал и/или был председателем
SELECT
    dep.Surname+' '+dep.DeputyName+' '+dep.FatherName as 'Депутат',
    comms.Subject as 'Комиссия'
FROM lab5.Deputies as dep INNER JOIN
    lab5.ComissionMembers as members ON dep.DeputyId=members.MemberId INNER JOIN
    lab5.Comissions as comms ON members.ComissionId=comms.ComissionId
GROUP BY dep.Surname+' '+dep.DeputyName+' '+dep.FatherName, comms.Subject

--Для указанного интервала дат и комиссии выдать список членов с указанием количества пропущенных заседаний.
DECLARE @startMissDate date='2016-10-10';
DECLARE @endMissDate date='2018-01-01';
DECLARE @comissionMiss nvarchar(50)='Образование';
WITH AttendanceCount(memberId,confCount) AS (
SELECT members.MemberId as memberId,
COUNT(*) as confCount
FROM lab5.Conferences as conf INNER JOIN
lab5.Comissions as coms ON coms.ComissionId=conf.ComissionId INNER JOIN
lab5.ComissionMembers as members ON coms.ComissionId=members.ComissionId INNER JOIN
lab5.ConferenceAttendance as attend ON attend.MemberId=members.MemberId AND attend.ConferenceId=conf.ConfId
WHERE coms.Subject=@comissionMiss AND
    conf.ConfTime>@startMissDate AND
    conf.ConfTime<@endMissDate
GROUP BY members.MemberId)
SELECT dep.Surname+' '+dep.DeputyName+' '+dep.FatherName as 'Депутат',
COUNT(*)-AttendanceCount.confCount as 'Пропущенные заседания'
FROM lab5.Conferences as conf INNER JOIN
lab5.Comissions as coms ON coms.ComissionId=conf.ComissionId,
AttendanceCount INNER JOIN
lab5.Deputies as dep ON dep.DeputyId=AttendanceCount.memberId
WHERE coms.Subject=@comissionMiss
GROUP BY dep.Surname+' '+dep.DeputyName+' '+dep.FatherName, AttendanceCount.confCount

--Вывести список заседаний в указанный интервал дат в хронологическом порядке, для каждого заседания – список присутствующих
DECLARE @confStartDate date='2016-10-10'
DECLARE @confEndDate date='2018-01-01'
SELECT comms.Subject as 'Комиссия',
    FORMAT(conf.ConfTime, 'D', 'ru-RU') as 'Дата',
    dep.Surname+' '+dep.DeputyName+' '+dep.FatherName as 'Депутат'
FROM
    lab5.Conferences as conf INNER JOIN
    lab5.Comissions as comms ON conf.ComissionId=comms.ComissionId INNER JOIN
    lab5.ConferenceAttendance as attend ON attend.ConferenceId=conf.ConfId INNER JOIN
    lab5.Deputies as dep ON dep.DeputyId=attend.MemberId
WHERE conf.ConfTime>@confStartDate AND
    conf.ConfTime<@confEndDate
ORDER BY conf.ConfTime

--По каждой комиссии показать количество проведенных заседаний в указанный период времени
DECLARE @confListStartDate date='2016-10-10'
DECLARE @confListEndDate date='2018-01-01'
SELECT coms.Subject as 'Комиссия',
COUNT(*) as 'Количество заседаний'
FROM lab5.Conferences as conf INNER JOIN
lab5.Comissions as coms ON conf.ComissionId=coms.ComissionId
WHERE conf.ConfTime>@confListStartDate AND
    conf.ConfTime<@confListEndDate
GROUP BY coms.Subject
