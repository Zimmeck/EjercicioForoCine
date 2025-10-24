-- =================================================================
-- Script para la creación de la Base de Datos ForoCine
-- VERSIÓN FINAL (con datos limpios y ON DELETE CASCADE)
-- =================================================================

-- 1. CREACIÓN Y USO DE LA BASE DE DATOS
-- -----------------------------------------------------------------
DROP DATABASE IF EXISTS ForoCine_Limpio;
CREATE DATABASE ForoCine_Limpio
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_general_ci;
USE ForoCine_Limpio;


-- 2. CREACIÓN DE TABLAS (Reflejo 1:1 de los CSV)
-- -----------------------------------------------------------------

CREATE TABLE ACTOR (
    idActor INT PRIMARY KEY,
    nombre VARCHAR(150)
);

CREATE TABLE DIRECTOR (
    idDirector INT PRIMARY KEY,
    nombre VARCHAR(150)
);

CREATE TABLE GUIONISTA (
    idGuionista INT PRIMARY KEY,
    nombre VARCHAR(150)
);

CREATE TABLE PERSONAJE (
    id_personaje INT PRIMARY KEY,
    nombre_personaje VARCHAR(100) NOT NULL,
    descripcion TEXT,
    identidad_humana VARCHAR(100) NULL
);

-- Tabla USUARIO
CREATE TABLE USUARIO (
    nombre_usuario VARCHAR(100) NOT NULL,
    email VARCHAR(255) PRIMARY KEY -- El email es ahora la PK
);

CREATE TABLE PELICULA (
    id_pelicula INT PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    año INT,
    duracion INT,
    pais VARCHAR(50)
);

CREATE TABLE PLATAFORMA (
    id_plataforma INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE GRUPO (
    id_grupo INT PRIMARY KEY,
    nombre_grupo VARCHAR(100) NOT NULL
);

CREATE TABLE DISPONIBILIDAD (
    id_disponibilidad INT AUTO_INCREMENT PRIMARY KEY, -- ¡NUEVO!
    id_pelicula INT NOT NULL,
    id_plataforma INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NULL, -- ¡NUEVO! (para que pueda ser NULL si no está en el CSV)
    FOREIGN KEY (id_pelicula) REFERENCES PELICULA(id_pelicula) ON DELETE CASCADE,
    FOREIGN KEY (id_plataforma) REFERENCES PLATAFORMA(id_plataforma) ON DELETE CASCADE
);

CREATE TABLE PRECIO (
    id_precio INT AUTO_INCREMENT PRIMARY KEY, -- ¡NUEVO!
    id_disponibilidad INT NOT NULL,
    valor DECIMAL(10, 2) NOT NULL,
    fecha_vigencia DATE,
    FOREIGN KEY (id_disponibilidad) REFERENCES DISPONIBILIDAD(id_disponibilidad) ON DELETE CASCADE
);

CREATE TABLE VALORACION (
    id_valoracion INT PRIMARY KEY,
    id_pelicula INT,
    -- Cambias id_usuario por email_usuario y lo enlazas
    email_usuario VARCHAR(255), 
    puntuacion INT,
    fecha DATE,
    FOREIGN KEY (id_pelicula) REFERENCES PELICULA(id_pelicula) ON DELETE CASCADE,
    -- La FK ahora apunta al email de USUARIO
    FOREIGN KEY (email_usuario) REFERENCES USUARIO(email) ON DELETE CASCADE 
);

-- CORRECCIÓN PARA LA TABLA COMENTARIO
CREATE TABLE COMENTARIO (
    id_comentario INT PRIMARY KEY,
    id_valoracion INT,
    email_usuario VARCHAR(255), -- Columna que almacena el email
    id_pelicula INT,
    texto TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Añadido DEFAULT por si acaso
    FOREIGN KEY (id_valoracion) REFERENCES VALORACION(id_valoracion) ON DELETE CASCADE,
    FOREIGN KEY (id_pelicula) REFERENCES PELICULA(id_pelicula) ON DELETE CASCADE,
    -- FK CORREGIDA 👇: Apunta desde email_usuario (en COMENTARIO) a email (en USUARIO)
    FOREIGN KEY (email_usuario) REFERENCES USUARIO(email) ON DELETE CASCADE 
);

-- 3. TABLAS DE RELACIÓN (CON 'ON DELETE CASCADE' AÑADIDO)
-- -----------------------------------------------------------------

CREATE TABLE PELICULA_DIRECTOR (
    id_pelicula INT,
    idDirector INT,
    PRIMARY KEY (id_pelicula, idDirector),
    FOREIGN KEY (id_pelicula) REFERENCES PELICULA(id_pelicula) ON DELETE CASCADE,
    FOREIGN KEY (idDirector) REFERENCES DIRECTOR(idDirector) ON DELETE CASCADE
);

CREATE TABLE PELICULA_GUIONISTA (
    id_pelicula INT,
    idGuionista INT,
    PRIMARY KEY (id_pelicula, idGuionista),
    FOREIGN KEY (id_pelicula) REFERENCES PELICULA(id_pelicula) ON DELETE CASCADE,
    FOREIGN KEY (idGuionista) REFERENCES GUIONISTA(idGuionista) ON DELETE CASCADE
);

CREATE TABLE PELICULA_PERSONAJE (
    id_pelicula INT,
    id_personaje INT,
    PRIMARY KEY (id_pelicula, id_personaje),
    FOREIGN KEY (id_pelicula) REFERENCES PELICULA(id_pelicula) ON DELETE CASCADE,
    FOREIGN KEY (id_personaje) REFERENCES PERSONAJE(id_personaje) ON DELETE CASCADE
);

CREATE TABLE ACTOR_PERSONAJE (
    idActor INT,
    id_personaje INT,
    PRIMARY KEY (idActor, id_personaje),
    FOREIGN KEY (idActor) REFERENCES ACTOR(idActor) ON DELETE CASCADE,
    FOREIGN KEY (id_personaje) REFERENCES PERSONAJE(id_personaje) ON DELETE CASCADE
);

CREATE TABLE PELICULA_GRUPO (
    id_pelicula INT,
    id_grupo INT,
    PRIMARY KEY (id_pelicula, id_grupo),
    FOREIGN KEY (id_pelicula) REFERENCES PELICULA(id_pelicula) ON DELETE CASCADE,
    FOREIGN KEY (id_grupo) REFERENCES GRUPO(id_grupo) ON DELETE CASCADE
);

CREATE TABLE PERSONAJE_GRUPO (
    id_personaje INT,
    id_grupo INT,
    PRIMARY KEY (id_personaje, id_grupo),
    FOREIGN KEY (id_personaje) REFERENCES PERSONAJE(id_personaje) ON DELETE CASCADE,
    FOREIGN KEY (id_grupo) REFERENCES GRUPO(id_grupo) ON DELETE CASCADE
);

-- 4. CREACIÓN DE USUARIO
-- -----------------------------------------------------------------
CREATE USER 'admin_forocine_limpio'@'localhost' IDENTIFIED BY 'password123';
GRANT ALL PRIVILEGES ON ForoCine_Limpio.* TO 'admin_forocine_limpio'@'localhost';
FLUSH PRIVILEGES;