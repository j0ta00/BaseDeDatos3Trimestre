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
CREATE OR ALTER FUNCTION FIGP(@IdGranPremio AS tinyint)
RETURNS TABLE AS RETURN
(
SELECT P.Dorsal,P.Nombre,SUM(ISNULL(P.CarrerasFinalizadas,0)) AS [Carreras Finalizadas],SUM(P.Puntos) AS Puntos, SUM(ISNULL(POD.Podios,0)) AS Podios, SUM(ISNULL(V.Victorias,0)) AS Victorias FROM
(SELECT P.Dorsal,GP.Fecha,P.Nombre,GP.NumOrden,COUNT(*) AS CarrerasFinalizadas,(CASE D.Posición WHEN 
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
WHERE Finalizado=1 GROUP BY P.Dorsal,P.Nombre,GP.NumOrden,D.Posición,GP.Fecha) AS P
FULL JOIN
(SELECT P.Dorsal,GP.NumOrden,COUNT(ISNULL(D.Posición,0)) AS Podios
FROM GrandesPremios AS GP
INNER JOIN Disputas AS D ON GP.NumOrden=D.NumOrden INNER JOIN
Pilotos AS P ON D.Dorsal=P.Dorsal
WHERE Finalizado=1 AND D.Posición BETWEEN 1 AND 3 GROUP BY P.Dorsal,GP.NumOrden) AS POD ON P.Dorsal=POD.Dorsal AND P.NumOrden=POD.NumOrden
FULL JOIN
(SELECT P.Dorsal,GP.NumOrden,COUNT(ISNULL(D.Posición,0)) AS Victorias
FROM GrandesPremios AS GP
INNER JOIN Disputas AS D ON GP.NumOrden=D.NumOrden INNER JOIN
Pilotos AS P ON D.Dorsal=P.Dorsal
WHERE Finalizado=1 AND D.Posición=1 GROUP BY P.Dorsal,GP.NumOrden) AS V ON P.Dorsal=V.Dorsal AND P.NumOrden=V.NumOrden
WHERE P.NumOrden=@IdGranPremio OR (SELECT Fecha FROM GrandesPremios WHERE NumOrden=@IdGranPremio)>P.Fecha
GROUP BY P.Dorsal,P.Nombre
)
GO
SELECT*FROM GrandesPremios
SELECT*FROM FIGP(4)
