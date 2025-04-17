CREATE DATABASE simulacro_primer_parcial;
USE simulacro_primer_parcial;

CREATE TABLE Clientes (
    cliente_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50)
);

CREATE TABLE Ventas (
    venta_id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT,
    fecha_venta DATE,
    valor DECIMAL(10,2),
    FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id)
);

CREATE TABLE Empleados (
    empleado_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50),
    fecha_contratacion DATE,
    salario DECIMAL(10,2),
    departamento_id INT
);

CREATE TABLE Departamentos (
    departamento_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_departamento VARCHAR(50),
    jefe_id INT
);

CREATE TABLE auditoria_ventas (
    venta_id INT,
    fecha_borrado DATETIME
);

-- Para 2.f agregamos la tabla productos
CREATE TABLE Productos (
    producto_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_producto VARCHAR(100),
    stock INT
);

-- Insertando Clientes
INSERT INTO Clientes (nombre, apellido) VALUES
('Juan', 'Pérez'),
('Ana', 'Gómez'),
('Luis', 'Martínez');

-- Insertando Empleados
INSERT INTO Empleados (nombre, fecha_contratacion, salario, departamento_id) VALUES
('Carlos Ruiz', '2015-03-15', 75000, 1),
('Sofía Pérez', '2019-06-10', 68000, 2),
('Miguel Torres', '2010-01-20', 90000, 1);

-- Insertando Departamentos
INSERT INTO Departamentos (nombre_departamento, jefe_id) VALUES
('Ventas', 1),
('Recursos Humanos', 2);

-- Insertando Ventas
INSERT INTO Ventas (cliente_id, fecha_venta, valor) VALUES
(1, '2024-05-10', 2000),
(1, '2024-06-11', 3500),
(2, '2024-03-15', 6000),
(3, '2024-04-20', 4500);

-- Insertando Productos
INSERT INTO Productos (nombre_producto, stock) VALUES
('Notebook', 10),
('Mouse', 25),
('Teclado', 15);

-- Ejercicio 2.a
DELIMITER //
CREATE PROCEDURE registrar_venta ( IN p_valor DECIMAL (10,2), OUT p_venta_id INT) 
BEGIN 
	IF p_valor < 0 THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'EL valor debe ser mayor a 0';
    END IF;
    
	INSERT INTO Ventas (fecha_venta, valor) 
    VALUES (NOW(), p_valor); 
	
    SET p_venta_id = LAST_INSERT_ID(); -- Retorna el ultimo ID insertado en la tabla
END; 
// DELIMITER ; 

CALL registrar_venta(-4.55, @venta_id);
SELECT @venta_id;

-- Ejercicio 2.b
WITH total_ventas AS (
	SELECT SUM(valor) AS total_vendido, cliente_id
    FROM Ventas
    GROUP BY cliente_id
    HAVING total_vendido > 5000
)
SELECT *
FROM total_ventas AS tv
JOIN Clientes AS cl
	ON tv.cliente_id = cl.cliente_id;
    
-- Ejercicio 2.c
CREATE TRIGGER eliminar_venta
AFTER DELETE ON Ventas
FOR EACH ROW
INSERT INTO auditoria_ventas(venta_id, fecha_borrado) VALUES
(OLD.venta_id, NOW());

DELETE FROM Ventas WHERE venta_id = 5;

-- Ejercicio 2.d
CREATE VIEW empleadosAntiguos AS
	SELECT nombre, salario, ROUND(DATEDIFF(NOW(), fecha_contratacion) / 365) AS antiguedad 
	FROM Empleados 
	WHERE ROUND(DATEDIFF(NOW(), fecha_contratacion) / 365);
SELECT * 
FROM empleadosAntiguos;

-- Ejercicio 2.e
DELIMITER //
CREATE PROCEDURE calcular_ventas_por_cliente(IN p_cliente_id INT, OUT total_ventas INT)
BEGIN
    IF NOT EXISTS (
		SELECT *
        FROM Clientes
        WHERE cliente_id = p_cliente_id
    ) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El ID ingresado no existe';
	END IF;
    
    SELECT COUNT(venta_id) INTO total_ventas
    FROM Ventas
    WHERE cliente_id = p_cliente_id;
END
// DELIMITER ;

CALL calcular_ventas_por_cliente(1, @total_ventas);
SELECT @total_ventas;

-- Ejercicio 2.f
DELIMITER //
CREATE PROCEDURE actualizarStock(IN p_producto_id INT, IN nuevo_stock INT)
BEGIN
	DECLARE producto_encontrado INT;
    
    DECLARE EXIT HANDLER FOR NOT FOUND
    BEGIN
		ROLLBACK;
		SELECT "El ID del producto no existe" AS mensaje;
    END;
    
    SELECT producto_id INTO producto_encontrado
    FROM Productos
    WHERE producto_id = p_producto_id;

/*
    IF NOT EXISTS(
		SELECT *
        FROM Productos
        WHERE producto_id = p_producto_id
    ) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El ID del producto no existe';
        */
        
	IF nuevo_stock < 0 THEN
		ROLLBACK;
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El stock no puede ser negativo';
	END IF;
    
    START TRANSACTION;
    
    UPDATE Productos
	SET stock = nuevo_stock
    WHERE producto_id = p_producto_id;
    
    COMMIT;
END
// DELIMITER ;

CALL actualizarStock(1, -1);