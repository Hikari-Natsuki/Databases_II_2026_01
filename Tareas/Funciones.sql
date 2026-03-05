USE Clinica
GO

-- Taller – Funciones en SQL Server 
/*  1.Cree una función escalar que calcule la edad de un paciente, 
	a partir de su fecha de nacimiento.*/

CREATE OR ALTER FUNCTION dbo.fn_Calcular_Edad(@PacienteID INT)
RETURNS INT
AS 
BEGIN 
    DECLARE @Edad INT;

    SELECT @Edad = 
        CASE 
            WHEN DATEADD(YEAR, DATEDIFF(YEAR, FechaNacimiento, GETDATE()), FechaNacimiento) > GETDATE() 
            THEN DATEDIFF(YEAR, FechaNacimiento, GETDATE()) - 1
            ELSE DATEDIFF(YEAR, FechaNacimiento, GETDATE())
        END
    FROM Paciente
    WHERE PacienteID = @PacienteID;

    RETURN ISNULL(@Edad, 0);
END
GO

-- EJECUTAR LA FUNCIÓN
SELECT PacienteID, Nombres, Apellidos, dbo.fn_Calcular_Edad(PacienteID) AS Edad
FROM Paciente
WHERE PacienteID = 1;
GO
/*2. Diseñe una función escalar que, dado el ID de una factura, 
     retorne el valor total sumando sus procedimientos facturados.*/
CREATE OR ALTER FUNCTION dbo.fn_CalcularTotalFactura(@FacturaID INT)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    -- Declarar variable
    DECLARE @CalcularTotal DECIMAL(18, 2);

    -- Sumar subtotales
    SELECT @CalcularTotal = SUM(Subtotal)
    FROM DetalleFactura
    WHERE FacturaID = @FacturaID;

    -- Si la factura no tiene detalles, retornamos 0 en lugar de NULL
    RETURN ISNULL(@CalcularTotal, 0);
END
GO

-- EJECUTAR FUNCIÓN
SELECT FacturaID, dbo.fn_CalcularTotalFactura(FacturaID) AS 'Total Procedimiento'
FROM Factura
WHERE FacturaID = 1
GO
/*3. Construya una función con valor de tabla en línea que devuelva 
     todas las citas pendientes de un paciente, mostrando fecha y procedimiento.*/
CREATE OR ALTER FUNCTION dbo.fn_CitasPendientesEnLinea(@PacienteID INT)
RETURNS TABLE
AS
RETURN 
(
    -- OBtener las citas del paciente y mostrar la fecha y el procedimiento 
    SELECT A.FechaCita, P.Nombre AS 'Procdimiento agendado' 
    FROM Agenda AS A INNER JOIN Procedimiento AS P ON A.ProcedimientoID = P.ProcedimientoID
    WHERE A.PacienteID = @PacienteID AND A.Estado = 'Pendiente'
);
GO
-- VER LOS DATOS DE LA TABLA RETORNAADA
SELECT * FROM dbo.fn_CitasPendientes(1);
GO
/*4. Implemente una función con valor de tabla multisentencia que devuelva todas 
     las facturas de un paciente con su total calculado.*/
CREATE OR ALTER FUNCTION dbo.fn_FacturasPaciente(@PacienteID INT)
RETURNS @PacientesFactura TABLE(
    FacturaID INT, 
    PacienteID INT,
    NombresPaciente NVARCHAR(100),
    Fecha DATETIME2 (7),
    Total DECIMAL (12, 2),
    MetodoPago NVARCHAR(30),
    NumeroDocumento NVARCHAR(60)
)
AS
BEGIN
    -- Insertar dentro de la tabla que se va a retornar
    INSERT INTO @PacientesFactura
    -- seleccionar e insertar
    SELECT F.FacturaID, F.PacienteID, P.Nombres, F.Fecha, F.Total, F.MetodoPago, F.NumeroDocumento
    FROM Paciente AS P INNER JOIN Factura AS F ON P.PacienteID = F.PacienteID
    WHERE F.PacienteID = @PacienteID
    RETURN
END
-- Ejecutar la funcion
SELECT * FROM dbo.fn_FacturasPaciente(1)
GO

/* 5. Desarrolle una función escalar que clasifique un procedimiento según su costo en: 
      Bajo (menor a 50.000), Medio (entre 50.000 y 150.000) o Alto (mayor a 150.000).*/
CREATE OR ALTER FUNCTION dbo.fn_ClasificarCostoProcedimiento(@Costo DECIMAL(12, 2))
RETURNS NVARCHAR(10)
AS
BEGIN
-- Declarar variable
    DECLARE @Clasificacion NVARCHAR(10)

    -- Agregar a "Clasificación"
    SET @Clasificacion = 
        CASE 
            WHEN @Costo < 50000 THEN 'Bajo'
            WHEN @Costo BETWEEN 50000 AND 150000 THEN 'Medio'
            WHEN @Costo > 150000 THEN 'Alto'
        END;
    -- retornaaar
    RETURN @Clasificacion
END
GO

SELECT Nombre, Costo, dbo.fn_ClasificarCostoProcedimiento(Costo) AS Categoria
FROM Procedimiento