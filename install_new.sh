#!/bin/bash

# ==============================================================================
#   CAZIL SYSTEM - MODULAR DEPLOYMENT PROTOCOL (v9.0)
#   Target: Debian Sid (Hyprland + NVIDIA + Acer Nitro)
#   Características: Instalación modular + Aplicación de dotfiles personalizada
# ==============================================================================

# Colores
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Activar manejo estricto de errores
set -euo pipefail
trap 'echo -e "${RED}[ERROR] Ocurrió un error en la línea $LINENO.${NC}"' ERR

# Validar conectividad a Internet
if ! ping -c 1 8.8.8.8 &>/dev/null; then
    echo -e "${RED}[ERROR] No hay conexión a Internet. Verifica tu red.${NC}"
    exit 1
fi

clear
echo -e "${CYAN}"
cat << "EOF"
  /$$$$$$  /$$$$$$  /$$$$$$$$ /$$$$$$ /$$
 /$$__  $$/$$__  $$|_____ $$ |_  $$_/| $$
| $$  \__/ $$  \ $$     /$$/   | $$  | $$
| $$     | $$$$$$$$    /$$/    | $$  | $$
| $$     | $$__  $$   /$$/     | $$  | $$
| $$    $| $$  | $$  /$$$$$$$$ | $$  | $$
|  $$$$$$| $$  | $$ |________//$$$$$$| $$$$$$$$
 \______/|__/  |__/          |______/|________/
EOF
echo -e "      >> MODULAR DEPLOYMENT v9.0 <<${NC}\n"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
LOG_FILE="/tmp/cazil_install_$(date +%Y%m%d_%H%M%S).log"

# Helper para logging
log() {
    echo -e "${1}" | tee -a "$LOG_FILE"
}

# Helper para preguntas
ask() {
    local prompt="$1"
    
    # Si está en modo automático, siempre devuelve true (sí)
    if [ "$AUTO_INSTALL" = true ]; then
        echo -e "${GREEN}[AUTO] ${prompt} → SÍ${NC}"
        return 0
    fi
    
    # Modo normal: preguntar al usuario
    local response
    echo -e "${YELLOW}[?] ${prompt} (s/n)${NC}"
    read -r response
    [[ "$response" =~ ^([sS][iI]|[sS])$ ]]
}

# Función para verificar si un paquete ya está instalado
is_installed() {
    dpkg -l "$1" &>/dev/null
}

# Helper para verificar comandos
command_exists() {
    command -v "$1" &> /dev/null
}

# ==============================================================================
# SECCIÓN 1: INSTALACIÓN DE COMPONENTES INDIVIDUALES
# ==============================================================================

install_system_base() {
    log "${CYAN}[*] Actualizando sistema...${NC}"
    sudo apt update && sudo apt upgrade -y
    
    log "${CYAN}[*] Instalando paquetes base del sistema...${NC}"
    for pkg in curl git wget gnupg2 build-essential net-tools software-properties-common unzip; do
        if ! is_installed "$pkg"; then
            sudo apt install -y "$pkg"
        else
            log "${GREEN}[OK] $pkg ya instalado.${NC}"
        fi
    done
}

# --- HYPRLAND ---
install_hyprland() {
    if ask "¿Instalar Hyprland (Compositor Wayland)?"; then
        if ! command_exists Hyprland; then
            log "${CYAN}[*] Instalando Hyprland...${NC}"
            sudo apt install -y hyprland
            log "${GREEN}[OK] Hyprland instalado.${NC}"
        else
            log "${GREEN}[OK] Hyprland ya está instalado.${NC}"
        fi
    fi
}

# --- WAYBAR ---
install_waybar() {
    if ask "¿Instalar Waybar (Barra de estado)?"; then
        if ! command_exists waybar; then
            log "${CYAN}[*] Instalando Waybar...${NC}"
            sudo apt install -y waybar
            log "${GREEN}[OK] Waybar instalado.${NC}"
        else
            log "${GREEN}[OK] Waybar ya está instalado.${NC}"
        fi
    fi
}

# --- KITTY ---
install_kitty() {
    if ask "¿Instalar Kitty (Terminal emulator)?"; then
        if ! command_exists kitty; then
            log "${CYAN}[*] Instalando Kitty...${NC}"
            sudo apt install -y kitty
            log "${GREEN}[OK] Kitty instalado.${NC}"
        else
            log "${GREEN}[OK] Kitty ya está instalado.${NC}"
        fi
    fi
}

