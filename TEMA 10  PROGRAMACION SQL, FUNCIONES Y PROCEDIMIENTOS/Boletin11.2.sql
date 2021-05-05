/*Ejercicio 0
La convocatoria de elecciones en Madrid ha causado tal conmoción entre los directivos de LeoMetro que han decidido conceder una amnistía a todos los pasajeros que tengan un saldo negativo en sus tarjetas.
Crea un procedimiento que racargue la cantidad necesaria para dejar a 0 el saldo de las tarjetas que tengan un saldo negativo y hayan sido recargadas al menos una vez en los últimos dos meses.
Ejercicio elaborado en colaboración con Sefran.
*/
/*Ejercicio 1
Crea un procedimiento RecargarTarjeta que reciba como parámetros el ID de una tarjeta y un importe y actualice el saldo de la tarjeta sumándole dicho importe, además de grabar la correspondiente recarga
*/
/*Ejercicio 2
Crea un procedimiento almacenado llamado PasajeroSale que reciba como parámetros el ID de una tarjeta, el ID de una estación y una fecha/hora (opcional). 
El procedimiento se llamará cuando un pasajero pasa su tarjeta por uno de los tornos de salida del metro. 
Su misión es grabar la salida en la tabla LM_Viajes. Para ello deberá localizar la entrada que corresponda, que será la última entrada correspondiente al mismo pasajero y hará un update de las columnas que correspondan. 
Si no existe la entrada, grabaremos una nueva fila en LM_Viajes dejando a NULL la estación y el momento de entrada.
Si se omite el parámetro de la fecha/hora, se tomará la actual.
También debe actualizarse el saldo de la tarjeta, descontando el importe del viaje grabado.
*/
GO
CREATE OR ALTER PROCEDURE [PPasajeroSale](@IdTarjeta int,@IdEstacion smallint,@fechaYHora smalldatetime=NULL) AS 
BEGIN
	DECLARE @Importe money
	SELECT @Importe=ZP.Precio_Zona FROM LM_Estaciones AS E INNER JOIN LM_Zona_Precios AS ZP ON E.Zona_Estacion=ZP.Zona
	WHERE E.ID=@IdEstacion
	IF(@fechaYHora IS NULL)
	BEGIN
		SET @fechaYHora=CAST(GETDATE() AS smalldatetime)
	END
	IF EXISTS(SELECT IDEstacionSalida FROM LM_Viajes AS V WHERE V.IDTarjeta=3 AND IDEstacionSalida IS NULL)
		BEGIN
			UPDATE LM_Viajes SET IDEstacionSalida=@IdEstacion, MomentoSalida=@fechaYHora,Importe_Viaje=@Importe
			WHERE IDTarjeta=@IdTarjeta AND IDEstacionSalida IS NULL
		END
	ELSE
		BEGIN
			INSERT INTO LM_Viajes VALUES(@IdTarjeta,NULL,@IdEstacion,NULL,@fechaYHora,@Importe)
		END
	UPDATE LM_Tarjetas SET Saldo-=@Importe
END
GO




/*Ejercicio 3
A veces, un pasajero reclama que le hemos cobrado un viaje de forma indebida. Escribe un procedimiento que reciba como parámetro el ID de un pasajero y la fecha y hora de la entrada en el metro y anule ese viaje, actualizando además el saldo de la tarjeta que utilizó.
*/

EXEC sys.sp_addmessage @msgnum=51000, @severity=16, @msgtext='Invalid parameters', @lang='us_english',@replace='replace'
GO
CREATE OR ALTER PROCEDURE PAnularViaje(@IdPasajero smallint,@Entrada smalldatetime) AS
BEGIN 
	DECLARE @Importe money,@IdTarjeta smallint
	IF EXISTS(SELECT ID FROM LM_Pasajeros WHERE ID=@IdPasajero)
		BEGIN
			SELECT @Importe=Importe_Viaje,@IdTarjeta=IDTarjeta FROM LM_Viajes LM_Viajes WHERE IDTarjeta=(SELECT T.ID FROM LM_Pasajeros AS P INNER JOIN LM_Tarjetas AS T ON P.ID=T.IDPasajero WHERE P.ID=@IdPasajero) AND MomentoEntrada=@Entrada
			DELETE FROM LM_Viajes WHERE IDTarjeta=@IdTarjeta AND MomentoEntrada=@Entrada
			UPDATE LM_Tarjetas SET Saldo-=@Importe WHERE ID=@IdTarjeta
		END
	ELSE
		THROW 51000,'Parámetros inválidos, introduce unos adecuados',1
END
GO
BEGIN TRANSACTION

BEGIN TRY
	EXECUTE PAnularViaje @IdPasajero=2000,@Entrada='2021-04-30 10:00:00'
END TRY
BEGIN CATCH
	SELECT ERROR_NUMBER() AS [Número del error], ERROR_SEVERITY() AS [Gravedad del error],ERROR_LINE() AS [Linea del error],ERROR_STATE() AS [Estado del error],ERROR_PROCEDURE() AS [Nombre del procedimiento donde se produjo]
