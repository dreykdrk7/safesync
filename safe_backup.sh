#!/bin/bash

# Cargar variables del archivo .env
if [ -f ./config/.env ]; then
    export $(cat ./config/.env | xargs)
else
    echo "ERROR: Archivo .env no encontrado. Crea uno antes de ejecutar el script."
    exit 1
fi

source ./config/backup_config.sh

# Función para loggear eventos
log_event() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# Rotación del log si excede el tamaño máximo
rotate_logs() {
    if [ -f "$LOG_FILE" ] && [ $(stat -c%s "$LOG_FILE") -gt $MAX_LOG_SIZE ]; then
        mv "$LOG_FILE" "${LOG_FILE}.1"
        log_event "Log rotado. Archivo original movido a ${LOG_FILE}.1"
    fi
}

# Validaciones iniciales
check_dependencies() {
    for cmd in rclone gpg; do
        if ! command -v $cmd &>/dev/null; then
            echo "ERROR: $cmd no está instalado. Instálalo antes de continuar." | tee -a $LOG_FILE
            exit 1
        fi
    done
    log_event "Dependencias validadas correctamente."
}

check_directories() {
    mkdir -p $BACKUP_DIR
    if [ ! -d "$(dirname $LOG_FILE)" ]; then
        mkdir -p "$(dirname $LOG_FILE)"
        log_event "Directorio de logs creado: $(dirname $LOG_FILE)"
    fi
}

# Crear y cifrar copia de seguridad
create_backup() {
    log_event "Creando copia de seguridad de la base de datos..."
    cp $DB_PATH $BACKUP_FILE
    log_event "Cifrando copia de seguridad con GPG..."
    gpg --encrypt --recipient $GPG_KEY --output $ENCRYPTED_FILE $BACKUP_FILE
    log_event "Copia de seguridad cifrada: $ENCRYPTED_FILE"
}

# Subir copia de seguridad a ambas cuentas
upload_to_remotes() {
    # Subir a HOURLY_DIR
    log_event "Subiendo copia de seguridad horaria a ambas cuentas..."

    # Primera cuenta
    mega-login $MEGA_ACCOUNT1_EMAIL $MEGA_ACCOUNT1_PASSWORD
    mega-put -c $ENCRYPTED_FILE /$HOURLY_DIR/
    log_event "Copia horaria subida a la primera cuenta (${HOURLY_DIR})."
    mega-logout

    sleep 15

    # Segunda cuenta
    mega-login $MEGA_ACCOUNT2_EMAIL $MEGA_ACCOUNT2_PASSWORD
    mega-put -c $ENCRYPTED_FILE /$HOURLY_DIR/
    log_event "Copia horaria subida a la segunda cuenta (${HOURLY_DIR})."
    mega-logout

    sleep 15

    # Comprobar si la hora actual es 02:00
    CURRENT_HOUR=$(date +%H)
    if [[ $CURRENT_HOUR -eq 02 ]]; then
        log_event "Es la hora programada (02:00). Subiendo copia de seguridad diaria..."

        # Primera cuenta
        mega-login $MEGA_ACCOUNT1_EMAIL $MEGA_ACCOUNT1_PASSWORD
        mega-put -c $ENCRYPTED_FILE /$DAILY_DIR/
        log_event "Copia diaria subida a la primera cuenta (${DAILY_DIR})."
        mega-logout

        sleep 15

        # Segunda cuenta
        mega-login $MEGA_ACCOUNT2_EMAIL $MEGA_ACCOUNT2_PASSWORD
        mega-put -c $ENCRYPTED_FILE /$DAILY_DIR/
        log_event "Copia diaria subida a la segunda cuenta (${DAILY_DIR})."
        mega-logout
    else
        log_event "No es la hora programada para la copia diaria. Solo se realizó la copia horaria."
    fi
}

# Limpieza de copias horarias antiguas
clean_hourly_backups() {
    for REMOTE in $REMOTE_1 $REMOTE_2; do
        log_event "Verificando existencia del directorio en $REMOTE..."
        rclone mkdir ${REMOTE}:${HOURLY_DIR} || log_event "Error al crear directorio en $REMOTE"

        log_event "Eliminando copias horarias antiguas en $REMOTE..."
        rclone ls ${REMOTE}:${HOURLY_DIR} --min-age 12h | awk '{print $2}' | grep -v '/$' | while read file; do
            if rclone delete "${REMOTE}:${HOURLY_DIR}/${file}"; then
                log_event "Eliminada copia horaria antigua: ${file} en $REMOTE"
            else
                log_event "ERROR al eliminar copia horaria: ${file} en $REMOTE"
            fi
        done
    done
}

# Limpieza de copias diarias antiguas
clean_daily_backups() {
    for REMOTE in $REMOTE_1 $REMOTE_2; do
        log_event "Verificando existencia del directorio en $REMOTE..."
        rclone mkdir ${REMOTE}:${DAILY_DIR} || log_event "Error al crear directorio en $REMOTE"

        log_event "Eliminando copias diarias antiguas en $REMOTE..."
        rclone ls ${REMOTE}:${DAILY_DIR} --min-age ${DAILY_RETENTION}d | awk '{print $2}' | grep -v '/$' | while read file; do
            if rclone delete "${REMOTE}:${DAILY_DIR}/${file}"; then
                log_event "Eliminada copia diaria antigua: ${file} en $REMOTE"
            else
                log_event "ERROR al eliminar copia diaria: ${file} en $REMOTE"
            fi
        done
    done
}

# Mover copias diarias a semanales
move_to_weekly() {
    log_event "Verificando si corresponde mover copias diarias a semanales..."
    CURRENT_DAY=$(date +%u) # Día de la semana (1=Lunes, 7=Domingo)
    if [[ $CURRENT_DAY -eq 7 ]]; then # Solo ejecuta el domingo
        log_event "Es domingo, copiando copias diarias a semanales..."
        for REMOTE in $REMOTE_1 $REMOTE_2; do
            if rclone copy ${REMOTE}:${DAILY_DIR} ${REMOTE}:${WEEKLY_DIR}; then
                log_event "Copias diarias copiadas a semanales con éxito en $REMOTE."
            else
                log_event "ERROR al copiar copias diarias a semanales en $REMOTE."
            fi
        done
    fi
}

# Limpieza de copias semanales antiguas
clean_weekly_backups() {
    for REMOTE in $REMOTE_1 $REMOTE_2; do
        log_event "Verificando existencia del directorio en $REMOTE..."
        rclone mkdir ${REMOTE}:${WEEKLY_DIR} || log_event "Error al crear directorio en $REMOTE"

        log_event "Eliminando copias semanales antiguas en $REMOTE..."
        rclone ls ${REMOTE}:${WEEKLY_DIR} --min-age ${WEEKLY_RETENTION}d | awk '{print $2}' | grep -v '/$' | while read file; do
            if rclone delete "${REMOTE}:${WEEKLY_DIR}/${file}"; then
                log_event "Eliminada copia semanal antigua: ${file} en $REMOTE"
            else
                log_event "ERROR al eliminar copia semanal: ${file} en $REMOTE"
            fi
        done
    done
}

# Inicio del script
rotate_logs
check_dependencies
check_directories
log_event "Iniciando la gestión de copias de seguridad..."

create_backup
upload_to_remotes
clean_hourly_backups
clean_daily_backups
move_to_weekly
clean_weekly_backups

log_event "Gestión de copias de seguridad completada."
