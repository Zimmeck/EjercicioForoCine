CREATE DATABASE ForoCine;
USE ForoCine;

DEFAULT CHARACTER SET=utf8mb4;
DEFAULT COLLATE=utf8mb4_general_ci;

-- Creación de la tabla PERSONA
-- Esta es la tabla principal para actores, guionistas y directores.
CREATE TABLE PERSONA (
    id_persona VARCHAR(36) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE,
    nacionalidad VARCHAR(50)
);

-- Creación de la tabla ACTOR
-- Se relaciona con PERSONA (relación 1:1)
CREATE TABLE ACTOR (
    id_actor VARCHAR(36) PRIMARY KEY,
    id_persona VARCHAR(36) UNIQUE,
    CONSTRAINT FK_Actor_Persona FOREIGN KEY (id_persona) REFERENCES PERSONA(id_persona)
);

-- Creación de la tabla GUIONISTA
-- Se relaciona con PERSONA (relación 1:1)
CREATE TABLE GUIONISTA (
    id_guionista VARCHAR(36) PRIMARY KEY,
    id_persona VARCHAR(36) UNIQUE,
    CONSTRAINT FK_Guionista_Persona FOREIGN KEY (id_persona) REFERENCES PERSONA(id_persona)
);

-- Creación de la tabla DIRECTOR
-- Se relaciona con PERSONA (relación 1:1)
CREATE TABLE DIRECTOR (
    id_director VARCHAR(36) PRIMARY KEY,
    id_persona VARCHAR(36) UNIQUE,
    CONSTRAINT FK_Director_Persona FOREIGN KEY (id_persona) REFERENCES PERSONA(id_persona)
);

-- Creación de la tabla PELICULA
CREATE TABLE PELICULA (
    id_pelicula VARCHAR(36) PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    año INT,
    duracion INT
);

-- Creación de la tabla GENERO
-- Un catálogo de géneros de películas
CREATE TABLE GENERO (
    id_genero VARCHAR(36) PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL
);

-- Tabla de relación PELICULA_GENERO (muchos a muchos)
-- Una película puede tener varios géneros, y un género puede aplicarse a varias películas.
CREATE TABLE PELICULA_GENERO (
    id_pelicula VARCHAR(36),
    id_genero VARCHAR(36),
    PRIMARY KEY (id_pelicula, id_genero),
    CONSTRAINT FK_PeliculaGenero_Pelicula FOREIGN KEY (id_pelicula) REFERENCES PELICULA(id_pelicula),
    CONSTRAINT FK_PeliculaGenero_Genero FOREIGN KEY (id_genero) REFERENCES GENERO(id_genero)
);

-- Creación de la tabla PERSONAJE
CREATE TABLE PERSONAJE (
    id_personaje VARCHAR(36) PRIMARY KEY,
    nombre_personaje VARCHAR(100) NOT NULL,
    descripcion TEXT
);

-- Tabla de relación PELICULA_PERSONAJE (muchos a muchos)
-- Un personaje puede aparecer en varias películas
CREATE TABLE PELICULA_PERSONAJE (
    id_pelicula VARCHAR(36),
    id_personaje VARCHAR(36),
    PRIMARY KEY (id_pelicula, id_personaje),
    CONSTRAINT FK_PeliculaPersonaje_Pelicula FOREIGN KEY (id_pelicula) REFERENCES PELICULA(id_pelicula),
    CONSTRAINT FK_PeliculaPersonaje_Personaje FOREIGN KEY (id_personaje) REFERENCES PERSONAJE(id_personaje)
);

-- Creación de la tabla GUIO
-- Relación entre guionistas y películas (muchos a muchos)
CREATE TABLE GUIO (
    id_guionista VARCHAR(36),
    id_pelicula VARCHAR(36),
    PRIMARY KEY (id_guionista, id_pelicula),
    CONSTRAINT FK_Guio_Guionista FOREIGN KEY (id_guionista) REFERENCES GUIONISTA(id_guionista),
    CONSTRAINT FK_Guio_Pelicula FOREIGN KEY (id_pelicula) REFERENCES PELICULA(id_pelicula)
);

