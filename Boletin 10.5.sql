--1.La tabla ActualizaTitles contiene una serie de modificaciones que hay que realizar sobre la tabla titles de la base de datos pubs.
select*from ActualizaTitle

GO
CREATE OR ALTER PROCEDURE PActualizarTitles AS
BEGIN
	IF('I'=ANY (SELECT TipoActualiza FROM ActualizaTitles))
	BEGIN
		INSERT INTO titles SELECT title_id,title,type,pub_id,price,advance,royalty,notes,pubdate FROM ActualizaTitles WHERE TipoActualiza='I'
	END
	IF('D' IN (SELECT TipoActualiza FROM ActualizaTitles))
	BEGIN
		DELETE titles WHERE title_id IN (SELECT title_id FROM ActualizaTitles WHERE TipoActualiza='D')
	END
	IF EXISTS (SELECT title_id FROM ActualizaTitles WHERE TipoActualiza='U' )
	BEGIN
		UPDATE titles SET title_id=A.title_id, title=ISNULL(A.title,titles.title), [type]=ISNULL(A.title,titles.title), pub_id=A.pub_id, 
		price=A.price,advance=A.advance,royalty=A.royalty,ytd_sales=ISNULL(A.ytd_sales,titles.ytd_sales),notes=ISNULL(A.notes,titles.notes),pubdate=A.pubdate FROM ActualizaTitles AS A
		WHERE A.TipoActualiza='U'
	END
END
SELECT*FROM titles
SELECT*FROM ActualizaTitles
GO
--Tienes que ir recorriendo la tabla con un bucle, leer cada fila y realizar la actualización que se indique.

--Si la columna TipoActualiza contiene una "I" hay que insertar una nueva fila en titles con todos los datos leídos de esa fila de ActualizaTitles.

--Si TipoActualiza contiene una "D" hay que eliminar la fila cuyo código (title_id) se incluye.

--Si TipoActualiza es "U" hay que actualizar la fila identificada por title_id con las columnas que no sean Null. Las que sean Null se dejan igual.


BEGIN TRANSACTION
GO
CREATE OR ALTER PROCEDURE PActualizarTitles2 AS
BEGIN
	DECLARE @VCB int,@Final int
	SELECT @VCB=MIN(A.NumActualiza),@Final=MAX(A.NumActualiza) FROM ActualizaTitles AS A
	WHILE @VCB<=@Final
	BEGIN
		IF((SELECT A.TipoActualiza FROM ActualizaTitles AS A WHERE A.NumActualiza=@VCB)='I')
		BEGIN
			IF NOT EXISTS(SELECT pub_id FROM publishers WHERE pub_id=(SELECT pub_id FROM ActualizaTitles WHERE NumActualiza=@VCB))
			BEGIN
				INSERT INTO publishers(pub_id) SELECT  pub_id FROM ActualizaTitles WHERE NumActualiza=@VCB
			END
			INSERT INTO titles SELECT title_id,title,type,pub_id,price,advance,royalty,ytd_sales,notes,pubdate FROM ActualizaTitles WHERE NumActualiza=@VCB
		END
		ELSE IF((SELECT A.TipoActualiza FROM ActualizaTitles AS A WHERE A.NumActualiza=@VCB)='D')
		BEGIN
			DELETE titles WHERE title_id=(SELECT title_id FROM ActualizaTitles WHERE NumActualiza=@VCB)
		END
		ELSE IF ((SELECT A.TipoActualiza FROM ActualizaTitles AS A WHERE A.NumActualiza=@VCB)='U' )
		BEGIN
			UPDATE titles SET title=ISNULL(A.title,titles.title), [type]=ISNULL(A.type,titles.type), pub_id=A.pub_id, 
			price=A.price,advance=A.advance,royalty=A.royalty,ytd_sales=ISNULL(A.ytd_sales,titles.ytd_sales),notes=ISNULL(A.notes,titles.notes),pubdate=A.pubdate FROM ActualizaTitles AS A
			WHERE A.NumActualiza=@VCB AND titles.title_id=A.title_id
		END
		SELECT @VCB = MIN(NumActualiza) FROM ActualizaTitles WHERE NumActualiza > @VCB
	END
END
GO

SELECT*FROM ActualizaTitles
SELECT*FROM titles
SELECT*FROM publishers
BEGIN TRANSACTION
EXECUTE PActualizarTitles2
ROLLBACK