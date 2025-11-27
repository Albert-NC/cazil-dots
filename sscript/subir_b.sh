#!/bin/bash

OUTPUT="eDP-1"  # Cambia esto por el nombre real de tu pantalla

# Obtiene el brillo actual
CURRENT_BRIGHTNESS=$(xrandr --verbose | grep -A 5 "^$OUTPUT" | grep Brightness | awk '{print $2}')

# Suma un 10% al brillo actual
NEW_BRIGHTNESS=$(echo "$CURRENT_BRIGHTNESS + 0.1" | bc)

# Limita el brillo máximo a 2.0 (200%)
MAX_BRIGHTNESS=2.0
if (( $(echo "$NEW_BRIGHTNESS > $MAX_BRIGHTNESS" | bc -l) )); then
  NEW_BRIGHTNESS=$MAX_BRIGHTNESS
fi

# Aplica el brillo nuevo
xrandr --output $OUTPUT --brightness $NEW_BRIGHTNESS