# --- WOFI ---
install_wofi() {
    if ask "¿Instalar Wofi (Lanzador de aplicaciones Wayland)?"; then
        if ! command_exists wofi; then
            log "${CYAN}[*] Instalando Wofi...${NC}"
            sudo apt install -y wofi
            log "${GREEN}[OK] Wofi instalado.${NC}"
        else
            log "${GREEN}[OK] Wofi ya está instalado.${NC}"
        fi
    fi
}

# --- UTILIDADES WAYLAND ---
install_wayland_utils() {
    if ask "¿Instalar utilidades de Wayland (wl-clipboard, grim, slurp, swww)?"; then
        log "${CYAN}[*] Instalando utilidades de Wayland...${NC}"
        for pkg in wl-clipboard grim slurp swww; do
            if ! is_installed "$pkg"; then
                sudo apt install -y "$pkg" || log "${YELLOW}[!] No se pudo instalar $pkg${NC}"
            fi
        done
        log "${GREEN}[OK] Utilidades de Wayland instaladas.${NC}"
    fi
}

# --- NOTIFICACIONES Y PORTAPAPELES ---
install_notifications_clipboard() {
    if ask "¿Instalar notificaciones (Mako) y portapapeles (cliphist)?"; then
        log "${CYAN}[*] Instalando Mako y cliphist...${NC}"
        sudo apt install -y mako-notifier
        
        # cliphist - puede no estar en repos, instalar desde binario
        if ! command_exists cliphist; then
            local tmpdir=$(mktemp -d)
            cd "$tmpdir"
            wget -q https://github.com/sentriz/cliphist/releases/latest/download/cliphist-linux-amd64
            chmod +x cliphist-linux-amd64
            sudo mv cliphist-linux-amd64 /usr/local/bin/cliphist
            cd ~ && rm -rf "$tmpdir"
        fi
        
        log "${GREEN}[OK] Notificaciones y portapapeles instalados.${NC}"
    fi
}

# --- POLKIT Y AUTENTICACIÓN ---
install_polkit() {
    if ask "¿Instalar Polkit Agent (autenticación GUI para sudo)?"; then
        log "${CYAN}[*] Instalando Polkit GNOME Agent...${NC}"
        sudo apt install -y polkit-gnome
        log "${GREEN}[OK] Polkit Agent instalado.${NC}"
    fi
}

# --- CURSOR Y TEMAS ---
install_cursor_themes() {
    if ask "¿Instalar cursor Bibata y herramientas de temas Qt/GTK?"; then
        log "${CYAN}[*] Instalando cursor Bibata y temas...${NC}"
        
        # Cursor Bibata
        if [ ! -d "$HOME/.local/share/icons/Bibata-Modern-Classic" ]; then
            local tmpdir=$(mktemp -d)
            cd "$tmpdir"
            wget -q https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Classic.tar.xz
            tar -xf Bibata-Modern-Classic.tar.xz
            mkdir -p "$HOME/.local/share/icons"
            mv Bibata-Modern-Classic "$HOME/.local/share/icons/"
            cd ~ && rm -rf "$tmpdir"
            log "${GREEN}[OK] Cursor Bibata instalado${NC}"
        fi
        
        # Qt/GTK theming tools
        sudo apt install -y qt6ct lxappearance
        
        log "${GREEN}[OK] Cursor y herramientas de temas instalados.${NC}"
    fi
}

# --- AUDIO Y MULTIMEDIA ---
install_audio() {
    if ask "¿Instalar herramientas de audio (PulseAudio + Pavucontrol + Pamixer)?"; then
        log "${CYAN}[*] Instalando herramientas de audio...${NC}"
        sudo apt install -y pavucontrol pamixer pulseaudio
        log "${GREEN}[OK] Audio configurado.${NC}"
    fi
}

# --- BRILLO Y ENERGÍA ---
install_brightness() {
    if ask "¿Instalar control de brillo (brightnessctl)?"; then
        if ! command_exists brightnessctl; then
            sudo apt install -y brightnessctl
            log "${GREEN}[OK] brightnessctl instalado.${NC}"
        else
            log "${GREEN}[OK] brightnessctl ya instalado.${NC}"
        fi
    fi
}

# --- HYPRLOCK + HYPRIDLE ---
install_lock_idle() {
    if ask "¿Instalar Hyprlock + Hypridle (Bloqueo y suspensión)?"; then
        log "${CYAN}[*] Instalando hyprlock + hypridle...${NC}"
        sudo apt install -y hyprlock hypridle || log "${YELLOW}[!] Instalar manualmente si falla${NC}"
        log "${GREEN}[OK] Hyprlock + Hypridle configurados.${NC}"
    fi
}

