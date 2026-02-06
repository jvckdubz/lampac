# Lampac — Медиа-агрегатор для онлайн-кинотеатров

Lampac — это self-hosted медиа-сервер, который агрегирует контент из различных источников и предоставляет единый интерфейс для просмотра фильмов и сериалов.

> **Примечание:** Это сохранённая копия проекта. Оригинальный репозиторий более недоступен.

## Возможности

- Агрегация контента из множества источников (парсеры)
- Встроенный TorrServer для стриминга торрентов
- Поддержка DLNA
- Совместимость с плеерами: Kodi, Lampa, iOS/Android приложения
- Минимальные требования к ресурсам

## Быстрый старт

### Docker Run

```bash
docker run -d \
  --name lampac \
  -p 9118:9118 \
  -v /opt/lampac:/home \
  --restart always \
  ghcr.io/jvckdubz/lampac:latest
```

### Docker Compose

```bash
mkdir -p /opt/lampac
curl -o /opt/lampac/docker-compose.yml https://raw.githubusercontent.com/jvckdubz/lampac/main/docker-compose.yml
cd /opt/lampac
docker compose up -d
```

## Конфигурация

### Структура директорий

```
/opt/lampac/
├── init.conf           # Основные настройки
├── module/             # Парсеры и модули
├── plugins/            # Плагины
├── torrserver/         # Данные TorrServer
└── passwd              # Пароль для веб-интерфейса (если включён)
```

### Основной конфиг (init.conf)

```json
{
  "listenport": 9118,
  "listenhost": "0.0.0.0",
  "typecache": "mem",
  "mikrotik": false,
  "pirate_store": false,
  "dlna": {
    "enable": false,
    "path": ""
  },
  "online": {
    "findkp": "all",
    "checkOnlineSearch": true
  },
  "Lampa": {
    "autoupdate": true
  }
}
```

### Настройка TorrServer

TorrServer встроен в Lampac и работает на порту 8090 внутри контейнера.

Для внешнего доступа к TorrServer:

```bash
docker run -d \
  --name lampac \
  -p 9118:9118 \
  -p 8090:8090 \
  -v /opt/lampac:/home \
  --restart always \
  ghcr.io/jvckdubz/lampac:latest
```

## Использование

### Веб-интерфейс

После запуска откройте в браузере:
```
http://YOUR_IP:9118
```

### Подключение Lampa

В приложении Lampa добавьте источник:
```
http://YOUR_IP:9118
```

### API Endpoints

| Endpoint | Описание |
|----------|----------|
| `/` | Веб-интерфейс |
| `/lampa` | Интерфейс Lampa |
| `/ts` | TorrServer API |
| `/lite/` | API парсеров |

## Защита паролем

Для включения базовой авторизации создайте файл:

```bash
echo "your_password" > /opt/lampac/passwd
docker restart lampac
```

## Reverse Proxy (Nginx)

```nginx
server {
    listen 443 ssl http2;
    server_name watch.example.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://127.0.0.1:9118;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

## Обновление

```bash
docker pull ghcr.io/jvckdubz/lampac:latest
docker stop lampac
docker rm lampac
docker run -d \
  --name lampac \
  -p 9118:9118 \
  -v /opt/lampac:/home \
  --restart always \
  ghcr.io/jvckdubz/lampac:latest
```

Или с docker-compose:

```bash
cd /opt/lampac
docker compose pull
docker compose up -d
```

## Устранение неполадок

### Контейнер не запускается

```bash
# Проверить логи
docker logs lampac

# Проверить права на директорию
ls -la /opt/lampac
```

### TorrServer не работает

```bash
# Проверить, слушает ли порт
docker exec lampac ss -tlnp | grep 8090

# Перезапустить контейнер
docker restart lampac
```

### Парсеры не работают

1. Проверьте подключение к интернету из контейнера
2. Некоторые источники могут быть заблокированы — используйте прокси

### Настройка прокси

В `init.conf` добавьте:

```json
{
  "proxy": {
    "useproxy": true,
    "list": ["socks5://127.0.0.1:1080"]
  }
}
```

## Системные требования

- **CPU:** 1 ядро (рекомендуется 2+)
- **RAM:** 512 MB (рекомендуется 1 GB+)
- **Диск:** 500 MB + место для кэша
- **Docker:** 20.10+

## Порты

| Порт | Назначение |
|------|------------|
| 9118 | Основной веб-интерфейс |
| 8090 | TorrServer (опционально) |

## Лицензия

Этот репозиторий содержит сохранённую копию проекта для архивных целей.

## Благодарности

Спасибо оригинальным разработчикам проекта Lampac за создание этого инструмента.
