-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 20-10-2024 a las 02:05:42
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `bd_colegio_santa_monica`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_auth_login` (`_correo` VARCHAR(120), `_password` VARCHAR(120))   BEGIN
	select u.id_usuario , u.id_rol , concat(concat(concat(concat(nombres , ' ') , apellido_paterno) , ' '), apellido_materno) as 'nombres', u.correo , p.id_profesor as 'id' , u.estado , foto
	from Usuario u inner join Profesor p on p.id_usuario = u.id_usuario
	where correo = _correo and password = _password;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_list_asistencia_curso` (`_idSeccion` INT, `_cursoProf` INT, `_fecha` DATE)   BEGIN 
	 DECLARE nIdAlumno INT;
	 DECLARE cNombre VARCHAR(200);
	 DECLARE cApePaterno VARCHAR(200);
	 DECLARE cApeMaterno  VARCHAR(200); 
	 DECLARE cCorreo VARCHAR(200);
	 DECLARE nAsistio INT;
	 DECLARE nIdAsistencia INT;
     
     DROP TEMPORARY TABLE IF EXISTS tmp_salida;

     CREATE TEMPORARY TABLE tmp_salida(
		 id_asis_alu int,
		 id_alumno int,
		 nombres varchar(100),
         ape_paterno varchar(100),
         ape_materno varchar(100),
         correo varchar(100),
         asistio int
	 );
   
   BEGIN

	   DECLARE done INT DEFAULT FALSE;
       
	   DECLARE cur1 CURSOR FOR 
	   SELECT a.id_alumno , nombres , ape_paterno , ape_materno , correo
	   FROM grupo_seccion g inner join alumno a on a.id_alumno = g.id_alumno
	   WHERE id_seccion = _idSeccion
       ORDER BY ape_paterno ASC , ape_materno ASC , nombres ASC;
	   
	   DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	   OPEN cur1;
			read_loop: LOOP
			FETCH cur1 INTO nIdAlumno,cNombre,cApePaterno,cApeMaterno,cCorreo;
			IF done THEN
			  LEAVE read_loop;
			END IF;
			SET nIdAsistencia = IFNULL((SELECT id_asis_alu FROM asistencia_alumno 
                                WHERE fecha = _fecha AND id_curso_prof = _cursoProf AND id_alumno = nIdAlumno) , 0);
			SET nAsistio = IFNULL((SELECT asistio FROM asistencia_alumno 
                                WHERE fecha = _fecha  AND id_curso_prof = _cursoProf  AND id_alumno = nIdAlumno) , 0);
			
			INSERT INTO tmp_salida(id_asis_alu , id_alumno , nombres , ape_paterno , ape_materno,correo , asistio)
			VALUES(nIdAsistencia,nIdAlumno,cNombre,cApePaterno,cApeMaterno,cCorreo,nAsistio);
		END LOOP;
		CLOSE cur1;
   END;
    
    SELECT * FROM tmp_salida;
    DROP TABLE tmp_salida;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_marcar_asistencia` (`_idSeccion` INT, `_idcursoProf` INT, `_idAlumno` INT, `_fecha` DATE, `_idAsistencia` INT, `_asistio` INT)   BEGIN
     IF _idAsistencia = 0 or _idAsistencia is null then
		insert into Asistencia_alumno(id_alumno,id_curso_prof, fecha,hora_marcacion,asistio) 
        values(_idAlumno,_idcursoProf,_fecha,DATE_FORMAT(NOW(), "%H:%i:%S" ),_asistio);
	else
       update Asistencia_alumno set asistio = _asistio
       where id_asis_alu = _idAsistencia;
     end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_fecha_curso` (IN `p_id_periodo` INT, IN `p_id_curso_prof` INT)   BEGIN
    DECLARE _fecha_actual DATE;
    DECLARE _fecha_fin DATE;
    
    SELECT fecha_inicio, fecha_fin
    INTO _fecha_actual, _fecha_fin
    FROM periodo_lectivo
    WHERE id_periodo = p_id_periodo;
    
    IF _fecha_fin > CURDATE() THEN
        SET _fecha_fin = CURDATE();
    END IF;
    
    CREATE TEMPORARY TABLE IF NOT EXISTS fechas_curso (
        fecha DATE
    );

    WHILE _fecha_actual <= _fecha_fin DO
 
        IF (SELECT COUNT(*) FROM horario_curso 
            WHERE id_curso_prof = p_id_curso_prof 
            AND WEEKDAY(_fecha_actual) + 1 = nro_dia) > 0 THEN
            INSERT INTO fechas_curso (fecha) VALUES (_fecha_actual);
        END IF;
        SET _fecha_actual = DATE_ADD(_fecha_actual, INTERVAL 1 DAY);
    END WHILE;
    
    SELECT * FROM fechas_curso;

    DROP TEMPORARY TABLE fechas_curso;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `alumno`
--

