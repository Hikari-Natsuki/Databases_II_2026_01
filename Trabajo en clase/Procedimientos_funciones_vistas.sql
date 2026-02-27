-- Crear base de datos si no existe
IF DB_ID ('clinica') IS NULL CREATE DATABASE clinica;
GO

USE clinica;
GO

/* ============================================================
TABLAS
============================================================ */

CREATE TABLE Paciente (
    PacienteID INT IDENTITY (1, 1) PRIMARY KEY,
    Nombres NVARCHAR (100) NOT NULL,
    Apellidos NVARCHAR (100) NOT NULL,
    Documento NVARCHAR (30) NOT NULL UNIQUE,
    FechaNacimiento DATE NULL,
    Telefono NVARCHAR (30) NULL,
    Correo NVARCHAR (150) NULL,
    Direccion NVARCHAR (250) NULL,
    FechaRegistro DATETIME2 DEFAULT sysutcdatetime ()
);
GO

CREATE TABLE Procedimiento (
    ProcedimientoID INT IDENTITY (1, 1) PRIMARY KEY,
    Codigo NVARCHAR (30) UNIQUE,
    Nombre NVARCHAR (150) NOT NULL,
    Descripcion NVARCHAR (MAX),
    DuracionMinutos INT,
    Costo DECIMAL(10, 2) DEFAULT(0.00)
);
GO

CREATE TABLE Odontologo (
    OdontologoID INT IDENTITY (1, 1) PRIMARY KEY,
    Nombres NVARCHAR (100) NOT NULL,
    Apellidos NVARCHAR (100) NOT NULL,
    Especialidad NVARCHAR (100),
    Telefono NVARCHAR (30),
    Correo NVARCHAR (150),
    RegistroProf NVARCHAR (50)
);
GO

CREATE TABLE Agenda (
    CitaID INT IDENTITY (1, 1) PRIMARY KEY,
    PacienteID INT NOT NULL,
    OdontologoID INT NOT NULL,
    ProcedimientoID INT NULL,
    FechaCita DATETIME2 NOT NULL,
    DuracionMinutos INT,
    Estado NVARCHAR (30) NOT NULL DEFAULT 'Pendiente',
    Observaciones NVARCHAR (1000),
    CreatedAt DATETIME2 DEFAULT sysutcdatetime (),
    CONSTRAINT CK_Agenda_Estado CHECK (
        Estado IN (
            'Pendiente',
            'Confirmada',
            'Atendida',
            'Cancelada'
        )
    )
);
GO

CREATE TABLE Factura (
    FacturaID INT IDENTITY (1, 1) PRIMARY KEY,
    PacienteID INT NOT NULL,
    Fecha DATETIME2 DEFAULT sysutcdatetime (),
    Total DECIMAL(12, 2) DEFAULT(0.00),
    MetodoPago NVARCHAR (30) NOT NULL,
    NumeroDocumento NVARCHAR (60),
    CONSTRAINT CK_Factura_MetodoPago CHECK (
        MetodoPago IN (
            'Efectivo',
            'Tarjeta',
            'Transferencia'
        )
    )
);
GO

CREATE TABLE DetalleFactura (
    DetalleID INT IDENTITY (1, 1) PRIMARY KEY,
    FacturaID INT NOT NULL,
    ProcedimientoID INT NOT NULL,
    Cantidad INT DEFAULT 1,
    PrecioUnitario DECIMAL(12, 2) DEFAULT(0.00),
    Subtotal AS (Cantidad * PrecioUnitario) PERSISTED
);
GO

CREATE TABLE HistoriaMedica (
    HistoriaID INT IDENTITY (1, 1) PRIMARY KEY,
    PacienteID INT NOT NULL,
    FechaActualizacion DATETIME2 DEFAULT sysutcdatetime (),
    Alergias NVARCHAR (MAX),
    EnfermedadesPrevias NVARCHAR (MAX),
    MedicamentosActuales NVARCHAR (MAX),
    AntecedentesQuirurgicos NVARCHAR (MAX),
    Observaciones NVARCHAR (MAX)
);
GO

/* ============================================================
RELACIONES
============================================================ */

