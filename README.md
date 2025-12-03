# 🚀 CAZIL DOTS - Sistema Hyprland Completo

```
  /$$$$$$  /$$$$$$  /$$$$$$$$ /$$$$$$ /$$
 /$$__  $$/$$__  $$|_____ $$ |_  $$_/| $$
| $$  \__/ $$  \ $$     /$$/   | $$  | $$
| $$     | $$$$$$$$    /$$/    | $$  | $$
| $$     | $$__  $$   /$$/     | $$  | $$
| $$    $| $$  | $$  /$$$$$$$$ | $$  | $$
|  $$$$$$| $$  | $$ |________//$$$$$$| $$$$$$$$
 \______/|__/  |__/          |______/|________/
```

**Sistema de configuración completo para Debian Sid con Hyprland, Waybar, Kitty, Rofi y más.**

---

## 📋 Requisitos

- **Sistema Operativo:** Debian 12 (Bookworm) o Debian Sid
- **Espacio en disco:** Mínimo 15GB libres
- **Conexión a internet:** Necesaria para descargar paquetes
- **Hardware compatible:** Funciona con Intel, AMD y NVIDIA (con drivers propietarios)

---

## 🎯 Instalación Rápida

### Opción A: Instalación en Debian 12 limpio

```bash
# 1. Clonar el repositorio
git clone https://github.com/Albert-NC/cazil-dots.git
cd cazil-dots

# 2. Ejecutar pre-instalación (actualiza a Sid automáticamente)
./pre-install.sh

# 3. Reiniciar (importante después de actualizar a Sid)
sudo reboot

# 4. Ejecutar instalación modular
cd cazil-dots
./install_new.sh
```

### Opción B: Ya estás en Debian Sid

```bash
# 1. Clonar el repositorio
git clone https://github.com/Albert-NC/cazil-dots.git
cd cazil-dots

# 2. Verificar sistema
./pre-install.sh

# 3. Ejecutar instalación
./install_new.sh
```

---

## 📦 Componentes Incluidos

### 🎨 **Entorno de Escritorio**
- **Hyprland** - Compositor Wayland con animaciones suaves
- **Waybar** - Barra de estado personalizada (tema cyberpunk)
- **Wofi** - Lanzador de aplicaciones nativo para Wayland
- **Hyprlock** - Pantalla de bloqueo
- **Hypridle** - Gestión de inactividad

### 🖥️ **Terminal y Shell**
- **Kitty** - Terminal emulator con transparencia
- **ZSH** - Shell avanzado con Oh-My-Zsh
- **Starship** - Prompt personalizado minimalista

### 🎨 **Visuales y Temas**
- **JetBrainsMono Nerd Font** - Fuente con íconos
- **Fastfetch** - System info con logo personalizado
- **Plymouth Theme** - Pantalla de arranque CAZIL
- **GRUB Theme** - Tema de bootloader personalizado
- **Wallpapers** - Fondos de pantalla cyberpunk

### 🛠️ **Utilidades**
- **Thunar** - Gestor de archivos
- **KeePassXC** - Gestor de contraseñas
- **brightnessctl** - Control de brillo
- **pamixer** - Control de volumen
- **grim + slurp** - Screenshots en Wayland
- **swww** - Wallpaper engine para Wayland

### 🔧 **Scripts Personalizados** (`sscript/`)
- `alternar_pantallas.sh` - Cambiar entre monitor interno/externo
- `modo_avion.sh` - Toggle modo avión
- `bajar_b.sh` / `subir_b.sh` - Control de brillo
- `teclado_neon.py` - Control RGB para Acer
- `load_acer_rgb.sh` - Cargar perfil RGB
- `camera.sh` - Toggle cámara
- `git_push.sh` - Push rápido a git

### 🌐 **Navegadores** (Opcional)
- Firefox ESR
- Brave Browser
- Waterfox
- Vivaldi

