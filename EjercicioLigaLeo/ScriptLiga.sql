--TRABAJO ACTUALIZACION LEOCHAMPIONSLEAGUE REALIZADO POR JUAN JOSÉ MUÑOZ Y JESÚS GARCÍA
--INSERTAR EL IDEQUIPO Y NOMBRE EQUIPO DE LA TABLA CLASIFICACION 
GO
DELETE FROM Clasificacion
INSERT INTO Clasificacion(IDEquipo,NombreEquipo) SELECT E.ID,E.Nombre FROM Equipos AS E


--CREO VISTA PARTIDOS JUGADOS
GO
CREATE OR ALTER VIEW [VPJ] AS 
SELECT PGL.ELocal,(PGL.NumeroPartidos+PJV.NumeroPartidos) AS [NumeroPartidosJugados] FROM
(SELECT P.ELocal,COUNT(*) AS [NumeroPartidos] FROM Partidos AS P
WHERE P.Finalizado=1 
GROUP BY P.ELocal) AS PGL
INNER JOIN
(SELECT P.EVisitante,COUNT(*) AS [NumeroPartidos] FROM Partidos AS P
WHERE P.Finalizado=1 
GROUP BY P.EVisitante) AS PJV ON PGL.ELocal=PJV.EVisitante
GO

--CREO VISTA CON LOS PARTIDOS GANADOS POR CADA EQUIPO
GO
CREATE OR ALTER VIEW [VPG] AS
SELECT PJL.ELocal,(PJL.PartidosGanados+PGV.PartidosGanados) AS [PartidosGanados] FROM 
(SELECT P.ELocal,COUNT(*) AS [PartidosGanados] FROM Partidos AS P
WHERE P.GolesLocal>P.GolesVisitante AND P.Finalizado=1 
GROUP BY P.ELocal) AS PJL
INNER JOIN 
(SELECT P.EVisitante,COUNT(*) AS [PartidosGanados] FROM Partidos AS P
WHERE P.GolesVisitante>P.GolesLocal AND P.Finalizado=1 
GROUP BY P.EVisitante) AS PGV ON PJL.ELocal=PGV.EVisitante
GO

--CREO VISTA CON LOS PARTIDOS EMPATADOS POR CADA EQUIPO
GO
CREATE OR ALTER VIEW [VPE] AS
SELECT  PEL.EVisitante,(PEL.PartidosEmpatados+PEV.PartidosEmpatados) AS [PartidosEmpatados] FROM
(SELECT P.EVisitante,COUNT(*) AS [PartidosEmpatados] FROM Partidos AS P
WHERE P.GolesVisitante=P.GolesLocal AND P.Finalizado=1 
GROUP BY P.EVisitante) AS PEL
INNER JOIN
(SELECT P.ELocal,COUNT(*) AS [PartidosEmpatados] FROM Partidos AS P
WHERE P.GolesLocal=P.GolesVisitante AND P.Finalizado=1 
GROUP BY P.ELocal) AS PEV ON PEL.EVisitante=PEV.ELocal
GO

--CREO VISTA CON LOS PARTIDOS PERDIDOS DE CADA EQUIPO NO ES NECESARIO
GO
CREATE OR ALTER VIEW [VPP] AS
SELECT VPJ.ELocal,VPJ.NumeroPartidosJugados-(VPG.PartidosGanados+VPE.PartidosEmpatados) AS [NumeroPartidosPerdidos] FROM VPJ INNER JOIN
VPG ON VPJ.ELocal=VPG.ELocal INNER JOIN VPE ON VPJ.ELocal=VPE.EVisitante
GO

--CREO VISTA CON LOS PUNTOS DE CADA EQUIPO NO ES NECESARIO
GO
CREATE OR ALTER VIEW [VPPE] AS
SELECT VPG.ELocal,(VPE.PartidosEmpatados+VPG.PartidosGanados*3) AS [Puntos] FROM VPG INNER JOIN
VPE ON VPG.ELocal=VPE.EVisitante
GO