ALTER TABLE Agenda
ADD CONSTRAINT FK_Agenda_Paciente FOREIGN KEY (PacienteID) REFERENCES Paciente (PacienteID),
CONSTRAINT FK_Agenda_Odontologo FOREIGN KEY (OdontologoID) REFERENCES Odontologo (OdontologoID),
CONSTRAINT FK_Agenda_Procedimiento FOREIGN KEY (ProcedimientoID) REFERENCES Procedimiento (ProcedimientoID) ON DELETE SET NULL;
GO

ALTER TABLE Factura
ADD CONSTRAINT FK_Factura_Paciente FOREIGN KEY (PacienteID) REFERENCES Paciente (PacienteID);
GO

ALTER TABLE DetalleFactura
ADD CONSTRAINT FK_DetalleFactura_Factura FOREIGN KEY (FacturaID) REFERENCES Factura (FacturaID) ON DELETE CASCADE,
CONSTRAINT FK_DetalleFactura_Procedimiento FOREIGN KEY (ProcedimientoID) REFERENCES Procedimiento (ProcedimientoID);
GO

ALTER TABLE HistoriaMedica
ADD CONSTRAINT FK_HistoriaMedica_Paciente FOREIGN KEY (PacienteID) REFERENCES Paciente (PacienteID) ON DELETE CASCADE;
GO

/* ============================================================
VISTAS
============================================================ */

CREATE VIEW vw_CitasCompletas AS
SELECT
    a.CitaID,
    a.FechaCita,
    a.Estado,
    a.Observaciones,
    p.PacienteID,
    p.Nombres AS PacNombres,
    p.Apellidos AS PacApellidos,
    p.Documento,
    o.OdontologoID,
    o.Nombres AS OdNombres,
    o.Apellidos AS OdApellidos,
    pr.ProcedimientoID,
    pr.Nombre AS ProcedimientoNombre
FROM
    Agenda a
    LEFT JOIN Paciente p ON a.PacienteID = p.PacienteID
    LEFT JOIN Odontologo o ON a.OdontologoID = o.OdontologoID
    LEFT JOIN Procedimiento pr ON a.ProcedimientoID = pr.ProcedimientoID;
GO

/* ============================================================
DATOS DE EJEMPLO
============================================================ */

INSERT INTO
    Paciente (
        Nombres,
        Apellidos,
        Documento,
        FechaNacimiento,
        Telefono,
        Correo
    )
VALUES (
        N'María',
        N'García',
        N'CC12345678',
        '1985-04-12',
        '3001234567',
        'maria@example.com'
    );
GO

INSERT INTO
    Odontologo (
        Nombres,
        Apellidos,
        Especialidad,
        Telefono
    )
VALUES (
        N'Juan',
        N'Pérez',
        N'Ortodoncia',
        '3017654321'
    );
GO

INSERT INTO
    Procedimiento (
        Codigo,
        Nombre,
        Descripcion,
        DuracionMinutos,
        Costo
    )
VALUES (
        N'PROC001',
        N'Limpieza dental',
        N'Profilaxis y pulido',
        30,
        50000.00
    );
GO

INSERT INTO
    Agenda (
        PacienteID,
        OdontologoID,
        ProcedimientoID,
        FechaCita,
        DuracionMinutos,
        Estado
    )
VALUES (
        1,
        1,
        1,
        '2025-09-19T15:47:00',
        30,
        'Pendiente'
    );
GO

INSERT INTO
    Factura (
        PacienteID,
        Total,
        MetodoPago,
        NumeroDocumento
    )
VALUES (
        1,
        50000.00,
        'Efectivo',
        'REC-0001'
    );
GO

INSERT INTO
    DetalleFactura (
        FacturaID,
        ProcedimientoID,
        Cantidad,
        PrecioUnitario
    )
VALUES (1, 1, 1, 50000.00);
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

 -- ========== EJECUTAR PROCEDIMIENTOS ==========
EXEC sp_AgregarPaciente 'Pedro', 'Ramirez', 'CC100811197', '1989-04-21', '3133096545', 'VENITRANS@gmail.com'
EXEC sp_AgregarCita 2, 1, 1, '2025-02-02 16:30';

-- Consultar tabla --
SELECT * FROM Agenda
