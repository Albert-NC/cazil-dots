#!/bin/bash

# ==============================================================================
#   CONFIGURAR HYPRLAND COMO INICIO AUTOMÁTICO
#   Desactiva X11 y Display Managers, configura Hyprland para iniciar en tty1
# ==============================================================================

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  CONFIGURACIÓN DE HYPRLAND AUTO-INICIO${NC}"
echo -e "${CYAN}════════════════════════════════════════════════${NC}\n"

# 1. Desactivar todos los display managers
echo -e "${CYAN}[*] Desactivando display managers (GDM, SDDM, LightDM)...${NC}"
for dm in gdm gdm3 sddm lightdm lxdm xdm; do
    if systemctl is-enabled $dm 2>/dev/null | grep -q enabled; then
        echo -e "${YELLOW}[*] Desactivando $dm...${NC}"
        sudo systemctl disable $dm
        sudo systemctl stop $dm 2>/dev/null || true
    fi
done

# 2. Configurar inicio automático en tty1 para Bash
echo -e "${CYAN}[*] Configurando ~/.bash_profile...${NC}"
cat > "$HOME/.bash_profile" << 'EOF'
# Auto-inicio de Hyprland en tty1
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
    exec Hyprland
fi
EOF

echo -e "${GREEN}[✓] ~/.bash_profile configurado${NC}"

# 3. Configurar inicio automático en tty1 para ZSH (si está instalado)
if command -v zsh &>/dev/null; then
    echo -e "${CYAN}[*] Configurando ~/.zprofile para ZSH...${NC}"
    cat > "$HOME/.zprofile" << 'EOF'
# Auto-inicio de Hyprland en tty1
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
    exec Hyprland
fi
EOF
    echo -e "${GREEN}[✓] ~/.zprofile configurado${NC}"
fi

# 4. Configurar .xinitrc como fallback
echo -e "${CYAN}[*] Configurando ~/.xinitrc...${NC}"
cat > "$HOME/.xinitrc" << 'EOF'
#!/bin/sh
exec Hyprland
EOF
chmod +x "$HOME/.xinitrc"
echo -e "${GREEN}[✓] ~/.xinitrc configurado${NC}"

# 5. Asegurar que no hay conflictos con sesiones X11
echo -e "${CYAN}[*] Verificando configuración del sistema...${NC}"

# Remover sesiones de inicio automático de GNOME/KDE si existen
if [ -d "$HOME/.config/autostart" ]; then
    echo -e "${YELLOW}[*] Limpiando autostart de otros entornos de escritorio...${NC}"
    rm -f "$HOME/.config/autostart/gnome-"* 2>/dev/null || true
    rm -f "$HOME/.config/autostart/kde-"* 2>/dev/null || true
fi

# 6. Configurar default target a graphical (multi-user si prefieres solo terminal)
echo -e "${CYAN}[*] Configurando target del sistema...${NC}"
sudo systemctl set-default multi-user.target
echo -e "${GREEN}[✓] Sistema configurado para iniciar en modo multi-usuario (tty)${NC}"

# 7. Crear archivo de servicio systemd alternativo (opcional)
echo -e "${CYAN}[*] ¿Crear servicio systemd para Hyprland? (s/n)${NC}"
read -r response
if [[ "$response" =~ ^([sS][iI]|[sS])$ ]]; then
    sudo mkdir -p /etc/systemd/system
    sudo tee /etc/systemd/system/hyprland@.service > /dev/null << 'EOF'
[Unit]
Description=Hyprland Wayland Compositor
After=systemd-user-sessions.service

[Service]
Type=simple
ExecStart=/usr/bin/Hyprland
Restart=on-failure
RestartSec=1
TimeoutStopSec=10
User=%i

[Install]
WantedBy=multi-user.target
EOF
    
    echo -e "${GREEN}[✓] Servicio systemd creado${NC}"
    echo -e "${YELLOW}[INFO] Para habilitar: sudo systemctl enable hyprland@$USER${NC}"
fi

echo -e "\n${GREEN}════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  CONFIGURACIÓN COMPLETADA${NC}"
echo -e "${GREEN}════════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}IMPORTANTE:${NC}"
echo -e "  1. Display managers desactivados (GDM, SDDM, etc.)"
echo -e "  2. Sistema configurado para iniciar en modo texto (multi-user.target)"
echo -e "  3. Hyprland se iniciará automáticamente al hacer login en tty1"
echo -e "  4. Para iniciar Hyprland manualmente: ${CYAN}Hyprland${NC}"
echo -e "\n${YELLOW}Al reiniciar:${NC}"
echo -e "  - Verás la pantalla de login en texto (tty1)"
echo -e "  - Ingresa tu usuario y contraseña"
echo -e "  - Hyprland iniciará automáticamente"
echo -e "\n${CYAN}¿Reiniciar ahora? (s/n)${NC}"
read -r reboot_response
if [[ "$reboot_response" =~ ^([sS][iI]|[sS])$ ]]; then
    echo -e "${GREEN}Reiniciando...${NC}"
    sudo reboot
else
    echo -e "${YELLOW}Recuerda reiniciar para aplicar los cambios${NC}"
fi
