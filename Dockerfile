FROM immisterio/lampac:latest

# Копируем содержимое /home в /app (эталонные файлы)
RUN cp -r /home /app

# Добавляем entrypoint скрипт
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Порт приложения
EXPOSE 9118

# Рабочая директория
WORKDIR /home

# Точка входа
ENTRYPOINT ["/entrypoint.sh"]
