USE clinica
GO
/*Funciones en SQL Server
En SQL Server, una función definida por el usuario (User Defined Function, UDF) 
es un objeto de base de datos que encapsula una lógica de cálculo y devuelve un resultado. 
A diferencia de los procedimientos almacenados, que pueden modificar datos o 
realizar múltiples operaciones, las funciones están orientadas a devolver un valor 
(ya sea escalar o en forma de tabla) que puede integrarse directamente dentro de consultas SQL.

Tipos de funciones en SQL Server:

============================================================
1- FUNCIONES ESCALARES
============================================================ 

	- Devuelven un solo valor (número, texto, fecha, etc.).
	- Se usan en cualquier parte de un SELECT, WHERE, ORDER BY, etc.
	- Ejemplo: calcular el total de una factura. */

CREATE OR ALTER FUNCTION fn_CalcularTotalFactura (@FacturaID INT)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @Total DECIMAL(12,2);

    SELECT @Total = SUM(Subtotal)
    FROM dbo.DetalleFactura
    WHERE FacturaID = @FacturaID;

    RETURN ISNULL(@Total,0);
END;
GO

-- Uso en consulta:
SELECT FacturaID,
       dbo.fn_CalcularTotalFactura(FacturaID) AS TotalFactura
FROM dbo.Factura;
GO

/* ====================================================================
2- Funciones con valores de tabla en línea (Inline Table-Valued Functions)
=======================================================================

    - Devuelven una tabla como resultado.
    - Se definen con una sola sentencia RETURN (SELECT ...).
    - Ejemplo: devolver todas las citas pendientes de un paciente. */

CREATE OR ALTER FUNCTION fn_CitasPendientesPorPaciente (@PacienteID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT CitaID, FechaCita, Estado, ProcedimientoID
    FROM dbo.Agenda
    WHERE PacienteID = @PacienteID AND Estado = 'Pendiente'
);
GO

 -- Uso en consulta:
 SELECT * FROM dbo.fn_CitasPendientesPorPaciente(1);
 GO

 /*====================================================================
 3- Funciones con valores de tabla multisentencia (Multi-Statement TVF)
=======================================================================

    - Devuelven una tabla, pero permiten construirla con varias operaciones internas.
    - Ejemplo: devolver todas las facturas de un paciente con su total calculado.*/

CREATE OR ALTER FUNCTION fn_FacturasPorPaciente (@PacienteID INT)
RETURNS @Resultado TABLE (
    FacturaID INT,
    Fecha DATETIME2,
    Total DECIMAL(12,2)
)
AS
BEGIN
    INSERT INTO @Resultado
    SELECT f.FacturaID, f.Fecha, dbo.fn_CalcularTotalFactura(f.FacturaID)
    FROM dbo.Factura f
    WHERE f.PacienteID = @PacienteID;

    RETURN;
END;
GO

-- Uso en consulta:
SELECT * FROM dbo.fn_FacturasPorPaciente(1);

/*
📌 ¿Cómo se usan las funciones?
- Se invocan como si fueran funciones nativas (GETDATE(), LEN(), etc.).

- Pueden usarse en:
    ○ SELECT → para traer cálculos personalizados.
    ○ WHERE → como condición de filtro.
    ○ ORDER BY → para ordenar resultados en base a cálculos.
    ○ JOIN → combinando resultados de funciones con tablas.*/

-- Ejemplo:
SELECT p.Nombres, p.Apellidos,
       dbo.fn_CalcularTotalFactura(f.FacturaID) AS TotalFactura
FROM dbo.Paciente p
JOIN dbo.Factura f ON p.PacienteID = f.PacienteID
WHERE dbo.fn_CalcularTotalFactura(f.FacturaID) > 100000;

/*
Las funciones en SQL Server son una herramienta poderosa para 
encapsular cálculos y consultas reutilizables.

    - Las funciones escalares permiten obtener un único valor (ejemplo: total de una factura).
    - Las funciones con valores de tabla devuelven conjuntos de datos completos 
      (ejemplo: citas pendientes de un paciente).

En el contexto del consultorio odontológico, las funciones sirven para simplificar reportes, 
calcular valores automáticamente y facilitar las consultas frecuentes, 
mejorando la claridad y mantenibilidad de la base de datos. */