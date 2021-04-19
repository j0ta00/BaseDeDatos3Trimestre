--1 Crea una función inline que nos devuelva el número de estaciones que ha recorrido cada tren en un determinado periodo de tiempo. El principio y el fin de ese periodo se pasarán como parámetros

SELECT*FROM LM_Recorridos
GO
CREATE OR ALTER FUNCTION FIEstacionesRecorridas(@Principio smallDateTime, @Fin smallDateTime )RETURNS TABLE AS RETURN
SELECT R.Tren,COUNT(DISTINCT R.estacion) AS [Numero Estaciones Recorrdidas] FROM LM_Recorridos AS R
WHERE R.Momento BETWEEN @Principio AND @Fin
GROUP BY R.Tren
GO

SELECT*FROM FIEstacionesRecorridas('2017-02-26 02:20:00.000','2017-02-26 02:25:18.000')
--2 Crea una función inline que nos devuelva el número de veces que cada usuario ha entrado en el metro en un periodo de tiempo. El principio y el fin de ese periodo se pasarán como parámetros


--3 Crea una función inline a la que pasemos la matrícula de un tren y una fecha de inicio y fin y nos devuelva una tabla con el número de veces que ese tren ha estado en cada estación, además del ID, nombre y dirección de la estación
GO
CREATE OR ALTER FUNCTION FIRecorridoTrenesMatricula
(@matricula char(7),@fechaInicio smalldatetime,@fechaFin smalldatetime) RETURNS TABLE AS RETURN
	SELECT  R.Tren,R.estacion AS IdEstacion,E.Denominacion,E.Direccion,COUNT(*) AS NumeroVeces FROM LM_Trenes AS T 
	INNER JOIN LM_Recorridos AS R ON T.ID=R.Tren 
	INNER JOIN LM_Estaciones AS E ON R.estacion=E.ID
	WHERE T.Matricula=@matricula AND R.Momento BETWEEN @fechaInicio AND @fechaFin 
	GROUP BY R.Tren,R.estacion,E.Denominacion,E.Direccion
GO
SELECT*FROM FIRecorridoTrenesMatricula('0100FRY','2017-02-26 02:20:00.000','2017-02-26 02:50:05.000')--PREGUNTAR POR EL BETWEEN PORQUÉ PARECE QUE EL VALOR LÍMITE  FECHAFIN NO SE HA INCLUIDO 

--4 Crea una función inline que nos diga el número de personas que han pasado por una estacion en un periodo de tiempo. 
--Se considera que alguien ha pasado por una estación si ha entrado o salido del metro por ella. El principio y el fin de ese periodo se pasarán como parámetros
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

--5 Crea una función inline que nos devuelva los kilómetros que ha recorrido cada tren en un periodo de tiempo. El principio y el fin de ese periodo se pasarán como parámetros


GO--FUNCION ESCALAR QUE CALCULA PASANDOLE POR PARÁMETROS EL MOMENTO Y EL ID DEL TREN, POR QUE ESTACION PASÓ EN EL MOMENTO INMEDIATAMENTE ANTERIOR 
CREATE OR ALTER FUNCTION FMomento 
(@momento smalldatetime,@idTren int) RETURNS smallint AS
BEGIN
	RETURN (SELECT R.estacion FROM 
	LM_Recorridos AS R	INNER JOIN 
	(SELECT MAX(Momento) AS MomentoAnterior FROM LM_Recorridos AS R
	WHERE Momento<@momento AND R.Tren=@idTren) AS MA ON R.Momento=MA.MomentoAnterior
	WHERE R.Tren=@idTren)
END
GO

GO
CREATE OR ALTER FUNCTION FIKilometros--FUNCION INLINE QUE DEVUELVE LOS KILOMETROS QUE HA RECORRIDO UN PERIODO DE TIEMPO PASADO POR PARÁMETROS
(@fechaInicio smalldatetime,@fechaFin smalldatetime) RETURNS TABLE AS RETURN
SELECT R.Tren,SUM(I.Distancia) AS KilometrosRecorridos FROM LM_Itinerarios AS I INNER JOIN --SUMAMOS DISTANCIA
LM_Recorridos AS R ON I.estacionFin=R.estacion AND I.estacionIni=dbo.FMomento(R.Momento,R.Tren)--UNIMOS EN EL ON LA ESTACION FINAL CON LA ESTACION Y LA INICIAL 
WHERE R.Momento BETWEEN @fechaInicio AND @fechaFin--CON LA ESTACION ANTERIOR DE ESTA FORMA TENEMOS TODOS LAS ESTACIONES POR DONDE HA PASADO YA QUE UNIMOS "RECURSIVAMENTE"(POR ASÍ DECIRLO) ESTAMOS UNIENDO FIN CON UNA Y INICIAL CON LA ANTERIOR Y ASÍ SUCESIVAMENTE DANDO DE ESTA FORMA EL RECORRIDO TOTAL POR ESTACIONES
GROUP BY R.Tren--EN EL WHERE PONEMOS LA CONDICION DEL MOMENTO EN EL QUE CALCULAREMOS LA DISTANCIA Y AGRUPAMOS POR TRENES
GO

SELECT*FROM FIKilometros('2017-02-26 00:50:00','2017-02-27 00:51:00')
SELECT*FROM LM_Recorridos
SELECT*FROM LM_Itinerarios

--6 Crea una función inline que nos devuelva el número de trenes que ha circulado por cada línea en un periodo de tiempo. El principio y el fin de ese periodo se pasarán como parámetros. Se devolverá el ID, denominación y color de la línea
CREATE FUNCTION FI
SELECT R.Linea,L.Color,L.Denominacion,COUNT(DISTINCT R.Tren) AS NumeroTrenes FROM LM_Recorridos AS R
INNER JOIN LM_Lineas AS L ON R.Linea=L.ID
WHERE R.Momento BETWEEN '2017-02-26 00:50:00'AND '2017-02-28 04:00:00'
GROUP BY R.Linea,L.Color,L.Denominacion

--7 Crea una función inline que nos devuelva el tiempo total que cada usuario ha pasado en el metro en un periodo de tiempo. 
--El principio y el fin de ese periodo se pasarán como parámetros. Se devolverá ID, nombre y apellidos del pasajero. 
--El tiempo se expresará en horas y minutos.