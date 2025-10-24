# Proyecto ForoCine (Módulo: Acceso a Datos)

## 1. Descripción del Proyecto

Este proyecto implementa el backend de una base de datos para un sitio web de críticas de películas (similar a Filmaffinity) con un enfoque en el universo de los superhéroes. El sistema está diseñado para gestionar y relacionar información sobre películas, sus fichas técnicas (directores, guionistas), actores, personajes, plataformas de streaming, y las valoraciones y comentarios aportados por los usuarios.

El objetivo principal es modelar una estructura de datos relacional robusta (DDL) y resolver una serie de consultas de negocio y operaciones de manipulación de datos.

## 2. Tecnologías Utilizadas

* **Base de Datos:** MariaDB (v10.x)
* **Lenguaje SQL:** DDL para la estructura, DML/TCL para la operativa y carga.
* **Scripts de Carga:** `LOAD DATA LOCAL INFILE` (SQL).
* **Scripting de Limpieza:** Python 3 (con Pandas) para el pre-procesamiento y limpieza de los archivos CSV de origen.

## 3. Estructura del Proyecto

* `/ForoCine.sql`: Script DDL que crea la base de datos `ForoCine_Limpio`, todas las tablas, relaciones (`FOREIGN KEY`) y el usuario de la base de datos.
* `/Insrets.sql`: Script DML centralizado que gestiona la carga masiva (ETL) de todos los archivos CSV en las tablas, incluyendo la limpieza de datos en tiempo de carga.
* `/consultas.sql`: Solución a las 15 consultas y operaciones de negocio solicitadas en el enunciado, incluyendo `SELECT` complejos, `JOIN`s, subconsultas y Procedimientos Almacenados.
* `/RegistrosCSV`: Carpeta que contiene los datos de origen (archivos `.csv`).

## 4. Instalación y Ejecución

Para recrear el entorno de la base de datos:

1.  Asegurarse de tener un servidor MariaDB en ejecución y un cliente (DBeaver, HeidiSQL, etc.).
2.  Ejecutar el script `ForoCine.sql` para crear la base de datos `ForoCine_Limpio` y toda su estructura de tablas.
3.  Ejecutar el script `Insrets.sql` para poblar la base de datos con los datos de los CSVs.
4.  Ejecutar las consultas deseadas del archivo `consultas.sql` para verificar los resultados.

## 5. Uso de IA y Pre-procesamiento de Datos

### 5.1. Asistencia de IA

Se ha utilizado asistencia por IA para la **resolución de incidencias y errores complejos** durante la fase de carga de datos. La IA fue fundamental para:
* Diagnosticar fallos sistemáticos en los `JOIN`s (que devolvían 0 resultados).
* Identificar la corrupción de datos por caracteres invisibles (`\r`) y el intercambio de columnas (SWAP) en las claves.
* Refinar la sintaxis de `LOAD DATA` para realizar limpiezas simétricas.
* Optimizar la sintaxis de consultas complejas (como la Consulta 1) para evitar errores de parser en MariaDB.

### 5.2. Pre-procesamiento de Datos (Python)

Los datos CSV de origen requerían un pre-procesamiento antes de la carga:
* **Script de Deduplicación:** Se utilizó un script de Python (Pandas) para procesar los archivos CSV de relación (M:N) y eliminar entradas duplicadas, resultando en los archivos `_sin_duplicados.csv`.
* **Script de Limpieza (Exploración):** Se exploró el uso de un script de Python (`procesar_comentarios.py`) para intentar enriquecer el archivo `COMENTARIO.csv`. Sin embargo, este enfoque se descartó en favor de una solución de limpieza más robusta y directa en el script `Insrets.sql`.

## 6. Incidencias Críticas y Soluciones en la Carga de Datos

La fase de carga de datos (`Insrets.sql`) fue la más compleja. Se detectaron numerosas inconsistencias en los archivos CSV que requerían una limpieza y mapeo explícito para garantizar la integridad de los datos.

### 6.1. Corrupción de Clave Primaria y Foránea (`email`)
Este fue el problema más grave y la causa de que los `JOIN`s por usuario fallaran (devolviendo 0 resultados).

* **Incidencia (SWAP):** El `LOAD DATA` de `USUARIO.csv` cargó las columnas **`email` y `nombre_usuario` de forma intercambiada**.
* **Incidencia (Caracteres Ocultos):** Las claves `email` (PK) y `email_usuario` (FK) contenían **caracteres invisibles** (`\r` - retorno de carro) que impedían la comparación de igualdad en los `JOIN`s.
* **Solución:** Se corrigió el **SWAP** en el `LOAD DATA` de `USUARIO` y se aplicó una **limpieza simétrica** (`TRIM(REPLACE(@columna, '\r', ''))`) a las columnas de email en **`USUARIO`**, **`VALORACION`** y **`COMENTARIO`**.

### 6.2. Mapeo de Columnas
* **`PELICULA.csv`:** El CSV solo tenía 3 columnas, pero el DDL requería 5 (`duracion`, `pais`). Se usó `SET` en `LOAD DATA` para mapear solo las 3 columnas existentes y dejar las faltantes como `NULL`.
* **`PERSONAJE.csv`:** Las columnas `descripcion` e `identidad_humana` estaban intercambiadas. Se corrigió el orden de asignación en el `SET`.

### 6.3. Sincronización de Claves Foráneas (FK) y `AUTO_INCREMENT`
* **Incidencia:** La FK `id_disponibilidad` (de `PRECIO`) debía coincidir con la PK `id_disponibilidad` (de `DISPONIBILIDAD`), pero ambas tablas se cargaban del mismo CSV y las PKs eran `AUTO_INCREMENT`.
* **Solución:** Se implementó una lógica de **contadores simulados** (`SET @id_disp_simulado = 0;`) en `Insrets.sql`. Al reiniciar el contador antes de cada `LOAD DATA` (`DISPONIBILIDAD` y `PRECIO`), se replicó la secuencia de IDs, garantizando la integridad referencial.

### 6.4. Inconsistencias de Datos de `COMENTARIO.csv`
* **Incidencia de Datos:** La columna `id_valoracion` en `COMENTARIO.csv` era `NULL` en la mayoría de las filas.
* **Incidencia de Fechas:** La columna `fecha` era `NULL` en todas las filas. Al cargarse con el `DEFAULT CURRENT_TIMESTAMP`, todas las filas se registraron con la fecha actual.
* **Solución:** Se utilizó `NULLIF(@id_valoracion_csv, 'NULL')` en el `LOAD DATA` para insertar `NULL`s reales, aceptando que solo algunos comentarios tendrían enlace directo a una valoración.
