USE clinica
GO

/* ============================================================
PROCEDIMIENTOS
============================================================ */

CREATE PROCEDURE sp_RevisarCitasPaciente
    @PacienteID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CitaID INT, @Estado NVARCHAR(30), @Fecha DATETIME2;

    DECLARE citas_cursor CURSOR FOR
        SELECT CitaID, Estado, FechaCita
        FROM Agenda
        WHERE PacienteID = @PacienteID
        ORDER BY FechaCita;

    OPEN citas_cursor;
    FETCH NEXT FROM citas_cursor INTO @CitaID, @Estado, @Fecha;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @Estado = 'Pendiente'
            PRINT 'Cita ' + CAST(@CitaID AS NVARCHAR) + ' el '
                  + CONVERT(NVARCHAR, @Fecha, 120) + ' está PENDIENTE';
        ELSE IF @Estado = 'Confirmada'
            PRINT 'Cita ' + CAST(@CitaID AS NVARCHAR) + ' el '
                  + CONVERT(NVARCHAR, @Fecha, 120) + ' está CONFIRMADA';
        ELSE
            PRINT 'Cita ' + CAST(@CitaID AS NVARCHAR) + ' el '
                  + CONVERT(NVARCHAR, @Fecha, 120) + ' ya fue ATENDIDA o CANCELADA';

        FETCH NEXT FROM citas_cursor INTO @CitaID, @Estado, @Fecha;
    END

    CLOSE citas_cursor;
    DEALLOCATE citas_cursor;
END;
GO

-- AGREGAR CITA
CREATE OR ALTER PROCEDURE sp_AgregarCita
    @PacienteID INT,
    @OdontologoID INT,
    @ProcedimientoID INT,
    @FechaCita DATETIME2,
    @DuracionMinutos INT = 30
AS
BEGIN
    INSERT INTO dbo.Agenda (PacienteID, OdontologoID, ProcedimientoID, FechaCita, DuracionMinutos, Estado)
    VALUES (@PacienteID, @OdontologoID, @ProcedimientoID, @FechaCita, @DuracionMinutos, 'Pendiente');
END;
GO
-- EJECUTAR PROCEDIMIENTO
EXEC sp_AgregarCita 2, 1, 1, '2025-02-02 16:30';
GO
-- AGREGAR A UN PACIENTE
CREATE or ALTER PROCEDURE sp_AgregarPaciente
    @Nombres NVARCHAR,
    @Apellidos NVARCHAR,
    @Documento NVARCHAR,
    @FechaNacimiento DATE,
    @Telefono NVARCHAR,
    @Correo NVARCHAR
AS
BEGIN
    INSERT INTO Paciente (Nombres, Apellidos, Documento,FechaNacimiento, Telefono, Correo)
    VALUES (@Nombres, @Apellidos, @Documento, @FechaNacimiento, @Telefono, @Correo)
END;
GO

-- EJECUTAR PROCEDIMIENTO
EXEC sp_AgregarPaciente 'Pedro', 'Ramirez', 'CC100811197', '1989-04-21', '3133096545', 'VENITRANS@gmail.com'
GO
/* 2. Consultar citas de un paciente
Procedimiento que devuelve todas las citas de un paciente, mostrando 
También el nombre del odontólogo y el procedimiento. */

CREATE OR ALTER PROCEDURE sp_VerCitasPorPaciente
    @PacienteID INT
AS
BEGIN
    SELECT a.CitaID, a.FechaCita, a.Estado,
           o.Nombres + ' ' + o.Apellidos AS Odontologo,
           p.Nombre AS Procedimiento
    FROM dbo.Agenda a
    JOIN dbo.Odontologo o ON a.OdontologoID = o.OdontologoID
    JOIN dbo.Procedimiento p ON a.ProcedimientoID = p.ProcedimientoID
    WHERE a.PacienteID = @PacienteID
    ORDER BY a.FechaCita;
END;
GO
-- EJECUTAR PROCEDIMIENTO
EXEC sp_VerCitasPorPaciente 1;
GO

 -- 3. Calcular total de una factura
 /*Procedimiento que, a partir de un identificador de factura, 
 suma los subtotales de los procedimientos incluidos y actualiza el total. */
CREATE OR ALTER PROCEDURE sp_CalcularTotalFactura
    @FacturaID INT
AS
BEGIN
    DECLARE @Total DECIMAL(12,2);

    SELECT @Total = SUM(Subtotal)
    FROM dbo.DetalleFactura
    WHERE FacturaID = @FacturaID;

    UPDATE dbo.Factura
    SET Total = ISNULL(@Total, 0)
    WHERE FacturaID = @FacturaID;
END;
GO
-- EJECUTAR PROCEDIMIENTO
EXEC sp_CalcularTotalFactura 1;
GO

/* 4. Escenario
Queremos un procedimiento que recorra todas las citas de un paciente, ordenadas por fecha,
y muestre un mensaje indicando si la cita está Pendiente, Confirmada o ya Atendida/Cancelada.
Esto nos permite ver cómo usar un bucle (WHILE) junto con condicionales (IF) en un caso práctico.

Procedimiento de ejemplo*/
CREATE OR ALTER PROCEDURE sp_RevisarCitasPaciente
    @PacienteID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CitaID INT, @Estado NVARCHAR(30), @Fecha DATETIME2;

    -- Cursor temporal de las citas
    DECLARE citas_cursor CURSOR FOR
        SELECT CitaID, Estado, FechaCita
        FROM dbo.Agenda
        WHERE PacienteID = @PacienteID
        ORDER BY FechaCita;

    OPEN citas_cursor;
    FETCH NEXT FROM citas_cursor INTO @CitaID, @Estado, @Fecha;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Usamos IF para evaluar el estado de la cita
        IF @Estado = 'Pendiente'
            PRINT 'Cita ' + CAST(@CitaID AS NVARCHAR) + ' el ' 
                  + CONVERT(NVARCHAR, @Fecha, 120) + ' está PENDIENTE';
        ELSE IF @Estado = 'Confirmada'
            PRINT 'Cita ' + CAST(@CitaID AS NVARCHAR) + ' el ' 
                  + CONVERT(NVARCHAR, @Fecha, 120) + ' está CONFIRMADA';
        ELSE
            PRINT 'Cita ' + CAST(@CitaID AS NVARCHAR) + ' el ' 
                  + CONVERT(NVARCHAR, @Fecha, 120) + ' ya fue ATENDIDA o CANCELADA';

        -- Avanzamos a la siguiente cita
        FETCH NEXT FROM citas_cursor INTO @CitaID, @Estado, @Fecha;
    END

    CLOSE citas_cursor;
    DEALLOCATE citas_cursor;
END;
GO
-- EJECUTAR PROCEDIMIENTO 
EXEC sp_RevisarCitasPaciente @PacienteID = 1;
GO
 -- ========== EJECUTAR PROCEDIMIENTOS ==========
EXEC sp_AgregarPaciente 'Pedro', 'Ramirez', 'CC100811197', '1989-04-21', '3133096545', 'VENITRANS@gmail.com'
EXEC sp_AgregarCita 2, 1, 1, '2025-02-02 16:30';
EXEC sp_VerCitasPorPaciente 1;
EXEC sp_CalcularTotalFactura 1;
EXEC sp_RevisarCitasPaciente @PacienteID = 1;

-- Consultar tabla --
SELECT * FROM Agenda
