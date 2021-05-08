/*EJERCICIO 10  MULTIPLES INSTRUCCIONES

LeoMetro quiere premiar mensualmente a los pasajeros que m�s utilizan el transporte p�blico. 
Para ello necesitamos una funci�n que nos devuelva una tabla con los que deben ser premiados.

Los premios tienen tres categor�as: 1: Mayores de 65 a�os, 2: menores de 25 a�os y 3: resto. 
En cada categor�a se premia a tres personas. Los elegidos ser�n los que hayan realizado m�s viajes en ese mes. 
En caso de empatar en n�mero de viajes, se dar� prioridad al que m�s dinero se haya gastado.

Queremos una funci�n que reciba como par�metros un mes (TinyInt) y un a�o (SmallInt) y nos devuelva una tabla con los premiados de ese mes. 
Las columnas de la tabla ser�n: ID del pasajero, nombre, apellidos, n�mero de viajes realizados en el mes, total de dinero gastado, categor�a y posici�n 
(primero, segundo o tercero) en su categor�a.

La tabla tendr� mucho arte.*/

GO
CREATE OR ALTER FUNCTION FMIPremiados(@mes tinyint,@anhio smallint)RETURNS @Premiados TABLE(
			IdPasajero int NOT NULL 
			,nombre varchar(20) NOT NULL
			,apelllidos varchar(30) NOT NULL
			,numeroViajes int NOT NULL
			,TotalDineroGastado money NOT NULL
			,Categoria Varchar(20) NOT NULL
			,Posicion tinyint NOT NULL	
)
AS
/*
CABECERA:FUNCTION FMIPremiados(@mes tinyint,@anhio tinyint)RETURNS @Premiados TABLE
PROPOSITO: Se trata de una funci�n que nos devolver� una tabla premiados con los datos de los usuarios que ser�n premiados
por su asiduidad viajando en LeoMetro
ENTRADA:@mes tinyint,@anhio tinyint
SALIDA:Tabla @Premiados
PRECONDICI�N: El mes y anhio debe ser v�lido es decir que se encuentren en la base de datos
POSTCONDI�N:Se trata de una funci�n de multiples instrucciones que nos devolver� una tabla temporal
*/
BEGIN--voy insertando los distintos datos	
	INSERT INTO @Premiados(IDPasajero,nombre,apelllidos,numeroViajes,TotalDineroGastado,Categoria,Posicion) SELECT TOP 3 ID,Nombre,Apellidos,NumeroViajes,MAX(DineroGastado) AS DG,Categoria,ROW_NUMBER() OVER (ORDER BY NumeroViajes DESC,MAX(DineroGastado) DESC) AS Posicion FROM FINVDC(@mes,@anhio)  WHERE Categoria='MayoresDe65' GROUP BY ID,Nombre,Apellidos,NumeroViajes,Categoria ORDER BY NumeroViajes DESC,DG DESC--inserto a los que son mayores de 65, la posicion la saco con el row number y con top cojo las 3 primeras filas que al ordenarlas de forma desc, ser�n los que mas han viajado y en caso de empate el que m�s gasto
	INSERT INTO @Premiados(IDPasajero,nombre,apelllidos,numeroViajes,TotalDineroGastado,Categoria,Posicion) SELECT TOP 3 ID,Nombre,Apellidos,NumeroViajes,MAX(DineroGastado) AS DG,Categoria,ROW_NUMBER() OVER (ORDER BY NumeroViajes DESC,MAX(DineroGastado) DESC) AS Posicion FROM FINVDC(@mes,@anhio)  WHERE Categoria='MenoresDe25' GROUP BY ID,Nombre,Apellidos,NumeroViajes,Categoria ORDER BY NumeroViajes DESC,DG DESC--inserto a los que menores de 25, la posicion la saco con el row number y con top cojo las 3 primeras filas que al ordenarlas de forma desc, ser�n los que mas han viajado y en caso de empate el que m�s gasto
	INSERT INTO @Premiados(IDPasajero,nombre,apelllidos,numeroViajes,TotalDineroGastado,Categoria,Posicion) SELECT TOP 3 ID,Nombre,Apellidos,NumeroViajes,MAX(DineroGastado) AS DG,Categoria,ROW_NUMBER() OVER (ORDER BY NumeroViajes DESC,MAX(DineroGastado) DESC) AS Posicion FROM FINVDC(@mes,@anhio)  WHERE Categoria='Resto' GROUP BY ID,Nombre,Apellidos,NumeroViajes,Categoria ORDER BY NumeroViajes DESC,DG DESC--inserto a los restantes, la posicion la saco con el row number y con top cojo las 3 primeras filas que al ordenarlas de forma desc, ser�n los que mas han viajado y en caso de empate el que m�s gasto
RETURN
END
GO


GO
CREATE OR ALTER FUNCTION FINVDC(@mes tinyint,@anhio smallint) RETURNS TABLE AS RETURN 
/*
CABECERA:FUNCTION FINVDC() RETURNS TABLE AS RETURN 
PROPOSITO: Se trata de una funci�n in line que devuelve una tabla con los distintos datos de un usuario,
entre estos su nombre, apellidos,id,numero de viajes y dinero gastado
ENTRADA:@mes tinyint,@anhio tinyint
SALIDA:Tabla con los datos de los pasajeros
PRECONDICI�N: El mes y anhio debe ser v�lido es decir que se encuentren en la base de datos
POSTCONDI�N:Se trata de una funci�n que devuelve una tabla con los datos del usuario y sus viajes
*/
(SELECT P.Nombre,P.Apellidos,P.ID,COUNT(*) AS NumeroViajes, SUM(V.Importe_Viaje) AS DineroGastado,CASE WHEN--selecciono los datos que me piden 

	DATEDIFF(DAY,P.FechaNacimiento,DATEFROMPARTS(@anhio,@mes,1))/365>64 THEN 'MayoresDe65'--calculo la diferencia entre la fecha de nacimiento y la fecha que se pasa por par�metros para saber la edad en ese momento, pues si usamos la fecha actual
	WHEN																					-- es decir un getdate es posible que una persona que en el momento en el que realizo los viajes estuviera en una categor�a ahora este en otra pues envejecio y entonces ser�a err�neo																		
	DATEDIFF(DAY,P.FechaNacimiento,DATEFROMPARTS(@anhio,@mes,1))/365<25 THEN 'MenoresDe25'
	ELSE 'Resto'
	END AS Categoria
	FROM LM_Pasajeros AS P INNER JOIN
	LM_Tarjetas AS T ON P.ID=T.IDPasajero INNER JOIN LM_Viajes AS V ON
	T.ID=V.IDTarjeta
	WHERE V.IDEstacionSalida IS NOT NULL AND (@mes BETWEEN MONTH(V.MomentoEntrada) AND MONTH(V.MomentoSalida)) AND (@anhio BETWEEN YEAR(V.MomentoEntrada) AND YEAR(V.MomentoSalida))--ponemos la condici�n del tiempo en el where para que nos devuelva solo los datos en el periodo que se pasa por par�metros
	GROUP BY P.Nombre,P.ID,P.FechaNacimiento,P.Apellidos)

GO
BEGIN TRANSACTION
SELECT * FROM FMIPremiados(2,2017)
ROLLBACK
