-- 1. CREACIÓN Y USO DE LA BASE DE DATOS

DROP DATABASE IF EXISTS ForoCine;
CREATE DATABASE ForoCine
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_general_ci;
USE ForoCine;

-- 2. CREACIÓN DE TABLAS

-- Tabla principal para almacenar datos de personas (actores, directores, guionistas)
CREATE TABLE PERSONA (
    id_persona INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL
);

-- Tabla Actores (hereda de PERSONA)
CREATE TABLE ACTOR (
    id_actor INT PRIMARY KEY,
    CONSTRAINT FK_Actor_Persona FOREIGN KEY (id_actor) REFERENCES PERSONA(id_persona) ON DELETE CASCADE
);

-- Tabla Guionistas (hereda de PERSONA)
CREATE TABLE GUIONISTA (
    id_guionista INT PRIMARY KEY,
    CONSTRAINT FK_Guionista_Persona FOREIGN KEY (id_guionista) REFERENCES PERSONA(id_persona) ON DELETE CASCADE
);

-- Tabla Directores (hereda de PERSONA)
CREATE TABLE DIRECTOR (
    id_director INT PRIMARY KEY,
    CONSTRAINT FK_Director_Persona FOREIGN KEY (id_director) REFERENCES PERSONA(id_persona) ON DELETE CASCADE
);

-- Tabla Películas
CREATE TABLE PELICULA (
    id_pelicula INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    ano_estreno INT,
    duracion_min INT,
    pais VARCHAR(50),
    valoracion_media DECIMAL(4, 2) DEFAULT 0.00 -- Requerido para actualizar y consultar la media
);

-- Tabla para los Superhéroes y su identidad humana
CREATE TABLE SUPERHEROE (
    id_superheroe INT AUTO_INCREMENT PRIMARY KEY,
    nombre_heroe VARCHAR(100) NOT NULL,
    identidad_humana VARCHAR(100)
);

-- Tabla para los Grupos de superhéroes
CREATE TABLE GRUPO (
    id_grupo INT AUTO_INCREMENT PRIMARY KEY,
    nombre_grupo VARCHAR(100) NOT NULL
);

