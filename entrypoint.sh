#!/bin/bash
set -e

# Директория с эталонными файлами (из образа)
APP_SOURCE="/app"
# Рабочая директория (монтируется пользователем)
APP_HOME="/home"

# Проверяем, есть ли Lampac.dll в /home
if [ ! -f "$APP_HOME/Lampac.dll" ]; then
    echo "[Lampac] First run detected. Copying application files..."
    
    # Копируем все файлы из /app в /home
    cp -rn "$APP_SOURCE"/* "$APP_HOME"/ 2>/dev/null || true
    
    echo "[Lampac] Application files copied successfully."
else
    echo "[Lampac] Existing installation found."
    
    # Обновляем только runtime файлы (не трогаем конфиги и данные)
    # Это позволит обновлять приложение при обновлении образа
    for file in Lampac.dll Lampac.deps.json Lampac.pdb Lampac Lampac.exe Lampac.runtimeconfig.json Lampac.staticwebassets.endpoints.json web.config; do
        if [ -f "$APP_SOURCE/$file" ]; then
            cp -f "$APP_SOURCE/$file" "$APP_HOME/$file" 2>/dev/null || true
        fi
    done
    
    # Обновляем runtimes и wwwroot
    cp -rf "$APP_SOURCE/runtimes" "$APP_HOME"/ 2>/dev/null || true
    cp -rf "$APP_SOURCE/wwwroot" "$APP_HOME"/ 2>/dev/null || true
    
    echo "[Lampac] Runtime files updated."
fi

# Переходим в рабочую директорию
cd "$APP_HOME"

echo "[Lampac] Starting application..."
exec /usr/share/dotnet/dotnet Lampac.dll "$@"
