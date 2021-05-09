--Versión B
--Si la inicial de tu primer apellido está entre la M y la Z (incluidas)

USE DonerSerranito

--Ejercicio 1 (2 points)
--Escribe una función a la que se pase un establecimiento y un rango de fechas, una salsa y un tipo de carne y nos devuelva el número de serranitos 
--que se han vendido en ese establecimiento que contengan ese tipo de carne y esa salsa en ese rango de fechas.

GO
--Nombre: NumeroSerranitosTipo
--Descripcion: Nos devuelve el numero de serranitos del tipo especificado (incluye serranitos con otra salsa aparte de la especificada) 
--				en el establecimiento dado en las fechas dadas.
--Entradas: Nombre del Establecimiento, Rango de fechas (fecha Inicio/fecha Fin), Id Salsa y el tipo de carne
											--Tomaremos la fecha de entrega como referencia
--Salida: Numero de serranitos con los parametros dados

CREATE OR ALTER FUNCTION NumeroSerranitosTipo (
		@Establecimiento varchar(30), 
		@FechaInicio date, 
		@FechaFin date, 
		@IdSalsa Int, 
		@TipoCarne varchar(12)
) RETURNS int AS
BEGIN
	DECLARE @CantidadSerranito Int
	SELECT @CantidadSerranito = COUNT(PL.ID) FROM DSEstablecimientos AS E
			INNER JOIN DSPedidos AS PE ON E.ID=PE.IDEstablecimiento
			INNER JOIN DSPlatos AS PL ON PE.ID=PL.IDPedido
			INNER JOIN DSPlatosSalsas AS PS ON PE.ID=PS.IDPlato
			WHERE	E.Denominacion=@Establecimiento AND
					PE.Enviado BETWEEN @FechaInicio AND @FechaFin AND
					PS.IDSalsa = @IdSalsa AND
					PL.TipoCarne = @TipoCarne
	RETURN @CantidadSerranito
END
GO
--PRUEBA
DECLARE @NumeroSerranito int
SET @NumeroSerranito= dbo.NumeroSerranitosTipo('La Fragua',DATEFROMPARTS(2017,2,1),DATEFROMPARTS(2017,4,30),2,'Ibérico')
PRINT @NumeroSerranito
SET @NumeroSerranito= dbo.NumeroSerranitosTipo('Sabroso',DATEFROMPARTS(2017,1,1),DATEFROMPARTS(2017,12,30),3,'Avestruz')
PRINT @NumeroSerranito
GO

--Ejercicio 2 (2 points)
--Queremos saber cuál es la salsa que prefieren los clientes de un establecimiento para acompañar cada tipo de carne. Escribe una función a la que 
--pasemos el nombre de un establecimiento y nos devuelva una tabla con los distintos tipos de carne y la salsa que más veces la acompaña, así como el
--número total de serranitos vendidos que incluyan ese tipo de carne y esa salsa. Utiliza la función desarrollada en el ejercicio 1

GO
--Nombre: MejorSalsa
--Descripción: Nos devuelve la salsa que más veces acompaña a cada tipo de carne y el numero de serranitos con esta combinación 
--				en un establecimiento dado.
--Entradas: Nombre del establecimiento
--Salidas: Tabla con: Tipo de carne, Salsa, Numero de Serranitos

CREATE OR ALTER FUNCTION MejorSalsa (@Establecimiento varchar(30)) 
	RETURNS @MejoresCombinaciones TABLE (
		LaCarne Char (12) NOT NULL,
		LaSalsa Char (13) NULL,
		NumeroSerranitos int NULL
		)AS
	BEGIN
		INSERT INTO @MejoresCombinaciones (LaCarne)
			SELECT Carne FROM DSTiposCarne
		UPDATE @MejoresCombinaciones
			SET NumeroSerranitos = (SELECT TOP(1) dbo.NumeroSerranitosTipo(@Establecimiento,DATEFROMPARTS(2000,1,1), CURRENT_TIMESTAMP, ID, LaCarne) AS NUM
				FROM DSTiposSalsa
				ORDER BY NUM DESC)
		UPDATE @MejoresCombinaciones
			SET LaSalsa = Salsa FROM DSTiposSalsa
			WHERE (NumeroSerranitos = dbo.NumeroSerranitosTipo(@Establecimiento,DATEFROMPARTS(2000,1,1), CURRENT_TIMESTAMP, ID, LaCarne) AND
					NumeroSerranitos !=0)
		UPDATE @MejoresCombinaciones
			SET LaSalsa='No disponible'
				WHERE (NumeroSerranitos=0)
		RETURN
	END
