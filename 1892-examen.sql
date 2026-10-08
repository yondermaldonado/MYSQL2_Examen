-- base de datos que vamos a usar
USE coworking_db;

-- verifica si existe la tabla
DROP TABLE IF EXISTS reservas_externas;

-- crea la tabla
CREATE TABLE reservas_externas (
    id_reserva_externa INT AUTO_INCREMENT PRIMARY KEY,
    plataforma         ENUM('Airbnb','Meetup') NOT NULL,
    fecha_reserva      DATETIME    NOT NULL,
    id_espacio         INT         NOT NULL,
    usuario_externo    VARCHAR(100) NOT NULL,
    duracion           INT         NOT NULL,   -- duración en horas
    CONSTRAINT fk_reserva_externa_espacio FOREIGN KEY (id_espacio)
        REFERENCES espacio (id_espacio)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_duracion_reserva_externa CHECK (duracion > 0)
) ENGINE = InnoDB CHARSET = utf8mb4;

-- verifica si existe el procedimiento
DROP PROCEDURE IF EXISTS sp_importar_reserva_externa;

DELIMITER $$
-- crea el procedimiento
CREATE PROCEDURE sp_importar_reserva_externa(
    IN  p_id_reserva_externa INT , -- entrada
    OUT p_reserva_que_se_creo INT) -- salida
BEGIN
-- declaramos variables
    DECLARE v_fecha_inicio    DATETIME;
    DECLARE v_fecha_fin       DATETIME;
    DECLARE v_id_espacio      INT;
    DECLARE v_usuario_externo VARCHAR(60);
    DECLARE v_duracion        INT;
    DECLARE v_estado_espacio  VARCHAR(20);
    DECLARE v_id_usuario      INT;

    -- revisa que la reserva externa exista
    IF NOT EXISTS (SELECT 1
                     FROM reservas_externas AS rex
                    WHERE rex.id_reserva_externa = p_id_reserva_externa) THEN
        SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'La reserva externa no existe';
    END IF;

    -- traer los datos de la reserva externa
    SELECT rex.fecha_reserva, rex.id_espacio, rex.usuario_externo, rex.duracion
      INTO v_fecha_inicio, v_id_espacio, v_usuario_externo, v_duracion
      FROM reservas_externas AS rex
     WHERE rex.id_reserva_externa = p_id_reserva_externa;

    -- calcular la hora en que termina la reserva
    SET v_fecha_fin = v_fecha_inicio + INTERVAL v_duracion HOUR;

    -- revisar que el espacio este disponible
    SELECT esp.estado
      INTO v_estado_espacio
      FROM espacio AS esp
     WHERE esp.id_espacio = v_id_espacio;

    IF v_estado_espacio <> 'Disponible' THEN
        SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'El espacio no esta disponible';
    END IF;

    -- revisar que no choque con otra reserva del mismo espacio
    IF EXISTS (SELECT 1
                 FROM reserva AS res
                WHERE res.id_espacio   = v_id_espacio
                  AND res.estado NOT IN ('Cancelada', 'Liberada')
                  AND res.fecha_inicio < v_fecha_fin
                  AND res.fecha_fin    > v_fecha_inicio) THEN
        SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'Hay conflicto de horario con otra reserva';
    END IF;

    -- se buscar el usuario temporal
    SELECT usu.id_usuario
      INTO v_id_usuario
      FROM usuario AS usu
     WHERE usu.nombre    = v_usuario_externo
       AND usu.apellidos = 'Externo'
     LIMIT 1;

    -- si no existe lo crea
    IF v_id_usuario IS NULL THEN
        INSERT INTO usuario (documento, nombre, apellidos, fecha_nacimiento)
        VALUES (CONCAT('EXT-', p_id_reserva_externa), v_usuario_externo, 'Externo', '1900-01-01');

        SET v_id_usuario = LAST_INSERT_ID();
    END IF;

    -- 8. Crear la reserva interna
    INSERT INTO reserva (id_usuario, id_espacio, fecha_inicio, fecha_fin, estado)
    VALUES (v_id_usuario, v_id_espacio, v_fecha_inicio, v_fecha_fin, 'Confirmada');

    -- 9. Devolver el id de la reserva creada
    SET p_reserva_que_se_creo = LAST_INSERT_ID();
END $$

DELIMITER ;

INSERT INTO reservas_externas (plataforma, fecha_reserva, id_espacio, usuario_externo, duracion)
VALUES
('Airbnb', '2026-10-20 09:00:00',  3, 'Carlos Mendoza', 3),
('Meetup', '2026-10-21 14:00:00', 11, 'Laura Perez',    2),
('Airbnb', '2026-10-22 08:00:00', 14, 'Andrea Gomez',   5),
('Meetup', '2026-10-23 10:00:00',  8, 'Carlos Mendoza', 4),
('Meetup', '2026-10-12 10:00:00',  7, 'Pedro Ruiz',     2),
('Airbnb', '2026-10-24 09:00:00',  6, 'Sofia Torres',   3);

CALL sp_importar_reserva_externa(1, @nueva_reserva);
SELECT @nueva_reserva;