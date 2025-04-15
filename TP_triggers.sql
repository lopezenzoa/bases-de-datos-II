CREATE DATABASE BdD2_TP_triggers;
USE BdD2_TP_triggers;

CREATE TABLE Clientes (
ClienteID INT PRIMARY KEY,
Nombre VARCHAR(50),
Apellido VARCHAR(50),
Email VARCHAR(100),
Telefono VARCHAR(15)
);

CREATE TABLE Pedidos (
PedidoID INT PRIMARY KEY,
FechaPedido DATE,
ClienteID INT,
FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
);

CREATE TABLE Productos (
ProductoID INT PRIMARY KEY,
NombreProducto VARCHAR(100),
Precio DECIMAL(10, 2)
);

CREATE TABLE DetallesPedido (
DetalleID INT PRIMARY KEY,
PedidoID INT,
ProductoID INT,
Cantidad INT,
FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID),
FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
);

INSERT INTO Clientes (ClienteID, Nombre, Apellido, Email, Telefono)
VALUES
(1, 'Juan', 'Pérez', 'juan@email.com', '123-456-7890'),
(2, 'María', 'Gómez', 'maria@email.com', '987-654-3210'),
(3, 'Carlos', 'López', 'carlos@email.com', '555-123-4567');

INSERT INTO Productos (ProductoID, NombreProducto, Precio)
VALUES
(101, 'Producto 1', 10.99),
(102, 'Producto 2', 19.99),
(103, 'Producto 3', 5.99);

INSERT INTO Pedidos (PedidoID, FechaPedido, ClienteID)
VALUES
(1001, '2023-10-15', 1),
(1002, '2023-10-16', 2),
(1003, '2023-10-17', 3),
(1004, '2023-10-18', 1);

INSERT INTO DetallesPedido (DetalleID, PedidoID, ProductoID, Cantidad)
VALUES
(2001, 1001, 101, 2),
(2002, 1001, 102, 1),
(2003, 1002, 103, 3),
(2004, 1003, 101, 1),
(2005, 1003, 103, 2),
(2006, 1004, 102, 2);

