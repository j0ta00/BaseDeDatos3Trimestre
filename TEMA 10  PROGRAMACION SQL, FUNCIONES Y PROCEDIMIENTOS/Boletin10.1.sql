/*1 Deseamos incluir un producto en la tabla Products llamado "Cruzcampo lata” pero no estamos seguros si se ha insertado o no.
 El precio son 4,40, el proveedor es el 16, la categoría 1 y la cantidad por unidad es "Pack 6 latas” "Discontinued” toma el valor 0 y el resto de columnas se dejarán a NULL.
Escribe un script que compruebe si existe un producto con ese nombre. En caso afirmativo, actualizará el precio y en caso negativo insertarlo.*/
GO
CREATE OR ALTER PROCEDURE PAnhadirProducto 
	@ProductName nvarchar(40),
	@Proveedor int,
	@IDCategoria int,
	@Unidades smallint,
	@precio money,
	@descontinuado bit
AS
	BEGIN
		IF NOT EXISTS (SELECT P.ProductName FROM Products AS P WHERE P.ProductName=@ProductName)
			BEGIN
				INSERT INTO [dbo].[Products]
			   ([ProductName]
			   ,[SupplierID]
			   ,[CategoryID]
			   ,[QuantityPerUnit]
			   ,[UnitPrice]
			   ,[UnitsInStock]
			   ,[UnitsOnOrder]
			   ,[ReorderLevel]
			   ,[Discontinued])
		 VALUES
			   (@ProductName,@Proveedor
			   ,@IdCategoria,@Unidades,@precio,NULL,NULL,NULL,@descontinuado)
			END
	END
GO
BEGIN TRANSACTION
EXECUTE PAnhadirProducto @ProductName='Cruzcampo lata',@Proveedor=16,@IdCategoria=1,@Unidades=6,@Precio=4.40,@descontinuado=0
SELECT*FROM Products
ROLLBACK
SELECT*FROM Products
/*2 Comprueba si existe una tabla llamada ProductSales. Esta tabla ha de tener de cada producto el ID, 
el Nombre, el Precio unitario, el número total de unidades vendidas 
y el total de dinero facturado con ese producto. Si no existe, créala
*/
GO
CREATE OR ALTER PROCEDURE PCrearTablaProductSales AS
	BEGIN
	DECLARE @UltimoId int,@Contador int,@IdProducto int
	SET @UltimoId=(SELECT MAX(ProductID) FROM Products)
	SET @Contador=1

		IF NOT	EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME ='ProductSales') 
			BEGIN
				WHILE(@Contador<=@UltimoId)
					BEGIN
						SET @IdProducto=(SELECT ProductID FROM Products WHERE ProductID=@Contador)
						IF NOT	EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME ='ProductSales')
							BEGIN
							SELECT*INTO ProductSales FROM FIMostrarCaracteristicasProducto(@IdProducto)
							END
						ELSE
							BEGIN
								INSERT INTO ProductSales SELECT * FROM FIMostrarCaracteristicasProducto(@IdProducto)
							END
						SET @Contador+=1
					END
			END
	END
GO
GO
CREATE OR ALTER FUNCTION FIMostrarCaracteristicasProducto
(@IdProducto as int) RETURNS TABLE AS RETURN
		SELECT P.ProductID,P.ProductName,P.UnitPrice,SUM(OD.Quantity) AS UnidadesVendidas,SUM((OD.Quantity)*(OD.UnitPrice*(1-OD.Discount))) AS TotalFacturado FROM Products AS P INNER JOIN
		[Order Details] AS OD ON P.ProductID=OD.ProductID 
		WHERE P.ProductID=@IdProducto
		GROUP BY P.ProductID,P.ProductName,P.UnitPrice
GO
BEGIN TRANSACTION
EXECUTE dbo.PCrearTablaProductSales
SELECT*FROM ProductSales
COMMIT
/*3 Comprueba si existe una tabla llamada ShipShip. Esta tabla ha de tener de cada Transportista el ID, 
el Nombre de la compañía, el número total de envíos que ha efectuado y el número de países diferentes a 
los que ha llevado cosas. Si no existe, créala
*/
/*4 Comprueba si existe una tabla llamada EmployeeSales. 
Esta tabla ha de tener de cada empleado su ID, el Nombre completo, el número de ventas totales que ha 
realizado, el número de clientes diferentes a los que ha vendido y el total de dinero facturado. Si no existe, créala
*/
/*5 Entre los años 96 y 97 hay productos que han aumentado sus ventas y otros que las han disminuido. Queremos cambiar el precio unitario según la siguiente tabla:
*/
/* Incremento de ventas

Incremento de precio

Negativo

-10%

Entre 0 y 10%

No varía

Entre 10% y 50%

+5%

Mayor del 50%

10% con un máximo de 2,25
*/
