CREATE DATABASE IF NOT EXISTS TP1;
USE TP1;

-- TP1: Repaso SP + Manejo de Errores y Transacciones
CREATE TABLE ejemplo_tabla (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50)
);

-- Ejercicio 1
/* Crea un procedimiento almacenado (insertarEnTablaInexistente) que intente insertar un registro en una tabla inexistente y maneje el error con un handler SQLEXCEPTION. */

DELIMITER //
CREATE PROCEDURE insertarEnTablaInexistente( IN numero INT)
BEGIN 
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 
		SELECT 'La tabla es inexistente' AS mensaje;
    END;
    
    INSERT INTO tablaInexistente(inexistente) VALUES (numero);
END
//DELIMITER ;

CALL insertarEnTablaInexistente(5); 

-- Ejercicio 2
/* Crea un procedimiento almacenado (crearTablaExistente) que intente crear una tabla que ya existe y maneje la advertencia con un handler SQLWARNING. */

DELIMITER //
CREATE PROCEDURE crearTablaExistente(IN nombre VARCHAR(20))
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT "La tabla que se quiere crear ya existe!" AS Mensaje;
    END;
    
    -- Linea que produce el error
    CREATE TABLE ejemplo_tabla(id INT PRIMARY KEY);
    
    SELECT "La tabla se creo con exito!" AS Mensaje;
END
// DELIMITER ;

CALL crearTablaExistente("ejemplo_tabla");

-- Ejercicio 3
/* Crea un procedimiento almacenado (CREATE PROCEDURE seleccionarRegistroInexistente) que intente seleccionar un registro de una tabla basándose en un ID que no existe y maneje la condición NOT FOUND.*/

DELIMITER // 
CREATE PROCEDURE seleccionarRegistroInexistente (IN idInexistente INT) 
BEGIN
	DECLARE buscarId INT;

	DECLARE EXIT HANDLER FOR NOT FOUND
    BEGIN 
		SELECT 'El id ingresado no existe' AS mensaje; 
    END; 
    
    SELECT id INTO buscarId FROM ejemplo_tabla WHERE id = idInexistente; 
END;
// DELIMITER ;
    
CALL seleccionarRegistroInexistente(8);

-- Ejercicio 4
/* Crea un procedimiento almacenado (manejoCombinado) que intente insertar un registro en una tabla inexistente y luego intente crear una tabla que ya existe, manejando ambos casos con sus respectivos handlers */

DELIMITER //
CREATE PROCEDURE manejoCombinado()
BEGIN
	-- Insertando un registro en una tabla inexistente
    BEGIN
		DECLARE EXIT HANDLER FOR 1146
        BEGIN
			SELECT 'La tabla es inexistente' AS mensaje;
		END;
        
		INSERT INTO tabla_inexistente(id_inexistente) VALUES (1);
    END;
	
    -- Creando una tabla que ya existe
    BEGIN
		DECLARE EXIT HANDLER FOR 1050
        BEGIN
			SELECT "La tabla que intenstaste crear ya existe" AS mensaje_2;
        END;
        
        CREATE TABLE ejemplo_tabla_2(id INT PRIMARY KEY, nombre VARCHAR(50));
    END;
END
// DELIMITER ;

CALL manejoCombinado();

CREATE TABLE socios (
    id_socio INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    fecha_nacimiento DATE,
    direccion VARCHAR(100),
    telefono VARCHAR(20)
);

CREATE TABLE planes (
    id_plan INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50),
    duracion INT,
    precio DECIMAL(10, 2),
    servicios TEXT
);

CREATE TABLE actividades (
    id_actividad INT AUTO_INCREMENT PRIMARY KEY,
    id_socio INT,
    id_plan INT,
    FOREIGN KEY (id_socio) REFERENCES socios(id_socio),
    FOREIGN KEY (id_plan) REFERENCES planes(id_plan)
);

-- Inserciones en la tabla socios
INSERT INTO socios (nombre, apellido, fecha_nacimiento, direccion, telefono)
VALUES 
('Juan', 'Pérez', '1985-03-15', 'Calle Ficticia 123', '555-1234'),
('Ana', 'Gómez', '1990-06-21', 'Avenida Libertad 456', '555-5678'),
('Luis', 'Martínez', '1978-11-03', 'Calle Real 789', '555-8765');

-- Inserciones en la tabla planes
INSERT INTO planes (nombre, duracion, precio, servicios)
VALUES 
('Plan Básico', 6, 50.00, 'Acceso limitado a servicios básicos'),
('Plan Premium', 12, 100.00, 'Acceso a todos los servicios y actividades exclusivas'),
('Plan Familiar', 6, 150.00, 'Acceso para 4 personas a servicios y actividades grupales');

-- Inserciones en la tabla actividades
INSERT INTO actividades (id_socio, id_plan)
VALUES
(1, 2), -- Juan Pérez se inscribe en el Plan Premium
(2, 1), -- Ana Gómez se inscribe en el Plan Básico
(3, 3); -- Luis Martínez se inscribe en el Plan Familiar

-- Ejercicio 5
/* Crea un procedimiento almacenado (insertarActividad) que intente insertar un registro en la tabla actividades y maneje el error si el id_socio o id_plan no existen en sus respectivas tablas. */

DELIMITER // 
CREATE PROCEDURE insertarActividad(IN idActividad INT, IN idSocio INT, IN idPlan INT)
BEGIN
	DECLARE idSocioEncontrado INT; 
	DECLARE idPlanEncontrado INT;
    
    -- Otra forma de manejar las excepciones es 
	DECLARE EXIT HANDLER FOR NOT FOUND 
	BEGIN 
        SELECT 'El id del socio o el id del plan son inexistentes!' AS mensaje; 
	END;
	
	SELECT id_socio INTO idSocioEncontrado FROM socios WHERE id_socio = idSocio; 
	SELECT id_plan INTO idPlanEncontrado FROM planes WHERE id_plan = idPlan;
        
	INSERT INTO actividades (id_actividad, id_socio, id_plan) VALUES (idActividad, idSocio, idPlan);
