#!/bin/bash

# Configuración
DB_PATH="./db.sqlite3"              # Ruta de tu base de datos SQLite
BACKUP_DIR="/tmp/db_backups"                 # Directorio temporal para backups
DATE=$(date +"%Y-%m-%d_%H-%M-%S")            # Fecha y hora actual
BACKUP_FILE="${BACKUP_DIR}/db_${DATE}.sqlite3" # Nombre del archivo de backup
REMOTE_DIR="mega_local:"                     # Remoto Rclone apuntando a Mega

# Crear el directorio temporal si no existe
mkdir -p $BACKUP_DIR

# Crear copia de la base de datos
echo "Creando copia de seguridad de la base de datos..."
cp $DB_PATH $BACKUP_FILE

# Subir la copia al remoto
echo "Subiendo copia de seguridad a Mega..."
rclone copy $BACKUP_FILE ${REMOTE_DIR}/

# Eliminar el archivo local
echo "Eliminando copia local..."
rm $BACKUP_FILE

echo "Copia de seguridad completada: $BACKUP_FILE"
