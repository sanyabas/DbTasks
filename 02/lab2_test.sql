USE [Belyov_lab2]
GO

TRUNCATE TABLE lab2.Passes
GO

--Неправильные номера
INSERT INTO lab2.Passes VALUES
	('15:00:00', 'х232ъл196', 2, 0)
GO

INSERT INTO lab2.Passes VALUES
	('15:00:00', 'а000ам66', 2, 0)
GO

INSERT INTO lab2.Passes VALUES
	('15:00:00', 'а453ен450', 2, 0)
GO

INSERT INTO lab2.Passes VALUES
	('15:00:00', 'а453еывфв', 2, 0)
GO

--Два раза подряд въезд
INSERT INTO lab2.Passes VALUES
   ('11:00:00', 'м754он777',1,0),
   ('11:05:10', 'м754он777', 2,1),
   ('10:05:10', 'м754он777', 2,1)
GO

--Въезд/выезд с разницей меньше минуты
INSERT INTO lab2.Passes VALUES
  ('10:30:00', 'м754он777', 2, 1),
  ('10:30:00', 'м754он777', 3, 0)
GO

--Разница по времени нормальная
INSERT INTO lab2.Passes VALUES
  ('10:30:00', 'м754он777', 2, 1),
  ('11:30:00', 'м754он777', 3, 0)
GO

SELECT * FROM lab2.Passes