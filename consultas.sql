-- 1. Obtener la ficha técnica de una película por título.
SELECT
    p.titulo,
    p.`año`,
    p.duracion,
    p.pais,
    (
        SELECT COALESCE(AVG(v.puntuacion), 0.0)
        FROM VALORACION v
        WHERE
            v.id_pelicula = p.id_pelicula
    ) AS Valoracion_Media,
    (
        SELECT GROUP_CONCAT(d.nombre SEPARATOR ', ')
        FROM
            DIRECTOR d
            JOIN PELICULA_DIRECTOR pd ON d.idDirector = pd.idDirector
        WHERE
            pd.id_pelicula = p.id_pelicula
    ) AS Directores,
    (
        SELECT GROUP_CONCAT(g.nombre SEPARATOR ', ')
        FROM
            GUIONISTA g
            JOIN PELICULA_GUIONISTA pg ON g.idGuionista = pg.idGuionista
        WHERE
            pg.id_pelicula = p.id_pelicula
    ) AS Guionistas,
    (
        SELECT GROUP_CONCAT(
                DISTINCT CONCAT(
                    a.nombre, ' (como ', pj.nombre_personaje, ')'
                ) SEPARATOR '; '
            )
        FROM
            PELICULA_PERSONAJE pp
            JOIN PERSONAJE pj ON pp.id_personaje = pj.id_personaje
            JOIN ACTOR_PERSONAJE ap ON pj.id_personaje = ap.id_personaje
            JOIN ACTOR a ON ap.idActor = a.idActor
        WHERE
            pp.id_pelicula = p.id_pelicula
    ) AS Reparto_Generico
FROM PELICULA p
ORDER BY p.`año` DESC, p.titulo;

-- 2. Listar las películas de superhéroes estrenadas después de 2020, ordenadas por año de estreno descendente.
SELECT p.titulo, p.año
FROM PELICULA p
WHERE
    p.año > 2020
    AND p.id_pelicula IN (
        SELECT DISTINCT
            id_pelicula
        FROM PELICULA_PERSONAJE
    )
ORDER BY p.`año` DESC, p.titulo;

-- 3. Calcular el número total de comentarios por película
SELECT
    p.titulo,
    -- Contamos los id_comentario asociados a cada película. 
    -- COUNT() devolverá 0 si el LEFT JOIN no encuentra comentarios.
    COUNT(c.id_comentario) AS Total_Comentarios
FROM
    PELICULA p
LEFT JOIN -- Para incluir películas sin comentarios
    COMENTARIO c ON p.id_pelicula = c.id_pelicula
GROUP BY
    p.id_pelicula, p.titulo -- Agrupamos para contar por película
ORDER BY
    Total_Comentarios DESC, -- Ordena de más comentado a menos
    p.titulo;

-- 4. Obtener la media de valoración para cada película
SELECT
    p.titulo,
    COALESCE(AVG(v.puntuacion), 0.0) AS Valoracion_Media
FROM
    PELICULA p
LEFT JOIN
    VALORACION v ON p.id_pelicula = v.id_pelicula
GROUP BY
    p.id_pelicula, p.titulo -- Agrupamos por el ID y el título de la película
ORDER BY
    Valoracion_Media DESC, p.titulo;

-- 5. Identificar la identidad humana de un superhéroe que aparece en una película específica
SELECT
    p.titulo AS Pelicula,
    pj.nombre_personaje AS Superheroe,
    pj.identidad_humana AS Identidad_Secreta
FROM
    PELICULA p
JOIN
    PELICULA_PERSONAJE pp ON p.id_pelicula = pp.id_pelicula
JOIN
    PERSONAJE pj ON pp.id_personaje = pj.id_personaje
WHERE
    p.titulo = 'Staff.' -- <<-- FILTRO 1: Introduce el título de la película
    AND pj.nombre_personaje = 'Doctor Strange'; -- <<-- FILTRO 2: Introduce el nombre del superhéroe

-- 6. Encontrar todos los actores que han interpretado al superhéroe 'Spider-Man'
SELECT
    p.nombre_personaje AS Superheroe,
    a.nombre AS Nombre_Actor
FROM
    PERSONAJE p
JOIN
    ACTOR_PERSONAJE ap ON p.id_personaje = ap.id_personaje
JOIN
    ACTOR a ON ap.idActor = a.idActor
WHERE
    -- Filtra por el nombre específico del personaje
    p.nombre_personaje = 'Spider-Man'
ORDER BY
    a.nombre;

-- 7. Listar todas las plataformas, mostrando cuántas películas tienen actualmente disponibles para alquiler (incluso si tienen 0).
SELECT
    pl.nombre AS Plataforma,
    COALESCE(COUNT(t1.id_pelicula), 0) AS Peliculas_Alquiler_Actuales
FROM
    PLATAFORMA pl
