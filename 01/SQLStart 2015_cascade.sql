USE master
/*ОБРАЩЕНИЕ К СИСТЕМНОЙ БАЗЕ SQL СЕРВЕРА
ДЛЯ СОЗДАНИЯ ПОЛЬЗОВАТЕЛЬСКОЙ БАЗЫ ДАННЫХ*/
GO --РАЗДЕЛИТЕЛЬ БАТЧЕЙ (BATH)

IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'ИМЯ БАЗЫ'
)
ALTER DATABASE [ИМЯ БАЗЫ] set single_user with rollback immediate
GO
/* ПРОВЕРЯЕМ, СУЩЕСТВУЕТ ЛИ НА СЕРВЕРЕ БАЗА ДАННЫХ
С ИМЕНЕМ [ИМЯ БАЗЫ], ЕСЛИ ДА, ТО ЗАКРЫВАЕМ ВСЕ ТЕКУЩИЕ
 СОЕДИНЕНИЯ С ЭТОЙ БАЗОЙ */

IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'ИМЯ БАЗЫ'
)
DROP DATABASE [ИМЯ БАЗЫ]
GO
/* СНОВА ПРОВЕРЯЕМ, СУЩЕСТВУЕТ ЛИ НА СЕРВЕРЕ БАЗА ДАННЫХ
С ИМЕНЕМ [ИМЯ БАЗЫ], ЕСЛИ ДА, УДАЛЯЕМ ЕЕ С СЕРВЕРА */

/* ДАННЫЙ БЛОК НЕОБХОДИМ ДЛЯ КОРРЕКТНОГО ПЕРЕСОЗДАНИЯ БАЗЫ
ДАННЫХ С ИМЕНЕМ [ИМЯ БАЗЫ] ПРИ НЕОБХОДИМОСТИ */

CREATE DATABASE [ИМЯ БАЗЫ]
GO
-- СОЗДАЕМ БАЗУ ДАННЫХ

USE [ИМЯ БАЗЫ]
GO
/* ПЕРЕХОДИМ К СОЗДАННОЙ БАЗЕ ДАННЫХ ДЛЯ ПОСЛЕДУЮЩЕЙ РАБОТЫ С НЕЙ 
ИЛИ С ЭТИХ КОМАНД ПРОДОЛЖАЕМ РАБОТУ С БАЗОЙ ДАННЫХ ЕСЛИ ОНА
 УЖЕ СУЩЕСТВУЕТ НА СЕРВЕРЕ */

IF EXISTS(
  SELECT *
    FROM sys.schemas
   WHERE name = N'Фамилия'
) 
 DROP SCHEMA Фамилия
GO
/*ПРОВЕРЯЕМ, СУЩЕСТВУЕТ ЛИ В БАЗЕ ДАННЫХ
 [ИМЯ БАЗЫ] СХЕМА С ИМЕНЕМ Фамилия, ЕСЛИ ДА,
  ТО ПРЕДВАРИТЕЛЬНО УДАЛЯЕМ ЕЕ ИЗ БАЗЫ
  ЕСЛИ ВЫ УАЛЯЕТЕ ВСЮ БАЗУ ЦЕЛИКОМ - ЭТА ЧАСТЬ СКРИПТА НЕ НУЖНА */

CREATE SCHEMA Фамилия 
GO
/*СОЗДАЕМ В БАЗЕ ДАННЫХ
 [ИМЯ БАЗЫ] СХЕМУ С ИМЕНЕМ Фамилия */

IF OBJECT_ID('[ИМЯ БАЗЫ].Фамилия.ut_students', 'U') IS NOT NULL
  DROP TABLE  [ИМЯ БАЗЫ].Фамилия.ut_students
GO

