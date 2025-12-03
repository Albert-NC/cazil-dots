#!/bin/bash

# ==============================================================================
#   CAZIL SYSTEM - PRE-INSTALACIÓN Y VALIDACIÓN
#   Prepara Debian 12/Sid antes de ejecutar install_new.sh
# ==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
cat << "EOF"
╔════════════════════════════════════════════════╗
║   CAZIL PRE-INSTALACIÓN Y VALIDACIÓN          ║
╚════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Verificar si es root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}[ERROR] No ejecutes este script como root.${NC}"
    exit 1
fi

# 1. VERIFICAR VERSIÓN DE DEBIAN
echo -e "\n${CYAN}[1/5] Verificando versión de Debian...${NC}"
if [ -f /etc/debian_version ]; then
    DEBIAN_VERSION=$(cat /etc/debian_version)
    echo -e "${GREEN}[✓] Debian detectado: $DEBIAN_VERSION${NC}"
    
    # Verificar si es Sid
    if grep -q "sid" /etc/apt/sources.list; then
        echo -e "${GREEN}[✓] Sistema configurado para Debian Sid${NC}"
    else
        echo -e "${YELLOW}[!] No estás en Debian Sid${NC}"
        echo -e "${YELLOW}    ¿Deseas actualizar a Debian Sid ahora? (s/n)${NC}"
        read -r response
        if [[ "$response" =~ ^([sS][iI]|[sS])$ ]]; then
            echo -e "${CYAN}[*] Actualizando a Debian Sid...${NC}"
            
            # Backup sources.list
            sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup.$(date +%s)
            
            # Crear nuevo sources.list para Sid
            cat << 'SOURCES_EOF' | sudo tee /etc/apt/sources.list
deb http://deb.debian.org/debian/ sid main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ sid main contrib non-free non-free-firmware
SOURCES_EOF
            
            echo -e "${CYAN}[*] Actualizando sistema a Sid (esto puede tardar)...${NC}"
            sudo apt update
            sudo apt upgrade -y
            sudo apt full-upgrade -y
            sudo apt autoremove -y
            
            echo -e "${GREEN}[✓] Sistema actualizado a Sid${NC}"
            echo -e "${YELLOW}[!] Es recomendable REINICIAR antes de continuar${NC}"
            echo -e "${YELLOW}    Después de reiniciar, ejecuta: ./install_new.sh${NC}"
            exit 0
        fi
    fi
else
    echo -e "${RED}[ERROR] Este script solo funciona en Debian${NC}"
    exit 1
fi

# 2. VERIFICAR CONEXIÓN A INTERNET
echo -e "\n${CYAN}[2/5] Verificando conexión a internet...${NC}"
if ping -c 1 8.8.8.8 &>/dev/null; then
    echo -e "${GREEN}[✓] Conexión a internet OK${NC}"
else
    echo -e "${RED}[ERROR] No hay conexión a internet${NC}"
    exit 1
fi

# 3. VERIFICAR ESPACIO EN DISCO
echo -e "\n${CYAN}[3/5] Verificando espacio en disco...${NC}"
AVAILABLE_SPACE=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$AVAILABLE_SPACE" -gt 10 ]; then
    echo -e "${GREEN}[✓] Espacio disponible: ${AVAILABLE_SPACE}GB${NC}"
else
    echo -e "${YELLOW}[!] Advertencia: Solo tienes ${AVAILABLE_SPACE}GB disponibles${NC}"
    echo -e "${YELLOW}    Se recomienda al menos 15GB para instalar todo${NC}"
fi

# 4. ACTUALIZAR REPOSITORIOS
echo -e "\n${CYAN}[4/5] Actualizando repositorios...${NC}"
sudo apt update
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[✓] Repositorios actualizados${NC}"
else
    echo -e "${RED}[ERROR] Fallo al actualizar repositorios${NC}"
    echo -e "${YELLOW}    Verifica tu /etc/apt/sources.list${NC}"
    exit 1
fi

# 5. VERIFICAR PAQUETES CRÍTICOS
echo -e "\n${CYAN}[5/5] Verificando paquetes base...${NC}"
MISSING_PACKAGES=""

for pkg in curl wget git build-essential; do
    if ! dpkg -l "$pkg" &>/dev/null; then
        MISSING_PACKAGES="$MISSING_PACKAGES $pkg"
    fi
done

if [ -n "$MISSING_PACKAGES" ]; then
    echo -e "${YELLOW}[!] Instalando paquetes base faltantes:$MISSING_PACKAGES${NC}"
    sudo apt install -y $MISSING_PACKAGES
else
    echo -e "${GREEN}[✓] Paquetes base OK${NC}"
fi

# VERIFICAR HARDWARE NVIDIA
echo -e "\n${CYAN}[HARDWARE] Detectando GPU...${NC}"
if lspci | grep -i nvidia &>/dev/null; then
    echo -e "${GREEN}[✓] GPU NVIDIA detectada${NC}"
    lspci | grep -i nvidia | head -1
    echo -e "${YELLOW}    El script te preguntará si quieres instalar drivers NVIDIA${NC}"
elif lspci | grep -i "vga.*amd" &>/dev/null; then
    echo -e "${YELLOW}[!] GPU AMD detectada (no requiere configuración especial)${NC}"
elif lspci | grep -i "vga.*intel" &>/dev/null; then
    echo -e "${YELLOW}[!] GPU Intel detectada (no requiere configuración especial)${NC}"
fi

# VERIFICAR LAPTOP ACER
echo -e "\n${CYAN}[HARDWARE] Detectando laptop Acer...${NC}"
if sudo dmidecode -s system-manufacturer 2>/dev/null | grep -iq "acer"; then
    echo -e "${GREEN}[✓] Laptop Acer detectado${NC}"
    echo -e "${YELLOW}    El script te preguntará si quieres instalar el módulo RGB${NC}"
else
    echo -e "${YELLOW}[!] No es laptop Acer (omitir instalación de módulo RGB)${NC}"
fi

# RESUMEN FINAL
echo -e "\n${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   SISTEMA LISTO PARA INSTALACIÓN              ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"

echo -e "\n${CYAN}Siguiente paso:${NC}"
echo -e "${YELLOW}  ./install_new.sh${NC}"
echo -e "\n${CYAN}Notas importantes:${NC}"
echo -e "  • El proceso puede tardar 30-60 minutos (según tu conexión)"
echo -e "  • Responde 's' solo a los componentes que necesites"
echo -e "  • Al final te preguntará si quieres aplicar los dotfiles CAZIL"
echo -e "  • Después de instalar, reinicia el sistema"
echo ""
