-- FUNCIONES
/*
 1. Realice una función que reciba el identificador de un asesor y 
	retorne la cantidad total de prospectos asignados.
*/

CREATE OR ALTER FUNCTION fn_CantidadProspectos(@IdAsesor INT)
RETURNS INT 
AS 
BEGIN 
	DECLARE @CantidadProspecto INT;

    SELECT @CantidadProspecto = COUNT(DISTINCT p.IdProspecto)
    FROM Asesor AS A
    INNER JOIN RegistroActividad AS RA ON RA.IdAsesor = A.IdAsesor
    INNER JOIN Oferta AS O ON O.IdOferta = RA.IdOferta
    INNER JOIN Prospecto AS P ON P.IdProspecto = O.IdProspecto
    WHERE A.IdAsesor = @IdAsesor

    RETURN @CantidadProspecto;
END
GO
-- EJECUTAR 
SELECT dbo.fn_CantidadProspectos(1) AS TotalProspectos;
GO
/*
 2. Realice una función que reciba el identificador de una 
    fase o estado del proceso comercial y retorne 
    la cantidad de prospectos en dicha fase.
*/

CREATE OR ALTER FUNCTION fn_ProspectosFases(@IdEstado INT)
RETURNS INT 
AS 
BEGIN 
    DECLARE @CantidadProspecto INT;

    SELECT @CantidadProspecto = COUNT(DISTINCT IdProspecto)
    FROM Oferta
    WHERE IdEstado = @IdEstado;

    RETURN @CantidadProspecto;
END
GO
-- Ejecutar
SELECT dbo.fn_ProspectosFases(1) AS TotalProspectos;
GO
/*
 3. Realice una función que reciba el identificador de un prospecto 
    y retorne el número total de actividades registradas para ese prospecto.
*/
CREATE FUNCTION fn_TotalActividades (@IdProspecto INT)
RETURNS INT
AS
BEGIN
    DECLARE @TotActividades INT;

    SELECT @TotActividades = COUNT(RA.IdRegistroActividad)
    FROM RegistroActividad AS RA INNER JOIN Oferta O ON RA.IdOferta = O.IdOferta
    WHERE O.IdProspecto = @IdProspecto;

    RETURN @TotActividades;
END
GO
-- Ejecutar
SELECT dbo.fn_TotalActividades(4) AS TotalActividades;
GO
/*
 4. Realice una función que calcule el promedio general del nivel 
    de interés de los prospectos registrados en el sistema.
*/
CREATE FUNCTION fn_PromedioCalificacion ()
RETURNS DECIMAL
AS 
BEGIN
    DECLARE @Promedio DECIMAL(5,2);

    SELECT @Promedio = AVG(CAST(NivelInteres AS DECIMAL(5,2)))
    FROM Oferta;

    RETURN @Promedio;
END
GO
-- EJECUTAR
SELECT dbo.fn_PromedioCalificacion() AS Calificacion
GO

/*
    5. 
*/
CREATE FUNCTION fn_DiasDesdeRegistro(
    @FechaRegistro DATE)
RETURNS INT
AS
BEGIN
    DECLARE @Dias INT;
    SELECT @Dias = DATEDIFF(DAY, @FechaRegistro, GETDATE());
    RETURN @Dias;
END;