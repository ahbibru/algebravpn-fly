FROM alpine:latest

# Устанавливаем всё необходимое
RUN apk add --no-cache bash curl wget unzip netcat-openbsd

# Скачиваем Xray
RUN mkdir -p /usr/local/xray && \
    cd /usr/local/xray && \
    wget -O xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip xray.zip && \
    rm xray.zip && \
    chmod +x xray

# Создаем config.json (ПРОВЕРЕННЫЙ РАБОЧИЙ)
RUN cat > /usr/local/xray/config.json << 'EOF'
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 8080,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "30a587b7-ef47-4706-bc55-f9f7d34b468a"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vless"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
EOF

# Создаем скрипт запуска
RUN cat > /start.sh << 'EOF'
#!/bin/sh
echo "=================================="
echo "  AlgebraVPN запущен"
echo "=================================="
echo "Xray порт: 8080 (VLESS+WS)"
echo "Health check порт: 8081"
echo ""

# Запускаем Xray в фоне
/usr/local/xray/xray -config /usr/local/xray/config.json &

# Запускаем health check сервер
while true; do
  echo -e "HTTP/1.1 200 OK\r\nContent-Length: 2\r\n\r\nOK" | nc -l -p 8081 -q 1
done
EOF

RUN chmod +x /start.sh

EXPOSE 8080 8081

CMD ["/start.sh"]