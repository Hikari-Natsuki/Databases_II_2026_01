USE Ejercicio 
GO
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
    UPDATE P
    SET P.Total = (SELECT SUM(DP.Subtotal) FROM DetallePedidos AS DP
        WHERE DP.PedidoID = P.PedidoID
    )
    FROM Pedidos AS P WHERE P.PedidoID IN (
        SELECT PedidoID FROM inserted
        UNION
        SELECT PedidoID FROM deleted
    );
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
        RETURN
    END

    -- Actualizar el stock
    UPDATE INV SET StockActual = INV.StockActual - I.Cantidad
    FROM inserted AS I INNER JOIN Inventario AS INV ON I.ProductoID = INV.ProductoID
END

/*
4) Alerta de stock mínimo
Cuando el inventario se actualice y el StockActual sea menor que StockMinimo, 
registrar un mensaje en la tabla AuditoriaPedidos:
*/ 

CREATE TRIGGER trg_AuditoriaActualizarStock
ON Inventario
AFTER UPDATE
AS 
BEGIN 
    INSERT INTO AuditoriaPedidos (Operacion, Mensaje)
    SELECT 'Alerta de stock', 'Stock bajo para el producto(ID): ' + I.ProductoID
    FROM inserted I
    WHERE I.StockActual < I.StockMinimo;
END

/*
Trigger 5 — Registrar fecha de actualización del pedido
Cuando un pedido sea modificado, actualizar automáticamente:
Pedidos.FechaActualizacion = GETDATE()
*/

CREATE TRIGGER trg_ActualizarFecha
ON Pedidos
AFTER UPDATE
AS 
BEGIN
    UPDATE P SET P.FechaActualizacion = GETDATE()
    FROM Pedidos AS P INNER JOIN inserted AS I ON P.PedidoID = I.PedidoID;
END


-- INSERTAR DATOS

INSERT INTO Productos VALUES
('Zapatos', 500000, '1'),
('Camisas', 55000, '1'),
('Pantalones', 100000, '1')

INSERT INTO Inventario (ProductoID, StockActual, StockMinimo)VALUES
(1, 50, 10),
(2, 100, 15),
(3, 25, 20)

INSERT INTO Pedidos (ProductoID, FechaPedido)
VALUES
(2, '2026-02-23'),
(1, '2026-02-23')


INSERT INTO DetallePedidos (PedidoID, ProductoID, Cantidad, PrecioUnitario)VALUES
(1, 1, 2, 500000),
(2, 1, 2, 500000)


-- ACTUALIZAR DETALLEPEDIDOS
UPDATE DetallePedidos SET Cantidad = 3 WHERE DetalleID = 1

SELECT * FROM DetallePedidos
SELECT * FROM Pedidos
SELECT * FROM Inventario

DROP DATABASE Ejercicio
-- Miguel Villegas 
-- Julian Higuita