GO

--Dada la función NumeroSerranitosTipo, tenemos todos los parametros de la funcion salvo la salsa. Para valorar todas las salsas cogemos los valores
--de la tabla TipoSalsa.
----------------------------------------------------
--Posible solción para reducir en un solo UPDATE devolviendo las dos columnas del top(1).
SELECT TOP(1) dbo.NumeroSerranitosTipo('LaFragua' ,DATEFROMPARTS(2000,1,1), CURRENT_TIMESTAMP, ID, 'Avestruz') AS NUM, Salsa
				FROM DSTiposSalsa
				ORDER BY NUM DESC
--PRUEBA
SELECT * FROM dbo.MejorSalsa('La Fragua')
--NOTA: Solucionar casos en los que NumeroSerranitos es cero (coge la primera salsa y no deberia)(SOLUCIONADO)

--Ejercicio 3 (3 points) (Exámen)
--A algunos clientes les gusta repetir sus pedidos. Crea un procedimiento al que se pase el ID de un cliente, el nombre de un establecimiento y una 
--fecha/hora y busque el último pedido de ese cliente anterior a esa fecha/hora (puede haber un margen de error) y duplique el pedido con los mismos 
--serranitos, salsas y complementos, en el mismo establecimiento, pero asignándole la fecha/hora actual. La fecha de envío serán 20' más de la hora 
--actual y deja el repartidor a NULL.

