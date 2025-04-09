CREATE DATABASE IF NOT EXISTS TP_CTEs;
USE TP_CTEs;

CREATE TABLE Ventas (
	venta_id INT PRIMARY KEY AUTO_INCREMENT,
	cliente_id INT NOT NULL,
	fecha_venta DATE NOT NULL,
	valor DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Empleados (
	empleado_id INT PRIMARY KEY AUTO_INCREMENT,
	nombre VARCHAR(100) NOT NULL,
	departamento_id INT NOT NULL,
	fecha_contratacion DATE NOT NULL,
	salario DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Clientes (
	cliente_id INT PRIMARY KEY AUTO_INCREMENT,
	nombre VARCHAR(100) NOT NULL,
	apellido VARCHAR(100) NOT NULL
);

CREATE TABLE Departamentos (
	departamento_id INT PRIMARY KEY AUTO_INCREMENT,
	nombre_departamento VARCHAR(100) NOT NULL,
	jefe_id INT DEFAULT NULL
);

ALTER TABLE Ventas
ADD CONSTRAINT fk_cliente_id FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id);

ALTER TABLE Empleados
ADD CONSTRAINT fk_departamento_id FOREIGN KEY (departamento_id) REFERENCES
Departamentos(departamento_id);

INSERT INTO Clientes (nombre, apellido) VALUES
('Juan', 'Pérez'),
('María', 'Gómez'),
('Carlos', 'Rodríguez'),
('Ana', 'Martínez'),
('Luis', 'López'),
('Patricia', 'Sánchez'),
('Jorge', 'Fernández'),
('Sofía', 'Ramírez'),
('Ricardo', 'Torres');

INSERT INTO Departamentos (nombre_departamento, jefe_id) VALUES
('Ventas', 1),
('Recursos Humanos', 2),
('TI', 3),
('Marketing', 4),
('Finanzas', 5),
('Operaciones', 6),
('Atención al Cliente', 7),
('Logística', 8),
('Administración', 9);

INSERT INTO Empleados (nombre, departamento_id, fecha_contratacion, salario) VALUES
('Pedro López', 1, '2020-03-10', 2500.50),
('Laura García', 2, '2019-06-22', 3000.75),
('Felipe Gómez', 3, '2021-01-15', 3500.40),
('Beatriz Fernández', 4, '2018-07-04', 2800.20),
('Andrés Martínez', 5, '2022-09-30', 3200.60),
('Julia Pérez', 6, '2020-11-12', 2700.30),
('Antonio Sánchez', 7, '2021-05-19', 2900.10),
('Eva Torres', 8, '2017-10-05', 3300.80),
('Luis Ramírez', 9, '2023-02-14', 3100.00);

INSERT INTO Ventas (cliente_id, fecha_venta, valor) VALUES
(1, '2025-04-01', 150.75),
(2, '2025-04-02', 200.00),
(3, '2025-04-03', 250.50),
(4, '2025-04-04', 300.00),
(5, '2025-04-05', 120.25),
(6, '2025-04-06', 500.00),
(7, '2025-04-07', 450.00),
(8, '2025-04-08', 175.80),
(9, '2025-04-09', 275.30);

INSERT INTO Ventas (cliente_id, fecha_venta, valor) VALUES
(9, '2025-04-09', 275.30),
(9, '2025-04-09', 275.30),
(9, '2025-04-09', 275.30);

-- Ejercicio 1: Crear una CTE llamada VentasAltas que seleccione todas las ventas con un valor mayor a 1000 de la tabla Ventas. Luego, en la consulta principal, mostrar el número total de ventas y el valor promedio de las ventas en esa categoría.
WITH VentasAltas AS (
	SELECT *
    FROM Ventas
    WHERE valor > 250
) 
SELECT 	COUNT(*) AS cantidadVentas,
		AVG(valor) AS valorPromedio
FROM VentasAltas;

-- Ejercicio 2: Usando una CTE llamada PromedioPorDepartamento, seleccionar el promedio de salarios por departamento de la tabla Empleados. En la consulta principal, mostrar solo los departamentos con un salario promedio superior a 4000.
WITH PromedioPorDepartamento AS (
	SELECT	AVG(salario) AS promedioSalario,
			nombre_departamento
	FROM Empleados
	JOIN Departamentos
		ON Empleados.departamento_id = Departamentos.departamento_id
    GROUP BY Departamentos.departamento_id
)
SELECT nombre_departamento
FROM PromedioPorDepartamento
WHERE promedioSalario > 3000;
    
-- Ejercicio 3: Crear una CTE llamada AntiguedadEmpleados que calcule la cantidad de días que lleva cada empleado en la empresa, utilizando la función DATEDIFF sobre la fecha de contratación. En la consulta principal, mostrar los empleados que llevan más de 5 años en la empresa
WITH AntiguedadEmpleados AS (
	SELECT 	*,
			DATEDIFF(NOW(), fecha_contratacion) AS antiguedad
	FROM Empleados
)
SELECT *
FROM AntiguedadEmpleados
WHERE antiguedad > (365 * 5);

-- Ejercicio 4: Crear una CTE llamada VentasClientes que una las tablas Ventas y Clientes por el cliente_id. Luego, en la consulta principal, mostrar los clientes que han hecho más de 3 compras en el último año.
WITH VentasClientes AS (
	SELECT 	nombre,
			COUNT(*) AS cantidadCompras,
            Ventas.fecha_venta
	FROM Clientes 
    JOIN Ventas
		ON Clientes.cliente_id = Ventas.cliente_id
    GROUP BY Clientes.cliente_id
)
SELECT 	nombre,
		cantidadCompras
FROM VentasClientes
WHERE cantidadCompras > 3 AND fecha_venta > "09-04-2025";

-- Ejercicio 5: Crear una CTE que seleccione los 10 empleados con los salarios más altos de la tabla Empleados. Mostrar su nombre y salario en la consulta principal.
WITH empleadosConAltoSalario AS (
	SELECT *
    FROM Empleados
    ORDER BY salario DESC
    LIMIT 5
)
SELECT nombre, salario
FROM empleadosConAltoSalario;

-- Ejecicio 6: Usar una CTE llamada VentasPorMes que agrupe las ventas por mes y año usando las funciones YEAR() y MONTH(). Luego, en la consulta principal, mostrar los meses que tienen un total de ventas superior a 5000.
WITH VentasPorMes AS(
	SELECT 	SUM(valor) AS totalVentas,
			YEAR(fecha_venta) AS anio,
            MONTH(fecha_venta) AS mes
	FROM Ventas 
    GROUP BY anio, mes
)
SELECT mes
FROM VentasPorMes
WHERE totalVentas > 2000;

-- Ejercicio 7: Usar una CTE recursiva llamada JerarquiaDepartamental para crear una lista jerárquica de departamentos de una empresa. Cada departamento tiene un jefe_id que es el responsable de un departamento superior.

-- Ejercicio 8: Crear una CTE llamada ClientesDuplicados que seleccione los clientes que tienen el mismo nombre y apellido en la tabla Clientes. Mostrar los duplicados en la consulta principal
WITH ClientesDuplicados AS (
	-- La funcion de agregacion COUNT(*) y GROUP BY 
	SELECT nombre, apellido, COUNT(*) AS cantClientes
    FROM Clientes
    GROUP BY nombre, apellido
    HAVING cantClientes > 1
)
SELECT *
FROM ClientesDuplicados;

-- Ejercicio 9: Crear una CTE llamada TotalVentasPorCliente que calcule el total de ventas por cada cliente. Luego, usar una segunda CTE para seleccionar los clientes con un total de ventas superior a 10,000.

-- Ejercicio 10: Crear una CTE llamada VentasUltimoMes que seleccione todas las ventas del último mes (usando la función DATE_SUB() con la fecha actual) y luego unirlas con la tabla Clientes para mostrar el nombre del cliente y el valor de la venta.