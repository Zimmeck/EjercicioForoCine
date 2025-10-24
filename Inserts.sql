SET FOREIGN_KEY_CHECKS=0;

-- 1. Carga de tablas principales (sin dependencias)
LOAD DATA LOCAL INFILE 'C:\\DAM\\AAD\\EjercicioForoCine\\RegistrosCSV\\ACTOR.csv' INTO TABLE ACTOR FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'C:\\DAM\\AAD\\EjercicioForoCine\\RegistrosCSV\\DIRECTOR.csv' INTO TABLE DIRECTOR FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'C:\\DAM\\AAD\\EjercicioForoCine\\RegistrosCSV\\GUIONISTA.csv' INTO TABLE GUIONISTA FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;

-- CORRECCIÓN CRÍTICA PARA USUARIO: Corrige el SWAP y aplica la limpieza al email (PK)
LOAD DATA LOCAL INFILE 'C:\\DAM\\AAD\\EjercicioForoCine\\RegistrosCSV\\USUARIO.csv' 
INTO TABLE USUARIO 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS
(@email_value, @name_value) 
SET 
    nombre_usuario = @name_value, -- Asigna el valor del nombre
    email = TRIM(REPLACE(@email_value, '\r', '')); -- Asigna el email con limpieza

LOAD DATA LOCAL INFILE 'C:\\DAM\\AAD\\EjercicioForoCine\\RegistrosCSV\\PELICULA.csv' INTO TABLE PELICULA FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'C:\\DAM\\AAD\\EjercicioForoCine\\RegistrosCSV\\PLATAFORMA.csv' INTO TABLE PLATAFORMA FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'C:\\DAM\\AAD\\EjercicioForoCine\\RegistrosCSV\\GRUPO.csv' INTO TABLE GRUPO FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'C:\\DAM\\AAD\\EjercicioForoCine\\RegistrosCSV\\PERSONAJE.csv'  INTO TABLE PERSONAJE FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n'  IGNORE 1 ROWS
(@id, @nombre, @valor_identidad, @valor_descripcion) 
SET
    id_personaje = @id,
    nombre_personaje = @nombre,
    descripcion = NULLIF(@valor_descripcion, ''),
    identidad_humana = NULLIF(@valor_identidad, '');

-- REEMPLAZA el comando LOAD DATA para VALORACION en Insrets.sql
LOAD DATA LOCAL INFILE 'C:\\DAM\\AAD\\EjercicioForoCine\\RegistrosCSV\\VALORACION.csv' 
INTO TABLE VALORACION
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS
(@idValoracion, @emailUsuario, @idPelicula, @puntuacion)
SET
    id_valoracion = @idValoracion,
    id_pelicula = @idPelicula,
    puntuacion = @puntuacion,
    email_usuario = TRIM(REPLACE(@emailUsuario, '\r', ''));

LOAD DATA LOCAL INFILE 'C:\\DAM\\AAD\\EjercicioForoCine\\RegistrosCSV\\COMENTARIO.csv' 
INTO TABLE COMENTARIO
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS
(@id_comentario, @id_valoracion_csv, @email_usuario_csv, @id_pelicula_csv, @texto_csv, @fecha_csv) 
SET
    id_comentario = @id_comentario,
    id_valoracion = NULLIF(@id_valoracion_csv, 'NULL'), 
    email_usuario = TRIM(REPLACE(@email_usuario_csv, '\r', '')),
    id_pelicula = @id_pelicula_csv,
    texto = @texto_csv,
    fecha = IF(@fecha_csv = 'NULL' OR @fecha_csv = '', CURRENT_TIMESTAMP, STR_TO_DATE(@fecha_csv, '%Y-%m-%d %H:%i:%s')); -- Ajusta formato si es necesario

-- ELIMINA las líneas que definen @current_disp_id, @disp_offset, @last_disp_id, @row_count, @first_disp_id, etc.
-- Usa solo esta lógica simple y segura:

SET @id_disp_simulado = 0; -- Reinicia el contador para simular el AUTO_INCREMENT

-- CORRECCIÓN PARA DISPONIBILIDAD (Elimina la línea del contador simulado)
TRUNCATE TABLE DISPONIBILIDAD; 
LOAD DATA LOCAL INFILE 'C:\\DAM\\AAD\\EjercicioForoCine\\RegistrosCSV\\DISPONIBILIDAD_sin_duplicados.csv' 
INTO TABLE DISPONIBILIDAD
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS
-- Lee las 4 columnas del CSV
(@idPelicula_csv, @idPlataforma_csv, @precio_csv, @fechaAlta_csv) 
SET
    id_pelicula = @idPelicula_csv, 
    id_plataforma = @idPlataforma_csv, 
    fecha_inicio = @fechaAlta_csv, 
    fecha_fin = NULL; 
    -- id_disponibilidad se genera automáticamente por AUTO_INCREMENT

-- PASO 2: CARGA PRECIO
LOAD DATA LOCAL INFILE 'C:\\DAM\\AAD\\EjercicioForoCine\\RegistrosCSV\\DISPONIBILIDAD_sin_duplicados.csv' 
INTO TABLE PRECIO
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS
(@idPelicula_csv, @idPlataforma_csv, @precio_csv, @fechaAlta_csv) 
SET
    -- Usa el contador simulado para la FK y genera la PK con otro contador
    id_disponibilidad = (@id_disp_simulado := @id_disp_simulado + 1),
    id_precio = (@id_precio_simulado := @id_precio_simulado + 1), 
    valor = @precio_csv,         
    fecha_vigencia = @fechaAlta_csv;


LOAD DATA LOCAL INFILE 'C:\\DAM\\AAD\\EjercicioForoCine\\RegistrosCSV\\PELICULA_DIRECTOR_sin_duplicados.csv' INTO TABLE PELICULA_DIRECTOR FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'C:\\DAM\\AAD\\EjercicioForoCine\\RegistrosCSV\\PELICULA_GUIONISTA_sin_duplicados.csv' INTO TABLE PELICULA_GUIONISTA FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'C:\\DAM\\AAD\\EjercicioForoCine\\RegistrosCSV\\PELICULA_PERSONAJE_sin_duplicados.csv' INTO TABLE PELICULA_PERSONAJE FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'C:\\DAM\\AAD\\EjercicioForoCine\\RegistrosCSV\\ACTOR_PERSONAJE_sin_duplicados.csv' INTO TABLE ACTOR_PERSONAJE FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'C:\\DAM\\AAD\\EjercicioForoCine\\RegistrosCSV\\PELICULA_GRUPO_sin_duplicados.csv' INTO TABLE PELICULA_GRUPO FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'C:\\DAM\\AAD\\EjercicioForoCine\\RegistrosCSV\\PERSONAJE_GRUPO_sin_duplicados.csv' INTO TABLE PERSONAJE_GRUPO FIELDS TERMINATED BY ';' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;

SET FOREIGN_KEY_CHECKS=1;

SELECT '¡Proceso de carga de datos completado!' AS Estado;