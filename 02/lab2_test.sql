USE [Belyov_lab2]
GO

TRUNCATE TABLE lab2.Passes
GO

--������������ ������
INSERT INTO lab2.Passes VALUES
	('15:00:00', '�232��196', 2, 0)
GO

INSERT INTO lab2.Passes VALUES
	('15:00:00', '�000��66', 2, 0)
GO

INSERT INTO lab2.Passes VALUES
	('15:00:00', '�453��450', 2, 0)
GO

INSERT INTO lab2.Passes VALUES
	('15:00:00', '�453�����', 2, 0)
GO

--��� ���� ������ �����
INSERT INTO lab2.Passes VALUES
   ('11:00:00', '�754��777',1,0),
   ('11:05:10', '�754��777', 2,1),
   ('10:05:10', '�754��777', 2,1)
GO

--�����/����� � �������� ������ ������
INSERT INTO lab2.Passes VALUES
  ('10:30:00', '�754��777', 2, 1),
  ('10:30:00', '�754��777', 3, 0)
GO

--������� �� ������� ����������
INSERT INTO lab2.Passes VALUES
  ('10:30:00', '�754��777', 2, 1),
  ('11:30:00', '�754��777', 3, 0)
GO

SELECT * FROM lab2.Passes