/*ПРОВЕРЯЕМ, СУЩЕСТВУЕТ ЛИ В БАЗЕ ДАННЫХ
 [ИМЯ БАЗЫ] И СХЕМЕ С ИМЕНЕМ Фамилия ТАБЛИЦА ut_students ЕСЛИ ДА, 
  ТО ПРЕДВАРИТЕЛЬНО УДАЛЯЕМ ЕЕ ИЗ БАЗЫ И СХЕМЫ.
  ЕСЛИ ВЫ УАЛЯЕТЕ ВСЮ БАЗУ ЦЕЛИКОМ - ЭТА ЧАСТЬ СКРИПТА НЕ НУЖНА */

CREATE TABLE [ИМЯ БАЗЫ].Фамилия.ut_students
(
	NumberZach nvarchar(12) NOT NULL, 
	Family nvarchar(40) NULL, 
	Name nvarchar(40) NULL, 
    CONSTRAINT PK_NumberZach PRIMARY KEY (NumberZach) 
)
GO
/*СОЗДАЕМ В БАЗЕ ДАННЫХ [ИМЯ БАЗЫ] В СХЕМЕ С ИМЕНЕМ
 Фамилия ТАБЛИЦУ ut_students С ТРЕМЯ ТЕКСТОВЫМИ ПОЛЯМИ 
 И ПЕРВИЧНЫМ КЛЮЧОМ (PRIMARY KEY),
 ГДЕ PK_NumberZach - ИМЯ КЛЮЧА, А NumberZach - ИМЯ КЛЮЧЕВОГО ПОЛЯ*/

ALTER TABLE [ИМЯ БАЗЫ].Фамилия.ut_students ADD 
	NumberGroup tinyint null,
	Kurs char(1) null
	GO

ALTER TABLE [ИМЯ БАЗЫ].Фамилия.ut_students ADD 
	Birthday date null
GO

ALTER TABLE [ИМЯ БАЗЫ].Фамилия.ut_students 
ALTER COLUMN Birthday date  NOT NULL
GO

/*СУЩЕСТВУЮЩИЕ ОБЪЕКТЫ БАЗЫ ДАННЫХ МОЖНО ИЗМЕНЯТЬ С ПОМОЩЬЮ
ИНСТРУКЦИИ ALTER (ИМЯ ОБЪЕКТА) */


--DROP TABLE	[ИМЯ БАЗЫ].Фамилия.ut_students
--GO

/*УДАЛЕНИЕ ОБЪЕКТА ТАБЛИЦЫ ИЗ БАЗЫ ДАННЫХ  */

CREATE TABLE [ИМЯ БАЗЫ].Фамилия.ut_nameGroup
(
	NumberGroup tinyint  NOT NULL, 
	NameGroup nvarchar(40) NULL, 
	Kurs tinyint DEFAULT (3) NOT NULL, 
    CONSTRAINT PK_NumberGroup PRIMARY KEY (NumberGroup)
)
GO
/*СОЗДАЕМ В БАЗЕ ДАННЫХ [ИМЯ БАЗЫ] В СХЕМЕ С ИМЕНЕМ
 Фамилия ТАБЛИЦУ ut_nameGroup С  ТЕКСТОВЫМ ПОЛЯМ И ДВУМЯ ЦЕЛОЧИСЛЕННЫМИ
 ПОЛЯМИ. ОДНО ПОЛЕ ДЕЛАЕМ ИДЕНТИФИКАТОРОМ, В ДРУГОЕ ПОЛЕ ВНОСИМ ЗНАЧЕНИЕ 
 ПО УМОЛЧЕНИЮ. СОЗДАЕМ ПЕРВИЧНЫЙ КЛЮЧ (PRIMARY KEY),
 ГДЕ PK_NumberGroup - ИМЯ КЛЮЧА, А NumberGroup - ИМЯ КЛЮЧЕВОГО ПОЛЯ*/
 
ALTER TABLE [ИМЯ БАЗЫ].Фамилия.ut_students ADD 
	CONSTRAINT FK_NameGroup FOREIGN KEY (NumberGroup) 
	REFERENCES [ИМЯ БАЗЫ].Фамилия.ut_nameGroup(NumberGroup)
	ON UPDATE CASCADE 
