FROM alpine:latest

# Устанавливаем Xray и простой веб-сервер
RUN apk add --no-cache bash curl wget unzip netcat-openbsd

# Скачиваем Xray
RUN mkdir -p /usr/local/xray && \
    cd /usr/local/xray && \
    wget -O xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip xray.zip && \
    rm xray.zip && \
    chmod +x xray

# Создаем config.json (БЕЗ ОШИБОК)
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

# Создаем скрипт запуска (запускает Xray + health check)
RUN cat > /start.sh << 'EOF'
#!/bin/sh
echo "🚀 Запуск Xray..."
/usr/local/xray/xray -config /usr/local/xray/config.json &

echo "📡 Запуск health check сервера на порту 8081..."
while true; do
  echo -e "HTTP/1.1 200 OK\r\nContent-Length: 2\r\n\r\nOK" | nc -l -p 8081 -q 1
done
EOF

RUN chmod +x /start.sh

EXPOSE 8080 8081

CMD ["/start.sh"]