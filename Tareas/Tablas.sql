CREATE DATABASE Ejercicio 
GO

USE Ejercicio 
GO

-- Tabla de productos
    CREATE TABLE Productos (
    ProductoID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR (40),
    Precio INT, 
    Activo NVARCHAR (10)
)

--Tabla de Empleados 
CREATE TABLE Empleados (
    EmpleadoID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR (40),
    Email NVARCHAR (60),
    Activo NVARCHAR (10) 
)

-- Tablas de Transportadora
CREATE TABLE Transportadora (
    TransportadoraID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR (40),
    Direccion NVARCHAR (100),
    Telefono NVARCHAR (40),
)

-- Tabla de clientes
CREATE TABLE Clientes (
    ClienteID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100),
    Email NVARCHAR(100)
);

-- Tabla de pedidos
CREATE TABLE Pedidos (
    PedidoID INT PRIMARY KEY IDENTITY(1,1),
	ProductoID INT,
    ClienteID INT,
	EmpleadoID INT,
    FechaPedido DATE,
    FechaActualizacion DATE DEFAULT GETDATE(),
    Total DECIMAL(10,2), 
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID),
	FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID),
	FOREIGN KEY (EmpleadoID) REFERENCES Empleados(EmpleadoID)
)

-- Tabla DetallePedidos
CREATE TABLE DetallePedidos (
    DetalleID INT PRIMARY KEY IDENTITY (1,1),
    PedidoID INT,
    ProductoID INT,
    Cantidad INT,
    PrecioUnitario DECIMAL(10,2),
    Subtotal AS (Cantidad * PrecioUnitario),
    FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID),
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
)

-- Tabla de Inventario 
CREATE TABLE Inventario (
    InventarioID INT PRIMARY KEY IDENTITY(1,1),
    ProductoID INT,
    StockActual INT,
    StockMinimo INT,
    FechaActualiizacion DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
)

-- Tabla de Pagos 
CREATE TABLE Pagos (
    PagoID INT PRIMARY KEY IDENTITY(1,1),
    PedidoID INT,
    FechaPago DATE,
    ValorPagado DECIMAL (10,2),
    MetodoPago NVARCHAR (40),
    FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID)
)
-- Tabla de Envios 
CREATE TABLE Envios (
    EnvioID INT PRIMARY KEY IDENTITY (1,1),
    PedidoID INT,
    TransportadoraID INT,
    FechaEnvio DATE,
    Direccion NVARCHAR (100),
    EstadoEnvio NVARCHAR (40),
    FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID)
)
-- Tabla AuditoriaPedidos
CREATE TABLE AuditoriaPedidos (
    AuditoriaID INT PRIMARY KEY IDENTITY(1,1),
    PedidoID INT,
    Operacion NVARCHAR(10),
    Mensaje NVARCHAR(20),
    FechaOperacion DATETIME DEFAULT GETDATE()
    FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID),
)
