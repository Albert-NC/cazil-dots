#!/bin/bash

# ==============================================================================
#   CAZIL SYSTEM - VERIFICACIÓN PRE-PUSH
#   Verifica que todos los archivos necesarios estén presentes
# ==============================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   VERIFICACIÓN DE CAZIL-DOTS                   ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════╝${NC}\n"

ERRORS=0
WARNINGS=0

# Función de verificación
check_file() {
    local file=$1
    local critical=${2:-true}
    
    if [ -e "$file" ]; then
        echo -e "${GREEN}[✓] $file${NC}"
    else
        if [ "$critical" = true ]; then
            echo -e "${RED}[✗] FALTA: $file (CRÍTICO)${NC}"
            ((ERRORS++))
        else
            echo -e "${YELLOW}[!] FALTA: $file (opcional)${NC}"
            ((WARNINGS++))
        fi
    fi
}

# 1. Scripts principales
echo -e "${CYAN}[1] Scripts de instalación:${NC}"
check_file "pre-install.sh"
check_file "install_new.sh"
check_file "install.sh"

# 2. Configuraciones Hyprland
echo -e "\n${CYAN}[2] Configuración Hyprland:${NC}"
check_file "hypr/hyprland.conf"
check_file "hypr/hypridle.conf"
check_file "hypr/hyprlock.conf"
check_file "hypr/monitores_internos.conf"
check_file "hypr/monitores_extendidos.conf"

# 3. Waybar
echo -e "\n${CYAN}[3] Configuración Waybar:${NC}"
check_file "waybar/config"
check_file "waybar/style.css"
check_file "waybar/ModulesWorkspaces" false

# 4. Terminal y Shell
echo -e "\n${CYAN}[4] Terminal y Shell:${NC}"
check_file "kitty/kitty.conf"
check_file "zsh/.zshrc"
check_file "starship/starship.toml"

# 5. Rofi
echo -e "\n${CYAN}[5] Configuración Rofi:${NC}"
check_file "rofi/config.rasi"
check_file "rofi/cazil_theme.rasi"

# 6. Fastfetch
echo -e "\n${CYAN}[6] Fastfetch:${NC}"
check_file "fastfetch/sample_1.jsonc"

# 7. Scripts personalizados
echo -e "\n${CYAN}[7] Scripts personalizados:${NC}"
check_file "sscript/alternar_pantallas.sh"
check_file "sscript/modo_avion.sh"
check_file "sscript/bajar_b.sh"
check_file "sscript/subir_b.sh"

# 8. Fuentes
echo -e "\n${CYAN}[8] Configuración de fuentes:${NC}"
check_file "fonts/10-nerd-font-symbols.conf"

# 9. Wallpapers
echo -e "\n${CYAN}[9] Wallpapers:${NC}"
check_file "wallpapers/bg_grub1_con_logo.png" false
check_file "wallpapers/cazil_logo.png" false

# 10. GRUB y Plymouth
echo -e "\n${CYAN}[10] Temas de boot:${NC}"
check_file "grub/theme.txt"
check_file "plymouth/themes/cazil-cyber.plymouth" false
check_file "plymouth/themes/cazil-cyber.script" false

# 11. Documentación
echo -e "\n${CYAN}[11] Documentación:${NC}"
check_file "README.md"

# 12. Verificar permisos de ejecución
echo -e "\n${CYAN}[12] Permisos de ejecución:${NC}"
for script in pre-install.sh install_new.sh install.sh; do
    if [ -x "$script" ]; then
        echo -e "${GREEN}[✓] $script es ejecutable${NC}"
    else
        echo -e "${RED}[✗] $script NO es ejecutable${NC}"
        ((ERRORS++))
    fi
done

# Verificar scripts en sscript/
if [ -d "sscript" ]; then
    NON_EXEC=$(find sscript/ -type f \( -name "*.sh" -o -name "*.py" \) ! -perm -u+x)
    if [ -n "$NON_EXEC" ]; then
        echo -e "${YELLOW}[!] Scripts sin permisos de ejecución en sscript/:${NC}"
        echo "$NON_EXEC"
        ((WARNINGS++))
    fi
fi

# Resumen final
echo -e "\n${CYAN}════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  RESUMEN${NC}"
echo -e "${CYAN}════════════════════════════════════════════════${NC}"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ TODO PERFECTO - Listo para push/deploy${NC}\n"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ $WARNINGS advertencia(s) - Puede funcionar pero revisa${NC}\n"
    exit 0
else
    echo -e "${RED}✗ $ERRORS error(es) crítico(s) - Corrige antes de continuar${NC}"
    [ $WARNINGS -gt 0 ] && echo -e "${YELLOW}⚠ $WARNINGS advertencia(s) adicionales${NC}"
    echo ""
    exit 1
fi
