#!/bin/bash
# CAZIL RGB FIX - Reinstala el driver de Acer para la sesión actual.
# Ejecutar solo una vez al iniciar Hyprland.

ACER_DIR="$HOME/acer-rgb-temp"
DRIVER_REPO="https://github.com/JafarAkhondali/acer-predator-turbo-and-rgb-keyboard-linux-module.git"
MOD_NAME="facer"

# 1. Comprobar si ya está cargado para no perder tiempo
if lsmod | grep -q "$MOD_NAME"; then
    exit 0
fi

# 2. Reportar y Limpiar
echo "[CAZIL RGB] Recompilando y cargando $MOD_NAME..."
sudo rm -rf "$ACER_DIR" # Eliminar builds anteriores
sudo rm -f /lib/modules/$(uname -r)/kernel/drivers/acpi/$MOD_NAME.ko # Eliminar módulo anterior

# 3. Clonar, Compilar e Instalar
git clone "$DRIVER_REPO" "$ACER_DIR"
cd "$ACER_DIR" || exit 1

sudo make clean
sudo make KERNELRELEASE=$(uname -r)

# 4. Cargar el módulo si la compilación fue exitosa
if [ -f src/$MOD_NAME.ko ]; then
    sudo cp src/$MOD_NAME.ko /lib/modules/$(uname -r)/kernel/drivers/acpi/
    sudo depmod -a
    sudo modprobe "$MOD_NAME"
    echo "[CAZIL RGB] Driver $MOD_NAME cargado exitosamente."
    
    # 5. Lanzar la aplicación GUI (para cargar el perfil guardado)
    rgb_config_acer_gkbbl_0 &
else
    echo "[CAZIL RGB] ERROR: Falló la compilación del módulo RGB."
fi

# 6. Limpiar la carpeta de trabajo
sudo rm -rf "$ACER_DIR"

