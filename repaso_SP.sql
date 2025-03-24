CREATE DATABASE IF NOT EXISTS Repaso_SP;
USE Repaso_SP;

/*
Ejercicio 1: Procedimiento con Parámetro de Entrada
Consigna: Crea un procedimiento almacenado llamado ObtenerSalario que reciba como parámetro de entrada un ID de empleado y devuelva su salario.
*/

CREATE TABLE empleados (
    id INT PRIMARY KEY,
    nombre VARCHAR(50),
    salario DECIMAL(10,2)
);

INSERT INTO empleados VALUES (1, 'Juan Pérez', 3500);
INSERT INTO empleados VALUES (2, 'Ana Gómez', 4200);
INSERT INTO empleados VALUES (3, 'Carlos Ruiz', 5000);

DELIMITER //
CREATE PROCEDURE ObtenerSalario(IN idEmpleado INT, OUT salarioEmpleado DECIMAL(10, 2))
BEGIN
	SELECT salario INTO salarioEmpleado FROM empleados WHERE id = idEmpleado;
END
// DELIMITER ;

CALL ObtenerSalario(1, @salarioEmpleado);
SELECT @salarioEmpleado;

/*
Ejercicio 2: Procedimiento con Parámetro de Salida
Consigna: Crea un procedimiento llamado CalcularDescuento que reciba un precio y devuelva el precio con un descuento del 10% en un parámetro de salida.
*/

DELIMITER // 
CREATE PROCEDURE calcularDescuento (IN precio DECIMAL(10,2), OUT precioDescuento DECIMAL (10,2) ) 
BEGIN 
 SET precioDescuento = precio - precio*0.1;
 END 
// DELIMITER ; 

CALL calcularDescuento(100, @precioDescuento);
SELECT @precioDescuento;

/*
Ejercicio 3: Procedimiento con Parámetro INOUT
Consigna: Crea un procedimiento llamado DuplicarNumero que reciba un número como parámetro INOUT y lo duplique.
*/

DELIMITER //
CREATE PROCEDURE DuplicarNumero(INOUT numero INT)
BEGIN
	SET numero = numero * 2;
END
// DELIMITER ;

SET @numero = 100;
CALL DuplicarNumero(@numero);
SELECT @numero;

/*
Ejercicio 4: Procedimiento con Condicional IF
Consigna: Crea un procedimiento llamado VerificarEdad que reciba una edad y devuelva en un parámetro de salida si la persona es "Menor de edad" (menos de 18 años) o "Mayor de edad" (18 o más).
*/

DELIMITER // 
CREATE PROCEDURE verificarEdad ( IN edad INT, OUT definicionEdad VARCHAR (100))
BEGIN
IF  edad < 18 THEN 
SET definicionEdad = 'Menor de edad';
ELSE 
SET definicionEdad = 'Mayor de edad';
END IF;
END 
// DELIMITER ;

CALL verificarEdad(20, @definicionEdad); 
SELECT @definicionEdad; 

/*
Ejercicio 5: Procedimiento con Bucle WHILE
Consigna: Crea un procedimiento llamado SumarHastaN que reciba un número n y devuelva en un parámetro de salida la suma de todos los números desde 1 hasta n.
*/

DELIMITER //
CREATE PROCEDURE SumarHastaN(IN n INT, OUT sumatoria INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    SET sumatoria = 0;
    
    WHILE i <= n DO
		SET sumatoria = sumatoria + i;
        SET i = i + 1;
	END WHILE;
END
// DELIMITER ;

CALL SumarHastaN(5, @sumatoria);
SELECT @sumatoria;