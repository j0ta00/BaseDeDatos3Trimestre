/*Ejercicio 10 (multiples instrucciones)
LeoMetro quiere premiar mensualmente a los pasajeros que m�s utilizan el transporte p�blico. 
Para ello necesitamos una funci�n que nos devuelva una tabla con los que deben ser premiados.

Los premios tienen tres categor�as: 1: Mayores de 65 a�os, 2: menores de 25 a�os y 3: resto. 
En cada categor�a se premia a tres personas. Los elegidos ser�n los que hayan realizado m�s viajes en ese mes. 
En caso de empatar en n�mero de viajes, se dar� prioridad al que m�s dinero se haya gastado.

Queremos una funci�n que reciba como par�metros un mes (TinyInt) y un a�o (SmallInt) y nos devuelva una tabla con los premiados de ese mes. 
Las columnas de la tabla ser�n: ID del pasajero, nombre, apellidos, n�mero de viajes realizados en el mes, total de dinero gastado, categor�a y posici�n 
(primero, segundo o tercero) en su categor�a.

La tabla tendr� mucho arte.*/



CREATE OR ALTER FUNCTION FMIPremiados()RETURNS @Premiados TABLE(

			IdPasajero int NOT NULL --No se si hace falta primary key, no me deja como restricci�n de tabla pero s� como de columna��??
			,prueba int NOT NULL
			
			
)
AS 
BEGIN
		insert into @Premiados(IdPasajero,prueba) values 
RETURN
END
GO

SELECT*FROM FMIPremiados()

SELECT T.IDPasajero,COUNT(*) AS [Numero Viajes] FROM LM_Viajes AS V INNER JOIN LM_Tarjetas AS T
ON V.IDTarjeta=T.ID 
GROUP BY T.IDPasajero
--No se si puede hacer correctamente debido a que no hay informaci�n de la edad de los pasajeros por lo tanto no podemos agruparlos por categor�as en funci�n
--de su edad


/*Ejercicio 8
La empresa del metro est� haciendo un estudio sobre los precios de los viajes. En concreto, quiere igualar la cantidad de dinero que ingresa el metro en cada
una de las zonas. Tomando como base el precio de la zona 1, queremos una funci�n a la que se pase como par�metro una zona y nos devuelva el precio que 
deber�an tener los billetes de esa zona para recaudar lo mismo que se recauda en la zona 1, teniendo en cuenta el n�mero der pasajeros que terminan sus 
viajes en esa zona y en la zona 1.

Ejemplo: Supongamos que en la zona 1 terminan sus viajes 5.000 pasajeros y el precio del billete es 1�, con lo que se recaudan 5.000�. 
Si en la zona 2 son s�lo 4.000 pasajeros, �cu�nto tendr�a que valer el billete de esa zona para igualar la recaudaci�n de 5.000 �?
*/

select*from LM_Zona_Precios
SELECT*FROM LM_Estaciones
select*from LM_Viajes

SELECT E.Zona_Estacion,COUNT(*) AS NumeroViajes,COUNT(*)*ZP.Precio_Zona AS DineroRecaudado,ZP.Precio_Zona, FROM LM_Viajes AS V INNER JOIN LM_Estaciones AS E
ON V.IDEstacionSalida=E.ID INNER JOIN LM_Zona_Precios AS ZP ON E.Zona_Estacion=ZP.Zona

GROUP BY E.Zona_Estacion,ZP.Precio_Zona


WHERE E.Zona_Estacion=@Zona


GO
CREATE OR ALTER FUNCTION FActualizarPrecioZonas(@Zona tinyInt) RETURNS money AS
/*
CABECERA: FUNCTION FActualizarPrecioZonas(@Zona tinyInt)
ENTRADA:@Zona tinyInt
SALIDA:@NuevoPrecio money
PRECONDICI�N:La zona no debe ser inferior a 1 ni superior a 4
POSTCONDICI�N:La funci�n devolver� un decimal monetario 
*/
BEGIN
	DECLARE @NuevoPrecio money,@dineroRecaudadoZona1 money,@numeroViajerosZonaIntroducida int

	SELECT @dineroRecaudadoZona1=(COUNT(*)*Precio_Zona) FROM LM_Viajes AS V INNER JOIN LM_Estaciones AS E
	ON V.IDEstacionSalida=E.ID INNER JOIN LM_Zona_Precios AS ZP ON E.Zona_Estacion=ZP.Zona--LOS INNER JOIN ME ASEGURAN LOS VIAJES TERMINADOS YA QUE SI HAN TERMINADO TIENEN ESTACI�N DE SALIDA
	WHERE E.Zona_Estacion=1 --Y AL UNIR POR DICHO CAMPO SI HUBIERA UN MOMENTO SALIDA NULO ESTE NO APARECER� COMO REGISTRO PUES EL INNER LO ELIMINAR� YA QUE NO HAY UNA ESTACION NULA COMO ID DE ESTACIONES
	GROUP BY Precio_Zona--CALCULO CANTIDAD DE DINERO QUE HA GENERADO LA ZONA 1

	SELECT @numeroViajerosZonaIntroducida=COUNT(*) FROM LM_Viajes AS V INNER JOIN LM_Estaciones AS E
	ON V.IDEstacionSalida=E.ID
	WHERE E.Zona_Estacion=@Zona--CUENTO LAS PERSONAS QUE HAN SALIDO POR LA ZONA QUE SE HA INTRODUCIDO POR PAR�METROS
	
	SET @NuevoPrecio=(@dineroRecaudadoZona1/@numeroViajerosZonaIntroducida)--CALCULO EL NUEVO PRECIO DIVIDIENDO EL DINERO QUE RECAUDA LA ZONA 1 ENTRE LOS VIAJEROS O M�S BIEN VIAJES
	--(YA QUE PUEDE SER EL MISMO VIAJERO QUE HA VIAJADO VARIAS VECES Y POR LO TANTO AL HABER PAGADO EN TODAS CONTAR�A COMO VIAJES DISTINTOS LOGICAMENTE)  Y AS� OBTENEMOS EL NUEVO PRECIO
		
	RETURN @NuevoPrecio 
END
GO


PRINT dbo.FActualizarPrecioZonas(4)


 