GO		
 /*СОЗДАЕМ В ТАБЛИЦЕ ut_students ВНЕШНИЙ КЛЮЧ  (FOREIGN KEY)
  С ИМЕНЕМ FK_NameGroup, СВЯЗЫВАЮЩИЙ ПОЛЕ NumberGroup ТАБЛИЦЫ ut_students
  С ПОЛЕМ NumberGroup ТАБЛИЦЫ ut_nameGroup. СВЯЗЬ МНОГИЕ-К-ОДНОМУ.
 ВНЕШНИЙ КЛЮЧ СОЗДАЕМ С ПОМОЩЬЮ ИНСТРУКЦИИ ALTER TABLE,
 ПОСКОЛЬКУ НАРУШЕНА ОЧЕРЕДНОСТЬ СОЗДАНИЯ ТАБЛИЦ*/

 ALTER TABLE [ИМЯ БАЗЫ].Фамилия.ut_nameGroup ADD 
	CONSTRAINT CK_Kurs 
	CHECK (Kurs>0 and Kurs<=6)
GO	
/*УСТАНАВЛИВАЕМ ОГРАНИЧЕНИЕ (CHECK) В ТАБЛИЦЕ ut_nameGroup НА ПОЛЕ Kurs.
 CK_Kurs - ИМЯ ОГРАНИЧЕНИЯ*/

 INSERT INTO [ИМЯ БАЗЫ].Фамилия.ut_nameGroup 
 (NumberGroup,NameGroup)
 VALUES 
 (1,N'КН-301')
 ,(2,N'КН-303')
 ,(3,N'КБ-301')	
GO	
/*ВНОСИМ ДАННЫЕ В ТАБЛИЦУ ut_nameGroup ТОЛЬКО В ДВА ПОЛЕ 
 ПОЛЕ Kurs ЗАПОЛНЯЕТСЯ АВТОМАТИЧЕСКИ*/

SELECT * From [ИМЯ БАЗЫ].Фамилия.ut_nameGroup 
--ПРОСМАТРИВАЕМ СОДЕРЖИМОЕ ТАБЛИЦЫ ut_nameGroup


INSERT INTO [ИМЯ БАЗЫ].Фамилия.ut_students 
  VALUES 
 ('095811',N'Сергеев',N'Петр',2,3,'19950924')
 , ('095812',N'Петров',N'Сергей',1,3,'19960924')

 /*ВНОСИМ ДАННЫЕ В ТАБЛИЦУ ut_students, 
 ПОСКОЛЬКУ ЗАПОЛНЯЮТСЯ ВСЕ ПОЛЯ, ПИШУТЬСЯ ТОЛЬКО ДАННЫЕ
 В ПОРЯДКЕ СЛЕДОВАНИЯ ПОЛЕЙ В ТАБЛИЦЕ.
 ОБРАТИТЕ ВНИМАНИЕ НА ВВОД ДАТЫ!!! */

SELECT * From [ИМЯ БАЗЫ].Фамилия.ut_students
--ПРОСМАТРИВАЕМ СОДЕРЖИМОЕ ТАБЛИЦЫ ut_students   

--DELETE FROM [ИМЯ БАЗЫ].Фамилия.ut_students 
/*УДАЛЯЕМ ВСЕ ДАННЫЕ ИЗ ТАБЛИЦЫ  ut_students. 
САМА ТАБЛИЦА ОСТАЕТСЯ В БАЗЕ ДАННЫХ*/

UPDATE [ИМЯ БАЗЫ].Фамилия.ut_nameGroup
SET NumberGroup = 7	where NumberGroup =2

--ПРОВЕРЯЕМ ОГРАНИЧЕНИЕ ON UPDATE CASCADE 

SELECT * From [ИМЯ БАЗЫ].Фамилия.ut_nameGroup 
--ПРОСМАТРИВАЕМ СОДЕРЖИМОЕ ТАБЛИЦЫ ut_nameGroup

SELECT * From [ИМЯ БАЗЫ].Фамилия.ut_students
--ПРОСМАТРИВАЕМ СОДЕРЖИМОЕ ТАБЛИЦЫ ut_students   