# --- NERD FONTS ---
install_nerd_fonts() {
    if ask "¿Instalar JetBrainsMono Nerd Font?"; then
        if [ ! -f "$HOME/.local/share/fonts/JetBrainsMonoNerdFont-Regular.ttf" ]; then
            log "${CYAN}[*] Descargando JetBrainsMono Nerd Font...${NC}"
            mkdir -p ~/.local/share/fonts
            local tmpzip=$(mktemp --suffix=.zip)
            wget -q --show-progress https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip -O "$tmpzip"
            unzip -o "$tmpzip" -d ~/.local/share/fonts
            rm "$tmpzip"
            fc-cache -fv
            log "${GREEN}[OK] Fuentes instaladas.${NC}"
        else
            log "${GREEN}[OK] Fuentes ya instaladas.${NC}"
        fi
    fi
}

# --- FASTFETCH ---
install_fastfetch() {
    if ask "¿Instalar Fastfetch (System info)?"; then
        if ! command_exists fastfetch; then
            log "${CYAN}[*] Descargando Fastfetch...${NC}"
            local tmpdeb=$(mktemp --suffix=.deb)
            if wget -q --show-progress https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb -O "$tmpdeb"; then
                sudo dpkg -i "$tmpdeb" && sudo apt -f install -y
                rm -f "$tmpdeb"
                log "${GREEN}[OK] Fastfetch instalado.${NC}"
            fi
        else
            log "${GREEN}[OK] Fastfetch ya instalado.${NC}"
        fi
    fi
}

# --- STARSHIP ---
install_starship() {
    if ask "¿Instalar Starship (Prompt)?"; then
        if ! command_exists starship; then
            log "${CYAN}[*] Instalando Starship...${NC}"
            sudo apt install -y starship || curl -sS https://starship.rs/install.sh | sh -s -- -y
            log "${GREEN}[OK] Starship instalado.${NC}"
        else
            log "${GREEN}[OK] Starship ya instalado.${NC}"
        fi
    fi
}

