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

/*
1- Cuando se inserte, actualice o elimine un registro en DetallePedidos, 
se debe recalcular el campo Pedidos.
Total como la suma de los subtotales del pedido.
*/

CREATE TRIGGER trg_ActualizarTotal
ON DetallePedidos
AFTER INSERT, UPDATE, DELETE
AS 
BEGIN 
    -- INSERTED 
    UPDATE P SET P.Total = SUM(I.Subtotal) -- No se usa el WHERE porque ya comprobamos que tiene el mismo ID
    FROM Pedidos AS P INNER JOIN inserted AS I ON P.PedidoID = I.PedidoID -- acá

    -- UPDATE              S Viejo      S Nuevo
    UPDATE P SET Total = (D.Subtotal - I.Subtotal)
    FROM Pedidos AS P 
    INNER JOIN deleted AS D ON P.PedidoID = D.PedidoID --  Tomar el subtotal anterior
    INNER JOIN inserted AS I ON D.PedidoID = I.PedidoID -- Tomar el nuevo subtotal
    
    -- Delete 
    UPDATE P SET P.Total = (P.Total - D.Subtotal)
    FROM Pedidos AS P INNER JOIN deleted AS D ON P.PedidoID = D.PedidoID
END

/*
2. Calcular subtotal automáticamente
Después de insertar registros en DetallePedidos, calcular:
Subtotal = Cantidad * PrecioUnitario

HECHO EN LA TABLA DetallePedidos, ESTÁ COMO CAMPO CALCULADO
*/ 

/* 
3- Descontar inventario
Cuando se inserte un registro en DetallePedidos, 
descontar la cantidad correspondiente en Inventario.StockActual.
Si el stock es insuficiente, cancelar la transacción.
*/

CREATE TRIGGER trg_DescontarInventario
ON DetallePedidos
AFTER INSERT
AS 
BEGIN 
    -- Verificar el stock
    IF EXISTS(
        SELECT 1
        -- INNER JOIN PRODUCTOS AS P ON P.ProductoID = I.ProductoID
        FROM inserted AS I INNER JOIN Inventario AS INV ON I.ProductoID = INV.ProductoID
        WHERE I.Cantidad > INV.StockActual
    )
    BEGIN 
        RAISERROR('El stock actual es menor a la cantidad solicitada', 15, 1)
        ROLLBACK TRANSACTION
    END

    -- Actualizar el stock
    UPDATE INV SET StockActual = INV.StockActual - I.Cantidad
    FROM inserted AS I INNER JOIN Inventario AS INV ON I.ProductoID = INV.ProductoID
END



-- Miguel Villegas 
-- Julian Higuita