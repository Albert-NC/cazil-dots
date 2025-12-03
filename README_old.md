cat << "EOF"
  /$$$$$$  /$$$$$$  /$$$$$$$$ /$$$$$$ /$$
 /$$__  $$/$$__  $$|_____ $$ |_  $$_/| $$
| $$  \__/ $$  \ $$     /$$/   | $$  | $$
| $$     | $$$$$$$$    /$$/    | $$  | $$
| $$     | $$__  $$   /$$/     | $$  | $$
| $$    $| $$  | $$  /$$$$$$$$ | $$  | $$
|  $$$$$$| $$  | $$ |________//$$$$$$| $$$$$$$$
 \______/|__/  |__/          |______/|________/
EOF
echo -e "      >> DEPLOYMENT PROTOCOL v8.1 <<${NC}\n"

cazil-dots/
├── hypr/
│   ├── hyprland.conf          <-- (MASTER CONF: GRADIENTE CIAN/ROSA, GESTOS, BINDINGS)
│   ├── hypridle.conf          <-- (POWER/SLEEP LOGIC)
│   ├── hyprlock.conf          <-- (LOCKSCREEN DESIGN)
│   ├── monitores_extendidos.conf <-- (MONITOR: EXTENDED MODE DEFINITION)
│   └── monitores_internos.conf <-- (MONITOR: INTERNAL MODE DEFINITION)
│
├── kitty/
│   └── kitty.conf             <-- (TERMINAL: JETBRAINSMONO, TRANSPARENCIA)
│
├── waybar/
│   ├── config                 <-- (LAYOUT: STATUS, NETWORK, BT, BATERÍA)
│   ├── style.css              <-- (ESTÉTICA: NEÓN/TRANSPARENTE)
│   └── ModulesWorkspaces      <-- (MOD: PACMAN ICONS DEFINITION)
│
├── rofi/
│   ├── config.rasi            <-- (ROFI LÓGICA)
│   └── cazil_theme.rasi       <-- (ROFI COLOR THEME)
│
├── starship/
│   └── starship.toml          <-- (ZSH PROMPT APPEARANCE)
│
├── zsh/
│   └── .zshrc                 <-- (ZSH CONFIG, STARSHIP STARTUP, ALIASES DE SEGURIDAD)
│
├── sscript/
│   ├── alternar_pantallas.sh  <-- (SCRIPT: TOGGLE MONITOR MODE)
│   └── modo_avion.sh          <-- (SCRIPT: AIRPLANE MODE STATUS CHECK)
│
├── fonts/
│   └── <archivos_.ttf/.otf>   <-- (CUSTOM/NERD FONTS)
│
├── wallpapers/
│   └── cazil_logo.png         <-- (FONDO DE ESCRITORIO Y FUENTE DEL FONDO GRUB)
│
├── grub/
│   └── cazil_grub_theme/      <-- (TEMA PERSONALIZADO GRUB CON WALLPAPER)
│
├── plymouth/
│   └── cazil_theme/           <-- (TEMA PLYMOUTH PARA PANTALLA LUKS UNLOCK)
│
├── fastfetch/
│   ├── sample_1.jsonc         <-- (CONFIG: FASTFETCH CON LOGO TRANSPARENTE)
│   └── assets/
│       └── cazil_logo_transparente.png <-- (LOGO PNG SIN FONDO)
│
└── install.sh                 <-- (MASTER DEPLOYMENT SCRIPT v8.1)