END;
// DELIMITER ;

CALL insertarActividad(4,1,1);
SELECT * FROM actividades;

 -- Ejercicio 6
 /* Crea un procedimiento almacenado (seleccionarSocio) que intente seleccionar un registro de la tabla socios basándose en un ID que no existe y maneje la condición NOT FOUND. */
 
DELIMITER //
CREATE PROCEDURE seleccionarSocio(IN idSocio INT)
BEGIN
	DECLARE idSocioEncontrado INT;
    
	DECLARE EXIT HANDLER FOR NOT FOUND 
	BEGIN 
		SELECT 'El id del socio es inexistente!' AS mensaje;
	END;
	
	SELECT id_socio INTO idSocioEncontrado FROM socios WHERE id_socio = idSocio;
    SELECT * FROM socios WHERE id_socio = idSocio;
END;
// DELIMITER ;

CALL seleccionarSocio(6);

-- Ejercicio 7
/* Desarrolla un procedimiento almacenado llamado registrarSocioConPlan. Este procedimiento debe recibir como parámetros los datos de un nuevo socio (nombre, apellido, fecha_nacimiento, dirección, teléfono) y los IDs de un plan y una actividad. */

DELIMITER //
CREATE PROCEDURE registrarSocioConPlan(
	IN nombre_socio VARCHAR(50),
    IN apellido_socio VARCHAR(50),
    IN fecha_nacimiento_socio DATE,
    IN direccion_socio VARCHAR(100),
    IN telefono_socio VARCHAR(20),
    IN idPlan INT
)
BEGIN
	DECLARE id_plan_valido INT;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		ROLLBACK; -- Si algo falla en el ingreso de los datos del socio, se lanza la excepcion y se elimina todos los cambios hechos
        SELECT "Hubo un problema en la insercion de los datos del socio!" AS mensaje;
    END;
    
    DECLARE EXIT HANDLER FOR NOT FOUND
    BEGIN
		ROLLBACK; -- Si no se encuentran los IDs correspondientes, se lanza la excepcion y se elimina todos los cambios hechos
        SELECT "El ID del plan no existe!" AS mensaje;
    END;

    START TRANSACTION;
	INSERT INTO socios(nombre, apellido, fecha_nacimiento, direccion, telefono)
    VALUES (nombre_socio, apellido_socio, fecha_nacimiento_socio, direccion_socio, telefono_socio);
    
    SELECT id_plan INTO id_plan_valido FROM planes WHERE id_plan = idPlan;
    
    INSERT INTO actividades(id_socio, id_plan) VALUES (LAST_INSERT_ID(), idPlan);
    COMMIT;
END;
// DELIMITER ;

CALL registrarSocioConPlan('Enzo', 'Lopez', '2003-02-07', '3 de Febrero 5074', '2236004953', 1);

-- Ejercicio 8
/* Desarrolla un procedimiento almacenado llamado actualizarPlanYRegistrarActividad. Este procedimiento debe recibir como parámetros el ID de un plan, su nuevo precio, el ID de un socio y el ID de una actividad. */

DELIMITER //
CREATE PROCEDURE actualizarPlanYRegistrarActividad(IN idPlan INT, IN nuevo_precio DECIMAL(10, 2), IN idSocio INT)
BEGIN
	DECLARE id_plan_valido INT;
    DECLARE id_socio_valido INT;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		ROLLBACK;
		SELECT "Hubo un problema durante la actualización del plan o la inserción de la actividad" AS mensaje;
    END;
    
    DECLARE EXIT HANDLER FOR NOT FOUND
	BEGIN
		ROLLBACK;
		SELECT "Alguno de los IDs ingresados no existen en las tablas" AS mensaje;
    END;

	START TRANSACTION;
		SELECT id_socio INTO id_socio_valido FROM socios WHERE id_socio = idSocio;
		SELECT id_plan INTO id_plan_valido FROM planes WHERE id_plan = idPlan;

		UPDATE planes SET precio = nuevo_precio WHERE id_plan = idPlan;
		INSERT INTO actividades(id_socio, id_plan) VALUES (idSocio, idPlan);
    COMMIT;
    
    SELECT "Todas las operaciones se realizaron con exito" AS mensaje;
END
// DELIMITER ;

CALL actualizarPlanYRegistrarActividad(1, 70.00, 8);

-- Ejercicio 9
/* Desarrolla un procedimiento almacenado llamado eliminarSocioYActividades. Este procedimiento debe recibir como parámetro el ID de un socio. */

DELIMITER //
CREATE PROCEDURE eliminarSocioYActividades(IN idSocio INT)
BEGIN
	DECLARE id_socio_valido INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		ROLLBACK;
        SELECT "Ha ocurrido un error durante la eliminación de las actividades o del socio" AS mensaje;
    END;
    
    DECLARE EXIT HANDLER FOR NOT FOUND
    BEGIN
		ROLLBACK;
		SELECT "El ID del socio ingresado no existe!" AS mensaje;
    END;
    
    START TRANSACTION;
		SELECT id_socio INTO id_socio_valido FROM socios WHERE id_socio = idSocio;
		
		DELETE FROM actividades WHERE id_socio = idSocio;
		DELETE FROM socios WHERE id_socio = idSocio;
	COMMIT;
    
    SELECT "El socio ha sido eliminado con exito!" AS mensaje;
END;
// DELIMITER ;

CALL eliminarSocioYActividades(7);
