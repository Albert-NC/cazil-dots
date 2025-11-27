#!/bin/bash

# ==============================================================================
#   CAZIL SYSTEM - FINAL DEPLOYMENT PROTOCOL (v8.2 - FIXED)
#   Target: Debian Sid (Hyprland + NVIDIA + Acer Nitro + Brother)
# ==============================================================================

# Colores
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Activar manejo estricto de errores
set -euo pipefail
trap 'echo -e "${RED}[ERROR] Ocurrió un error en la línea $LINENO.${NC}"' ERR

# Validar conectividad a Internet antes de continuar
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
echo -e "      >> DEPLOYMENT PROTOCOL v8.2 <<${NC}\n"

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

# Validar integridad de descargas externas (OPCIONAL - requiere checksum conocido)
validate_checksum() {
    local file=$1
    local checksum=$2
    if [ "$checksum" != "SKIP" ]; then
        echo "$checksum  $file" | sha256sum -c - &>/dev/null
    fi
}

# --- 1. INSTALACIÓN BASE ---
install_base() {
    if ask "¿Instalar Núcleo del Sistema (Hyprland, Waybar, Rofi...)?"; then
        log "${CYAN}[*] Actualizando sistema...${NC}"
        sudo apt update && sudo apt upgrade -y
        
        log "${CYAN}[*] Instalando paquetes base...${NC}"
        for pkg in hyprland waybar kitty rofi-wayland curl git micro build-essential net-tools \
                   spice-vdagent libinput-tools keepassxc pavucontrol brightnessctl pamixer swww unzip \
                   wl-clipboard grim slurp wget gnupg2 software-properties-common; do
            if ! is_installed "$pkg"; then
                sudo apt install -y "$pkg"
            else
                log "${GREEN}[OK] $pkg ya instalado.${NC}"
            fi
        done
        log "${GREEN}[OK] Núcleo operativo.${NC}"
    fi
}

# --- 2. HERRAMIENTAS EXTERNAS ---
install_externals() {
    # FASTFETCH
    if ! command_exists fastfetch; then
        log "${CYAN}[*] Descargando Fastfetch...${NC}"
        local tmpdeb=$(mktemp --suffix=.deb)
        if wget -q --show-progress https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb -O "$tmpdeb"; then
            sudo dpkg -i "$tmpdeb" && sudo apt -f install -y
            rm -f "$tmpdeb"
        else
            log "${RED}[!] Fallo descarga Fastfetch${NC}"
        fi
    fi

    # NERD FONTS
    if ask "¿Instalar Fuentes Hacker (JetBrainsMono)?"; then
        if [ ! -f "$HOME/.local/share/fonts/JetBrainsMonoNerdFont-Regular.ttf" ]; then
            log "${CYAN}[*] Descargando JetBrainsMono...${NC}"
            mkdir -p ~/.local/share/fonts
            local tmpzip=$(mktemp --suffix=.zip)
            wget -q --show-progress https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip -O "$tmpzip"
            unzip -o "$tmpzip" -d ~/.local/share/fonts
            rm "$tmpzip"
            fc-cache -fv
            log "${GREEN}[OK] Fuentes instaladas.${NC}"
        else
            log "${YELLOW}[!] Fuentes ya instaladas${NC}"
        fi
    fi
}