# --- ZSH + OH-MY-ZSH ---
install_zsh() {
    if ask "¿Instalar ZSH + Oh-My-Zsh + plugins?"; then
        sudo apt install -y zsh zsh-autosuggestions zsh-syntax-highlighting
        
        if [ ! -d "$HOME/.oh-my-zsh" ]; then
            log "${CYAN}[*] Instalando Oh-My-Zsh...${NC}"
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        fi
        
        ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
        [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && \
            git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        
        [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && \
            git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        
        if [ "$SHELL" != "$(which zsh)" ]; then
            sudo chsh -s "$(which zsh)" "$USER"
            log "${GREEN}[OK] ZSH configurado como shell por defecto${NC}"
        fi
        log "${GREEN}[OK] ZSH instalado.${NC}"
    fi
}

# --- THUNAR (File Manager) ---
install_thunar() {
    if ask "¿Instalar Thunar (Gestor de archivos)?"; then
        sudo apt install -y thunar thunar-archive-plugin file-roller
        log "${GREEN}[OK] Thunar instalado.${NC}"
    fi
}

# --- KEEPASSXC ---
install_keepassxc() {
    if ask "¿Instalar KeePassXC (Gestor de contraseñas)?"; then
        sudo apt install -y keepassxc
        log "${GREEN}[OK] KeePassXC instalado.${NC}"
    fi
}

# --- NAVEGADORES ---
install_browsers() {
    if ask "¿Instalar navegadores (Brave, Waterfox, Vivaldi, Firefox)?"; then
        log "${CYAN}[*] Configurando repositorios de navegadores...${NC}"
        
        # BRAVE
        if ! command_exists brave-browser; then
            sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
                https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
                | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
        fi
        
        # WATERFOX
        if ! command_exists waterfox-g4; then
            curl -fsSL https://apt.waterfox.net/gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/waterfox.gpg
            echo "deb [arch=amd64] https://apt.waterfox.net/ waterfox main" \
                | sudo tee /etc/apt/sources.list.d/waterfox.list
        fi

        # VIVALDI
        if ! command_exists vivaldi-stable; then
            wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/vivaldi-archive-keyring.gpg
            echo "deb [arch=amd64 signed-by=/usr/share/keyrings/vivaldi-archive-keyring.gpg] https://repo.vivaldi.com/archive/deb/ stable main" \
                | sudo tee /etc/apt/sources.list.d/vivaldi.list
        fi

        sudo apt update
        sudo apt install -y firefox-esr brave-browser waterfox-g4-kpe vivaldi-stable
        log "${GREEN}[OK] Navegadores instalados.${NC}"
    fi
}

# --- MULTIMEDIA ---
install_multimedia() {
    if ask "¿Instalar suite multimedia (VLC, visores de imagen, Yazi)?";
        log "${CYAN}[*] Instalando multimedia...${NC}"
        sudo apt install -y vlc feh imv thunar-archive-plugin file-roller
        
        # Yazi (gestor archivos terminal moderno)
        if ! command_exists yazi; then
            log "${CYAN}[*] Instalando Yazi...${NC}"
            if ! sudo apt install -y yazi 2>/dev/null; then
                log "${YELLOW}[!] Yazi no disponible en repos, instalando desde GitHub...${NC}"
                local tmpzip=$(mktemp --suffix=.zip)
                wget -q --show-progress https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip -O "$tmpzip"
                unzip -q "$tmpzip" && sudo mv yazi-*/yazi /usr/local/bin/
                rm -rf "$tmpzip" yazi-*
                log "${GREEN}[OK] Yazi instalado desde GitHub${NC}"
            fi
        fi
        
        log "${GREEN}[OK] Suite multimedia instalada.${NC}"
    fi
}

# --- OFICINA ---
install_office() {
    if ask "¿Instalar suite de oficina (Zathura PDF + Impresoras)?";
        log "${CYAN}[*] Instalando suite de oficina...${NC}"
        sudo apt install -y zathura zathura-pdf-poppler \
            cups system-config-printer avahi-daemon printer-driver-all \
            sane-airscan simple-scan
        
        sudo systemctl enable --now cups avahi-daemon
        
        log "${GREEN}[OK] Oficina configurada (PDF + impresoras).${NC}"
        log "${YELLOW}[INFO] Usa system-config-printer para configurar impresoras${NC}"
    fi
}

# --- CREATIVO ---
install_creative() {
    if ask "¿Instalar GIMP (editor de imágenes)?";
        log "${RED}[!] Advertencia: GIMP añade ~500MB de dependencias${NC}"
        if ask "¿Continuar con la instalación de GIMP?";
            log "${CYAN}[*] Instalando GIMP...${NC}"
            sudo apt install -y gimp
            log "${GREEN}[OK] GIMP instalado.${NC}"
        fi
    fi
}

# --- NVIDIA DRIVERS ---
install_nvidia() {
    if ask "¿Instalar drivers NVIDIA propietarios?"; then
        if ! command_exists nvidia-smi; then
            log "${CYAN}[*] Instalando NVIDIA...${NC}"
            sudo dpkg --add-architecture i386
            sudo apt update
            sudo apt install -y linux-headers-$(uname -r) dkms build-essential
            sudo apt install -y nvidia-driver firmware-misc-nonfree nvidia-settings \
                libnvidia-gl-wayland libnvidia-egl-wayland1 libgl1-nvidia-glx:i386
            
            # Activar modeset en GRUB
            if ! grep -q "nvidia-drm.modeset=1" /etc/default/grub; then
                sudo sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/ s/"$/ nvidia-drm.modeset=1"/' /etc/default/grub
                sudo update-grub
            fi
            
            # Agregar módulos NVIDIA para cargar al inicio
            log "${CYAN}[*] Configurando módulos NVIDIA para carga automática...${NC}"
            echo "nvidia" | sudo tee /etc/modules-load.d/nvidia.conf
            echo "nvidia-drm" | sudo tee -a /etc/modules-load.d/nvidia.conf
            echo "nvidia-modeset" | sudo tee -a /etc/modules-load.d/nvidia.conf
            echo "nvidia-uvm" | sudo tee -a /etc/modules-load.d/nvidia.conf
            
            # Configurar opciones de módulo para DRM
            echo "options nvidia-drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf
            
            # Regenerar initramfs
            sudo update-initramfs -u
            
            log "${GREEN}[OK] NVIDIA instalado y configurado.${NC}"
            log "${YELLOW}[!] IMPORTANTE: Debes reiniciar el sistema para aplicar cambios.${NC}"
        else
            log "${GREEN}[OK] NVIDIA ya instalado ($(nvidia-smi --query-gpu=driver_version --format=csv,noheader))${NC}"
        fi
    fi
}

# --- ACER RGB KEYBOARD ---
install_acer_rgb() {
    if ask "¿Instalar módulo RGB para Acer Predator/Nitro?"; then
        if ! lsmod | grep -q "acer-predator"; then
            log "${CYAN}[*] Instalando módulo Acer RGB...${NC}"
            sudo apt install -y python3-pip python3-wxgtk4.0 dkms
            
            local tmpdir=$(mktemp -d)
            cd "$tmpdir"
            git clone --depth=1 https://github.com/JafarAkhondali/acer-predator-turbo-and-rgb-keyboard-linux-module.git .
            
            sudo cp -r . /usr/src/acer-predator-1.0
            cat <<EOF | sudo tee /usr/src/acer-predator-1.0/dkms.conf
PACKAGE_NAME="acer-predator"
PACKAGE_VERSION="1.0"
BUILT_MODULE_NAME[0]="acer-predator-turbo-and-rgb-keyboard-linux-module"
DEST_MODULE_LOCATION[0]="/kernel/drivers/platform/x86"
AUTOINSTALL="yes"
EOF
            
            sudo dkms add -m acer-predator -v 1.0
            sudo dkms build -m acer-predator -v 1.0
            sudo dkms install -m acer-predator -v 1.0
            
            echo "acer-predator-turbo-and-rgb-keyboard-linux-module" | sudo tee /etc/modules-load.d/acer-predator.conf
            sudo modprobe acer-predator-turbo-and-rgb-keyboard-linux-module
            
            cd ~ && rm -rf "$tmpdir"
            log "${GREEN}[OK] Módulo Acer RGB instalado.${NC}"
        else
            log "${GREEN}[OK] Módulo Acer RGB ya cargado.${NC}"
        fi
    fi
}

# --- SEGURIDAD ---
install_security_suite() {
    if ask "¿Activar Suite de Seguridad (UFW, Fail2Ban, ClamAV, RKHunter, Firejail, USBGuard)?"; then
        log "${CYAN}[*] Instalando suite de seguridad...${NC}"
        sudo apt install -y ufw fail2ban clamav rkhunter firejail usbguard
        
        # Configurar UFW (Firewall)
        log "${CYAN}[*] Configurando UFW (Firewall)...${NC}"
        sudo ufw --force default deny incoming
        sudo ufw --force default allow outgoing
        sudo ufw --force enable
        
        # Activar servicios
        sudo systemctl enable --now fail2ban usbguard
        
        # Actualizar bases de datos
        log "${CYAN}[*] Actualizando bases de datos de seguridad...${NC}"
        sudo freshclam || log "${YELLOW}[!] No se pudo actualizar ClamAV (normal en primera instalación)${NC}"
        sudo rkhunter --propupd
        
        log "${GREEN}[OK] Suite de seguridad activada.${NC}"
        log "${YELLOW}[INFO] Firewall UFW activo - Bloqueando conexiones entrantes${NC}"
        log "${YELLOW}[INFO] Fail2Ban monitoreando intentos de acceso${NC}"
        log "${YELLOW}[INFO] USBGuard requiere configuración inicial: sudo usbguard generate-policy > /etc/usbguard/rules.conf${NC}"
    fi
}

# --- LOCALES ---
configure_locales() {
    if ask "¿Configurar locales y teclado (ES_PE Latinoamérica)?"; then
        log "${CYAN}[*] Generando locales...${NC}"
        sudo sed -i 's/^# *es_PE.UTF-8/es_PE.UTF-8/' /etc/locale.gen
        sudo locale-gen
        
        log "${CYAN}[*] Configurando teclado latinoamericano...${NC}"
        sudo localectl set-keymap latam
        
        log "${GREEN}[OK] Locales y teclado configurados (es_PE + latam).${NC}"
    fi
}

# --- DOCKER ---
install_docker() {
    if ask "¿Instalar Docker + Docker Compose?"; then
        if ! command_exists docker; then
            log "${CYAN}[*] Instalando Docker...${NC}"
            sudo apt install -y ca-certificates curl gnupg lsb-release

            sudo mkdir -p /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
              $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

            sudo apt update
            sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

            sudo usermod -aG docker $USER
            log "${GREEN}[OK] Docker instalado. Reinicia sesión para aplicar cambios.${NC}"
        else
            log "${GREEN}[OK] Docker ya instalado.${NC}"
        fi
    fi
}

# --- TLP (Power Management) ---
install_tlp() {
    if ask "¿Instalar TLP (Gestión de energía)?"; then
        sudo apt install -y tlp tlp-rdw
        sudo systemctl enable --now tlp
        sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket
        log "${GREEN}[OK] TLP activado.${NC}"
    fi
}

# --- PLYMOUTH THEME ---
install_plymouth_theme() {
    if ask "¿Instalar tema Plymouth CAZIL?"; then
        log "${CYAN}[*] Instalando tema Plymouth...${NC}"
        
        sudo apt install -y plymouth plymouth-themes imagemagick
        sudo mkdir -p /usr/share/plymouth/themes/cazil-cyber
        
        if [ -f "$DOTFILES_DIR/plymouth/themes/cazil-cyber.plymouth" ]; then
            sudo cp "$DOTFILES_DIR/plymouth/themes/cazil-cyber.plymouth" /usr/share/plymouth/themes/cazil-cyber/
            sudo cp "$DOTFILES_DIR/plymouth/themes/cazil-cyber.script" /usr/share/plymouth/themes/cazil-cyber/
            
            # Copiar fondo con logo
            if [ -f "$DOTFILES_DIR/wallpapers/bg_grub1_con_logo.png" ]; then
                sudo cp "$DOTFILES_DIR/wallpapers/bg_grub1_con_logo.png" /usr/share/plymouth/themes/cazil-cyber/
            fi
            
            # Crear imágenes de barra de progreso si imagemagick está disponible
            if command -v convert &>/dev/null; then
                log "${CYAN}[*] Creando imágenes de barra de progreso...${NC}"
                sudo convert -size 400x20 xc:'#1a1b2e' -fill '#33ccff' -draw "rectangle 0,0 0,20" \
                    /usr/share/plymouth/themes/cazil-cyber/progress_box.png
                sudo convert -size 400x20 xc:'#00d9ff' \
                    /usr/share/plymouth/themes/cazil-cyber/progress_bar.png
            else
                log "${YELLOW}[!] ImageMagick no disponible, se omiten barras de progreso animadas${NC}"
            fi
            
            # Establecer como tema por defecto
            sudo plymouth-set-default-theme -R cazil-cyber
            sudo update-initramfs -u
            log "${GREEN}[OK] Tema Plymouth instalado.${NC}"
        else
            log "${RED}[!] No se encontró plymouth/themes/cazil-cyber.plymouth${NC}"
        fi
    fi
}

# --- GRUB THEME ---
install_grub_theme() {
    if ask "¿Configurar tema GRUB CAZIL?"; then
        log "${CYAN}[*] Configurando tema GRUB...${NC}"

        sudo mkdir -p /boot/grub/themes/cazil
        
        if [ -f "$DOTFILES_DIR/grub/theme.txt" ]; then
            sudo cp "$DOTFILES_DIR/grub/theme.txt" /boot/grub/themes/cazil/
            
            if [ -f "$DOTFILES_DIR/wallpapers/bg_grub1_con_logo.png" ]; then
                sudo cp "$DOTFILES_DIR/wallpapers/bg_grub1_con_logo.png" /boot/grub/themes/cazil/
            fi

            if ! grep -q "^GRUB_THEME=" /etc/default/grub; then
                echo 'GRUB_THEME="/boot/grub/themes/cazil/theme.txt"' | sudo tee -a /etc/default/grub
            else
                sudo sed -i 's|^GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/cazil/theme.txt"|' /etc/default/grub
            fi

            if ! grep -q "^GRUB_GFXMODE=" /etc/default/grub; then
                echo "GRUB_GFXMODE=1920x1080" | sudo tee -a /etc/default/grub
                echo "GRUB_GFXPAYLOAD_LINUX=keep" | sudo tee -a /etc/default/grub
            fi

            sudo update-grub
            log "${GREEN}[OK] Tema GRUB configurado.${NC}"
        else
            log "${RED}[!] No se encontró grub/theme.txt${NC}"
        fi
    fi
}

# --- AUTO-INICIO DE HYPRLAND ---
configure_hyprland_autostart() {
    if ask "¿Configurar inicio automático de Hyprland al login?"; then
        log "${CYAN}[*] Configurando auto-inicio de Hyprland...${NC}"
        
        # ~/.bash_profile
        cat > "$HOME/.bash_profile" << 'BASH_PROFILE_EOF'
# Auto-inicio de Hyprland en tty1
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
    exec Hyprland
fi
BASH_PROFILE_EOF
        
        log "${GREEN}[OK] ~/.bash_profile configurado${NC}"
        
        # ~/.zprofile (si usa zsh)
        if command_exists zsh; then
            cat > "$HOME/.zprofile" << 'ZPROFILE_EOF'
# Auto-inicio de Hyprland en tty1
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
    exec Hyprland
fi
ZPROFILE_EOF
            log "${GREEN}[OK] ~/.zprofile configurado${NC}"
        fi
        
        log "${YELLOW}[!] Hyprland se iniciará automáticamente en tty1 después del login${NC}"
    fi
}

# ==============================================================================
# SECCIÓN 2: APLICACIÓN DE DOTFILES CAZIL
# ==============================================================================

apply_cazil_dotfiles() {
    if ask "¿Aplicar las configuraciones personalizadas de CAZIL-DOTS?"; then
        log "\n${MAGENTA}═══════════════════════════════════════════════${NC}"
        log "${MAGENTA}  APLICANDO DOTFILES CAZIL${NC}"
        log "${MAGENTA}═══════════════════════════════════════════════${NC}\n"
        
        # Helper para crear symlinks
        link_component() {
            local source=$1
            local target=${2:-$1}
            local src_path="$DOTFILES_DIR/$source"

            if [[ "$target" = /* ]]; then
                local tgt_path="$target"
            elif [[ "$target" = .* ]]; then
                local tgt_path="$HOME/$target"
            else
                local tgt_path="$CONFIG_DIR/$target"
            fi

            if [ ! -e "$src_path" ]; then
                log "${RED}[!] No existe: $src_path${NC}"
                return 1
            fi

            mkdir -p "$(dirname "$tgt_path")"

            if [ -e "$tgt_path" ] && [ ! -L "$tgt_path" ]; then
                local backup="${tgt_path}.bak.$(date +%s)"
                mv "$tgt_path" "$backup"
                log "${YELLOW}[BAK] $target -> $(basename $backup)${NC}"
            fi

            [ -L "$tgt_path" ] && rm -f "$tgt_path"
            ln -s "$src_path" "$tgt_path"
            log "${GREEN}[✓] $target → $source${NC}"
        }
        
        # Configuraciones disponibles
        echo -e "\n${CYAN}Configuraciones de CAZIL disponibles:${NC}"
        echo -e "  • Hyprland (hypr/)"
        echo -e "  • Waybar (waybar/)"
        echo -e "  • Kitty (kitty/)"
        echo -e "  • Wofi (wofi/)"
        echo -e "  • Starship (starship/)"
        echo -e "  • ZSH (.zshrc)"
        echo -e "  • Fastfetch (fastfetch/)"
        echo -e "  • Scripts (sscript/)"
        echo -e "  • Fuentes (fonts/)"
        echo -e "  • VSCode settings (vscode-user/)\n"
        
        # Vincular cada componente
        [ -d "$DOTFILES_DIR/hypr" ] && link_component "hypr"
        [ -d "$DOTFILES_DIR/waybar" ] && link_component "waybar"
        [ -d "$DOTFILES_DIR/kitty" ] && link_component "kitty"
        [ -d "$DOTFILES_DIR/wofi" ] && link_component "wofi"
        [ -d "$DOTFILES_DIR/starship" ] && link_component "starship"
        [ -f "$DOTFILES_DIR/zsh/.zshrc" ] && link_component "zsh/.zshrc" ".zshrc"
        [ -d "$DOTFILES_DIR/fastfetch" ] && link_component "fastfetch"
        [ -d "$DOTFILES_DIR/sscript" ] && link_component "sscript" "scripts"
        
        # Fuentes (copiar config)
        if [ -f "$DOTFILES_DIR/fonts/10-nerd-font-symbols.conf" ]; then
            mkdir -p "$HOME/.config/fontconfig/conf.d"
            cp "$DOTFILES_DIR/fonts/10-nerd-font-symbols.conf" "$HOME/.config/fontconfig/conf.d/"
            log "${GREEN}[✓] Configuración de fuentes aplicada${NC}"
        fi
        
        # VSCode (si existe)
        if [ -d "$DOTFILES_DIR/vscode-user" ]; then
            link_component "vscode-user" ".config/Code/User"
        fi
        
        # Dar permisos de ejecución a scripts
        if [ -d "$HOME/.config/scripts" ]; then
            chmod +x "$HOME/.config/scripts"/*.sh 2>/dev/null || true
            chmod +x "$HOME/.config/scripts"/*.py 2>/dev/null || true
            log "${GREEN}[✓] Permisos de ejecución aplicados a scripts${NC}"
        fi
        
        log "\n${GREEN}╔════════════════════════════════════════════════╗${NC}"
        log "${GREEN}║   DOTFILES CAZIL APLICADOS EXITOSAMENTE       ║${NC}"
        log "${GREEN}╚════════════════════════════════════════════════╝${NC}\n"
    fi
}

# ==============================================================================
# EJECUCIÓN PRINCIPAL
# ==============================================================================

main() {
    log "${CYAN}════════════════════════════════════════════════${NC}"
    log "${CYAN}  MODO DE INSTALACIÓN${NC}"
    log "${CYAN}════════════════════════════════════════════════${NC}\n"
    
    echo -e "${YELLOW}Selecciona el modo de instalación:${NC}"
    echo -e "${GREEN}[1]${NC} Instalación Completa (instala TODO automáticamente)"
    echo -e "${GREEN}[2]${NC} Instalación Personalizada (pregunta componente por componente)"
    echo -e "${GREEN}[3]${NC} Solo aplicar dotfiles CAZIL (sin instalar software)\n"
    
    read -p "Opción [1/2/3]: " INSTALL_MODE
    
    # Variable global para modo automático
    AUTO_INSTALL=false
    DOTFILES_ONLY=false
    
    case $INSTALL_MODE in
        1)
            log "${GREEN}[✓] Modo: Instalación Completa${NC}\n"
            AUTO_INSTALL=true
            ;;
        2)
            log "${GREEN}[✓] Modo: Instalación Personalizada${NC}\n"
            AUTO_INSTALL=false
            ;;
        3)
            log "${GREEN}[✓] Modo: Solo Dotfiles${NC}\n"
            DOTFILES_ONLY=true
            ;;
        *)
            log "${YELLOW}[!] Opción inválida, usando modo personalizado${NC}\n"
            AUTO_INSTALL=false
            ;;
    esac
    
    # Si solo quiere dotfiles, saltar instalación
    if [ "$DOTFILES_ONLY" = true ]; then
        log "\n${CYAN}════════════════════════════════════════════════${NC}"
        log "${CYAN}  APLICACIÓN DE DOTFILES CAZIL${NC}"
        log "${CYAN}════════════════════════════════════════════════${NC}\n"
        
        apply_cazil_dotfiles
        
        echo ""
        log "${GREEN}╔════════════════════════════════════════════════╗${NC}"
        log "${GREEN}║   DOTFILES CAZIL APLICADOS                    ║${NC}"
        log "${GREEN}╚════════════════════════════════════════════════╝${NC}\n"
        exit 0
    fi
    
    log "${CYAN}════════════════════════════════════════════════${NC}"
    log "${CYAN}  PASO 1: INSTALACIÓN DE COMPONENTES${NC}"
    log "${CYAN}════════════════════════════════════════════════${NC}\n"
    
    install_system_base
    
    # Componentes principales
    install_hyprland
    install_waybar
    install_kitty
    install_wofi
    install_wayland_utils
    
    # Herramientas de sistema
    install_audio
    install_brightness
    install_lock_idle
    install_notifications_clipboard
    install_polkit
    install_cursor_themes
    
    # Visuales
    install_nerd_fonts
    install_fastfetch
    install_starship
    
    # Shell
    install_zsh
    
    # Aplicaciones
    install_thunar
    install_keepassxc
    install_browsers
    install_multimedia
    install_office
    install_creative
    
    # Hardware específico
    install_nvidia
    install_acer_rgb
    
    # Seguridad
    install_security_suite
    
    # Sistema
    configure_locales
    
    # Desarrollo
    install_docker
    
    # Energía
    install_tlp
    
    # Boot
    install_plymouth_theme
    install_grub_theme
    
    # Auto-inicio
    configure_hyprland_autostart
    
    log "\n${CYAN}════════════════════════════════════════════════${NC}"
    log "${CYAN}  PASO 2: APLICACIÓN DE DOTFILES CAZIL${NC}"
    log "${CYAN}════════════════════════════════════════════════${NC}\n"
    
    apply_cazil_dotfiles
    
    # Resumen final
    echo ""
    log "${GREEN}╔════════════════════════════════════════════════╗${NC}"
    log "${GREEN}║   CAZIL SYSTEM v9.0 INSTALADO EXITOSAMENTE    ║${NC}"
    log "${GREEN}╚════════════════════════════════════════════════╝${NC}"
    
    log "\n${CYAN}════════════════════════════════════════════════${NC}"
    log "${CYAN}  PRÓXIMOS PASOS:${NC}"
    log "${CYAN}════════════════════════════════════════════════${NC}"
    log "${YELLOW}1.${NC} Reinicia el sistema: ${CYAN}sudo reboot${NC}"
    log "${YELLOW}2.${NC} Al iniciar sesión, Hyprland arrancará automáticamente"
    log "${YELLOW}3.${NC} Revisa el log completo: ${CYAN}cat $LOG_FILE${NC}"
    log "${YELLOW}4.${NC} Si instalaste NVIDIA, verifica: ${CYAN}nvidia-smi${NC}"
    log ""
    log "${GREEN}Log guardado en: $LOG_FILE${NC}\n"
}

main "$@"
