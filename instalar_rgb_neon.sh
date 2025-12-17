#!/bin/bash

# Script completo: Instalar módulo RGB + Aplicar colores neón + Guardar configuración
# Instala en /tmp (se borra al reiniciar)
# Para Ubuntu 24.04
# Uso: sudo ./instalar_rgb_neon.sh

if [ "$EUID" -ne 0 ]; then 
    echo "❌ ERROR: Este script necesita permisos de superusuario"
    echo "Por favor ejecuta: sudo ./instalar_rgb_neon.sh"
    exit 1
fi

INSTALL_DIR="/tmp/acer-predator-turbo-and-rgb-keyboard-linux-module"

echo "🎨 Instalación completa Acer Predator RGB - Colores Neón"
echo "========================================================="
echo "📂 Instalando en: $INSTALL_DIR (temporal)"
echo ""

# 1. Detener servicios
echo "🛑 Paso 1: Deteniendo servicios..."
systemctl stop acer-gkbbl-service 2>/dev/null
systemctl disable acer-gkbbl-service 2>/dev/null
systemctl stop acer-rgb-neon.service 2>/dev/null
systemctl disable acer-rgb-neon.service 2>/dev/null
sleep 1

# 2. Descargar módulo
echo "📤 Paso 2: Descargando módulo..."
rmmod acer_gkbbl 2>/dev/null
sleep 1

# 3. Limpiar instalación anterior
echo "🧹 Paso 3: Limpiando instalación anterior..."
rm -f /etc/systemd/system/acer-gkbbl-service.service 2>/dev/null
rm -f /etc/systemd/system/acer-rgb-neon.service 2>/dev/null
systemctl daemon-reload
depmod -a
sleep 1

# 4. Clonar repositorio en /tmp
echo "📦 Paso 4: Descargando repositorio..."
cd /tmp

if [ -d "$INSTALL_DIR" ]; then
    echo "   Eliminando versión anterior..."
    rm -rf "$INSTALL_DIR"
fi

git clone https://github.com/JafarAkhondali/acer-predator-turbo-and-rgb-keyboard-linux-module
cd "$INSTALL_DIR"

