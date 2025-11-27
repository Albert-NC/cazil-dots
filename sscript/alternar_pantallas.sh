#!/bin/bash
# Script para alternar entre modo pantalla única (Unificado) y extendida (Split) con movimiento de ventanas.

HYPR_CONFIG="$HOME/.config/hypr/hyprland.conf"
# Archivos de configuración de monitores
EXT_CONF="$HOME/cazil-dots/hypr/monitores_extendidos.conf"
INT_CONF="$HOME/cazil-dots/hypr/monitores_internos.conf"

# NOTA CRÍTICA: Reemplaza estos valores con tus nombres reales de hyprctl
INTERNAL_MONITOR="eDP-1" 
PRESENTATION_WORKSPACE="1"
WORK_WORKSPACE="2"

# 1. VERIFICAR ESTADO ACTUAL
if grep -q "source = $EXT_CONF" "$HYPR_CONFIG"; then
    
    # --- SWAPPING FROM EXTENDED TO INTERNAL (UNIFICAR) ---
    echo "Cambiando a Modo Interno. Moviendo W$PRESENTATION_WORKSPACE a W$WORK_WORKSPACE..."
    
    # Mover el contenido de W1 (Proyector) a W2 (Laptop)
    hyprctl dispatch movetoworkspace $WORK_WORKSPACE,monitor:$INTERNAL_MONITOR
    
    # Cambiar la fuente de configuración para desactivar el monitor externo
    sed -i "s|source = $EXT_CONF|source = $INT_CONF|" "$HYPR_CONFIG"
    
    echo "Cambiado a Modo Interno (Unificado)."
else
    # --- SWAPPING FROM INTERNAL TO EXTENDED (SPLIT) ---
    # Cambiar la fuente para activar los monitores externos
    sed -i "s|source = $INT_CONF|source = $EXT_CONF|" "$HYPR_CONFIG"
    echo "Cambiado a Modo Extendido (W1 Proyector, W10 Notas)."
fi

# 2. Forzar recarga de Hyprland
hyprctl reload