-- Creación de la tabla DIRECCION
-- Relación entre directores y películas (muchos a muchos)
CREATE TABLE DIRECCION (
    id_director VARCHAR(36),
    id_pelicula VARCHAR(36),
    PRIMARY KEY (id_director, id_pelicula),
    CONSTRAINT FK_Direccion_Director FOREIGN KEY (id_director) REFERENCES DIRECTOR(id_director),
    CONSTRAINT FK_Direccion_Pelicula FOREIGN KEY (id_pelicula) REFERENCES PELICULA(id_pelicula)
);

-- Creación de la tabla ACTUACION
-- Relación entre actores, personajes y películas (muchos a muchos)
CREATE TABLE ACTUACION (
    id_actor VARCHAR(36),
    id_personaje VARCHAR(36),
    id_pelicula VARCHAR(36),
    PRIMARY KEY (id_actor, id_personaje, id_pelicula),
    CONSTRAINT FK_Actuacion_Actor FOREIGN KEY (id_actor) REFERENCES ACTOR(id_actor),
    CONSTRAINT FK_Actuacion_Personaje FOREIGN KEY (id_personaje) REFERENCES PERSONAJE(id_personaje),
    CONSTRAINT FK_Actuacion_Pelicula FOREIGN KEY (id_pelicula) REFERENCES PELICULA(id_pelicula)
);

-- Creación de la tabla PLATAFORMA
CREATE TABLE PLATAFORMA (
    id_plataforma VARCHAR(36) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

-- Creación de la tabla DISPONIBILIDAD
-- Relaciona películas con plataformas (muchos a muchos)
CREATE TABLE DISPONIBILIDAD (
    id_disponibilidad VARCHAR(36) PRIMARY KEY,
    id_pelicula VARCHAR(36),
    id_plataforma VARCHAR(36),
    fecha_inicio DATE,
    fecha_fin DATE,
    CONSTRAINT FK_Disponibilidad_Pelicula FOREIGN KEY (id_pelicula) REFERENCES PELICULA(id_pelicula),
    CONSTRAINT FK_Disponibilidad_Plataforma FOREIGN KEY (id_plataforma) REFERENCES PLATAFORMA(id_plataforma)
);

-- Creación de la tabla PRECIO
CREATE TABLE PRECIO (
    id_precio VARCHAR(36) PRIMARY KEY,
    id_disponibilidad VARCHAR(36),
    valor DECIMAL(10, 2) NOT NULL,
    fecha_vigencia DATE,
    CONSTRAINT FK_Precio_Disponibilidad FOREIGN KEY (id_disponibilidad) REFERENCES DISPONIBILIDAD(id_disponibilidad)
);

-- Creación de la tabla VALORACION
CREATE TABLE VALORACION (
    id_valoracion VARCHAR(36) PRIMARY KEY,
    id_pelicula VARCHAR(36),
    puntuacion INT CHECK (puntuacion >= 1 AND puntuacion <= 10),
    fecha DATE,
    CONSTRAINT FK_Valoracion_Pelicula FOREIGN KEY (id_pelicula) REFERENCES PELICULA(id_pelicula)
);

-- Creación de la tabla COMENTARIO
CREATE TABLE COMENTARIO (
    id_comentario VARCHAR(36) PRIMARY KEY,
    id_valoracion VARCHAR(36),
    texto TEXT,
    CONSTRAINT FK_Comentario_Valoracion FOREIGN KEY (id_valoracion) REFERENCES VALORACION(id_valoracion)
);

-- Creación de la tabla SEGUIDOR
-- Representa a un usuario que sigue un tema o contenido
CREATE TABLE SEGUIDOR (
    id_seguidor VARCHAR(36) PRIMARY KEY,
    nombre_usuario VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE
);

-- Tabla de relación SEGUIDOR_PELICULA (muchos a muchos)
-- Un seguidor puede seguir varias películas
CREATE TABLE SEGUIDOR_PELICULA (
    id_seguidor VARCHAR(36),
    id_pelicula VARCHAR(36),
    PRIMARY KEY (id_seguidor, id_pelicula),
    CONSTRAINT FK_SeguidorPelicula_Seguidor FOREIGN KEY (id_seguidor) REFERENCES SEGUIDOR(id_seguidor),
    CONSTRAINT FK_SeguidorPelicula_Pelicula FOREIGN KEY (id_pelicula) REFERENCES PELICULA(id_pelicula)
);