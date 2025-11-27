#!/bin/bash

OUTPUT="eDP-1"  # Cambia por el nombre de tu pantalla

# Obtiene el brillo actual
CURRENT_BRIGHTNESS=$(xrandr --verbose | grep -A 5 "^$OUTPUT" | grep Brightness | awk '{print $2}')

# Calcula el nuevo brillo restando un 10%
NEW_BRIGHTNESS=$(echo "$CURRENT_BRIGHTNESS - 0.1" | bc)

# Asegura que no baje de 0 (pantalla completamente negra)
if (( $(echo "$NEW_BRIGHTNESS < 0" | bc -l) )); then
  NEW_BRIGHTNESS=0
fi

# Aplica el nuevo brillo
xrandr --output $OUTPUT --brightness $NEW_BRIGHTNESS