/* Tablas de auditoria */
-- Cada tabla tiene los atributos que tiene la tabla que va a ser auditada
create table AuditoriaClientes (
    AuditoriaID INT PRIMARY KEY AUTO_INCREMENT,
    ClienteID INT,
    Nombre VARCHAR(50),
    Apellido VARCHAR(50),
    Email VARCHAR(100),
    Telefono VARCHAR(15),
    TipoOperacion VARCHAR(30),
    FechaInsercion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

create table AuditoriaPedidos (
    AuditoriaID INT PRIMARY KEY AUTO_INCREMENT,
    PedidoID INT,
    FechaPedido DATE,
    ClienteID INT,
    Total_Pedido DECIMAL (10, 2),
    TipoOperacion VARCHAR(30),
    FechaInsercion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

create table AuditoriaProductos (
    AuditoriaID INT PRIMARY KEY AUTO_INCREMENT,
    ProductoID INT,
    NombreProducto VARCHAR(100),
    Precio DECIMAL(10, 2),
    Stock INT,
    TipoOperacion VARCHAR(30),
    FechaInsercion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ejercicio 1: Crear un trigger para auditar inserciones en la tabla Clientes.
CREATE TRIGGER insercionCliente
AFTER INSERT ON Clientes
FOR EACH ROW
INSERT INTO AuditoriaClientes(ClienteID, Nombre, Apellido, Email, Telefono, TipoOperacion)
VALUES (NEW.ClienteID, NEW.Nombre, NEW.Apellido, NEW.Email, NEW.Telefono, 'INSERCION');

INSERT INTO Clientes VALUES (4, 'Enzo', 'López', 'enzo@email.com', '555-123-4567');

-- Ejercicio 2: Crear un trigger para auditar actualizaciones en la tabla Clientes.
/* Es mejor, para las auditorias de actualizaciones, usar el trigger AFTER para garantizar que solo se dispara cuando el cambio fue real y exitoso */
CREATE TRIGGER actualizacionCliente
AFTER UPDATE ON Clientes
FOR EACH ROW
INSERT INTO AuditoriaClientes(ClienteID, Nombre, Apellido, Email, Telefono, TipoOperacion)
VALUES (New.ClienteID, New.Nombre, NEW.Apellido, NEW.Email, NEW.Telefono, 'ACTUALIZACION');

UPDATE Clientes SET email = 'enzoagustinlopez2003@gmail.com' WHERE ClienteID = 4;

-- Ejercicio 3: Crear un trigger para auditar eliminaciones en la tabla Clientes.
CREATE TRIGGER eliminacionCliente
AFTER DELETE ON Clientes
FOR EACH ROW
INSERT INTO AuditoriaClientes(ClienteID, Nombre, Apellido, Email, Telefono, TipoOperacion)
VALUES (OLD.ClienteID, OLD.Nombre, OLD.Apellido, OLD.Email, OLD.Telefono, 'ELIMINACION');

DELETE FROM Clientes WHERE ClienteID = 4;

-- Ejercicio 4: Crear un trigger para actualizar el precio total en la tabla Pedidos.
-- Entiendo que el ejercicio requiere una columna que no se contempla en la tabla original.
ALTER TABLE Pedidos
ADD COLUMN PrecioTotal DECIMAL(10, 2) DEFAULT 0; -- Agrego una nueva columna PrecioTotal a la tabla de pedidos

-- Cuando se inserte un nuevo registro en la tabla pedidos, se va a modificar el PrecioTotal
DELIMITER //
CREATE TRIGGER actualizarPrecioTotal
AFTER INSERT ON DetallesPedido
FOR EACH ROW
BEGIN
	-- Se actualiza el precio total del pedido asociado al nuevo detalle en DetallesPedido
    UPDATE Pedidos
    SET PrecioTotal = (
		-- Calculo el precio total
        SELECT SUM(dp.cantidad * p.precio)
        FROM DetallesPedido dp
        JOIN Productos p
			ON dp.ProductoID = p.ProductoID
		WHERE dp.PedidoID = NEW.PedidoID -- Solo toma los pedidos que se agrega
    )
    WHERE PedidoID = NEW.PedidoID; -- Actualiza solo el registro que coincide con el PedidoID que se esta ingresando
END;

// DELIMITER ;

INSERT INTO DetallesPedido (DetalleID, PedidoID, ProductoID, Cantidad)
VALUES (2007, 1001, 101, 2);

-- Ejercicio 5: Crear un trigger para validar la cantidad de productos en la tabla DetallesPedido.
DELIMITER //
CREATE TRIGGER validarCantidadProductos
BEFORE INSERT ON DetallesPedido
FOR EACH ROW
BEGIN
	-- Los triggers no permiten transacciones
	IF NEW.cantidad <= 0 THEN
		SIGNAL SQLSTATE '45000' -- '45000' hace referencia a un tipo de error generico definido por el usuario
        SET MESSAGE_TEXT = 'La cantidad de un producto debe ser mayor a 0'; -- MESSAGE_TEXT es una clausula usada dentro de un SIGNAL como un mensjae de error personalizado
    END IF;
END;
// DELIMITER ;

INSERT INTO DetallesPedido (DetalleID, PedidoID, ProductoID, Cantidad)
VALUES (2007, 1001, 101, -1);

-- Ejercicio 6: Crear un trigger para actualizar el precio de un producto en la tabla Productos
DELIMITER //
CREATE TRIGGER actualizarPrecioProducto
BEFORE UPDATE ON Productos
FOR EACH ROW
BEGIN
	-- El ejercicio no esta claro, entonces se valida que el precio del producto realmente cambie
    IF NEW.Precio = OLD.Precio THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El precio del producto no cambio';
	END IF;
END;

// DELIMITER ;

UPDATE Productos SET precio = 23.33 WHERE ProductoID = 103;

-- Ejercicio 7: Crear un trigger para auditar inserciones en la tabla Pedidos.
CREATE TRIGGER insercionPedido
AFTER INSERT ON Pedidos
FOR EACH ROW
INSERT INTO AuditoriaPedidos(PedidoID, FechaPedido, ClienteID, Total_Pedido, TipoOperacion)
VALUES (NEW.PedidoID, NEW.FechaPedido, NEW.ClienteID, NEW.PrecioTotal, 'INSERCION');

INSERT INTO Pedidos(PedidoID, FechaPedido, ClienteID)
VALUES (1007, '2023-10-15', 1);

-- Ejercicio 8: Crear un trigger para auditar actualizaciones en la tabla Pedidos.
CREATE TRIGGER actualizacionPedido
AFTER UPDATE ON Pedidos
FOR EACH ROW
INSERT INTO AuditoriaPedidos(PedidoID, FechaPedido, ClienteID, Total_Pedido, TipoOperacion)
VALUES (NEW.PedidoID, NEW.FechaPedido, NEW.ClienteID, NEW.PrecioTotal, 'ACTUALIZACION');

UPDATE Pedidos SET ClienteID = 3 WHERE PedidoID = 1007;

-- Ejercicio 9: Crear un trigger para auditar eliminaciones en la tabla Pedidos.
CREATE TRIGGER eliminacionPedido
AFTER DELETE ON Pedidos
FOR EACH ROW
INSERT INTO AuditoriaPedidos(PedidoID, FechaPedido, ClienteID, Total_Pedido, TipoOperacion)
VALUES (OLD.PedidoID, OLD.FechaPedido, OLD.ClienteID, OLD.PrecioTotal, 'ELIMINACION');

DELETE FROM Pedidos WHERE PedidoID IN (1005, 1006, 1007);

-- Ejercicio 10: Crear un trigger para actualizar el stock de productos en la tabla Productos.
-- Entiendo que el ejercicio requiere de una nueva columna en la tabla
ALTER TABLE Productos
ADD COLUMN Stock INT;

CREATE TRIGGER acutalizarStockProductos
AFTER UPDATE ON Productos
FOR EACH ROW
UPDATE AuditoriaProductos
SET Stock = NEW.Stock
WHERE ProductoID = OLD.ProductoID;

UPDATE Productos SET Stock = 20, Precio = 5.99 WHERE ProductoID = 103;

-- Ejercicio 11: Crear un trigger para validar el email en la tabla Clientes.
DELIMITER //
CREATE TRIGGER validarEmailCliente
BEFORE INSERT ON Clientes
FOR EACH ROW
BEGIN
	IF NEW.Email NOT LIKE "%@%.com" THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El email no cumple con el formato nombre@ejemplo.com';
	END IF;
END;

// DELIMITER ;

INSERT INTO Clientes (ClienteID, Nombre, Apellido, Email, Telefono)
VALUES(4, 'Enzo', 'Lopez', 'enzo@gmail.com', '123-456-7890');

-- Ejercicio 12: Crear un trigger para auditar inserciones en la tabla Productos.
CREATE TRIGGER insercionProducto
AFTER INSERT ON Productos
FOR EACH ROW
INSERT INTO AuditoriaProductos(ProductoID, NombreProducto, Precio, Stock, TipoOperacion)
VALUES (NEW.ProductoID, NEW.NombreProducto, NEW.Precio, 10, 'INSERCION');

INSERT INTO Productos(ProductoID, NombreProducto, Precio)
VALUES (104, 'Producto 4', 6.99);

-- Ejercicio 13: Crear un trigger para auditar actualizaciones en la tabla Productos.
CREATE TRIGGER actualizacionProducto
AFTER UPDATE ON Productos
FOR EACH ROW
INSERT INTO AuditoriaProductos(ProductoID, NombreProducto, Precio, Stock, TipoOperacion)
VALUES (NEW.ProductoID, NEW.NombreProducto, NEW.Precio, 10, 'ACTUALIZACION');

UPDATE Productos SET Precio = 7.99 WHERE ProductoID = 104;

-- Ejercicio 14: Crear un trigger para auditar eliminaciones en la tabla Productos.
CREATE TRIGGER eliminacionProducto
AFTER DELETE ON Productos
FOR EACH ROW
INSERT INTO AuditoriaProductos(ProductoID, NombreProducto, Precio, Stock, TipoOperacion)
VALUES (OLD.ProductoID, OLD.NombreProducto, OLD.Precio, 10, 'ELIMINACION');

DELETE FROM Productos WHERE ProductoID = 104;

-- Ejercicio 15: Crear un trigger para actualizar el stock de productos en la tabla Productos al eliminar un detalle de pedido.
DELIMITER //
CREATE TRIGGER actualizarStockAlEliminar
AFTER DELETE ON DetallesPedido
FOR EACH ROW
BEGIN
	UPDATE Productos
    SET Stock = (
		SELECT Cantidad
        FROM DetallePedido dp
        WHERE ProductoID = DetallesPedido.ProductoID
    ) + Stock
    WHERE ProductoID = OLD.ProductoID;
END;

// DELIMITER ;

DELETE FROM DetallesPedido WHERE DetalleID = 2007;