#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$project_root"

dist_path="$project_root/Ejecutable"
work_path="$project_root/temp_build"

# Detectar PyInstaller
pyinstaller="pyinstaller"
if [ -x "$project_root/venv/bin/pyinstaller" ]; then
  pyinstaller="$project_root/venv/bin/pyinstaller"
fi

if ! command -v "$pyinstaller" >/dev/null 2>&1; then
  echo "Error: pyinstaller no encontrado. Activa el venv o instala pyinstaller." >&2
  exit 1
fi

echo "=== Compilando MrBot para macOS ==="

# Usar .icns si existe, de lo contrario usar .ico
icon_path="$project_root/bin/ABP-blanco-en-fondo-negro.icns"
if [ ! -f "$icon_path" ]; then
  icon_path="$project_root/bin/ABP-blanco-en-fondo-negro.ico"
fi

"$pyinstaller" \
  --noconfirm \
  --clean \
  --onefile \
  --windowed \
  --distpath "$dist_path" \
  --workpath "$work_path" \
  --specpath "$work_path" \
  --name "mrbot" \
  --icon "$icon_path" \
  "$project_root/mrbot.py"

echo "=== Copiando archivos adicionales ==="

# Copiar bin/
mkdir -p "$dist_path/bin"
cp -R "$project_root/bin/." "$dist_path/bin/"

# Copiar ejemplos_api/
if [ -d "$project_root/ejemplos_api" ]; then
  mkdir -p "$dist_path/ejemplos_api"
  cp -R "$project_root/ejemplos_api/." "$dist_path/ejemplos_api/"
fi

# Copiar .env.example como .env
if [ -f "$project_root/.env.example" ]; then
  cp -f "$project_root/.env.example" "$dist_path/.env"
fi

echo "Ejecutable creado en: $dist_path"
