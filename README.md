# SafeSync: Backup Automático con MegaCMD

SafeSync es un script de Bash diseñado para automatizar copias de seguridad de bases de datos utilizando **MegaCMD**.

Permite realizar copias horarias y diarias en dos cuentas diferentes de Mega, asegurando redundancia y simplicidad en la configuración.

## Características

- Copias de seguridad horarias y diarias automatizadas.
- Subida de archivos a dos cuentas de Mega simultáneamente.
- Retención configurable de copias horarias, diarias y semanales.
- Uso de **GPG** para cifrar las copias de seguridad.
- Compatibilidad con configuraciones personalizadas a través de un archivo `.env`.

## Requisitos

Antes de usar el script, asegúrate de tener instalados los siguientes paquetes:

- **MegaCMD** (cliente oficial de Mega).
- **GPG** para cifrado.
- **Bash** (normalmente preinstalado en sistemas Linux).

## Instalación

#### 1. **Clona el repositorio**:
   ```bash
   git clone https://github.com/tu_usuario/safesync.git
   cd safesync
   ```

#### 2. **Instala las dependencias**:

MegaCMD: Sigue las instrucciones oficiales:
    [MegaCMD Installation](https://mega.io/es/cmd)

GPG: En Ubuntu/Debian:
    ```bash
    sudo apt install gnupg
    ```

#### 3. **Configura tu archivo .env**:

Crea un archivo .env en la carpeta config/ con el siguiente contenido:

    ```bash
    MEGA_ACCOUNT1_EMAIL=account1@sample.com
    MEGA_ACCOUNT1_PASSWORD=safepassword1
    MEGA_ACCOUNT2_EMAIL=account2@sample.com
    MEGA_ACCOUNT2_PASSWORD=safepassword2
    GPG_KEY=12345678
    ```

#### 4. **Configura las rutas en backup_config.sh**:

Edita el archivo config/backup_config.sh para definir las rutas y retenciones:

    ```bash
    DB_PATH="./db.sqlite3"                 # Ruta de la base de datos a respaldar
    BACKUP_DIR="/tmp/db_backups"           # Directorio temporal para backups
    HOURLY_DIR="backups/hourly"            # Carpeta para copias horarias
    DAILY_DIR="backups/daily"              # Carpeta para copias diarias
    WEEKLY_DIR="backups/weekly"            # Carpeta para copias semanales
    DAILY_RETENTION=7                      # Retención de copias diarias (días)
    WEEKLY_RETENTION=28                    # Retención de copias semanales (días)
    LOG_FILE="./logs/backup_management.log" # Archivo de logs
    MAX_LOG_SIZE=5000000                   # Tamaño máximo de log (5 MB)
    ```

## **Uso**:

#### 1. **Ejecuta el script manualmente**:

    ```bash
    ./safe_backup.sh
    ```

#### 2. **Automatiza con cron**:

Para ejecutar el script cada hora, añade la siguiente línea a tu crontab:

    ```bash
    crontab -e
    ```

Y añade:

    ```bash
    0 * * * * /ruta/al/repositorio/safe_backup.sh
    ```

#### 3. **Verifica los logs**: 

Los eventos y errores se registran en el archivo definido en LOG_FILE. Por defecto:

    ```bash
    cat ./logs/backup_management.log
    ```

## Personalización

#### 1. **Cifrado con GPG**:

Genera una clave GPG si no tienes una:

    ```bash
    gpg --full-generate-key
    ```

Encuentra tu ID de clave GPG:

    ```bash
    gpg --list-keys
    ```

Usa ese ID en la variable GPG_KEY del archivo .env.

#### 2. **Retención personalizada**:

Ajusta los valores de DAILY_RETENTION y WEEKLY_RETENTION en backup_config.sh según tus necesidades.

## Contribuciones

Las contribuciones son bienvenidas. Por favor, crea un issue o abre un pull request con tus sugerencias o mejoras.

## Licencia

Este proyecto está licenciado bajo la Licencia GPL3. Consulta el archivo LICENSE para más detalles.