# 5. Instalar módulo
echo "⚙️  Paso 5: Instalando módulo..."
chmod +x ./*.sh
./install_service.sh

if [ $? -ne 0 ]; then
    echo "❌ Error instalando el módulo"
    exit 1
fi

sleep 2

# 6. Verificar dispositivo
echo "🔍 Paso 6: Verificando dispositivo..."
if [ ! -e "/dev/acer-gkbbl-0" ]; then
    modprobe acer_gkbbl
    sleep 2
    if [ ! -e "/dev/acer-gkbbl-0" ]; then
        echo "❌ No se pudo cargar el dispositivo"
        exit 1
    fi
fi

echo "✅ Dispositivo encontrado"

# 7. Detener servicio para aplicar colores
echo "🛑 Paso 7: Deteniendo servicio para configurar colores..."
systemctl stop acer-gkbbl-service
sleep 2

# 8. Aplicar colores neón
echo "🎨 Paso 8: Aplicando colores neón fosforescentes..."
echo ""

# Zona 1: Magenta neón
python3 facer_rgb.py -m 0 -b 100 -z 1 -cR 255 -cG 0 -cB 255
sleep 0.5
echo "✓ Zona 1: 💗 Magenta neón"

# Zona 2: Magenta neón
python3 facer_rgb.py -m 0 -b 100 -z 2 -cR 255 -cG 0 -cB 255
sleep 0.5
echo "✓ Zona 2: 💗 Magenta neón"

# Zona 3: Cyan neón
python3 facer_rgb.py -m 0 -b 100 -z 3 -cR 0 -cG 255 -cB 255
sleep 0.5
echo "✓ Zona 3: 💙 Cyan neón"

# Zona 4: Cyan neón
python3 facer_rgb.py -m 0 -b 100 -z 4 -cR 0 -cG 255 -cB 255
sleep 0.5
echo "✓ Zona 4: 💙 Cyan neón"

echo ""
echo "💾 Paso 9: Guardando perfil en kernel..."
python3 facer_rgb.py -save neon_profile
sleep 1

# 9. Crear script permanente para cargar colores al inicio
echo "⚙️  Paso 10: Configurando inicio automático..."

# Copiar facer_rgb.py a ubicación permanente
cp facer_rgb.py /usr/local/bin/facer_rgb.py
chmod +x /usr/local/bin/facer_rgb.py

# Crear script de inicio en ubicación permanente
cat > /usr/local/bin/acer_rgb_neon.sh << 'EOF'
#!/bin/bash
# Script permanente para aplicar colores neón al iniciar
sleep 5

# Cargar módulo si no está cargado
if [ ! -e "/dev/acer-gkbbl-0" ]; then
    modprobe acer_gkbbl
    sleep 2
fi

# Aplicar colores usando facer_rgb.py
cd /usr/local/bin

# Detener servicio que pone colores por defecto
systemctl stop acer-gkbbl-service 2>/dev/null
sleep 1

# Aplicar colores neón
python3 /usr/local/bin/facer_rgb.py -m 0 -b 100 -z 1 -cR 255 -cG 0 -cB 255
python3 /usr/local/bin/facer_rgb.py -m 0 -b 100 -z 2 -cR 255 -cG 0 -cB 255
python3 /usr/local/bin/facer_rgb.py -m 0 -b 100 -z 3 -cR 0 -cG 255 -cB 255
python3 /usr/local/bin/facer_rgb.py -m 0 -b 100 -z 4 -cR 0 -cG 255 -cB 255
EOF

chmod +x /usr/local/bin/acer_rgb_neon.sh

# Crear servicio systemd permanente
cat > /etc/systemd/system/acer-rgb-neon.service << EOF
[Unit]
Description=Acer RGB Neon Colors - Magenta & Cyan
After=acer-gkbbl-service.service
Requires=acer-gkbbl-service.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/acer_rgb_neon.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Habilitar servicio
systemctl daemon-reload
systemctl enable acer-rgb-neon.service
systemctl start acer-gkbbl-service
sleep 2

# 10. Aplicar colores inmediatamente
echo ""
echo "🎨 Paso 11: Aplicando colores ahora mismo..."
systemctl stop acer-gkbbl-service
sleep 1

python3 /usr/local/bin/facer_rgb.py -m 0 -b 100 -z 1 -cR 255 -cG 0 -cB 255
python3 /usr/local/bin/facer_rgb.py -m 0 -b 100 -z 2 -cR 255 -cG 0 -cB 255
python3 /usr/local/bin/facer_rgb.py -m 0 -b 100 -z 3 -cR 0 -cG 255 -cB 255
python3 /usr/local/bin/facer_rgb.py -m 0 -b 100 -z 4 -cR 0 -cG 255 -cB 255

echo ""
echo "✨ ¡Colores neón aplicados!"

echo ""
echo "🌟 ¡INSTALACIÓN COMPLETADA!"
echo "=========================================="
echo ""
echo "✅ Colores configurados:"
echo "   💗💗 Zonas 1-2: Magenta neón fosforescente"
echo "   💙💙 Zonas 3-4: Cyan neón fosforescente"
echo ""
echo "💾 Configuración guardada y persistirá después de reiniciar"
echo ""
echo "📂 Repositorio temporal: $INSTALL_DIR"
echo "   (Se borrará automáticamente al reiniciar)"
echo ""
echo "⚙️  Script permanente: /usr/local/bin/acer_rgb_neon.sh"
echo "⚙️  Script RGB copiado: /usr/local/bin/facer_rgb.py"
echo "⚙️  Servicio: acer-rgb-neon.service"
echo ""
echo "🔄 Para recargar colores manualmente:"
echo "   sudo /usr/local/bin/acer_rgb_neon.sh"
echo "   O: sudo systemctl restart acer-rgb-neon.service"
echo ""
echo "🗑️  Para desinstalar:"
echo "   sudo systemctl disable acer-rgb-neon.service"
echo "   sudo rm /usr/local/bin/acer_rgb_neon.sh"
echo "   sudo rm /usr/local/bin/facer_rgb.py"
echo "   sudo rm /etc/systemd/system/acer-rgb-neon.service"
echo ""
