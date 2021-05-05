/*Ejercicio 10 (multiples instrucciones)
LeoMetro quiere premiar mensualmente a los pasajeros que más utilizan el transporte público. Para ello necesitamos una función que nos devuelva una tabla con los que deben ser premiados.

Los premios tienen tres categorías: 1: Mayores de 65 años, 2: menores de 25 años y 3: resto. En cada categoría se premia a tres personas. Los elegidos serán los que hayan realizado más viajes en ese mes. En caso de empatar en número de viajes, se dará prioridad al que más dinero se haya gastado.

Queremos una función que reciba como parámetros un mes (TinyInt) y un año (SmallInt) y nos devuelva una tabla con los premiados de ese mes. Las columnas de la tabla serán: ID del pasajero, nombre, apellidos, número de viajes realizados en el mes, total de dinero gastado, categoría y posición (primero, segundo o tercero) en su categoría.

La tabla tendrá

*/

CREATE FUNCTION FPrueba() RETURNS @Prueba TABLE(

	Id smallint NOT NULL

) AS 
BEGIN
	
	RETURN 
END