# --- 3. HARDWARE (METAL) ---
install_hardware() {
    if ask "¿Estamos en METAL (NVIDIA + ACER)?"; then
        # NVIDIA PROPIETARIO
        if ! command_exists nvidia-smi; then
            log "${CYAN}[*] Instalando NVIDIA...${NC}"
            sudo dpkg --add-architecture i386
            sudo apt update
            sudo apt install -y linux-headers-$(uname -r) dkms build-essential
            sudo apt install -y nvidia-driver firmware-misc-nonfree nvidia-settings \
                libnvidia-gl-wayland libnvidia-egl-wayland1 libgl1-nvidia-glx:i386
            
            # PARCHE GRUB WAYLAND (solo si no existe)
            if ! grep -q "nvidia-drm.modeset=1" /etc/default/grub; then
                sudo sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/ s/"$/ nvidia-drm.modeset=1"/' /etc/default/grub
                sudo update-grub
            fi
        else
            log "${YELLOW}[!] NVIDIA ya instalado ($(nvidia-smi --query-gpu=driver_version --format=csv,noheader))${NC}"
        fi

        # ACER RGB
        if ! lsmod | grep -q "acer-predator"; then
            log "${CYAN}[*] Instalando módulo Acer RGB...${NC}"
            sudo apt install -y python3-pip python3-wxgtk4.0
            
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
            
            # Autoload en boot
            echo "acer-predator-turbo-and-rgb-keyboard-linux-module" | sudo tee /etc/modules-load.d/acer-predator.conf
            sudo modprobe acer-predator-turbo-and-rgb-keyboard-linux-module
            
            # GUI (opcional)
            if ask "¿Instalar GUI de control RGB?"; then
                local gui_url=$(curl -s https://api.github.com/repos/x211321/RGB-Config-Acer-gkbbl-0/releases/latest | grep "browser_download_url.*deb" | cut -d '"' -f 4)
                wget -q "$gui_url" -O acer_gui.deb
                sudo apt install -y ./acer_gui.deb || true
                rm acer_gui.deb
            fi
            
            cd ~ && rm -rf "$tmpdir"
            log "${GREEN}[OK] Hardware Acer configurado.${NC}"
        else
            log "${YELLOW}[!] Módulo Acer ya cargado${NC}"
        fi
    fi
}

# --- 4. SOFTWARE SUITE ---
install_software() {
    if ask "¿Instalar Software Suite (Browsers, Files, Gaming)?"; then
        log "${CYAN}[*] Configurando repositorios externos...${NC}"
        
        sudo dpkg --add-architecture i386
        
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
        
        # Navegadores y utilidades
        sudo apt install -y firefox-esr brave-browser waterfox-g4-kpe vivaldi-stable vlc \
            thunar thunar-archive-plugin file-roller feh imv
        
        # Yazi
        if ! command_exists yazi; then
            if ! sudo apt install -y yazi 2>/dev/null; then
                local tmpzip=$(mktemp --suffix=.zip)
                wget -q https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip -O "$tmpzip"
                unzip -q "$tmpzip" && sudo mv yazi-*/yazi /usr/local/bin/
                rm -rf "$tmpzip" yazi-*
            fi
        fi

        # Gaming
        if ask "¿Instalar paquetes de Gaming (Steam, Proton)?"; then
            sudo apt install -y steam-installer gamemode mangohud mesa-utils vulkan-tools \
                libvulkan1 libvulkan1:i386
        fi

        log "${GREEN}[OK] Software desplegado.${NC}"
    fi
}

# --- 5. PRODUCTIVIDAD ---
install_productivity() {
    if ask "¿Instalar Oficina (Zathura PDF + Impresora)?"; then
        sudo apt install -y zathura zathura-pdf-poppler \
            cups system-config-printer avahi-daemon printer-driver-all sane-airscan simple-scan
        sudo systemctl enable --now cups avahi-daemon
        log "${GREEN}[OK] Oficina lista.${NC}"
    fi
}

# --- 6. SUITE CREATIVA ---
install_creative_suite() {
    if ask "¿Instalar GIMP?"; then
        log "${RED}[!] Advertencia: GIMP añade ~500MB de dependencias${NC}"
        if ask "¿Continuar?"; then
            sudo apt install -y gimp
            log "${GREEN}[OK] GIMP instalado.${NC}"
        fi
    fi
}

# --- 7. POWER & ENERGÍA ---
install_power() {
    if ask "¿Instalar Gestión de Energía (Hyprlock + TLP)?"; then
        sudo apt install -y hyprlock hypridle tlp tlp-rdw
        sudo systemctl enable --now tlp
        sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket
        log "${GREEN}[OK] TLP activado.${NC}"
    fi
}

# --- 8. ZSH SUITE ---
install_zsh_suite() {
    if ask "¿Instalar ZSH + Oh-My-Zsh + Starship?"; then
        sudo apt install -y zsh curl git starship zsh-autosuggestions zsh-syntax-highlighting
        
        if [ ! -d "$HOME/.oh-my-zsh" ]; then
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
    fi
}

# --- 9. DOCKER ---
install_docker() {
    if ask "¿Instalar Docker y Docker Compose?"; then
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

        log "${GREEN}[OK] Docker instalado.${NC}"
        log "${YELLOW}[!] Reinicia sesión para aplicar cambios.${NC}"
    fi
}

# --- 10. CONFIGURACIÓN DE SISTEMA ---
configure_system() {
    # LOCALES
    if ask "¿Generar Locale ES_PE + EN_US?"; then
        sudo sed -i 's/^# *es_PE.UTF-8/es_PE.UTF-8/' /etc/locale.gen
        sudo sed -i 's/^# *en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
        sudo locale-gen
    fi

    # SEGURIDAD
    if ask "¿Activar Suite de Seguridad (UFW/Fail2Ban)?"; then
        sudo apt install -y ufw fail2ban clamav rkhunter firejail usbguard
        
        sudo ufw --force default deny incoming
        sudo ufw --force default allow outgoing
        sudo ufw --force enable
        
        sudo systemctl enable --now fail2ban usbguard
        sudo freshclam
        sudo rkhunter --propupd
        
        log "${GREEN}[OK] Seguridad activada.${NC}"
    fi
}

# --- 11. PLYMOUTH THEME (LUKS) ---
install_plymouth_theme() {
    if ask "¿Instalar tema Plymouth para LUKS?"; then
        log "${CYAN}[*] Instalando tema Plymouth CAZIL...${NC}"
        
        # Instalar plymouth si no está
        sudo apt install -y plymouth plymouth-themes
        
        # Crear directorio del tema
        sudo mkdir -p /usr/share/plymouth/themes/cazil-cyber
        
        # Copiar archivos del tema
        sudo cp "$DOTFILES_DIR/plymouth/themes/cazil-cyber.plymouth" /usr/share/plymouth/themes/cazil-cyber/
        sudo cp "$DOTFILES_DIR/plymouth/themes/cazil-cyber.script" /usr/share/plymouth/themes/cazil-cyber/
        
        # Copiar imágenes
        [ -f "$DOTFILES_DIR/wallpapers/bg_grub1_con_logo.png" ] && sudo cp "$DOTFILES_DIR/wallpapers/bg_grub1_con_logo.png" /usr/share/plymouth/themes/cazil-cyber/
        [ -f "$DOTFILES_DIR/wallpapers/cazil_logo.png" ] && sudo cp "$DOTFILES_DIR/wallpapers/cazil_logo.png" /usr/share/plymouth/themes/cazil-cyber/logo.png
        
        # Crear imágenes de barra de progreso (si no existen)
        if command -v convert &>/dev/null; then
            sudo convert -size 400x20 xc:'#1a1b26' -fill '#33ccff' -draw "rectangle 0,0 0,20" /usr/share/plymouth/themes/cazil-cyber/progress_box.png
            sudo convert -size 400x20 xc:'#00d9ff' /usr/share/plymouth/themes/cazil-cyber/progress_bar.png
        fi
        
        # Establecer como tema por defecto
        sudo plymouth-set-default-theme -R cazil-cyber
        
        # Actualizar initramfs
        sudo update-initramfs -u
        
        log "${GREEN}[OK] Tema Plymouth instalado.${NC}"
    fi
}

# --- 12. CONFIGURACIÓN GRUB ---
install_grub_theme() {
    if ask "¿Configurar GRUB con tema personalizado?"; then
        log "${CYAN}[*] Configurando tema GRUB...${NC}"

        # Copiar fondo (con logo integrado)
        local grub_bg="$DOTFILES_DIR/wallpapers/bg_grub1_con_logo.png"
        
        # Crear directorio del tema GRUB
        sudo mkdir -p /boot/grub/themes/cazil
        
        # Copiar theme.txt
        sudo cp "$DOTFILES_DIR/grub/theme.txt" /boot/grub/themes/cazil/
        
        # Copiar fondo con logo
        if [ -f "$grub_bg" ]; then
            sudo cp "$grub_bg" /boot/grub/themes/cazil/bg_grub1_con_logo.png
        else
            log "${YELLOW}[!] No se encontró bg_grub1_con_logo.png${NC}"
        fi

        # Configurar GRUB para usar el tema
        if ! grep -q "^GRUB_THEME=" /etc/default/grub; then
            echo 'GRUB_THEME="/boot/grub/themes/cazil/theme.txt"' | sudo tee -a /etc/default/grub
        else
            sudo sed -i 's|^GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/cazil/theme.txt"|' /etc/default/grub
        fi

        # Habilitar resolución y splash
        if ! grep -q "^GRUB_GFXMODE=" /etc/default/grub; then
            echo "GRUB_GFXMODE=1920x1080" | sudo tee -a /etc/default/grub
            echo "GRUB_GFXPAYLOAD_LINUX=keep" | sudo tee -a /etc/default/grub
        fi

        sudo update-grub
        log "${GREEN}[OK] Tema GRUB configurado.${NC}"
    fi
}

# --- 12. ENLACES DOTFILES ---
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
        log "${YELLOW}[BAK] $tgt_path -> $backup${NC}"
    fi

    [ -L "$tgt_path" ] && rm -f "$tgt_path"
    ln -s "$src_path" "$tgt_path"
    log "${GREEN}[LINK] $target${NC}"
}