LEFT JOIN
    (
        SELECT 
            d.id_pelicula, 
            d.id_plataforma
        FROM 
            DISPONIBILIDAD d
        JOIN 
            PRECIO pr ON d.id_disponibilidad = pr.id_disponibilidad
        WHERE
            -- Condición 1: El período de disponibilidad está activo
            d.fecha_inicio <= CURDATE() 
            AND (d.fecha_fin IS NULL OR d.fecha_fin >= CURDATE())
            -- Condición 2: El precio indica que es de alquiler (mayor a 0)
            AND pr.valor > 0
        GROUP BY 
            d.id_pelicula, d.id_plataforma 
            -- Agrupa para asegurar que contamos películas distintas por plataforma
    ) AS t1 ON pl.id_plataforma = t1.id_plataforma
GROUP BY
    pl.id_plataforma, pl.nombre
ORDER BY
    pl.nombre;

-- 8. Encontrar los títulos de las películas que tienen un coste de alquiler superior a 5€ en alguna plataforma.
SELECT DISTINCT
    p.titulo AS Titulo_Pelicula
FROM
    PELICULA p
JOIN
    DISPONIBILIDAD d ON p.id_pelicula = d.id_pelicula
JOIN
    PRECIO pr ON d.id_disponibilidad = pr.id_disponibilidad
WHERE
    pr.valor > 5 
ORDER BY
    p.titulo;

-- 9. Listar los superhéroes (nombre e identidad) que nunca han aparecido en una película estrenada antes de 2000.*
SELECT
    pj.nombre_personaje AS Superheroe,
    pj.identidad_humana AS Identidad_Humana
FROM
    PERSONAJE pj
WHERE
    pj.id_personaje NOT IN (
        SELECT DISTINCT
            pp.id_personaje
        FROM
            PELICULA_PERSONAJE pp
        JOIN
            PELICULA p ON pp.id_pelicula = p.id_pelicula
        WHERE
            p.`año` < 2000
    )
ORDER BY
    pj.nombre_personaje;

-- 10. Encontrar la película con la valoración media más alta (OPTIONAL)
SELECT
    p.titulo AS Pelicula_Mejor_Valorada,
    COALESCE(AVG(v.puntuacion), 0.0) AS Valoracion_Media_Maxima
FROM
    PELICULA p
LEFT JOIN
    VALORACION v ON p.id_pelicula = v.id_pelicula
GROUP BY
    p.id_pelicula, p.titulo
ORDER BY
    Valoracion_Media_Maxima DESC
LIMIT 1; 

-- 11. Obtener todos los comentarios realizados por seguidores que votaron una película con un 10*
SELECT
    c.texto AS Comentario,
    p.titulo AS Pelicula,
    u.nombre_usuario AS Usuario,
    v.puntuacion AS Puntuacion_Voto
FROM
    COMENTARIO c
INNER JOIN
    VALORACION v ON c.id_valoracion = v.id_valoracion
INNER JOIN
    PELICULA p ON c.id_pelicula = p.id_pelicula
INNER JOIN
    USUARIO u ON c.email_usuario = u.email
WHERE
    v.puntuacion = 10 
    AND c.id_valoracion IS NOT NULL
ORDER BY
    p.titulo, c.fecha;

-- 12. Actualizar la media de valoración de una película específica después de un nuevo voto
-- Consultar la media actualizada de una película específica
SELECT 
    p.titulo,
    COALESCE(AVG(v.puntuacion), 0.0) AS Valoracion_Media
FROM 
    PELICULA p
LEFT JOIN 
    VALORACION v ON p.id_pelicula = v.id_pelicula
WHERE 
    p.id_pelicula = 1  -- Cambia por el ID de la película
GROUP BY 
    p.id_pelicula, p.titulo;


-- 13.  Eliminar una película y sus datos relacionados

-- Ver todos los datos relacionados con una película antes de eliminar
SET @pelicula_id = 1;

SELECT 'PELICULA' AS Tabla, COUNT(*) AS Registros 
FROM PELICULA WHERE id_pelicula = 100
UNION ALL
SELECT 'VALORACION', COUNT(*) 
FROM VALORACION WHERE id_pelicula = 100
UNION ALL
SELECT 'COMENTARIO', COUNT(*) 
FROM COMENTARIO WHERE id_pelicula = 100
UNION ALL
SELECT 'DISPONIBILIDAD', COUNT(*) 
FROM DISPONIBILIDAD WHERE id_pelicula = 100
UNION ALL
SELECT 'PRECIO', COUNT(*) 
FROM PRECIO WHERE id_disponibilidad IN (
    SELECT id_disponibilidad FROM DISPONIBILIDAD WHERE id_pelicula = 100
)
UNION ALL
SELECT 'PELICULA_DIRECTOR', COUNT(*) 
FROM PELICULA_DIRECTOR WHERE id_pelicula = 100
UNION ALL
SELECT 'PELICULA_GUIONISTA', COUNT(*) 
FROM PELICULA_GUIONISTA WHERE id_pelicula = 100
UNION ALL
SELECT 'PELICULA_PERSONAJE', COUNT(*) 
FROM PELICULA_PERSONAJE WHERE id_pelicula = 100
UNION ALL
SELECT 'PELICULA_GRUPO', COUNT(*) 
FROM PELICULA_GRUPO WHERE id_pelicula = 100;

-- Eliminar una película por ID
DELETE FROM PELICULA 
WHERE id_pelicula = 100;