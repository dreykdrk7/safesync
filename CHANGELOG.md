# Changelog

## [1.0.3] - 2024-12-30
- Añadida validación para ejecutar la copia de seguridad diaria únicamente a las 02:00.
- Incorporada la subida de copias horarias a ambas cuentas utilizando la carpeta `$HOURLY_DIR`.

## [1.0.2] - 2024-12-30
- Añadido soporte para manejar dos cuentas de Mega simultáneamente utilizando `MegaCMD`.
- Implementación de un archivo `.env` para almacenar credenciales y configuraciones sensibles.
- Ajuste en la función `upload_to_remotes` para garantizar que las carpetas de destino se creen automáticamente al subir archivos.
- Modificación de las funciones `clean_daily_backups` y `clean_weekly_backups` para asegurar la existencia de los directorios en ambos remotos antes de realizar operaciones de limpieza.
- Mejoras en la estructura del script para mayor modularidad y compatibilidad con Rclone.

## [1.0.1] - 2024-12-29
- Ajuste en la función `move_to_weekly` para mantener las copias diarias los domingos.

## [1.0.0] - 2024-12-29
- Primera versión funcional del script de backup.
