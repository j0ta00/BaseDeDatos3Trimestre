/*Ejercicio 10 (multiples instrucciones)
LeoMetro quiere premiar mensualmente a los pasajeros que m�s utilizan el transporte p�blico. Para ello necesitamos una funci�n que nos devuelva una tabla con los que deben ser premiados.

Los premios tienen tres categor�as: 1: Mayores de 65 a�os, 2: menores de 25 a�os y 3: resto. En cada categor�a se premia a tres personas. Los elegidos ser�n los que hayan realizado m�s viajes en ese mes. En caso de empatar en n�mero de viajes, se dar� prioridad al que m�s dinero se haya gastado.

Queremos una funci�n que reciba como par�metros un mes (TinyInt) y un a�o (SmallInt) y nos devuelva una tabla con los premiados de ese mes. Las columnas de la tabla ser�n: ID del pasajero, nombre, apellidos, n�mero de viajes realizados en el mes, total de dinero gastado, categor�a y posici�n (primero, segundo o tercero) en su categor�a.

La tabla tendr�

*/

CREATE FUNCTION FPrueba() RETURNS @Prueba TABLE(

	Id smallint NOT NULL

) AS 
BEGIN
	
	RETURN 
END