CREATE TABLE `alumno` (
  `id_alumno` int(11) NOT NULL,
  `nombres` varchar(50) NOT NULL,
  `ape_paterno` varchar(50) NOT NULL,
  `ape_materno` varchar(50) NOT NULL,
  `dni` varchar(8) DEFAULT NULL,
  `genero` char(1) DEFAULT NULL,
  `telefono` varchar(15) DEFAULT NULL,
  `correo` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `alumno`
--

INSERT INTO `alumno` (`id_alumno`, `nombres`, `ape_paterno`, `ape_materno`, `dni`, `genero`, `telefono`, `correo`) VALUES
(1, 'GianFranco Mauricio', 'García', 'Becerra', '71534112', 'M', '997595599', 'gianM32@gmail.com'),
(2, 'Yelibeth', 'Chirinos', 'Sánchez', '76783411', 'F', '986848938', 'yelibeth2019@outlook.com'),
(3, 'Victor Alexander', 'Villegas', 'Fernández', '61546523', 'M', '977976577', 'alex_76@outlook.com'),
(4, 'Armando', 'López', 'Chong', '12332354', 'M', '967660609', 'lopez_56@outlook.com'),
(5, 'Jenifer Maybe', 'Montenegro', 'Camarena', '62575687', 'F', '978555585', 'jenifer98@gmail.com'),
(6, 'Marta', 'Noriega', 'Vásquez', '76764454', 'F', '946746434', 'marta43@outlook.com'),
(7, 'Milagros Luciana', 'Rodriguez', 'Guzman', '67454657', 'F', '975654234', 'milagros34@gmail.com'),
(8, 'Shirley', 'Castillo', 'Velasquez', '73456534', 'F', '987453233', 'sirley764@gmail.com'),
(9, 'Aldo Simon', 'Escalante', 'Rodriguez', '67876456', 'M', '946233354', 'aldo_simon@gmail.com'),
(10, 'Daisy', 'Fernandez', 'Baca', '76656463', 'F', '999874111', 'daisy@gmail.com'),
(11, 'Britney Danuska', 'Pilar', 'Huamani', '67563422', 'F', '987452324', 'danuska65@gmail.com'),
(12, 'Stephanie', 'Del Pilar', 'Huamani', '75444342', 'F', '964243434', 'stephanie65_1@gmail.com'),
(13, 'Juan Carlos', 'Aguilar', 'Puente', '73436588', 'M', '912354777', 'juan-65@gmail.com'),
(14, 'Enrique', 'Guzman', 'Cardenas', '67454535', 'M', '987456234', 'enrique54@gmail.com'),
(15, 'Ingrid Sugey', 'Velasquez', 'Chavez', '73332365', 'F', '987342111', 'ingrid-43@gmail.com'),
(16, 'Dayana', 'Sullca', 'Salazar', '56453422', 'F', '999875678', 'dayana43@gmail.com'),
(17, 'Carlos', 'Bardales', 'Carbajal', '67633464', 'M', '987888342', 'carlos-12@gmail.com'),
(18, 'Adely', 'Sotomayor', 'Carbajal', '72763836', 'F', '9123222643', 'adely-65123@gmail.com'),
(19, 'Alan', 'Paucar', 'Caceres', '70125433', 'M', '999123112', 'alan_1999@gmail.com'),
(20, 'Luis Alonzo', 'Dextre', 'Sanchez', '67453477', 'M', '987666231', 'alonzo-luis34@gmail.com'),
(21, 'Luis Alberto', 'Huaman', 'Vera', '73265768', 'M', '999345111', 'luis-19835@gmail.com'),
(22, 'Luis', 'Palacios', 'Sanchez', '01254522', 'M', '912423111', 'luis1834@hotmail.com'),
(23, 'Carlos Humberto', 'Mori', 'Moscoso', '10345565', 'M', '900087123', 'carlos-hum12@gmail.com'),
(24, 'Francisco', 'Mori', 'Quiroz', '01254564', 'M', '912435123', 'franci-12-4@gmail.com'),
(25, 'Alex Roger', 'Muñoz', 'Gomez', '10547254', 'M', '912546561', 'alex-76@gmail.com'),
(26, 'Erick Ramon', 'Nuñez', 'Tarillo', '10572324', 'M', '934462675', 'erick-ramon@gmail.com'),
(27, 'Carmen Rosa', 'Olivera', 'Delgado', '10546524', 'F', '994721222', 'carmen-rosa@gmail.com'),
(28, 'Cecilia', 'Valverde', 'Quispe', '01275343', 'F', '993722343', ''),
(29, 'Juan', 'Aguilar', 'Caceres', '12354465', 'M', '995111275', 'juan-12@gmail.com'),
(30, 'Silvana Rocio', 'Pacora', 'Bazalar', '01646453', 'F', '934352223', 'silvana-1254@gmail.com'),
(31, 'Manuel Jesus', 'Palomino', 'Berrios', '01243545', 'M', '945112121', 'manuel-123@gmail.com'),
(32, 'Alberto', 'Pereyra', 'Parra', '15342423', 'M', '993564656', 'alberto-12_54@gmail.com'),
(33, 'Patricia Laura', 'Pinto', 'Victorio', '16565657', 'F', '935452323', 'pati-pinto@gmail.com'),
(34, 'Fernando Jose', 'Pozo', 'Gonzales', '04645623', 'M', '999345111', 'fer-jose@gmail.com'),
(35, 'Maria Teresa', 'Quiroz', 'Vasquez', '05666723', 'F', '945123577', 'maria-54@gmail.com'),
(36, 'Miguel Angel', 'Rayme', 'Delgado', '04756733', 'M', '993542324', 'miguel.243@gmail.com'),
(37, 'Andy Maicol', 'Reyna', 'Diaz', '04546232', 'M', '994511113', 'andy-57@gmail.com'),
(38, 'Marina Ximena', 'Rodriguez', 'Revilla', '06563434', 'F', '986435343', 'marina-87@gmail.com'),
(39, 'Juan Esteban', 'Cardenas', 'Zevallos', '47875453', 'M', '906764534', 'juan-4566@gmail.com'),
(40, 'Raul ', 'Ramirez', 'Sevilla', '68354543', 'M', '943132323', 'raul-1243@gmail.com'),
(41, 'Samir', 'Palacios', 'Ramirez', '06745353', 'M', '999444522', ''),
(42, 'Alfredo', 'Matos', 'Olarte', '42968655', 'M', '994690444', ''),
(43, 'Jose Luis', 'Caceres', 'Guzman', '30142275', 'M', '935161230', 'jose.9481@hotmail.com'),
(44, 'Franco', 'Tadeo', 'Jeri', '74291343', 'M', '957467564', ''),
(45, 'Luis Miguel', 'Zuñiga', 'Noriega', '10804263', 'M', '987767656', ''),
(46, 'Esteban', 'Garcia', 'Soto', '74321234', 'M', '987651234', 'esteban.garcia@gmail.com'),
(47, 'Mariana', 'Lopez', 'Chavez', '65432178', 'F', '976543214', 'mariana.lopez@gmail.com'),
(48, 'Pablo', 'Rojas', 'Sanchez', '74856412', 'M', '935674812', 'pablo.rojas@hotmail.com'),
(49, 'Camila', 'Diaz', 'Fernandez', '74325678', 'F', '964234567', 'camila.diaz@outlook.com'),
(50, 'Javier', 'Torres', 'Gomez', '71823123', 'M', '978231543', 'javier.torres@gmail.com'),
(51, 'Lucia', 'Mejia', 'Vasquez', '71598765', 'F', '946873214', 'lucia.mejia@gmail.com'),
(52, 'Santiago', 'Mendoza', 'Perez', '73219476', 'M', '995132456', 'santiago.mendoza@yahoo.com'),
(53, 'Sofia', 'Castro', 'Ruiz', '74213476', 'F', '987564738', 'sofia.castro@hotmail.com'),
(54, 'Felipe', 'Flores', 'Ramirez', '75689432', 'M', '987641234', 'felipe.flores@gmail.com'),
(55, 'Daniela', 'Cruz', 'Gonzalez', '73654321', 'F', '935671234', 'daniela.cruz@gmail.com'),
(56, 'Matias', 'Chavez', 'Morales', '74832145', 'M', '964323546', 'matias.chavez@hotmail.com'),
(57, 'Gabriela', 'Ortiz', 'Martinez', '73521547', 'F', '976542314', 'gabriela.ortiz@gmail.com'),
(58, 'Fernando', 'Reyes', 'Diaz', '71231456', 'M', '987654214', 'fernando.reyes@gmail.com'),
(59, 'Isabella', 'Silva', 'Lopez', '76542145', 'F', '975431235', 'isabella.silva@outlook.com'),
(60, 'Andres', 'Romero', 'Garcia', '74321458', 'M', '964213574', 'andres.romero@gmail.com'),
(61, 'Valentina', 'Santos', 'Rivera', '73542312', 'F', '987342125', 'valentina.santos@hotmail.com'),
(62, 'Diego', 'Herrera', 'Mora', '72543123', 'M', '964213547', 'diego.herrera@gmail.com'),
(63, 'Martina', 'Paredes', 'Castillo', '74123213', 'F', '987654214', 'martina.paredes@gmail.com'),
(64, 'Sebastian', 'Vargas', 'Soto', '75412346', 'M', '987341234', 'sebastian.vargas@outlook.com'),
(65, 'Paula', 'Moreno', 'Vega', '72134567', 'F', '975341245', 'paula.moreno@gmail.com'),
(66, 'Oscar', 'Serrano', 'Mendez', '73564321', 'M', '964323457', 'oscar.serrano@hotmail.com'),
(67, 'Elena', 'Fuentes', 'Navarro', '72654321', 'F', '987312434', 'elena.fuentes@gmail.com'),
(68, 'Vicente', 'Gallardo', 'Ortiz', '74314523', 'M', '975432125', 'vicente.gallardo@gmail.com'),
(69, 'Victoria', 'Molina', 'Perez', '75413467', 'F', '964312345', 'victoria.molina@outlook.com'),
(70, 'Ricardo', 'Escobar', 'Lopez', '74832415', 'M', '964321754', 'ricardo.escobar@hotmail.com'),
(71, 'Manuela', 'Ramos', 'Silva', '76342515', 'F', '987321645', 'manuela.ramos@gmail.com'),
(72, 'Rafael', 'Villalobos', 'Garcia', '73542145', 'M', '976543251', 'rafael.villalobos@gmail.com'),
(73, 'Andrea', 'Correa', 'Martinez', '74215367', 'F', '964321345', 'andrea.correa@hotmail.com'),
(74, 'Agustin', 'Acosta', 'Sanchez', '75412378', 'M', '964321654', 'agustin.acosta@gmail.com'),
(75, 'Natalia', 'Pizarro', 'Moreno', '76341234', 'F', '987632145', 'natalia.pizarro@gmail.com'),
(76, 'Julian', 'Saez', 'Garcia', '73542178', 'M', '964321843', 'julian.saez@outlook.com'),
(77, 'Angela', 'Fierro', 'Martinez', '75432614', 'F', '987321764', 'angela.fierro@gmail.com'),
(78, 'Maximiliano', 'Zambrano', 'Perez', '74214567', 'M', '964312478', 'maximiliano.zambrano@gmail.com'),
(79, 'Ana', 'Garrido', 'Gomez', '74321567', 'F', '975432134', 'ana.garrido@hotmail.com'),
(80, 'Elias', 'Carrasco', 'Lopez', '73543124', 'M', '964312456', 'elias.carrasco@gmail.com'),
(81, 'Olivia', 'Palacios', 'Diaz', '74326531', 'F', '987321764', 'olivia.palacios@gmail.com'),
(82, 'Rodrigo', 'Peña', 'Soto', '75431465', 'M', '987321435', 'rodrigo.pena@gmail.com'),
(83, 'Emilia', 'Espinoza', 'Garcia', '76234567', 'F', '987321842', 'emilia.espinoza@hotmail.com'),
(84, 'Cristian', 'Lara', 'Mendez', '73542143', 'M', '964321534', 'cristian.lara@gmail.com'),
(85, 'Isidora', 'Vidal', 'Martinez', '75431432', 'F', '987321435', 'isidora.vidal@gmail.com'),
(86, 'Mauricio', 'Moya', 'Sanchez', '73542146', 'M', '975431234', 'mauricio.moya@gmail.com'),
(87, 'Florencia', 'Nunez', 'Perez', '76543231', 'F', '987321456', 'florencia.nunez@outlook.com'),
(88, 'Nicolas', 'Arellano', 'Gomez', '75431245', 'M', '964312345', 'nicolas.arellano@gmail.com'),
(89, 'Amparo', 'Vergara', 'Ramirez', '76325413', 'F', '987321754', 'amparo.vergara@gmail.com'),
(90, 'Ivan', 'Campos', 'Diaz', '73543125', 'M', '964312567', 'ivan.campos@hotmail.com'),
(91, 'Luz', 'Cifuentes', 'Moreno', '74214325', 'F', '987321842', 'luz.cifuentes@gmail.com'),
(92, 'Alexis', 'Araya', 'Soto', '76543231', 'M', '987632145', 'alexis.araya@gmail.com'),
(93, 'Catalina', 'Guerrero', 'Diaz', '75432167', 'F', '964312346', 'catalina.guerrero@outlook.com'),
(94, 'Tomás', 'Cordero', 'Sanchez', '73542154', 'M', '975432145', 'tomas.cordero@gmail.com'),
(95, 'Julieta', 'Riquelme', 'Vega', '74231465', 'F', '987432154', 'julieta.riquelme@gmail.com'),
(96, 'Renato', 'Soto', 'Mora', '75431234', 'M', '964312547', 'renato.soto@hotmail.com'),
(97, 'Belen', 'Salas', 'Cruz', '74231456', 'F', '987654124', 'belen.salas@gmail.com'),
(98, 'Benjamin', 'Vergara', 'Diaz', '76341235', 'M', '987643124', 'benjamin.vergara@gmail.com'),
(99, 'Pia', 'Muñoz', 'Gomez', '73542164', 'F', '964312457', 'pia.munoz@hotmail.com'),
(100, 'Lucas', 'Montenegro', 'Sanchez', '74213476', 'M', '964321754', 'lucas.montenegro@gmail.com'),
(101, 'Alejandro', 'Bravo', 'Navarro', '73451234', 'M', '987654345', 'alejandro.bravo@gmail.com'),
(102, 'Carla', 'Saavedra', 'Ortega', '74672341', 'F', '976543214', 'carla.saavedra@hotmail.com'),
(103, 'Gonzalo', 'Maldonado', 'Pizarro', '73891234', 'M', '934562345', 'gonzalo.maldonado@yahoo.com'),
(104, 'Antonia', 'Villanueva', 'Salazar', '75689123', 'F', '975632156', 'antonia.villanueva@gmail.com'),
(105, 'Cristian', 'Sanchez', 'Cortes', '74856421', 'M', '987654231', 'cristian.sanchez@gmail.com'),
(106, 'Josefa', 'Montero', 'Romero', '75432654', 'F', '964213456', 'josefa.montero@hotmail.com'),
(107, 'Luis', 'Riquelme', 'Guzman', '73451267', 'M', '935674124', 'luis.riquelme@gmail.com'),
(108, 'Valeria', 'Lagos', 'Palma', '74561234', 'F', '976543267', 'valeria.lagos@yahoo.com'),
(109, 'Joaquin', 'Pizarro', 'Tapia', '76341235', 'M', '964231654', 'joaquin.pizarro@gmail.com'),
(110, 'Daniel', 'Leiva', 'Gutierrez', '75432176', 'M', '987632143', 'daniel.leiva@hotmail.com'),
(111, 'Renata', 'Espinosa', 'Carrillo', '76451235', 'F', '975321456', 'renata.espinosa@gmail.com'),
(112, 'Ignacio', 'Fierro', 'Nunez', '76543217', 'M', '964321675', 'ignacio.fierro@yahoo.com'),
(113, 'Claudia', 'Pena', 'Hernandez', '73654123', 'F', '976543287', 'claudia.pena@gmail.com'),
(114, 'Martin', 'Cardenas', 'Campos', '74312654', 'M', '975432123', 'martin.cardenas@hotmail.com'),
(115, 'Camila', 'Cabrera', 'Garcia', '76543231', 'F', '987641256', 'camila.cabrera@gmail.com'),
(116, 'Diego', 'Jimenez', 'Farias', '73542134', 'M', '964213657', 'diego.jimenez@hotmail.com'),
(117, 'Trinidad', 'Aravena', 'Solis', '75643121', 'F', '975643216', 'trinidad.aravena@gmail.com'),
(118, 'Benjamin', 'Rios', 'Alvarez', '75431234', 'M', '987641234', 'benjamin.rios@gmail.com'),
(119, 'Catalina', 'Gutierrez', 'Morales', '74213487', 'F', '964213754', 'catalina.gutierrez@gmail.com'),
(120, 'Vicente', 'Reyes', 'Gomez', '74651235', 'M', '975432168', 'vicente.reyes@hotmail.com'),
(121, 'Laura', 'Muñoz', 'Rojas', '75432189', 'F', '976543298', 'laura.munoz@yahoo.com'),
(122, 'Emilio', 'Olivares', 'Mora', '74351234', 'M', '987654312', 'emilio.olivares@gmail.com'),
(123, 'Sofia', 'Tapia', 'Riveros', '74561234', 'F', '976543217', 'sofia.tapia@gmail.com'),
(124, 'Juan', 'Carrasco', 'Pizarro', '75643125', 'M', '964213456', 'juan.carrasco@gmail.com'),
(125, 'Gabriela', 'Riquelme', 'Vega', '73654125', 'F', '975432178', 'gabriela.riquelme@hotmail.com'),
(126, 'Cristobal', 'Soto', 'Palacios', '73451289', 'M', '935674512', 'cristobal.soto@yahoo.com'),
(127, 'Elisa', 'Vargas', 'Montes', '76543256', 'F', '976543267', 'elisa.vargas@gmail.com'),
(128, 'Leonardo', 'Salinas', 'Ramirez', '74351289', 'M', '987651243', 'leonardo.salinas@gmail.com'),
(129, 'Maite', 'Gutierrez', 'Vera', '75431245', 'F', '964213567', 'maite.gutierrez@hotmail.com'),
(130, 'Rodrigo', 'Paredes', 'Oliva', '74651289', 'M', '975432134', 'rodrigo.paredes@gmail.com'),
(131, 'Camilo', 'Gonzalez', 'Perez', '75643187', 'M', '987651234', 'camilo.gonzalez@yahoo.com'),
(132, 'Francisca', 'Cifuentes', 'Martinez', '75432176', 'F', '964213754', 'francisca.cifuentes@gmail.com'),
(133, 'Javier', 'Mora', 'Hernandez', '74351254', 'M', '975643216', 'javier.mora@gmail.com'),
(134, 'Martina', 'Morales', 'Soto', '76543234', 'F', '987651276', 'martina.morales@hotmail.com'),
(135, 'Vicente', 'Alvarez', 'Guzman', '73654123', 'M', '976543267', 'vicente.alvarez@gmail.com'),
(136, 'Emilia', 'Araya', 'Pizarro', '74351234', 'F', '975643218', 'emilia.araya@gmail.com'),
(137, 'Felipe', 'Zapata', 'Carrasco', '75432165', 'M', '987654216', 'felipe.zapata@gmail.com'),
(138, 'Jose', 'Ortega', 'Moreno', '75643125', 'M', '975432145', 'jose.ortega@hotmail.com'),
(139, 'Amanda', 'Fuentes', 'Reyes', '73451237', 'F', '964213587', 'amanda.fuentes@gmail.com'),
(140, 'Matias', 'Lara', 'Lopez', '74651245', 'M', '987654134', 'matias.lara@gmail.com'),
(141, 'Valentina', 'Pena', 'Cruz', '75432154', 'F', '975643276', 'valentina.pena@hotmail.com'),
(142, 'Lucas', 'Vega', 'Saez', '73654128', 'M', '964213876', 'lucas.vega@gmail.com'),
(143, 'Ignacia', 'Mendez', 'Soto', '74351298', 'F', '975432154', 'ignacia.mendez@yahoo.com'),
(144, 'Joaquin', 'Leiva', 'Garcia', '76543247', 'M', '987654321', 'joaquin.leiva@gmail.com'),
(145, 'Monica', 'Salinas', 'Ortiz', '75431298', 'F', '975643265', 'monica.salinas@hotmail.com'),
(146, 'Sebastian', 'Guzman', 'Espinoza', '75643124', 'M', '976543289', 'sebastian.guzman@gmail.com'),
(147, 'Ana', 'Herrera', 'Gutierrez', '74351276', 'F', '975643218', 'ana.herrera@gmail.com'),
(148, 'Cristobal', 'Navarro', 'Campos', '73451249', 'M', '935674123', 'cristobal.navarro@gmail.com'),
(149, 'Isabella', 'Garrido', 'Pizarro', '76543267', 'F', '987654321', 'isabella.garrido@gmail.com'),
(150, 'Elias', 'Castro', 'Cortes', '74351267', 'M', '964213789', 'elias.castro@gmail.com');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asistencia_alumno`
--

CREATE TABLE `asistencia_alumno` (
  `id_asis_alu` int(11) NOT NULL,
  `id_curso_prof` int(11) DEFAULT NULL,
  `id_alumno` int(11) DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  `hora_marcacion` time DEFAULT NULL,
  `asistio` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `curso`
--

CREATE TABLE `curso` (
  `id_Curso` int(11) NOT NULL,
  `nombre_curso` varchar(60) DEFAULT NULL,
  `horas` int(11) DEFAULT NULL,
  `creditos` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `curso`
--

INSERT INTO `curso` (`id_Curso`, `nombre_curso`, `horas`, `creditos`) VALUES
(1, 'Matematica', 6, 4),
(2, 'Computación', 2, 4),
(3, 'Fisica', 4, 5),
(4, 'Ingles', 2, 3),
(5, 'Educación Cívica', 2, 3),
(6, 'Comunicación', 2, 3),
(7, 'Literatura', 2, 3),
(8, 'Quimica General', 2, 4),
(9, 'CTA', 2, 4),
(10, 'Religion', 2, 3),
(11, 'Ciencias Sociales', 4, 4),
(12, 'Arte', 2, 3),
(13, 'Musica', 4, 6),
(14, 'Educación Fisica', 4, 4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `curso_profesor`
--

CREATE TABLE `curso_profesor` (
  `id_curso_prof` int(11) NOT NULL,
  `id_seccion` int(11) DEFAULT NULL,
  `id_curso` int(11) DEFAULT NULL,
  `id_profesor` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `curso_profesor`
--

INSERT INTO `curso_profesor` (`id_curso_prof`, `id_seccion`, `id_curso`, `id_profesor`) VALUES
(1, 1, 1, 1),
(2, 1, 3, 1),
(3, 1, 2, 2),
(4, 1, 4, 3),
(5, 1, 5, 3),
(6, 1, 10, 3),
(7, 1, 6, 4),
(8, 1, 7, 4),
(9, 1, 8, 5),
(10, 1, 9, 5),
(11, 1, 12, 6),
(12, 1, 13, 6),
(13, 2, 1, 1),
(14, 2, 3, 1),
(15, 2, 2, 2),
(16, 2, 4, 3),
(18, 2, 10, 3),
(19, 2, 6, 4),
(20, 2, 7, 4),
(21, 2, 8, 5),
(22, 2, 9, 5),
(23, 2, 12, 6),
(24, 2, 13, 6),
(25, 3, 2, 1),
(26, 3, 3, 1),
(27, 3, 1, 2),
(29, 3, 6, 4),
(30, 3, 7, 4),
(32, 5, 12, 6),
(33, 5, 13, 6),
(34, 5, 1, 1),
(35, 5, 3, 1),
(36, 6, 2, 2),
(37, 6, 5, 3),
(42, 6, 13, 6);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `grado`
--

CREATE TABLE `grado` (
  `id_grado` int(11) NOT NULL,
  `nivel` varchar(20) DEFAULT NULL,
  `nro` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `grado`
--

INSERT INTO `grado` (`id_grado`, `nivel`, `nro`) VALUES
(1, 'Primaria', 1),
(2, 'Primaria', 2),
(3, 'Primaria', 3),
(4, 'Primaria', 4),
(5, 'Primaria', 5),
(6, 'Primaria', 6);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `grupo_seccion`
--

CREATE TABLE `grupo_seccion` (
  `id_grupo_seccion` int(11) NOT NULL,
  `id_alumno` int(11) DEFAULT NULL,
  `id_seccion` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `grupo_seccion`
--

INSERT INTO `grupo_seccion` (`id_grupo_seccion`, `id_alumno`, `id_seccion`) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 3, 1),
(4, 4, 1),
(5, 5, 1),
(6, 6, 1),
(7, 7, 1),
(8, 8, 1),
(9, 9, 1),
(10, 10, 1),
(11, 11, 1),
(12, 12, 1),
(13, 13, 1),
(14, 14, 1),
(15, 15, 1),
(16, 16, 1),
(17, 17, 1),
(18, 18, 1),
(19, 19, 1),
(20, 20, 1),
(21, 21, 1),
(22, 22, 1),
(23, 23, 1),
(24, 24, 1),
(25, 25, 1),
(26, 26, 2),
(27, 27, 2),
(28, 28, 2),
(29, 29, 2),
(30, 30, 2),
(31, 31, 2),
(32, 32, 2),
(33, 33, 2),
(34, 34, 2),
(35, 35, 2),
(36, 36, 2),
(37, 37, 2),
(38, 38, 2),
(39, 39, 2),
(40, 40, 2),
(41, 41, 2),
(42, 42, 2),
(43, 43, 2),
(44, 44, 2),
(45, 45, 2),
(46, 46, 2),
(47, 47, 2),
(48, 48, 2),
(49, 49, 2),
(50, 50, 2),
(51, 51, 3),
(52, 52, 3),
(53, 53, 3),
(54, 54, 3),
(55, 55, 3),
(56, 56, 3),
(57, 57, 3),
(58, 58, 3),
(59, 59, 3),
(60, 60, 3),
(61, 61, 3),
(62, 62, 3),
(63, 63, 3),
(64, 64, 3),
(65, 65, 3),
(66, 66, 3),
(67, 67, 3),
(68, 68, 3),
(69, 69, 3),
(70, 70, 3),
(71, 71, 3),
(72, 72, 3),
(73, 73, 3),
(74, 74, 3),
(75, 75, 3),
(76, 76, 4),
(77, 77, 4),
(78, 78, 4),
(79, 79, 4),
(80, 80, 4),
(81, 81, 4),
(82, 82, 4),
(83, 83, 4),
(84, 84, 4),
(85, 85, 4),
(86, 86, 4),
(87, 87, 4),
(88, 88, 4),
(89, 89, 4),
(90, 90, 4),
(91, 91, 4),
(92, 92, 4),
(93, 93, 4),
(94, 94, 4),
(95, 95, 4),
(96, 96, 4),
(97, 97, 4),
(98, 98, 4),
(99, 99, 4),
(100, 100, 4),
(101, 101, 5),
(102, 102, 5),
(103, 103, 5),
(104, 104, 5),
(105, 105, 5),
(106, 106, 5),
(107, 107, 5),
(108, 108, 5),
(109, 109, 5),
(110, 110, 5),
(111, 111, 5),
(112, 112, 5),
(113, 113, 5),
(114, 114, 5),
(115, 115, 5),
(116, 116, 5),
(117, 117, 5),
(118, 118, 5),
(119, 119, 5),
(120, 120, 5),
(121, 121, 5),
(122, 122, 5),
(123, 123, 5),
(124, 124, 5),
(125, 125, 5),
(126, 126, 6),
(127, 127, 6),
(128, 128, 6),
(129, 129, 6),
(130, 130, 6),
(131, 131, 6),
(132, 132, 6),
(133, 133, 6),
(134, 134, 6),
(135, 135, 6),
(136, 136, 6),
(137, 137, 6),
(138, 138, 6),
(139, 139, 6),
(140, 140, 6),
(141, 141, 6),
(142, 142, 6),
(143, 143, 6),
(144, 144, 6),
(145, 145, 6),
(146, 146, 6),
(147, 147, 6),
(148, 148, 6),
(149, 149, 6),
(150, 150, 6);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `horario_curso`
--

CREATE TABLE `horario_curso` (
  `id_horario` int(11) NOT NULL,
  `id_curso_prof` int(11) DEFAULT NULL,
  `dia_semana` varchar(50) DEFAULT NULL,
  `hora_inicio` time DEFAULT NULL,
  `hora_fin` time DEFAULT NULL,
  `nro_dia` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `horario_curso`
--

INSERT INTO `horario_curso` (`id_horario`, `id_curso_prof`, `dia_semana`, `hora_inicio`, `hora_fin`, `nro_dia`) VALUES
(1, 1, 'Martes', '08:00:00', '09:30:00', 2),
(2, 1, 'Miercoles', '09:45:00', '11:15:00', 3),
(3, 1, 'Viernes', '08:00:00', '09:30:00', 5),
(4, 2, 'Lunes', '08:00:00', '09:30:00', 1),
(5, 2, 'Martes', '11:30:00', '13:00:00', 2),
(6, 3, 'Lunes', '09:45:00', '11:15:00', 1),
(7, 4, 'Lunes', '11:30:00', '13:00:00', 1),
(8, 5, 'Miercoles', '11:30:00', '13:00:00', 3),
(9, 6, 'Miercoles', '08:00:00', '09:30:00', 3),
(10, 7, 'Jueves', '08:00:00', '09:30:00', 4),
(11, 8, 'Jueves', '09:45:00', '11:15:00', 4),
(12, 9, 'Jueves', '11:30:00', '13:00:00', 4),
(13, 10, 'Viernes', '09:45:00', '11:15:00', 5),
(14, 11, 'Viernes', '11:30:00', '13:00:00', 5),
(15, 12, 'Sabado', '08:00:00', '11:15:00', 6),
(16, 13, 'Lunes', '09:45:00', '11:15:00', 1),
(17, 14, 'Miercoles', '08:00:00', '09:30:00', 3),
(18, 15, 'Jueves', '11:30:00', '13:00:00', 4),
(19, 16, 'Viernes', '09:45:00', '11:15:00', 5),
(21, 18, 'Lunes', '08:00:00', '09:30:00', 1),
(22, 19, 'Lunes', '11:30:00', '13:00:00', 1),
(23, 20, 'Martes', '08:00:00', '09:30:00', 2),
(24, 21, 'Martes', '11:30:00', '13:00:00', 2),
(25, 22, 'Miercoles', '09:45:00', '11:15:00', 3),
(26, 23, 'Viernes', '08:00:00', '09:30:00', 5),
(27, 24, 'Sabado', '08:00:00', '09:30:00', 6),
(28, 25, 'Sabado', '09:45:00', '11:15:00', 6),
(29, 26, 'Jueves', '08:00:00', '09:30:00', 4),
(30, 27, 'Jueves', '09:45:00', '11:15:00', 4),
(31, 34, 'Viernes', '11:30:00', '13:00:00', 5),
(32, 35, 'Martes', '09:45:00', '11:15:00', 2),
(33, 36, 'Martes', '09:45:00', '11:15:00', 2),
(35, 37, 'Jueves', '08:00:00', '09:30:00', 4),
(36, 29, 'Viernes', '08:00:00', '09:30:00', 5),
(37, 30, 'Viernes', '09:45:00', '11:15:00', 5),
(38, 32, 'Viernes', '09:45:00', '11:15:00', 5),
(39, 33, 'Lunes', '09:45:00', '11:15:00', 1),
(40, 42, 'Miercoles', '09:45:00', '11:15:00', 3);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `nota`
--

CREATE TABLE `nota` (
  `id_nota` int(11) NOT NULL,
  `id_curso_Prof` int(11) DEFAULT NULL,
  `id_alumno` int(11) DEFAULT NULL,
  `nota_1` int(11) DEFAULT NULL,
  `nota_2` int(11) DEFAULT NULL,
  `nota_3` int(11) DEFAULT NULL,
  `nota_4` int(11) DEFAULT NULL,
  `ex_final` int(11) DEFAULT NULL,
  `promedio` decimal(8,2) GENERATED ALWAYS AS ((`nota_1` + `nota_2` + `nota_3` + `nota_4` + `ex_final`) / 5) STORED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `periodo_lectivo`
--

CREATE TABLE `periodo_lectivo` (
  `id_periodo` int(11) NOT NULL,
  `nombre_periodo` varchar(50) DEFAULT NULL,
  `vigente` int(11) DEFAULT NULL,
  `fecha_inicio` date DEFAULT NULL,
  `fecha_fin` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `periodo_lectivo`
--

INSERT INTO `periodo_lectivo` (`id_periodo`, `nombre_periodo`, `vigente`, `fecha_inicio`, `fecha_fin`) VALUES
(1, '2024', 1, '2024-03-01', '2024-12-23');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `profesor`
--

CREATE TABLE `profesor` (
  `Id_Profesor` int(11) NOT NULL,
  `nombres` varchar(60) DEFAULT NULL,
  `apellido_Paterno` varchar(60) DEFAULT NULL,
  `apellido_Materno` varchar(60) DEFAULT NULL,
  `tipo_documento` varchar(60) DEFAULT NULL,
  `nro_documento` varchar(15) DEFAULT NULL,
  `Fecha_Nac` date DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `profesor`
--

INSERT INTO `profesor` (`Id_Profesor`, `nombres`, `apellido_Paterno`, `apellido_Materno`, `tipo_documento`, `nro_documento`, `Fecha_Nac`, `id_usuario`) VALUES
(1, 'Andres', 'Rojas', 'Cruz', 'DNI', '89641258', '1991-02-12', 1),
(2, 'Edgard', 'Moreno', 'Cueva', 'DNI', '74512368', '1992-12-11', 2),
(3, 'Sergio', 'Garcia', 'Angulo', 'DNI', '84512658', '1993-05-24', 3),
(4, 'Marco', 'Vizcarra', 'Gomez', 'DNI', '78451265', '1994-06-27', 4),
(5, 'Nicanor', 'Paucar', 'Guevara', 'DNI', '25698452', '1991-07-13', 5),
(6, 'Jaime', 'Jimenez', 'Cruz', 'DNI', '89641258', '1991-02-12', 6),
(7, 'Paulo', 'Peralta', 'Martinez', 'DNI', '10269826', '1992-12-11', 7),
(8, 'Luciana', 'Santisteban', 'Peralta', 'DNI', '10025486', '1993-05-24', 8),
(9, 'Dayana', 'Fernandez', 'Alama', 'DNI', '10236985', '1994-06-27', 9),
(10, 'Maria', 'Palacios', 'Aguilar', 'DNI', '10102348', '1991-07-13', 10);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol`
--

CREATE TABLE `rol` (
  `id_rol` int(11) NOT NULL,
  `nom_rol` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `rol`
--

INSERT INTO `rol` (`id_rol`, `nom_rol`) VALUES
(1, 'Profesor');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `seccion`
--

CREATE TABLE `seccion` (
  `id_seccion` int(11) NOT NULL,
  `id_grado` int(11) DEFAULT NULL,
  `id_periodo` int(11) DEFAULT NULL,
  `letra` char(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `seccion`
--

INSERT INTO `seccion` (`id_seccion`, `id_grado`, `id_periodo`, `letra`) VALUES
(1, 3, 1, 'A'),
(2, 3, 1, 'B'),
(3, 4, 1, 'A'),
(4, 5, 1, 'B'),
(5, 6, 1, 'A'),
(6, 6, 1, 'B');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id_usuario` int(11) NOT NULL,
  `id_Rol` int(11) DEFAULT NULL,
  `correo` varchar(60) DEFAULT NULL,
  `password` varchar(200) DEFAULT NULL,
  `estado` tinyint(1) DEFAULT NULL,
  `fecha_registro` datetime DEFAULT current_timestamp(),
  `foto` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id_usuario`, `id_Rol`, `correo`, `password`, `estado`, `fecha_registro`, `foto`) VALUES
(1, 1, 'c1624514@sm.edu.pe', '123456', 1, '2024-10-19 19:02:39', '1.jpg'),
(2, 1, 'c1624515@sm.edu.pe', '123456', 1, '2024-10-19 19:02:39', '2.jpg'),
(3, 1, 'c1624516@sm.edu.pe', '123456', 1, '2024-10-19 19:02:39', '3.jpg'),
(4, 1, 'c1624517@sm.edu.pe', '123456', 1, '2024-10-19 19:02:39', '4.jpg'),
(5, 1, 'c1624518@sm.edu.pe', '123456', 1, '2024-10-19 19:02:39', '5.jpg'),
(6, 1, 'c1624519@sm.edu.pe', '123456', 1, '2024-10-19 19:02:39', '6.jpg'),
(7, 1, 'c1624520@sm.edu.pe', '123456', 1, '2024-10-19 19:02:39', '7.jpg'),
(8, 1, 'c1624521@sm.edu.pe', '123456', 1, '2024-10-19 19:02:39', '8.jpg'),
(9, 1, 'c1624528@sm.edu.pe', '123456', 1, '2024-10-19 19:02:39', '9.jpg'),
(10, 1, 'c1624544@sm.edu.pe', '123456', 1, '2024-10-19 19:02:39', '10.jpg');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `alumno`
--
ALTER TABLE `alumno`
  ADD PRIMARY KEY (`id_alumno`);

--
-- Indices de la tabla `asistencia_alumno`
--
ALTER TABLE `asistencia_alumno`
  ADD PRIMARY KEY (`id_asis_alu`),
  ADD KEY `id_curso_prof` (`id_curso_prof`),
  ADD KEY `id_alumno` (`id_alumno`);

--
-- Indices de la tabla `curso`
--
ALTER TABLE `curso`
  ADD PRIMARY KEY (`id_Curso`);

--
-- Indices de la tabla `curso_profesor`
--
ALTER TABLE `curso_profesor`
  ADD PRIMARY KEY (`id_curso_prof`),
  ADD KEY `id_curso` (`id_curso`),
  ADD KEY `id_seccion` (`id_seccion`),
  ADD KEY `id_profesor` (`id_profesor`);

--
-- Indices de la tabla `grado`
--
ALTER TABLE `grado`
  ADD PRIMARY KEY (`id_grado`);

--
-- Indices de la tabla `grupo_seccion`
--
ALTER TABLE `grupo_seccion`
  ADD PRIMARY KEY (`id_grupo_seccion`),
  ADD KEY `id_alumno` (`id_alumno`),
  ADD KEY `id_seccion` (`id_seccion`);

--
-- Indices de la tabla `horario_curso`
--
ALTER TABLE `horario_curso`
  ADD PRIMARY KEY (`id_horario`),
  ADD KEY `id_curso_prof` (`id_curso_prof`);

--
-- Indices de la tabla `nota`
--
ALTER TABLE `nota`
  ADD PRIMARY KEY (`id_nota`),
  ADD KEY `notas_ibfk_1` (`id_curso_Prof`),
  ADD KEY `notas_ibfk_2` (`id_alumno`);

--
-- Indices de la tabla `periodo_lectivo`
--
ALTER TABLE `periodo_lectivo`
  ADD PRIMARY KEY (`id_periodo`);

--
-- Indices de la tabla `profesor`
--
ALTER TABLE `profesor`
  ADD PRIMARY KEY (`Id_Profesor`),
  ADD KEY `Id_usuario` (`id_usuario`);

--
-- Indices de la tabla `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`id_rol`),
  ADD UNIQUE KEY `nom_rol` (`nom_rol`);

--
-- Indices de la tabla `seccion`
--
ALTER TABLE `seccion`
  ADD PRIMARY KEY (`id_seccion`),
  ADD KEY `id_grado` (`id_grado`),
  ADD KEY `id_periodo` (`id_periodo`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `correo` (`correo`),
  ADD KEY `id_Rol` (`id_Rol`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `alumno`
--
ALTER TABLE `alumno`
  MODIFY `id_alumno` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=151;

--
-- AUTO_INCREMENT de la tabla `asistencia_alumno`
--
ALTER TABLE `asistencia_alumno`
  MODIFY `id_asis_alu` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `curso`
--
ALTER TABLE `curso`
  MODIFY `id_Curso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `curso_profesor`
--
ALTER TABLE `curso_profesor`
  MODIFY `id_curso_prof` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT de la tabla `grado`
--
ALTER TABLE `grado`
  MODIFY `id_grado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `grupo_seccion`
--
ALTER TABLE `grupo_seccion`
  MODIFY `id_grupo_seccion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=151;

--
-- AUTO_INCREMENT de la tabla `horario_curso`
--
ALTER TABLE `horario_curso`
  MODIFY `id_horario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT de la tabla `nota`
--
ALTER TABLE `nota`
  MODIFY `id_nota` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `periodo_lectivo`
--
ALTER TABLE `periodo_lectivo`
  MODIFY `id_periodo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `profesor`
--
ALTER TABLE `profesor`
  MODIFY `Id_Profesor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `seccion`
--
ALTER TABLE `seccion`
  MODIFY `id_seccion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `asistencia_alumno`
--
ALTER TABLE `asistencia_alumno`
  ADD CONSTRAINT `asistencia_alumno_ibfk_1` FOREIGN KEY (`id_curso_prof`) REFERENCES `curso_profesor` (`id_curso_prof`),
  ADD CONSTRAINT `asistencia_alumno_ibfk_2` FOREIGN KEY (`id_alumno`) REFERENCES `alumno` (`id_alumno`);

--
-- Filtros para la tabla `curso_profesor`
--
ALTER TABLE `curso_profesor`
  ADD CONSTRAINT `curso_profesor_ibfk_1` FOREIGN KEY (`id_curso`) REFERENCES `curso` (`id_Curso`),
  ADD CONSTRAINT `curso_profesor_ibfk_2` FOREIGN KEY (`id_seccion`) REFERENCES `seccion` (`id_seccion`),
  ADD CONSTRAINT `curso_profesor_ibfk_3` FOREIGN KEY (`id_profesor`) REFERENCES `profesor` (`Id_Profesor`);

--
-- Filtros para la tabla `grupo_seccion`
--
ALTER TABLE `grupo_seccion`
  ADD CONSTRAINT `grupo_ibfk_1` FOREIGN KEY (`id_alumno`) REFERENCES `alumno` (`id_alumno`),
  ADD CONSTRAINT `grupo_ibfk_2` FOREIGN KEY (`id_seccion`) REFERENCES `seccion` (`id_seccion`);

--
-- Filtros para la tabla `horario_curso`
--
ALTER TABLE `horario_curso`
  ADD CONSTRAINT `horario_curso_ibfk_1` FOREIGN KEY (`id_curso_prof`) REFERENCES `curso_profesor` (`id_curso_prof`);

--
-- Filtros para la tabla `nota`
--
ALTER TABLE `nota`
  ADD CONSTRAINT `notas_ibfk_1` FOREIGN KEY (`id_curso_Prof`) REFERENCES `curso_profesor` (`id_curso_prof`),
  ADD CONSTRAINT `notas_ibfk_2` FOREIGN KEY (`id_alumno`) REFERENCES `alumno` (`id_alumno`);

--
-- Filtros para la tabla `profesor`
--
ALTER TABLE `profesor`
  ADD CONSTRAINT `profesor_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `seccion`
--
ALTER TABLE `seccion`
  ADD CONSTRAINT `seccion_ibfk_1` FOREIGN KEY (`id_grado`) REFERENCES `grado` (`id_grado`),
  ADD CONSTRAINT `seccion_ibfk_2` FOREIGN KEY (`id_periodo`) REFERENCES `periodo_lectivo` (`id_periodo`);

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `usuario_ibfk_1` FOREIGN KEY (`id_Rol`) REFERENCES `rol` (`id_rol`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
