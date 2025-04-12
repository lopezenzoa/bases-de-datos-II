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

-- Ejercicio 5: Crear un trigger para validar la cantidad de productos en la tabla DetallesPedido.

-- Ejercicio 6: Crear un trigger para actualizar el precio de un producto en la tabla Productos

-- Ejercicio 7: Crear un trigger para auditar inserciones en la tabla Pedidos.
-- Por hacer: se tiene que completar el campo 'Total_Pedidos' (declarando una variable que se selecciona junto con un JOIN entre las tablas DetallePedido y Producto)
/*
	DECLARE total DECIMAL(10, 2);

	SELECT de.cantidad * pr.precio INTO total
    FROM DetallesPedido de
    JOIN Productos pr
		ON de.ProductoID = pr.ProductoID;
        
	INSERT INTO AuditoriaPedidos(PedidoID, FechaPedido, ClienteID, Total_Pedido, TipoOperacion)
	VALUES (NEW.PedidoID, NEW.FechaPedido, NEW.ClienteID, total, 'INSERCION');
*/
CREATE TRIGGER insercionPedido
AFTER INSERT ON Pedidos
FOR EACH ROW
INSERT INTO AuditoriaPedidos(PedidoID, FechaPedido, ClienteID, Total_Pedido, TipoOperacion)
VALUES (NEW.PedidoID, NEW.FechaPedido, NEW.ClienteID, 0, 'INSERCION');

INSERT INTO Pedidos(PedidoID, FechaPedido, ClienteID)
VALUES (1007, '2023-10-15', 1);

-- Ejercicio 8: Crear un trigger para auditar actualizaciones en la tabla Pedidos.
CREATE TRIGGER actualizacionPedido
AFTER UPDATE ON Pedidos
FOR EACH ROW
INSERT INTO AuditoriaPedidos(PedidoID, FechaPedido, ClienteID, Total_Pedido, TipoOperacion)
VALUES (NEW.PedidoID, NEW.FechaPedido, NEW.ClienteID, 0, 'ACTUALIZACION');

UPDATE Pedidos SET ClienteID = 3 WHERE PedidoID = 1007;

-- Ejercicio 9: Crear un trigger para auditar eliminaciones en la tabla Pedidos.
CREATE TRIGGER eliminacionPedido
AFTER DELETE ON Pedidos
FOR EACH ROW
INSERT INTO AuditoriaPedidos(PedidoID, FechaPedido, ClienteID, Total_Pedido, TipoOperacion)
VALUES (OLD.PedidoID, OLD.FechaPedido, OLD.ClienteID, 0, 'ELIMINACION');

DELETE FROM Pedidos WHERE PedidoID IN (1005, 1006, 1007);

-- Ejercicio 10: Crear un trigger para actualizar el stock de productos en la tabla Productos.

-- Ejercicio 11: Crear un trigger para validar el email en la tabla Clientes.

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
