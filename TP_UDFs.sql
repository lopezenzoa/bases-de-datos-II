CREATE DATABASE IF NOT EXISTS TUP;
USE TUP;

CREATE TABLE Clientes (
    cliente_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    ciudad VARCHAR(50),
    email VARCHAR(50)
);

CREATE TABLE Libros (
    libro_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_libro VARCHAR(100),
    autor VARCHAR(100),
    precio DECIMAL(10, 2)
);

CREATE TABLE Ventas (
    venta_id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT,
    fecha_venta DATE,
    FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id)
);

CREATE TABLE Detalle_Venta (
    detalle_venta_id INT PRIMARY KEY AUTO_INCREMENT,
    venta_id INT,
    libro_id INT,
    cantidad INT,
    FOREIGN KEY (venta_id) REFERENCES Ventas(venta_id),
    FOREIGN KEY (libro_id) REFERENCES Libros(libro_id)
);

INSERT INTO Clientes (nombre, apellido, ciudad, email)
VALUES 
('Carlos', 'Gomez', 'Madrid', 'carlos.gomez@email.com'),
('Ana', 'Martinez', 'Barcelona', 'ana.martinez@email.com'),
('Juan', 'Lopez', 'Sevilla', 'juan.lopez@email.com'),
('Maria', 'Perez', 'Valencia', 'maria.perez@email.com');

INSERT INTO Libros (nombre_libro, autor, precio)
VALUES
('Cien años de soledad', 'Gabriel García Márquez', 15.99),
('Don Quijote de la Mancha', 'Miguel de Cervantes', 12.50),
('La sombra del viento', 'Carlos Ruiz Zafón', 18.75),
('El código Da Vinci', 'Dan Brown', 20.99),
('Harry Potter y la piedra filosofal', 'J.K. Rowling', 25.00);

INSERT INTO Ventas (cliente_id, fecha_venta)
VALUES
(1, '2025-03-10'),
(2, '2025-03-12'),
(3, '2025-03-15'),
(4, '2025-03-17'),
(1, '2025-03-20'),
(2, '2025-03-22'),
(3, '2025-03-25'),
(4, '2025-03-28'),
(1, '2025-03-30'),
(2, '2025-04-01');

INSERT INTO Detalle_Venta (venta_id, libro_id, cantidad)
VALUES
(1, 1, 2),  -- Carlos compra 2 copias de "Cien años de soledad" (venta 1)
(1, 2, 1),  -- Carlos compra 1 copia de "Don Quijote de la Mancha" (venta 1)
(2, 3, 1),  -- Ana compra 1 copia de "La sombra del viento" (venta 2)
(3, 4, 3),  -- Juan compra 3 copias de "El código Da Vinci" (venta 3)
(4, 5, 2),  -- Maria compra 2 copias de "Harry Potter y la piedra filosofal" (venta 4)
(5, 3, 1),  -- Carlos compra 1 copia de "La sombra del viento" (venta 5)
(6, 4, 2),  -- Ana compra 2 copias de "El código Da Vinci" (venta 6)
(7, 1, 1),  -- Juan compra 1 copia de "Cien años de soledad" (venta 7)
(8, 2, 1),  -- Maria compra 1 copia de "Don Quijote de la Mancha" (venta 8)
(9, 5, 1),  -- Carlos compra 1 copia de "Harry Potter y la piedra filosofal" (venta 9)
(10, 4, 3); -- Ana compra 3 copias de "El código Da Vinci" (venta 10)

-- Ejercicio 1: Obtener el Nombre Completo de un Cliente
DELIMITER //
CREATE FUNCTION devolver_nombre_completo(id INT) RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
	DECLARE nombreCompleto VARCHAR(100);
    SELECT CONCAT(nombre, " ", apellido) INTO nombreCompleto FROM Clientes WHERE cliente_id = id;
    RETURN nombreCompleto;
END;
// DELIMITER ;

SELECT devolver_nombre_completo(1) AS nombre;

-- Ejercicio 2: Obtener el Total Vendido de un Libro
DELIMITER //
CREATE FUNCTION total_vendido(id INT) RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
	DECLARE total DECIMAL(10, 2);
    
    SELECT SUM(l.precio * dv.cantidad) INTO total
    FROM Libros l
    JOIN Detalle_Venta dv
		ON l.libro_id = dv.libro_id
	WHERE l.libro_id = id;
    
    RETURN total;
END;
// DELIMITER ;

SELECT total_vendido(1) AS total;

-- Ejercicio 3: Obtener el Cliente que Más Ha Gastado
DELIMITER //
CREATE FUNCTION cliente_mas_gastador() RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE id_cliente INT;
    
	SELECT c.cliente_id INTO id_cliente
	FROM Clientes c
	JOIN Ventas v
		ON v.cliente_id = c.cliente_id
	JOIN Detalle_Venta dv
		ON dv.venta_id = v.venta_id
	JOIN Libros l
		ON dv.libro_id = l.libro_id
	GROUP BY c.cliente_id
	ORDER BY SUM(l.precio * dv.cantidad) DESC LIMIT 1;
    
    RETURN id_cliente;
END;
// DELIMITER ;

SELECT * FROM Clientes WHERE cliente_id = cliente_mas_gastador();

-- Ejercicio 4: Obtener el Libro Más Vendido en un Año
DELIMITER //
CREATE FUNCTION libro_mas_vendido() RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE id_libro INT;
    
    SELECT l.libro_id INTO id_libro
    FROM Libros l
    JOIN Detalle_Venta dv
		ON l.libro_id = dv.libro_id
    GROUP BY dv.libro_id
    HAVING MAX(dv.cantidad) LIMIT 1;
    
    RETURN id_libro;
END;
// DELIMITER ;

SELECT * FROM Libros WHERE libro_id = libro_mas_vendido();

-- Ejercicio 5: Verificar si un Cliente Comprado un Libro en Particular
DELIMITER //
CREATE FUNCTION verificar_compra(id_libro INT) RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE id_cliente INT;
	
    SELECT v.cliente_id INTO id_cliente
    FROM Clientes c
    JOIN Ventas v
		ON v.cliente_id = c.cliente_id
	JOIN Detalle_Venta dv
		ON dv.venta_id = v.venta_id
	JOIN Libros l
		ON dv.libro_id = l.libro_id
	GROUP BY c.cliente_id
    HAVING COUNT(l.libro_id) > 0 LIMIT 1;
    
    RETURN id_cliente;
END;
// DELIMITER ;

DROP FUNCTION verificar_compra;

SELECT * FROM Clientes WHERE cliente_id = verificar_compra(1);