### ⚙️ **Hardware Específico** (Opcional)
- **NVIDIA Drivers** - Drivers propietarios con configuración Wayland
- **Acer RGB Module** - Soporte para teclados RGB Acer Predator/Nitro
- **TLP** - Gestión de energía para laptops

### 🐳 **Desarrollo** (Opcional)
- Docker + Docker Compose

---

## 📂 Estructura del Repositorio

```
cazil-dots/
├── hypr/                      # Configuración Hyprland
│   ├── hyprland.conf          # Config principal
│   ├── hypridle.conf          # Gestión de inactividad
│   ├── hyprlock.conf          # Pantalla de bloqueo
│   ├── monitores_extendidos.conf
│   └── monitores_internos.conf
│
├── waybar/                    # Barra de estado
│   ├── config                 # Layout y módulos
│   ├── style.css              # Estilo cyberpunk
│   └── ModulesWorkspaces      # Iconos de workspaces
│
├── kitty/                     # Terminal
│   └── kitty.conf             # Config con transparencia
│
├── wofi/                      # Lanzador de apps
│   ├── config                 # Configuración
│   └── style.css              # Tema cyberpunk
│
├── starship/                  # Prompt
│   └── starship.toml
│
├── zsh/                       # Shell
│   └── .zshrc
│
├── fastfetch/                 # System info
│   ├── sample_1.jsonc
│   └── assets/
│
├── sscript/                   # Scripts personalizados
│   ├── alternar_pantallas.sh
│   ├── modo_avion.sh
│   └── ...
│
├── fonts/                     # Fuentes
│   └── 10-nerd-font-symbols.conf
│
├── wallpapers/                # Fondos
│   ├── bg_grub1_con_logo.png
│   └── cazil_logo.png
│
├── grub/                      # Tema GRUB
│   └── theme.txt
│
├── plymouth/                  # Tema boot
│   └── themes/
│
├── vscode-user/               # Settings VSCode
│   └── settings.json
│
├── pre-install.sh             # Script de preparación
├── install_new.sh             # Instalación modular (RECOMENDADO)
└── install.sh                 # Instalación legacy
```

---

## ⚙️ Instalación Detallada

### 1️⃣ **Pre-instalación** (`pre-install.sh`)

Este script verifica y prepara tu sistema:

- ✅ Detecta si estás en Debian 12 o Sid
- ✅ Ofrece actualizar automáticamente a Sid
- ✅ Verifica conexión a internet
- ✅ Comprueba espacio en disco
- ✅ Detecta hardware (GPU NVIDIA, laptop Acer)
- ✅ Instala paquetes base necesarios

```bash
./pre-install.sh
```

### 2️⃣ **Instalación Modular** (`install_new.sh`)

Este es el script **RECOMENDADO**. Te pregunta por cada componente:

```bash
./install_new.sh
```

**Características:**
- 🎯 Pregunta por cada componente individualmente
- 🔄 Detecta si ya está instalado (evita reinstalar)
- 📦 Compila Rofi-Wayland desde fuente si es necesario
- 🎨 Al final pregunta si quieres aplicar los dotfiles CAZIL
- 📝 Genera log detallado en `/tmp/cazil_install_*.log`
- 💾 Crea backups automáticos de configuraciones existentes

**Ejemplo de flujo:**
```
¿Instalar Hyprland (Compositor Wayland)? (s/n) → s
¿Instalar Waybar (Barra de estado)? (s/n) → s
¿Instalar Kitty (Terminal emulator)? (s/n) → s
...
¿Aplicar las configuraciones personalizadas de CAZIL-DOTS? (s/n) → s
```

---

## 🎨 Aplicación de Dotfiles

Cuando el script pregunta **"¿Aplicar las configuraciones personalizadas de CAZIL-DOTS?"**, vinculará:

| Origen | Destino |
|--------|---------|
| `hypr/` | `~/.config/hypr/` |
| `waybar/` | `~/.config/waybar/` |
| `kitty/` | `~/.config/kitty/` |
| `wofi/` | `~/.config/wofi/` |
| `starship/` | `~/.config/starship/` |
| `zsh/.zshrc` | `~/.zshrc` |
| `fastfetch/` | `~/.config/fastfetch/` |
| `sscript/` | `~/.config/scripts/` |
| `fonts/10-nerd-font-symbols.conf` | `~/.config/fontconfig/conf.d/` |
| `vscode-user/` | `~/.config/Code/User/` |

**Importante:** Si ya tienes configuraciones, se crearán backups automáticos con timestamp.

---

## 🚀 Post-Instalación

### 1. **Reiniciar el sistema**
```bash
sudo reboot
```

### 2. **Iniciar Hyprland**
Después del reinicio, Hyprland debería iniciar automáticamente. Si no:
```bash
Hyprland
```

### 3. **Atajos de teclado principales**

| Atajo | Acción |
|-------|--------|
| `Super + Q` | Cerrar ventana activa |
| `Super + Enter` | Abrir Kitty (terminal) |
| `Super + D` | Abrir Wofi (lanzador) |
| `Super + E` | Abrir Thunar (archivos) |
| `Super + L` | Bloquear pantalla |
| `Super + [1-9]` | Cambiar a workspace |
| `Super + Shift + [1-9]` | Mover ventana a workspace |
| `Super + Mouse` | Mover ventana |
| `Super + Right Mouse` | Redimensionar |
| `Super + O` | Alternar monitores |

### 4. **Verificar instalación**

```bash
# Ver versión de Hyprland
Hyprland --version

# Ver log de instalación
cat /tmp/cazil_install_*.log

# Verificar NVIDIA (si instalaste)
nvidia-smi
```

---

## 🐛 Solución de Problemas

### Wofi no se instala
Wofi debería estar disponible en los repositorios de Debian Sid:
```bash
sudo apt install -y wofi
```

### Hyprland no inicia automáticamente
Verifica que existe `~/.bash_profile` o `~/.zprofile`:
```bash
cat ~/.bash_profile
# Debería contener: exec Hyprland
```

### NVIDIA: Cursor invisible
Ya está configurado en `hypr/hyprland.conf`:
```conf
env = WLR_NO_HARDWARE_CURSORS,1
```

### Wallpapers no se ven
Ejecuta swww manualmente:
```bash
swww init
swww img ~/cazil-dots/wallpapers/bg_grub1_con_logo.png
```

---

## 🎯 Personalización

### Cambiar tema de colores
Edita `waybar/style.css` y `wofi/style.css`

### Agregar más atajos
Edita `hypr/hyprland.conf` en la sección de bindings

### Cambiar fuente
Edita `kitty/kitty.conf` y `starship/starship.toml`

---

## 📝 Notas Importantes

- ⚠️ **Debian 12 → Sid:** Es una actualización rolling. No es reversible fácilmente.
- 🔒 **Backups:** El script crea backups de tus configs existentes
- 🐧 **Compatibilidad:** Diseñado para Debian Sid, puede funcionar en otras distros con ajustes
- 🔋 **Laptop:** TLP optimiza automáticamente el consumo de energía

---

## 🤝 Contribuir

Si encuentras bugs o quieres agregar features:
1. Fork el repositorio
2. Crea una branch: `git checkout -b feature/nueva-feature`
3. Commit: `git commit -m 'Agregar nueva feature'`
4. Push: `git push origin feature/nueva-feature`
5. Abre un Pull Request

---

## 📜 Licencia

Este proyecto está bajo licencia MIT. Úsalo libremente.

---

## 👤 Autor

**Albert-NC** - [GitHub](https://github.com/Albert-NC)

---

## ⭐ Agradecimientos

- [Hyprland](https://hyprland.org/)
- [Waybar](https://github.com/Alexays/Waybar)
- [Wofi](https://hg.sr.ht/~scoopta/wofi)
- [Starship](https://starship.rs/)
- [JetBrainsMono](https://www.jetbrains.com/lp/mono/)

---

**¿Te gustó? Dale una ⭐ al repositorio!**