GO
--Nombre: ClonarPedido
--Descripción: Duplica el último pedido de un cliente en un establecimiento anterior a una fecha dada
--Entradas: Id del Cliente, Nombre del establecimiento, Fecha de busqueda
--Salida:	Cambios en la tabla pedidos (Añade pedido con fecha actual, fecha envio 20' más tarde, datos del pedido encontrado y repartidor NULL)
--			Cambios en las tablas Platos, PlatosSalsas, PlatosAdicionales, y PedidosComplementos

CREATE OR ALTER PROCEDURE ClonarPedido
	@IdCliente int,
	@Establecimiento varchar(12),
	@FechaBusqueda smalldatetime
AS BEGIN
	DECLARE @PedidoClonar int
	DECLARE @UltimoPedido bigint	
	DECLARE @IDPlatosGenerado AS TABLE(
		IDNuevo int NOT NULL,
		IDAntiguo int NULL
		)
		--Coger fecha mayor, TOP 1 
	SELECT @PedidoClonar = P.ID FROM DSPedidos AS P
		INNER JOIN DSEstablecimientos AS E 
		ON P.IDEstablecimiento=E.ID
		WHERE (	P.Enviado BETWEEN DATEADD(HOUR,-1,@FechaBusqueda) AND @FechaBusqueda AND
				E.Denominacion=@Establecimiento AND
				P.IDCliente=@IdCliente)
	
	--(CORREGIR en caso de no exisitir pedido)
	IF @PedidoClonar IS NOT NULL
		BEGIN
			
			--DECLARE @IdEstab smallint
			--SELECT @IdEstab = ID FROM DSEstablecimientos WHERE @Establecimiento LIKE Denominacion

			--DECLARE @Import smallmoney
			--SELECT @Import = Importe FROM DSPedidos WHERE ID = @PedidoClonar


			INSERT INTO DSPedidos ( Recibido, Enviado, IDCliente, IDEstablecimiento, Importe)
				SELECT  CURRENT_TIMESTAMP, DATEADD(MINUTE,20, CURRENT_TIMESTAMP),IDCliente, IDEstablecimiento, Importe FROM DSPedidos
				WHERE ID = @PedidoClonar
			SET @UltimoPedido = @@IDENTITY


			INSERT INTO DSPlatos 
			OUTPUT INSERTED.ID INTO @IDPlatosGenerado (IDNuevo)
				SELECT @UltimoPedido, TipoPan,TipoCarne FROM DSPlatos
				WHERE IDPedido=@PedidoClonar

			UPDATE @IDPlatosGenerado
				SET IDAntiguo = PL1.IDPedido FROM DSPlatos AS PL1
								INNER JOIN DSPlatos AS PL2 
								ON PL1.TipoCarne=PL2.TipoCarne AND PL1.TipoPan=PL2.TipoPan
								WHERE PL1.IDPedido=@PedidoClonar AND PL2.ID = IDNuevo


			INSERT INTO DSPlatosAdicionales (IDPlato, IDAdicional)
			SELECT IG.IDNuevo, PA.IDAdicional FROM DSPlatosAdicionales AS PA
				INNER JOIN DSPlatos AS PL ON PA.IDPlato=PL.ID
				INNER JOIN DSPedidos AS PE ON PL.IDPedido=PE.ID
				INNER JOIN @IDPlatosGenerado AS IG ON PE.ID=IG.IDAntiguo
				WHERE PE.ID=@PedidoClonar

			INSERT INTO DSPlatosSalsas (IDPlato,IDSalsa)
			SELECT IG.IDNuevo, PS.IDSalsa FROM DSPlatosSalsas AS PS
				INNER JOIN DSPlatos AS PL ON PS.IDPlato=PL.ID
				INNER JOIN DSPedidos AS PE ON PL.IDPedido=PE.ID
				INNER JOIN @IDPlatosGenerado AS IG ON PE.ID=IG.IDAntiguo
				WHERE PE.ID=@PedidoClonar
		END
	ELSE
		BEGIN
			--USAR EXCEPCIONES 
			PRINT ('No se ha encontrado ningún pedido')
		END
END
GO


SELECT * FROM DSPlatos

BEGIN TRANSACTION
DECLARE @fecha smalldatetime
SET @fecha = SMALLDATETIMEFROMPARTS(2017, 12, 20, 0, 55)
EXECUTE ClonarPedido 3, 'La Fragua', @fecha
SELECT * FROM DSPedidos
order by Recibido
ROLLBACK
--(CORREGIR)

--Ejercicio 4 (3 points) (Exámen)
--Escribe una función a la que pasemos el ID de un establecimiento y nos devuelva una tabla con los nombre de cada uno de los adicionales, el número 
--total y el porcentaje de serranitos que los llevan, referido a los pedidos que se han servido en ese local. También queremos saber el precio medio 
--de los pedidos que incluyen cada uno de los adicionales.
--Las columnas serán: Nombre adicional, número de serranitos, porcentaje de serranitos, precio medio de pedidos con ese adicional

GO
--Nombre: EstudiosAdicionales
--Descripción: Nos devuelve una tabla con los adicionales, y un estudio de la cantidad, el porcentaje y el precio medio del pedido de el local dado.
--Entrada: Id establecimiento
--Salida: Tabla (Nombre adicional, número de serranitos, porcentaje de serranitos, precio medio de pedidos con ese adicional)

CREATE OR ALTER FUNCTION EstudiosAdicionales (@IdEstablecimiento int)
	RETURNS @Estudio TABLE (
			[Nombre Adicional] VarChar (20) NOT NULL,
			[Número de serranitos] int NULL,
			[Porcentaje de serranitos %] int NULL,
			[Precio medio de pedidos con ese adicional] smallmoney NULL
			)AS
	BEGIN
		INSERT INTO @Estudio ([Nombre Adicional])
		SELECT Adicional FROM DSAdicionales

		UPDATE @Estudio
		SET [Número de serranitos] = 
				 (SELECT COUNT (PL.ID) FROM DSAdicionales AS A
				INNER JOIN DSPlatosAdicionales AS PA ON A.ID=PA.IDAdicional
				INNER JOIN DSPlatos AS PL ON PA.IDPlato=PL.ID
				INNER JOIN DSPedidos AS PD ON PL.IDPedido=PD.ID
				WHERE PD.IDEstablecimiento=@IdEstablecimiento AND
						A.Adicional=[Nombre Adicional])
		UPDATE @Estudio
		SET [Porcentaje de serranitos %] = 
				(SELECT [Número de serranitos]*100/COUNT (PL.ID) FROM DSAdicionales AS A
				INNER JOIN DSPlatosAdicionales AS PA ON A.ID=PA.IDAdicional
				INNER JOIN DSPlatos AS PL ON PA.IDPlato=PL.ID
				INNER JOIN DSPedidos AS PD ON PL.IDPedido=PD.ID
				WHERE PD.IDEstablecimiento=@IdEstablecimiento)
		UPDATE @Estudio
		SET [Precio medio de pedidos con ese adicional] = 
				(SELECT AVG (PD.Importe) FROM DSPedidos AS PD
				INNER JOIN DSPlatos AS PL ON PD.ID=PL.IDPedido
				INNER JOIN DSPlatosAdicionales AS PA ON PL.ID=PA.IDPlato
				INNER JOIN DSAdicionales AS A ON PA.IDAdicional=A.ID
				WHERE IDEstablecimiento=@IdEstablecimiento AND 
						A.Adicional = [Nombre Adicional])

	RETURN
	END
GO

--PRUEBA
SELECT * FROM DBO.EstudiosAdicionales(1)

