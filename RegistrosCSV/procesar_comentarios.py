import pandas as pd
import os
import csv

# --- Configuración ---
ruta_base = "C:\DAM\AAD\EjercicioForoCine\RegistrosCSV"
archivo_valoracion = os.path.join(ruta_base, "VALORACION.csv")
# Asegúrate de que este es el archivo ORIGINAL con 4 columnas
archivo_comentario_original = os.path.join(ruta_base, "COMENTARIO.csv") 
archivo_comentario_nuevo = os.path.join(ruta_base, "COMENTARIO_procesado_v3.csv")
# --- Fin Configuración ---

print("Iniciando procesamiento v3 de comentarios (asumiendo 4 columnas)...")

try:
    # 1. Cargar VALORACION.csv y limpiar claves para el mapeo
    print(f"Cargando {archivo_valoracion}...")
    df_valoracion = pd.read_csv(archivo_valoracion)
    # Limpia emails y convierte IDs para la búsqueda
    df_valoracion['emailUsuario_clean'] = df_valoracion['emailUsuario'].str.strip().str.lower()
    df_valoracion['idPelicula'] = pd.to_numeric(df_valoracion['idPelicula'], errors='coerce')
    
    print("Creando mapeo de valoraciones...")
    # Crea diccionario: (email_limpio, id_pelicula) -> id_valoracion
    mapeo_valoracion = df_valoracion.set_index(['emailUsuario_clean', 'idPelicula'])['idValoracion'].to_dict()
    print(f"Mapeo creado con {len(mapeo_valoracion)} entradas.")

    # 2. Cargar COMENTARIO.csv original (con las 4 columnas indicadas)
    print(f"Cargando {archivo_comentario_original}...")
    # Asigna nombres a las 4 columnas leídas
    try:
        df_comentario = pd.read_csv(
            archivo_comentario_original, 
            header=0, # Asume cabecera en la primera línea
            # Nombres asignados según tu indicación
            names=['idComentario', 'contenido', 'emailUsuario', 'idPelicula'] 
        )
        print("Columnas leídas y renombradas: idComentario, contenido, emailUsuario, idPelicula")
    except pd.errors.ParserError as pe:
         print(f"Error al leer CSV Comentario con 4 columnas: {pe}")
         print("Verifica si el delimitador es ',' y si realmente tiene 4 columnas.")
         exit()
    except Exception as e:
        print(f"Error inesperado al cargar Comentario CSV: {e}")
        exit()

    # Limpia claves en COMENTARIO para la búsqueda
    df_comentario['emailUsuario_clean'] = df_comentario['emailUsuario'].str.strip().str.lower()
    df_comentario['idPelicula_num'] = pd.to_numeric(df_comentario['idPelicula'], errors='coerce') # Columna numérica temporal

    # 3. Función para buscar id_valoracion usando claves limpias
    def obtener_id_valoracion(row):
        # Usa las claves limpias para buscar en el mapa
        clave_busqueda = (row['emailUsuario_clean'], row['idPelicula_num']) 
        return mapeo_valoracion.get(clave_busqueda) # Devuelve None si no lo encuentra

    # 4. Aplicar la función para añadir la columna id_valoracion
    print("Buscando id_valoracion para cada comentario...")
    df_comentario['id_valoracion'] = df_comentario.apply(obtener_id_valoracion, axis=1)

    comentarios_sin_valoracion = df_comentario['id_valoracion'].isnull().sum()
    print(f"Resultado: {comentarios_sin_valoracion} comentarios tendrán NULL en id_valoracion.")

    # 5. Preparar DataFrame final - ASEGURA QUE idPelicula ORIGINAL SE CONSERVA
    print("Preparando DataFrame final...")
    # Limpia el email final que irá a la BD (quitando espacios extra)
    df_comentario['email_usuario_final'] = df_comentario['emailUsuario'].str.strip() 

    df_final = pd.DataFrame({
        # Usa los nombres de columna de tu tabla SQL
        'id_comentario': df_comentario['idComentario'],
        'id_valoracion': df_comentario['id_valoracion'], # El ID calculado
        'email_usuario': df_comentario['email_usuario_final'], # Email limpio para BD
        'id_pelicula': df_comentario['idPelicula'], # <-- USA EL VALOR ORIGINAL LEÍDO
        'texto': df_comentario['contenido'], # Renombra contenido a texto
        'fecha': pd.NA # Deja que SQL ponga el default
    })
    
    # Convierte id_valoracion a entero (permite nulos)
    df_final['id_valoracion'] = df_final['id_valoracion'].astype('Int64')

    # 6. Guardar el nuevo archivo CSV
    print(f"Guardando el archivo procesado en: {archivo_comentario_nuevo}")
    df_final.to_csv(
        archivo_comentario_nuevo, 
        index=False, 
        na_rep='NULL', # Representa NaN como la cadena 'NULL'
        quoting=csv.QUOTE_NONNUMERIC, # Comillas solo en texto
        lineterminator='\r\n' # Formato Windows
    )

    print("\n--- Proceso v3 completado ---")
    print("Primeras 5 filas del archivo generado:")
    print(pd.read_csv(archivo_comentario_nuevo).head())
    print("\nRecuerda renombrar este archivo a 'COMENTARIO.csv' (o actualizar 'Insrets.sql').")
    print("Asegúrate de que el LOAD DATA para COMENTARIO maneje NULLIF y limpie el email.")

except FileNotFoundError as fnf:
    print(f"\nError: Archivo no encontrado - {fnf}.")
except KeyError as ke:
    print(f"\nError: Nombre de columna incorrecto - {ke}. Verifica las cabeceras en los CSVs.")
except Exception as e:
    print(f"\nOcurrió un error inesperado: {e}")