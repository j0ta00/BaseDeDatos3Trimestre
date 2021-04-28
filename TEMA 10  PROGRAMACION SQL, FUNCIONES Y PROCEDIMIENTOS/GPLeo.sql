/*
Puntuación
Posicion	Puntos
1			20
2			15
3			11
4			8
5			6
6			4
7			3
Posiciones posteriores
1

-En cada carrera, a los pilotos se le asignan puntos, según sus resultados, de acuerdo a la siguiente tabla:

-Los pilotos que no hayan finalizado la carrera no puntúan.
-Queremos hacer una función inline a la que pasemos el número de un Gran Premio (numOrden) y nos devuelva una tabla con la clasificación tras disputarse dicho gran premio (y todos los anteriores, claro). La tabla devuelta tendrá las siguientes columnas: Dorsal del Piloto, Nombre, Numero de carreras finalizadas, número de carreras ganadas, Número de podiums (posiciones del 1 al 3), puntos.

-NOTA: Los CASE se pueden anidar

*/

SELECT*FROM GrandesPremios
SELECT*FROM Disputas
SELECT*FROM Pilotos
SELECT*FROM Circuitos

GO
CREATE FUNCTION FIGP(@IdGranPremio tinyint)
RETURNS TABLE AS RETURN
(
SELECT P.Dorsal, SUM(P.Puntos) AS Puntos FROM
(SELECT P.Dorsal,GP.NumOrden,(CASE D.Posición WHEN 
1 THEN 20 
WHEN 2 THEN 15 
WHEN 3 THEN 11 
WHEN 4 THEN 8 
WHEN 5 THEN 6
WHEN 6 THEN 4 
WHEN 7 THEN 3
ELSE 1
END) AS Puntos
FROM GrandesPremios AS GP
INNER JOIN Disputas AS D ON GP.NumOrden=D.NumOrden INNER JOIN
Pilotos AS P ON D.Dorsal=P.Dorsal
WHERE Finalizado=1) AS P GROUP BY P.Dorsal



)



GO

