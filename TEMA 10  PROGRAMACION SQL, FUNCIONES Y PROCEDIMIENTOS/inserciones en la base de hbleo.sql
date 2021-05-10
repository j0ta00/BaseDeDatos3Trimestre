USE [HBleO]
GO






INSERT INTO [dbo].[HVisionados]
           ([ID]
           ,[IDContenido]
           ,[IDPerfil]
           ,[FechaHora]
           ,[MinutoInicio]
           ,[MinutoFin])
     VALUES
           (
			,2
           ,3
           ,'06-06-2018'
           ,'04:00'
           ,'20:00'),

		   (
			,2
           ,3
           ,'06-06-2018'
           ,'20:00'
           ,'40:00')
GO

SELECT*FROM HGeneros


SELECT*FROM HPeliculasGeneros

INSERT INTO HPeliculasGeneros VALUES (NEWID(),1)

SELECT*FROM HPeliculas




--INSERT EN PELICULAS
set dateformat dmy
INSERT INTO HPeliculas VALUES ('2f8ab0d5-3d61-4c6b-94c5-e9fcf3eb7b28','Lo que el viento se llevo','06-07-2000',0,0)
INSERT INTO HPeliculas VALUES ('c240d549-d0d2-4902-ae71-f8d689a7ba3f','Lo que la marea se llevo','06-07-2000',0.6,0.80)

--INSERTS EN LOS VISIONADOS
set dateformat dmy
INSERT INTO HVisionados VALUES (NEWID(),'C240D549-D0D2-4902-AE71-F8D689A7BA3F','628BD9F2-B795-4C45-A87D-099D416EE93F','31-12-2008', '00:00:00', '00:40:00')
INSERT INTO HVisionados VALUES (NEWID(),'C240D549-D0D2-4902-AE71-F8D689A7BA3F','FF85A53E-4639-4F45-8FBE-836BC48C6035','09-04-2020','00:03:00','00:46:00')
INSERT INTO HVisionados VALUES (NEWID(),'C240D549-D0D2-4902-AE71-F8D689A7BA3F','FF85A53E-4639-4F45-8FBE-836BC48C6035','09-04-2020','00:03:00','03:00:00')
INSERT INTO HVisionados VALUES (NEWID(),'2F8AB0D5-3D61-4C6B-94C5-E9FCF3EB7B28','628BD9F2-B795-4C45-A87D-099D416EE93F','09-04-2020','00:06:00','00:56:00')
INSERT INTO HVisionados VALUES (NEWID(),'2F8AB0D5-3D61-4C6B-94C5-E9FCF3EB7B28','628BD9F2-B795-4C45-A87D-099D416EE93F','09-04-2020','00:07:00','01:46:00')
select*from HVisionados
select*from HContenidos

select*from HPerfiles
select*from HSuscripciones

--ISNERT INTO CAPITULOS
SELECT*FROM HCapitulos

INSERT INTO HCapitulos VALUES ('a6605113-024e-46f7-9e75-2f9df80aa2c6',8,1,1)

INSERT INTO HCapitulos VALUES ('9e809898-5cd0-4fdd-8eb1-370f600d646e',8,1,2)

INSERT INTO HCapitulos VALUES ('6dbb25ea-fa0f-4554-bd45-966f82435502',8,1,3)

--INSERT INTO CONTENIDOS
SELECT*FROM HContenidos

INSERT INTO HContenidos VALUES (NEWID(),1,'01:30',1)
INSERT INTO HContenidos VALUES (NEWID(),'P','02:30',1)
INSERT INTO HContenidos VALUES (NEWID(),'S','00:40',1)
INSERT INTO HContenidos VALUES (NEWID(),'S','03:30',1)
INSERT INTO HContenidos VALUES (NEWID(),'S','00:30',1)
INSERT INTO HContenidos VALUES (NEWID(),'P','03:50',2)

--INSERTS INTO TEMPORADAS
SET DATEFORMAT DMY
INSERT INTO HTemporadas VALUES (1,1,'06-07-2005',2)
INSERT INTO HTemporadas VALUES (2,1,'06-07-2005',2)
INSERT INTO HTemporadas VALUES (8,1,'23-01-2007',2)
INSERT INTO HTemporadas VALUES (8,2,'06-03-2009',2)
INSERT INTO HTemporadas VALUES (8,3,'03-07-2011',2)

--INSERTS EN LOS PERFILES
insert into HPerfiles values (NEWID(),7,'Luis','dfdfsd',2)
insert into HPerfiles values (NEWID(),7,'Pepa','dfdfsd',1)
insert into HPerfiles values (NEWID(),8,'Ramon','dfdfsd',0)
insert into HPerfiles values (NEWID(),8,'Teresa','dfdfsd',2)
insert into HPerfiles values (NEWID(),60,'Maria','dfdfsd',1)





--INSERTA EN LAS SUSCRIPCIONES
insert into HSuscripciones values (5,'E','2015-02-03 00:00:00.000','2017-09-05 00:00:00.000')
insert into HSuscripciones values (7,'E','2015-02-03 00:00:00.000','2017-09-05 00:00:00.000')
insert into HSuscripciones values (8,'P','2015-02-03 00:00:00.000','2017-09-05 00:00:00.000')
insert into HSuscripciones values (60,'S','2015-02-03 00:00:00.000','2017-09-05 00:00:00.000')