END CATCH

/*Ejercicio 4
La empresa de Metro realiza una campaña de promoción para pasajeros fieles.

Crea un procedimiento almacenado que recargue saldo a los pasajeros que cumplan determinados requisitos.
Se recargarán N1 euros a los pasajeros que hayan consumido más de 30 euros en el mes anterior (considerar mes completo, del día 1 al fin) y N2 euros a los que hayan utilizado más de 10 veces alguna estación de las zonas 3 o 4.

Los valores de N1 y N2 se pasarán como parámetros. Si se omiten, se tomará el valor 5.

Ambos premios son excluyentes. Si algún pasajero cumple ambas condiciones se le aplicará la que suponga mayor bonificación de las dos.
*/

select*from LM_Viajes

SELECT V.IDTarjeta,SUM(V.Importe_Viaje) Gastado FROM LM_Viajes AS V 
GROUP BY V.IDTarjeta 


SELECT  NVCE.IDTarjeta,NVCE.NVeces+NVCS.NVeces AS NVeces  FROM
(SELECT V.IDTarjeta,V.IDEstacionEntrada,COUNT(*) AS NVeces FROM LM_Viajes AS V
WHERE V.IDEstacionEntrada  IN (SELECT ID FROM LM_Estaciones WHERE Zona_Estacion IN (3,4)) 
GROUP BY  V.IDTarjeta,V.IDEstacionEntrada) AS NVCE 
INNER JOIN
(SELECT V.IDTarjeta,V.IDEstacionSalida,COUNT(*) AS NVeces FROM LM_Viajes AS V
WHERE V.IDEstacionSalida  IN (SELECT ID FROM LM_Estaciones WHERE Zona_Estacion IN (3,4))
GROUP BY  V.IDTarjeta,V.IDEstacionSalida) AS NVCS ON NVCE.IDTarjeta=NVCS.IDTarjeta 




SELECT Zona_Estacion FROM LM_Estaciones



/*Ejercicio 5
Crea una función que nos devuelva verdadero si es posible que un pasajero haya subido a un tren en un determinado viaje. Se pasará como parámetro el código del viaje y la matrícula del tren.

Primera aproximación: Se considera que un pasajero ha podido subir a un tren si ese tren se encontraba en serviciodurante el tiempo que el pasajero ha permanecido dentro del sistema de metro

*/

GO
CREATE OR ALTER FUNCTION FPosiblePasajero 
(@MatriculaTren char(7),@CodigoViaje int)RETURNS bit AS
BEGIN
	DECLARE @Posible bit
	SET @Posible=0
		IF EXISTS(SELECT * FROM LM_Recorridos AS R INNER JOIN 
		LM_Trenes AS T ON R.Tren=ID 
		WHERE T.Matricula=@MatriculaTren AND Momento BETWEEN (SELECT MomentoEntrada FROM LM_Viajes WHERE ID=@CodigoViaje) AND (SELECT MomentoSalida FROM LM_Viajes WHERE ID=@CodigoViaje))
			BEGIN
				SET @Posible=1
			END
	RETURN @Posible
END
PRINT dbo.FPosiblePasajero('3290GPT',28) 



/*Ejercicio 6
Crea un procedimiento SustituirTarjeta que Cree una nueva tarjeta y la asigne al mismo usuario y con el mismo saldo que otra tarjeta existente. El código de la tarjeta a sustituir se pasará como parámetro.

*/





/*Ejercicio 7
Las estaciones de la zona 3 tienen ciertas deficiencias, lo que nos ha obligado a introducir una serie de modificaciones en los trenes  para cumplir las medidas de seguridad.

A consecuencia de estas modificaciones, la capacidad de los trenes se ha visto reducida en 6 plazas para los trenes de tipo 1 y 4 plazas para los trenes de tipo 2.

Realiza un procedimiento al que se pase un intervalo de tiempo y modifique la capacidad de todos los trenes que hayan circulado más de una vez por alguna estación de la zona 3 en ese intervalo.
*/
GO
CREATE OR ALTER PROCEDURE PModificarCapacidad(@Entrada smalldatetime,@Salida smalldatetime) AS
BEGIN
	UPDATE LM_Trenes SET Capacidad-=CASE Tipo WHEN
	1 THEN 6
	WHEN 2 THEN 4
	END
	WHERE ID IN(
	SELECT Tren FROM LM_Recorridos AS R
	INNER JOIN LM_Estaciones AS E ON R.estacion=E.ID
	WHERE E.Zona_Estacion=3 AND Momento BETWEEN @Entrada AND @Salida
	GROUP BY Tren
	HAVING COUNT(*)>1)
END
GO
BEGIN TRANSACTION
EXECUTE PModificarCapacidad @Entrada='2017-02-24 14:32:16.000',@Salida='2017-02-28 14:32:16.000'
SELECT*FROM LM_Trenes
SELECT*FROM LM_Recorridos