--GOLES A FAVOR DE CADA EQUIPO
GO
CREATE OR ALTER VIEW [VGF] AS
SELECT GL.ELocal, (GL.Goles+GV.Goles) AS [Goles] FROM
(SELECT P.ELocal,SUM(P.GolesLocal) AS [Goles] FROM Partidos AS P
GROUP BY  P.ELocal) AS GL INNER JOIN 
(SELECT P.EVisitante,SUM(P.GolesVisitante) AS [Goles] FROM Partidos AS P
GROUP BY  P.EVisitante)AS GV ON GL.ELocal=GV.EVisitante
GO

--GOLES EN CONTRA DE CADA EQUIPO
GO
CREATE OR ALTER VIEW [VGC] AS
SELECT GL.EVisitante, (GL.GolesContra+GV.GolesContra) AS [Goles] FROM
(SELECT P.EVisitante,SUM(P.GolesLocal) AS [GolesContra] FROM Partidos AS P
GROUP BY  P.EVisitante) AS GL INNER JOIN 
(SELECT P.ELocal,SUM(P.GolesVisitante) AS [GolesContra] FROM Partidos AS P
GROUP BY  P.ELocal)AS GV ON GL.EVisitante=GV.ELocal
GO

--ACTUALIZO LA TABLA AÑADIENDO LOS DATOS RESTANTES
GO
UPDATE Clasificacion SET PartidosJugados=VPJ.NumeroPartidosJugados,PartidosGanados=VPG.PartidosGanados,PartidosEmpatados=VPE.PartidosEmpatados,
GolesFavor=VGF.Goles,GolesContra=VGC.Goles 
FROM VPG INNER JOIN 
VPJ ON VPG.ELocal=VPJ.ELocal INNER JOIN
VPE ON VPG.ELocal=VPE.EVisitante INNER JOIN
VGF ON VPG.ELocal=VGF.ELocal INNER JOIN
VGC ON VPG.ELocal=VGC.EVisitante
WHERE VPG.ELocal=Clasificacion.IDEquipo 
GO

--CONSULTAR CLASIFICACION
SELECT*FROM Clasificacion AS C 
ORDER BY C.Puntos DESC,C.GolesFavor-C.GolesContra DESC,C.GolesFavor DESC


/*FUNCION INLINE QUE TE DICE CUANTOS PARTIDOS A JUGADO CADA EQUIPO PASANDOLE EL ID DE ESTE POR PARÁMETROS NO HEMOS HECHO MÁS DEBIDO A QUE ES MUY POCO EFICIENTE
COMPARADO CON LAS VISTAS, A LA HORA DE REALIZAR ESTE EJERCICIO EN CONCRETO PUES PASAR LOS 20 Y PICO ID DE LOS EQUIPOS ES MUCHO MÁS TEDIOSO POR LO QUE HEMOS HECHO ESTA
FUNCIÓN INLINE PARA QUE VEA QUE SABEMOS HACERLAS, PERO NO HEMOS REALIZADO MÁS.
*/
GO
CREATE OR ALTER FUNCTION [FIPartidoJugados]
(@IdEquipo varchar(20)) RETURNS TABLE AS
RETURN SELECT PJL.ELocal,(PJL.NumeroPartidos+PJV.NumeroPartidos) AS [NumeroPartidosJugados] FROM
(SELECT P.ELocal,COUNT(*) AS [NumeroPartidos] FROM Partidos AS P
WHERE P.Finalizado=1 
GROUP BY P.ELocal) AS PJL
INNER JOIN
(SELECT P.EVisitante,COUNT(*) AS [NumeroPartidos] FROM Partidos AS P
WHERE P.Finalizado=1 
GROUP BY P.EVisitante) AS PJV ON PJL.ELocal=PJV.EVisitante
WHERE PJL.ELocal=@IdEquipo
GO
