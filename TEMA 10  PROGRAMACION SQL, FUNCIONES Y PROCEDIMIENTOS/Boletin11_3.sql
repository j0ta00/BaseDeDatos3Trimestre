/*Ejercicio 10 (multiples instrucciones)
LeoMetro quiere premiar mensualmente a los pasajeros que más utilizan el transporte público. 
Para ello necesitamos una función que nos devuelva una tabla con los que deben ser premiados.

Los premios tienen tres categorías: 1: Mayores de 65 años, 2: menores de 25 años y 3: resto. 
En cada categoría se premia a tres personas. Los elegidos serán los que hayan realizado más viajes en ese mes. 
En caso de empatar en número de viajes, se dará prioridad al que más dinero se haya gastado.

Queremos una función que reciba como parámetros un mes (TinyInt) y un año (SmallInt) y nos devuelva una tabla con los premiados de ese mes. 
Las columnas de la tabla serán: ID del pasajero, nombre, apellidos, número de viajes realizados en el mes, total de dinero gastado, categoría y posición 
(primero, segundo o tercero) en su categoría.

La tabla tendrá mucho arte.*/



CREATE OR ALTER FUNCTION FMIPremiados()RETURNS @Premiados TABLE(

			IdPasajero int NOT NULL --No se si hace falta primary key, no me deja como restricción de tabla pero sí como de columna¿¿??
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
--No se si puede hacer correctamente debido a que no hay información de la edad de los pasajeros por lo tanto no podemos agruparlos por categorías en función
--de su edad


/*Ejercicio 8
La empresa del metro está haciendo un estudio sobre los precios de los viajes. En concreto, quiere igualar la cantidad de dinero que ingresa el metro en cada
una de las zonas. Tomando como base el precio de la zona 1, queremos una función a la que se pase como parámetro una zona y nos devuelva el precio que 
deberían tener los billetes de esa zona para recaudar lo mismo que se recauda en la zona 1, teniendo en cuenta el número der pasajeros que terminan sus 
viajes en esa zona y en la zona 1.

Ejemplo: Supongamos que en la zona 1 terminan sus viajes 5.000 pasajeros y el precio del billete es 1€, con lo que se recaudan 5.000€. 
Si en la zona 2 son sólo 4.000 pasajeros, ¿cuánto tendría que valer el billete de esa zona para igualar la recaudación de 5.000 €?
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
PRECONDICIÓN:La zona no debe ser inferior a 1 ni superior a 4
POSTCONDICIÓN:La función devolverá un decimal monetario 
*/
BEGIN
	DECLARE @NuevoPrecio money,@dineroRecaudadoZona1 money,@numeroViajerosZonaIntroducida int

	SELECT @dineroRecaudadoZona1=(COUNT(*)*Precio_Zona) FROM LM_Viajes AS V INNER JOIN LM_Estaciones AS E
	ON V.IDEstacionSalida=E.ID INNER JOIN LM_Zona_Precios AS ZP ON E.Zona_Estacion=ZP.Zona--LOS INNER JOIN ME ASEGURAN LOS VIAJES TERMINADOS YA QUE SI HAN TERMINADO TIENEN ESTACIÓN DE SALIDA
	WHERE E.Zona_Estacion=1 --Y AL UNIR POR DICHO CAMPO SI HUBIERA UN MOMENTO SALIDA NULO ESTE NO APARECERÁ COMO REGISTRO PUES EL INNER LO ELIMINARÁ YA QUE NO HAY UNA ESTACION NULA COMO ID DE ESTACIONES
	GROUP BY Precio_Zona--CALCULO CANTIDAD DE DINERO QUE HA GENERADO LA ZONA 1

	SELECT @numeroViajerosZonaIntroducida=COUNT(*) FROM LM_Viajes AS V INNER JOIN LM_Estaciones AS E
	ON V.IDEstacionSalida=E.ID
	WHERE E.Zona_Estacion=@Zona--CUENTO LAS PERSONAS QUE HAN SALIDO POR LA ZONA QUE SE HA INTRODUCIDO POR PARÁMETROS
	
	SET @NuevoPrecio=(@dineroRecaudadoZona1/@numeroViajerosZonaIntroducida)--CALCULO EL NUEVO PRECIO DIVIDIENDO EL DINERO QUE RECAUDA LA ZONA 1 ENTRE LOS VIAJEROS O MÁS BIEN VIAJES
	--(YA QUE PUEDE SER EL MISMO VIAJERO QUE HA VIAJADO VARIAS VECES Y POR LO TANTO AL HABER PAGADO EN TODAS CONTARÍA COMO VIAJES DISTINTOS LOGICAMENTE)  Y ASÍ OBTENEMOS EL NUEVO PRECIO
		
	RETURN @NuevoPrecio 
END
GO


PRINT dbo.FActualizarPrecioZonas(4)


 
