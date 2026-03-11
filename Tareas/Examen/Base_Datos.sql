CREATE DATABASE ModeloCRM
GO

USE ModeloCRM
GO
-- TABLAS INDEPENDIENTES
-- ACCESO
CREATE TABLE Acceso(
    IdAcceso INT PRIMARY KEY IDENTITY(1, 1),
    Contrasena NVARCHAR (36) NOT NULL,
    TipoUsuario NVARCHAR (20) NOT NULL
)

-- ESTADO
CREATE TABLE Estado(
    IdEstado INT PRIMARY KEY IDENTITY(1,1),
    NombreEstado NVARCHAR(20) NOT NULL
)

-- ORIGEN
CREATE TABLE Origen(
    IdOrigen INT PRIMARY KEY IDENTITY(1,1),
    NombreOrigen NVARCHAR(20) NOT NULL
)

-- PRODUCTO
CREATE TABLE Producto(
    IdProducto INT PRIMARY KEY IDENTITY(1,1),
    NombreProducto NVARCHAR(50) NOT NULL
)

-- ANOTACION
CREATE TABLE Anotacion(
    IdAnotacion INT PRIMARY KEY IDENTITY(1,1),
    Anotacion NVARCHAR (200)
)

-- CITAS
CREATE TABLE Citas (
    IdCitas INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATE NOT NULL,
    Hora TIME NOT NULL,
    Direccion NVARCHAR(50) NOT NULL,
    Descripcion NVARCHAR(80) NULL
)

-- TAREA
CREATE TABLE Tarea (
    IdTarea INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATE NOT NULL,
    Hora TIME NOT NULL,
    Recordatorio NVARCHAR(50) NULL,
    Descripcion NVARCHAR(80) NULL,
)

-- PROSPECTO
CREATE TABLE Prospecto (
    IdProspecto INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL,
    Correo NVARCHAR(100) NOT NULL,
    Celular NVARCHAR(20) NOT NULL
)

-- TABLAS DEPENDIENTES
-- OFERTA
CREATE TABLE Oferta(
    IdOferta INT PRIMARY KEY IDENTITY(1,1),
    IdEstado INT,
    IdOrigen INT,
    IdProducto INT,
    IdProspecto INT,
    NivelInteres NVARCHAR(50)
    -- FOREIGN KEY
    FOREIGN KEY (IdEstado) REFERENCES Estado(IdEstado),
    FOREIGN KEY (IdOrigen) REFERENCES Origen(IdOrigen),
    FOREIGN KEY (IdProducto) REFERENCES Producto(IdProducto),
    FOREIGN KEY (IdProspecto) REFERENCES Producto(IdProducto)
)

-- ASESOR
CREATE TABLE Asesor (
    IdAsesor INT PRIMARY KEY IDENTITY (1,1),
    IdAcceso int,
    Nombre NVARCHAR(45),
    Apellido NVARCHAR (60),
    Correo NVARCHAR (150),
    Telefono NVARCHAR (15)
    FOREIGN KEY (IdAcceso) REFERENCES Acceso(IdAcceso)
)

-- REGISTROACTIVIDAD
CREATE TABLE RegistroActividad (
    IdRegistroActividad INT PRIMARY KEY IDENTITY (1,1),
    IdOferta INT,
    IdAnotacion INT,
    IdTarea INT,
    IdAsesor INT,
    IdCitas INT
    FOREIGN KEY (IdOferta) REFERENCES Oferta(IdOferta),
    FOREIGN KEY (IdAnotacion) REFERENCES Anotacion(IdAnotacion),
    FOREIGN KEY (IdTarea) REFERENCES Tarea(IdTarea),
    FOREIGN KEY (IdAsesor) REFERENCES Asesor(IdAsesor),
    FOREIGN KEY (IdCitas) REFERENCES Citas(IdCitas)
)

-- HISTORICO
CREATE TABLE Historico (
    IdHistorico INT PRIMARY KEY IDENTITY (1,1),
    IdProspecto INT,
    IdEstadoAnterior INT,
    IdEstadoNuevo INT,
    IdAsesor INT,
    FechaCambio DATE,
    FOREIGN KEY (IdProspecto) REFERENCES Prospecto(IdProspecto),
    FOREIGN KEY (IdEstadoAnterior) REFERENCES Estado(IdEstado),
    FOREIGN KEY (IdEstadoNuevo) REFERENCES Estado(IdEstado),
    FOREIGN KEY (IdAsesor) REFERENCES Asesor(IdAsesor),
)

USE master;
DECLARE @sql NVARCHAR(MAX) = '';

SELECT @sql += 'KILL ' + CAST(session_id AS VARCHAR) + ';'
FROM sys.dm_exec_sessions
WHERE database_id = DB_ID('ModeloCRM');

EXEC(@sql);

DROP DATABASE ModeloCRM;