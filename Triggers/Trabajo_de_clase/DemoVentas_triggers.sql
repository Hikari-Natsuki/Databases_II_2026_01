CREATE DATABASE DemoVentas;
GO

USE DemoVentas;
GO

-- Tabla de clientes
CREATE TABLE Clientes (
    ClienteID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100),
    Email NVARCHAR(100)
);

-- Tabla de pedidos
CREATE TABLE Pedidos (
    PedidoID INT PRIMARY KEY IDENTITY(1,1),
    ClienteID INT,
    FechaPedido DATE,
    Total DECIMAL(10,2),
    FechaActualizacion DATETIME,
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
);

-- Tabla para auditoría de inserciones y eliminaciones de pedidos
CREATE TABLE AuditoriaPedidos (
    AuditoriaID INT PRIMARY KEY IDENTITY(1,1),
    PedidoID INT,
    Operacion NVARCHAR(10),
    FechaOperacion DATETIME DEFAULT GETDATE()
);
-- ********************** TRIGGERS **********************

/**
 Los triggers son bloques de codigo almacenados que se ejecuntan
 automaticamente cuando ocurre un evento en especifico
 Automatización: Se ejecutan por sí mismos, no requieren que un usuario los llame.
 Eventos: Se activan con acciones INSERT (inserción), 
          UPDATE (actualización) o DELETE (borrado).
 Funcionalidad: Son ideales para validaciones complejas, 
                sincronización de tablas, 
 auditoría de registros y forzar reglas de negocio. 
*/

-- 1. Trigger para auditar inserciones en la tabla Pedidos *****
CREATE TRIGGER trg_AuditarInsertarProducto -- Crear el trigger
ON Pedidos -- El trigger está ligada con la tabla "Pedidos"
AFTER INSERT -- El trigger se ejecuta SOLO cuando se INSERTEN datos en la tabla
AS 
BEGIN -- Hace que el código se ejecute
    INSERT INTO AuditoriaPedidos (PedidoID, Operacion) -- Se insertará información en la tabla de auditoría.
    SELECT PedidoID, 'INSERT' -- Insertar el id del pedido y la operación será 'INSERT'
    FROM inserted -- inserted es una tabla temporal automática creada por 
                  -- SQL Server que contiene las filas recién insertadas.
END -- NOTA: Los triggers crean automaticamente las tablas "inserted" y "deleted"
-- Si no se usa "inserted", el trigger no sabe qué registros fueron agregados.

-- 2. Trigger para evitar pedidos con total negativo       ******
CREATE TRIGGER trg_ValidarTotalPedido
ON Pedidos
AFTER INSERT, UPDATE
AS 
BEGIN
    -- Verificar si hay registros con Total negativo
    IF EXISTS (SELECT 1 FROM inserted WHERE total < 0)
    BEGIN
    --  sirve para generar errores personalizados desde tus consultas, procedimientos o triggers.
        RAISERROR('El total del pedido no puede ser negativo', 16, 1);
        /*
        16, 1: 
        16 -> Nivel de severidad (severity)
              Indica qué tan grave es el error.
              Escala: 0 a 25.

        1 ->  Estado (state)
              Es un número interno para identificar de dónde viene el error.
        
      - ROLLBACK TANSACTION sirve para deshacer una operación en la base de datos 
        cuando ocurre un error o una condición no válida. Es como un botón de “cancelar cambios”.*/
        ROLLBACK TRANSACTION
    END
END

-- 3. Trigger para auditar eliminación de pedidos *****
-- Pasa el producto de la tabla "inserted" a la tabla "delete"
CREATE TRIGGER trg_AuditoriaDeletePedido
ON Pedidos
AFTER DELETE
AS 
BEGIN
 -- Inserta un nuevo dato y lo guarda como DELETE
    INSERT INTO AuditoriaPedidos (PedidoID, Operacion)
    SELECT PedidoID, 'DELETE'
    FROM deleted
END

-- 4. Trigger para evitar eliminar un cliente *****
CREATE TRIGGER trg_ImpedirBorrarCliente
ON Clientes
INSTEAD OF DELETE
AS
BEGIN
    -- Verificar si se está intentando borrar el cliente con ClienteID = 1
    IF EXISTS (SELECT 1 FROM deleted WHERE ClienteID = 1)
    BEGIN
        RAISERROR('No está permitido borrar el cliente con ClienteID = 1.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    -- Si no se intenta borrar el cliente 1, proceder con el borrado normalmente
    DELETE FROM Clientes
    WHERE ClienteID IN (SELECT ClienteID FROM deleted);
END;


-- ******** Poner a prueba los triggers ********
-- 1. Insertar pedidos:
INSERT INTO Pedidos 
VALUES 
(1, '2026-02-17', 150000, GETDATE()),
(3, '2026-02-17', 90000, GETDATE()),
(5, '2026-02-17', 100000, GETDATE())

-- Verificar en AuditoriaPedidos
SELECT * FROM AuditoriaPedidos

-- 2. Poner a prueba el precio negativo (Con INSERT y UPDATE
INSERT INTO Pedidos VALUES (1, '2026-02-17', -100, GETDATE())
UPDATE Pedidos SET Total = -10 WHERE PedidoID = 3

-- 3. Eliminar un dato: 
DELETE FROM Pedidos WHERE PedidoID = 2
-- Verificar en AuditoriaPedidos
SELECT * FROM AuditoriaPedidos

-- 4. Eliminar usuarios
DELETE FROM Clientes WHERE ClienteID = 1 -- No me da ;p Conflictos con la FK