link_dotfiles() {
    log "\n${CYAN}[*] Vinculando CAZIL Dotfiles...${NC}"
    
    link_component "hypr"
    link_component "waybar"
    link_component "kitty"
    link_component "rofi"
    link_component "starship"
    link_component "zsh/.zshrc" ".zshrc"
    link_component "fastfetch"
    link_component "sscript" "scripts"
    
    # VSCode (si existe)
    [ -d "$DOTFILES_DIR/vscode-user" ] && link_component "vscode-user" ".config/Code/User"
    
    log "${GREEN}[OK] Dotfiles vinculados${NC}"
}

# ================= EJECUCIÓN PRINCIPAL =================
main() {
    install_base
    install_externals
    install_hardware
    install_software
    install_productivity
    install_creative_suite
    install_power
    install_zsh_suite
    install_docker
    configure_system
    install_plymouth_theme
    install_grub_theme
    link_dotfiles
    
    echo ""
    log "${GREEN}╔════════════════════════════════════════════════╗${NC}"
    log "${GREEN}║   CAZIL SYSTEM v8.2 INSTALADO EXITOSAMENTE    ║${NC}"
    log "${GREEN}╚════════════════════════════════════════════════╝${NC}"
    
    log "\n${CYAN}════════════════════════════════════════════════${NC}"
    log "${CYAN}  PRÓXIMOS PASOS:${NC}"
    log "${CYAN}════════════════════════════════════════════════${NC}"
    log "${YELLOW}1.${NC} Reinicia el sistema: ${CYAN}sudo reboot${NC}"
    log "${YELLOW}2.${NC} Revisa el log: ${CYAN}cat $LOG_FILE${NC}"
    log "${YELLOW}3.${NC} Si hay NVIDIA, verifica: ${CYAN}nvidia-smi${NC}"
    log ""
    log "${GREEN}Log guardado en: $LOG_FILE${NC}\n"
}

main "$@"