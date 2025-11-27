#!/bin/bash
# Script rápido para subir cambios a GitHub

msg=${1:-"update"}  # Mensaje de commit por defecto

echo "📂 Directorio actual: $(pwd)"
echo "🔄 Agregando todos los cambios (archivos modificados y nuevos)"
git add .

# Solo hacer commit si hay cambios para evitar error
if git diff --cached --quiet; then
  echo "⚠️ No hay cambios para commitear."
else
  git commit -m "$msg"
fi

echo "🚀 Haciendo push al remoto"
git push

