-- Tabla Clientes
CREATE TABLE Clientes (
    cliente_id INT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    ciudad VARCHAR(50),
    email VARCHAR(50)
);

-- Tabla Productos
CREATE TABLE Productos (
    producto_id INT PRIMARY KEY,
    nombre_producto VARCHAR(50),
    categoria VARCHAR(50),
    precio DECIMAL(10, 2)
);

-- Tabla Pedidos
CREATE TABLE Pedidos (
    pedido_id INT PRIMARY KEY,
    cliente_id INT,
    fecha_pedido DATE,
    FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id)
);

-- Tabla Detalle_Pedido
CREATE TABLE Detalle_Pedido (
    detalle_id INT PRIMARY KEY,
    pedido_id INT,
    producto_id INT,
    cantidad INT,
    FOREIGN KEY (pedido_id) REFERENCES Pedidos(pedido_id),
    FOREIGN KEY (producto_id) REFERENCES Productos(producto_id)
);

-- Insertar registros en Clientes
INSERT INTO Clientes (cliente_id, nombre, apellido, ciudad, email) VALUES
(1, 'Ana', 'García', 'Madrid', 'ana.garcia@email.com'),
(2, 'Juan', 'Pérez', 'Barcelona', 'juan.perez@email.com'),
(3, 'María', 'López', 'Madrid', 'maria.lopez@email.com'),
(4, 'Carlos', 'Ruiz', 'Valencia', 'carlos.ruiz@email.com');

-- Insertar registros en Productos
INSERT INTO Productos (producto_id, nombre_producto, categoria, precio) VALUES
(1, 'Laptop', 'Electrónicos', 1200.00),
(2, 'Tablet', 'Electrónicos', 300.00),
(3, 'Libro', 'Libros', 25.00),
(4, 'Smartphone', 'Electrónicos', 800.00);

-- Insertar registros en Pedidos
INSERT INTO Pedidos (pedido_id, cliente_id, fecha_pedido) VALUES
(1, 1, '2023-10-26'),
(2, 1, '2023-11-10'),
(3, 2, '2023-11-05'),
(4, 3, '2023-10-28'),
(5, 4, '2023-11-15');

-- Insertar registros en Detalle_Pedido
INSERT INTO Detalle_Pedido (detalle_id, pedido_id, producto_id, cantidad) VALUES
(1, 1, 1, 1),
(2, 1, 2, 2),
(3, 2, 4, 1),
(4, 3, 3, 3),
(5, 4, 1, 1),
(6, 5, 2, 2),
(7, 5, 4, 1);

-- Ejercicio 1
CREATE OR REPLACE VIEW clientes_por_ciudad AS
	SELECT CONCAT(nombre, " ", apellido) AS nombre_completo, email FROM Clientes WHERE ciudad = "Barcelona"
WITH CHECK OPTION;

INSERT INTO clientes_por_ciudad(nombre, apellido, ciudad, email) VALUES ("Enzo", "Lopez", "Mar del Plata", "enzo@gmail.com");

-- Ejercicio 2
CREATE OR REPLACE VIEW resumen_ventas_categorias AS 
	SELECT categoria, SUM(cantidad) AS total_ventas FROM Productos P 
	JOIN Detalle_Pedido D ON P.producto_id = D.producto_id
    GROUP BY categoria;
    
SELECT * FROM resumen_ventas_categorias;

-- Ejercicio 3
CREATE VIEW cliente_total_pedidos AS
	SELECT CONCAT(nombre, " ", apellido) AS nombre_completo, COUNT(pedido_id) AS total_pedidos
	FROM Pedidos P
	JOIN Clientes C
		ON P.cliente_id = C.cliente_id
	GROUP BY C.cliente_id;

SELECT * FROM cliente_total_pedidos;

-- Ejercicio 4
CREATE OR REPLACE VIEW productos_mas_vendido_ciudad AS 
	SELECT ciudad, nombre_producto, SUM(cantidad) AS total_ventas FROM Detalle_Pedido D 
	JOIN Pedidos P 
		ON D.pedido_id = P.pedido_id 
	JOIN Clientes C 
		ON C.cliente_id = P.cliente_id 
	JOIN Productos pr
		ON pr.producto_id = D.producto_id
	GROUP BY C.ciudad;
    
SELECT * FROM productos_mas_vendido_ciudad;

-- Ejercicio 5
CREATE OR REPLACE VIEW ingresos_por_mes AS
	SELECT DATE_FORMAT("2023-10-01", "%Y %m") AS mes, SUM(cantidad * precio) AS total_ingresos
    FROM Detalle_Pedido dp
	JOIN Pedidos p
		ON dp.pedido_id = p.pedido_id
	JOIN Productos pr
		ON dp.producto_id = pr.producto_id
	WHERE fecha_pedido BETWEEN "2023-10-01" AND "2023-10-31";
    
SELECT * FROM ingresos_por_mes;

-- Ejercicio 6
CREATE OR REPLACE VIEW productos_electronicos AS 
	SELECT * FROM Productos 
		WHERE categoria= "Electrónicos";
        
SELECT * FROM productos_electronicos;

CREATE OR REPLACE VIEW ventas_electronicos AS
	SELECT pe.producto_id, pe.nombre_producto, dp.cantidad FROM productos_electronicos pe
		JOIN Detalle_Pedido dp
		ON dp.producto_id = pe.producto_id
	WITH LOCAL CHECK OPTION;
    
SELECT * FROM ventas_electronicos;

-- Ejercicio 7
CREATE OR REPLACE VIEW ventas_electronicos AS
	SELECT pe.producto_id, pe.nombre_producto, dp.cantidad FROM productos_electronicos pe
		JOIN Detalle_Pedido dp
		ON dp.producto_id = pe.producto_id
	WITH CASCADED CHECK OPTION;
    
SELECT * FROM ventas_electronicos;