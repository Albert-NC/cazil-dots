# ==============================================================================
# CAZIL SYSTEM - ZSHRC MASTER CONFIGURATION
# Version: 1.0 Final Deployment
# ==============================================================================

# --- 1. PROMPT Y PLUGINS ---
# Inicializa el prompt de Starship (El motor Rust)
eval "$(starship init zsh)"

# Cargar plugins esenciales desde las rutas de APT
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# --- 2. PATHS Y ENTORNO ---
# Agrega directorios de ejecutables locales
export PATH="$HOME/.local/bin:$PATH"
export PATH=/usr/local/bin:$PATH
export TERM=xterm-256color 

# --- 3. CONFIGURACIÓN DE HISTORIAL ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Opciones de Historial (Compartir y sin duplicados)
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS

# --- 4. STARTUP Y VISUALES ---
# Fastfetch al inicio (solo si está instalado)
if command -v fastfetch &>/dev/null; then
    fastfetch -c "$HOME/cazil-dots/fastfetch/sample_1.jsonc"
fi

# Activar colores para ls
alias ls='ls --color=auto'

# Cargar esquema de colores para ls (si está disponible)
if [ -x /usr/bin/dircolors ]; then
    eval "$(dircolors -b)"
fi

# ==============================================================================
# --- 5. ALIASES DE SEGURIDAD Y DESARROLLO (CAZIL COMMANDS) ---
# ==============================================================================

# --- FIREWALL Y AUDITORÍA DE RED ---
alias ufw-stat="sudo ufw status verbose"          # Ver estado del escudo UFW
alias ports-listen="sudo ss -tulpn | grep LISTEN" # Ver qué puertos están escuchando
alias ports-all="sudo ss -tulpn"                   # Ver todas las conexiones activas

# --- AUDITORÍA DE INTRUSIÓN Y MALWARE ---
alias hunter-check="sudo rkhunter --check --sk"   # Ejecutar Rootkit Hunter
alias hunter-update="sudo rkhunter --propupd"     # Actualizar base de RKHunter
alias scan-here="clamscan -r --bell -i ."         # Escanear directorio actual con ClamAV

# --- SANDBOXING (Firejail) ---
alias brave="firejail brave-browser"              # Brave en jaula
alias firefox="firejail firefox-esr"              # Firefox en jaula
alias waterfox="firejail waterfox"                # Waterfox en jaula
alias discord="firejail discord"                  # Discord en jaula

# --- MODO DESARROLLADOR WEB (UFW) ---
# Abre puertos estándar para testing en LAN (3306, 8000, 3000, 80/443)
alias dev-on="sudo ufw allow 80/tcp && sudo ufw allow 443/tcp && sudo ufw allow 3000/tcp && sudo ufw allow 8000/tcp && sudo ufw allow 3306/tcp && sudo ufw allow 5432/tcp && echo '🔓 MODO DEV ACTIVADO: Puertos abiertos a la LAN'"

# Cierra todos los puertos de desarrollo (Vuelve al modo Búnker)
alias dev-off="sudo ufw delete allow 80/tcp && sudo ufw delete allow 443/tcp && sudo ufw delete allow 3000/tcp && sudo ufw delete allow 8000/tcp && sudo ufw delete allow 3306/tcp && sudo ufw delete allow 5432/tcp && echo '🔒 MODO BÚNKER: Todo cerrado'"

# --- UTILIDADES ---
alias update="sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean"
alias git-push='git add . && git commit -m "Commit $(date)" && git push'
alias logs="journalctl -xe"                    # Ver logs del sistema
alias docker-clean="docker system prune -af"   # Limpiar Docker

# --- SANDBOXING (Firejail) ---
# ... (dejar los alias existentes) ...
alias vivaldi="firejail vivaldi-stable"      # NUEVO
alias vlc="firejail vlc"                     # NUEVO