--Crea una funci�n inline a la que pasemos la matr�cula de un tren y una fecha de inicio y fin y nos devuelva una tabla con el n�mero de veces que ese tren ha estado en cada estaci�n, adem�s del ID, nombre y direcci�n de la estaci�n
GO
CREATE OR ALTER FUNCTION FIRecorridoTrenesMatricula
(@matricula char(7),@fechaInicio smalldatetime,@fechaFin smalldatetime) RETURNS TABLE AS RETURN
	SELECT  R.Tren,R.estacion AS IdEstacion,E.Denominacion,E.Direccion,COUNT(*) AS NumeroVeces FROM LM_Trenes AS T 
	INNER JOIN LM_Recorridos AS R ON T.ID=R.Tren 
	INNER JOIN LM_Estaciones AS E ON R.estacion=E.ID
	WHERE T.Matricula=@matricula AND R.Momento BETWEEN @fechaInicio AND @fechaFin 
	GROUP BY R.Tren,R.estacion,E.Denominacion,E.Direccion
GO
SELECT*FROM FIRecorridoTrenesMatricula('0100FRY','2017-02-26 02:20:00.000','2017-02-26 02:50:05.000')--PREGUNTAR POR EL BETWEEN PORQU� PARECE QUE EL VALOR L�MITE  FECHAFIN NO SE HA INCLUIDO 

--Crea una funci�n inline que nos diga el n�mero de personas que han pasado por una estacion en un periodo de tiempo. 
--Se considera que alguien ha pasado por una estaci�n si ha entrado o salido del metro por ella. El principio y el fin de ese periodo se pasar�n como par�metros
GO
CREATE OR ALTER FUNCTION FINumeroPersonasPasanEstacion
(@fechaInicio smalldatetime,@fechaFin smalldatetime) RETURNS TABLE AS RETURN
SELECT DISTINCT NPS.IDEstacionSalida,(NPS.NumeroPersonas+NPE.NumeroPersonas) AS NumeroPersonasTotales FROM
(SELECT IDEstacionSalida,COUNT(V.IDTarjeta) AS [NumeroPersonas] FROM LM_Viajes AS V
WHERE  V.MomentoSalida BETWEEN @fechaInicio AND @fechaFin
GROUP BY IDEstacionSalida) AS [NPS] INNER JOIN
(SELECT IDEstacionEntrada,COUNT(V.IDTarjeta) AS [NumeroPersonas] FROM LM_Viajes AS V
WHERE V.MomentoEntrada BETWEEN @fechaInicio AND @fechaFin
GROUP BY IDEstacionEntrada) AS [NPE] ON NPS.IDEstacionSalida=NPE.IDEstacionEntrada 
GO
SELECT*FROM FINumeroPersonasPasanEstacion('2017-02-24 16:50:00','2017-02-25 16:50:00')

--Crea una funci�n inline que nos devuelva los kil�metros que ha recorrido cada tren en un periodo de tiempo. El principio y el fin de ese periodo se pasar�n como par�metros
SELECT*FROM LM_Viajes
SELECT*FROM LM_Recorridos
SELECT*FROM LM_Lineas
SELECT*FROM LM_Itinerarios
GO
CREATE OR ALTER FUNCTION FIKMTren
(@fechaInicio smalldatetime,@fechaFin smalldatetime) RETURNS TABLE AS RETURN
SELECT DISTINCT TLV.Tren,LND.Distancia*(TLV.NVeces/LND.NEstaciones) AS NOSE FROM
(SELECT R.Tren,R.Linea,COUNT(R.Linea) NVeces FROM LM_Recorridos AS R
GROUP BY R.Tren,R.Linea) AS TLV
INNER JOIN
(SELECT I.Linea,COUNT(estacionFin) AS NEstaciones, SUM(I.Distancia) AS Distancia FROM LM_Itinerarios AS I
GROUP BY I.Linea) AS LND ON TLV.Linea=LND.Linea
GO
SELECT*FROM FIKMTren('2017-02-26 16:50:00','2017-02-27 16:50:00')
--Crea una funci�n inline que nos devuelva el n�mero de trenes que ha circulado por cada l�nea en un periodo de tiempo. El principio y el fin de ese periodo se pasar�n como par�metros. Se devolver� el ID, denominaci�n y color de la l�nea
--Crea una funci�n inline que nos devuelva el tiempo total que cada usuario ha pasado en el metro en un periodo de tiempo. El principio y el fin de ese periodo se pasar�n como par�metros. Se devolver� ID, nombre y apellidos del pasajero. El tiempo se expresar� en horas y minutos.