-- Tabla para las Plataformas de streaming
CREATE TABLE PLATAFORMA (
    id_plataforma INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

-- Tabla para los Seguidores (usuarios de la web)
CREATE TABLE SEGUIDOR (
    email VARCHAR(255) PRIMARY KEY, 
    password_hash VARCHAR(255) NOT NULL -- Almacena el hash de la contraseña
);


-- 3. CREACIÓN DE TABLAS DE RELACIÓN 

-- Relaciona Películas con sus Directores
CREATE TABLE PELICULA_DIRECTOR (
    id_pelicula INT,
    id_director INT,
    PRIMARY KEY (id_pelicula, id_director),
    CONSTRAINT FK_PD_Pelicula FOREIGN KEY (id_pelicula) REFERENCES PELICULA(id_pelicula) ON DELETE CASCADE,
    CONSTRAINT FK_PD_Director FOREIGN KEY (id_director) REFERENCES DIRECTOR(id_director) ON DELETE CASCADE
);

-- Relaciona Películas con sus Guionistas
CREATE TABLE PELICULA_GUIONISTA (
    id_pelicula INT,
    id_guionista INT,
    PRIMARY KEY (id_pelicula, id_guionista),
    CONSTRAINT FK_PG_Pelicula FOREIGN KEY (id_pelicula) REFERENCES PELICULA(id_pelicula) ON DELETE CASCADE,
    CONSTRAINT FK_PG_Guionista FOREIGN KEY (id_guionista) REFERENCES GUIONISTA(id_guionista) ON DELETE CASCADE
);

-- Tabla de INTERPRETACIÓN: relaciona al Actor, con la Película y el Superhéroe que interpreta
CREATE TABLE INTERPRETACION (
    id_pelicula INT,
    id_actor INT,
    id_superheroe INT,
    PRIMARY KEY (id_pelicula, id_actor, id_superheroe),
    CONSTRAINT FK_Interpretacion_Pelicula FOREIGN KEY (id_pelicula) REFERENCES PELICULA(id_pelicula) ON DELETE CASCADE,
    CONSTRAINT FK_Interpretacion_Actor FOREIGN KEY (id_actor) REFERENCES ACTOR(id_actor) ON DELETE CASCADE,
    CONSTRAINT FK_Interpretacion_Superheroe FOREIGN KEY (id_superheroe) REFERENCES SUPERHEROE(id_superheroe) ON DELETE CASCADE
);

-- Relaciona qué superhéroes aparecen en qué grupo para una película determinada
CREATE TABLE PERTENENCIA_GRUPO (
    id_pelicula INT,
    id_superheroe INT,
    id_grupo INT,
    PRIMARY KEY (id_pelicula, id_superheroe, id_grupo),
    CONSTRAINT FK_PGrupo_Pelicula FOREIGN KEY (id_pelicula) REFERENCES PELICULA(id_pelicula) ON DELETE CASCADE,
    CONSTRAINT FK_PGrupo_Superheroe FOREIGN KEY (id_superheroe) REFERENCES SUPERHEROE(id_superheroe) ON DELETE CASCADE,
    CONSTRAINT FK_PGrupo_Grupo FOREIGN KEY (id_grupo) REFERENCES GRUPO(id_grupo) ON DELETE CASCADE
);

-- Indica en qué plataformas está disponible una película, cuándo y a qué precio
CREATE TABLE DISPONIBILIDAD (
    id_disponibilidad INT AUTO_INCREMENT PRIMARY KEY,
    id_pelicula INT NOT NULL,
    id_plataforma INT NOT NULL,
    fecha_inicio DATE,
    fecha_fin DATE, -- Requerido para la regla de borrado (3 años sin plataforma)
    es_alquiler BOOLEAN DEFAULT FALSE, -- Requerido para saber si es alquiler
    coste_alquiler DECIMAL(5, 2), -- Requerido para el coste de alquiler
    CONSTRAINT FK_Disponibilidad_Pelicula FOREIGN KEY (id_pelicula) REFERENCES PELICULA(id_pelicula) ON DELETE CASCADE,
    CONSTRAINT FK_Disponibilidad_Plataforma FOREIGN KEY (id_plataforma) REFERENCES PLATAFORMA(id_plataforma) ON DELETE CASCADE
);

-- Almacena las votaciones de los seguidores a las películas
CREATE TABLE VALORACION (
    seguidor_email VARCHAR(255),
    id_pelicula INT,
    puntuacion INT NOT NULL CHECK (puntuacion >= 0 AND puntuacion <= 10), -- Rango 0-10
    PRIMARY KEY (seguidor_email, id_pelicula), -- Un seguidor solo puede votar una vez por película
    CONSTRAINT FK_Valoracion_Seguidor FOREIGN KEY (seguidor_email) REFERENCES SEGUIDOR(email) ON DELETE CASCADE,
    CONSTRAINT FK_Valoracion_Pelicula FOREIGN KEY (id_pelicula) REFERENCES PELICULA(id_pelicula) ON DELETE CASCADE
);

-- Almacena los comentarios de los seguidores a las películas
CREATE TABLE COMENTARIO (
    id_comentario INT AUTO_INCREMENT PRIMARY KEY,
    seguidor_email VARCHAR(255) NOT NULL,
    id_pelicula INT NOT NULL,
    texto TEXT,
    fecha_comentario TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Requerido para la regla de borrado (5 años sin comentario)
    CONSTRAINT FK_Comentario_Seguidor FOREIGN KEY (seguidor_email) REFERENCES SEGUIDOR(email) ON DELETE CASCADE,
    CONSTRAINT FK_Comentario_Pelicula FOREIGN KEY (id_pelicula) REFERENCES PELICULA(id_pelicula) ON DELETE CASCADE
);


-- 4. CREACIÓN DE USUARIO Y ASIGNACIÓN DE PERMISOS

CREATE USER 'admin_forocine'@'localhost' IDENTIFIED BY 'password123';
GRANT ALL PRIVILEGES ON ForoCine.* TO 'admin_forocine'@'localhost';
FLUSH PRIVILEGES;