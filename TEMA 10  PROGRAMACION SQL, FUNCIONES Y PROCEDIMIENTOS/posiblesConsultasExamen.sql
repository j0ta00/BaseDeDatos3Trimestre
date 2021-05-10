
SELECT*FROM HGeneros
GO
CREATE FUNCTION FPeliculaMasConsumidaYGenero(@Nombre varchar(20)) 
RETURNS TABLE AS RETURN

	SELECT P.nombre,PG.IDPelicula,PG.IDGenero,COUNT(*) FROM HPerfiles AS P
	INNER JOIN HVisionados AS V ON P.ID=V.IDPerfil INNER JOIN HContenidos AS C ON V.IDContenido=C.ID
	INNER JOIN HPeliculas AS PC ON C.ID=PC.ID INNER JOIN HPeliculasGeneros AS PG ON PC.ID=PG.IDPelicula
	GROUP BY P.nombre,PG.IDGenero,PG.IDPelicula--PELICULA CON SU GENERO 


	SELECT P.nombre,PG.IDGenero,COUNT(*) FROM HPerfiles AS P
	INNER JOIN HVisionados AS V ON P.ID=V.IDPerfil INNER JOIN HContenidos AS C ON V.IDContenido=C.ID
	INNER JOIN HPeliculas AS PC ON C.ID=PC.ID INNER JOIN HPeliculasGeneros AS PG ON PC.ID=PG.IDPelicula
	GROUP BY P.nombre,PG.IDGenero--LO MISMO PERO SIN LA PELICULA SERÍA EL GENERO MÁS CONSUMIDO

	--A AMBOS  QUEDARÍA HACERLE EL MAX Y TAL BASICAMENTE UNOS SUPERVENTAS

GO
SELECT*FROM HPerfiles

SELECT*FROM HSeries
SELECT*FROM HTiposSuscripcion
SELECT*FROM HPeliculas

SELECT NVV.ID,MAX(NV.NVisionados) AS NVisionados,POS.IDSerie,POS.titulo FROM 
(SELECT C.ID,COUNT(*) AS NVisionados FROM HVisionados AS V INNER JOIN HContenidos AS C
ON V.IDContenido=C.ID 
GROUP BY C.ID) AS NV INNER JOIN 
(SELECT C.ID,COUNT(*) AS NVisionados FROM HVisionados AS V INNER JOIN HContenidos AS C
ON V.IDContenido=C.ID 
GROUP BY C.ID)AS NVV ON NV.NVisionados=NVV.NVisionados
INNER JOIN(
SELECT C.ID,HC.IDSerie,P.titulo FROM HContenidos AS C INNER JOIN HCapitulos AS HC ON C.ID=HC.ID
INNER JOIN HPeliculas AS P ON C.ID=P.ID
) AS POS ON NVV.ID=POS.ID
GROUP BY NVV.ID,POS.IDSerie,POS.titulo



--CALCULANDO EL IMPORTE EXTRA

--FORMA 1
SELECT S.ID,SUM(CASE S.Tipo WHEN 'E' THEN PP.precioE 
WHEN 'S' THEN PP.precioS ELSE 0 END)
FROM HSuscripciones AS S
INNER JOIN HPerfiles AS P ON S.ID=P.IDSuscripcion INNER JOIN HVisionados AS V 
ON P.ID=V.IDPerfil INNER JOIN HContenidos AS C ON V.IDContenido=C.ID
INNER JOIN HPeliculas AS PP ON C.ID=PP.ID
GROUP BY S.ID


--FORMA 2
DECLARE @Importe money
SET @Importe= (SELECT S.ID, CASE S.tipo WHEN 'E' THEN SUM(PP.precioE)
WHEN 'S' THEN SUM(PP.precioS) END 
FROM HSuscripciones AS S
INNER JOIN HPerfiles AS P ON S.ID=P.IDSuscripcion INNER JOIN HVisionados AS V 
ON P.ID=V.IDPerfil INNER JOIN HContenidos AS C ON V.IDContenido=C.ID
INNER JOIN HPeliculas AS PP ON C.ID=PP.ID
GROUP BY S.ID,S.tipo)
