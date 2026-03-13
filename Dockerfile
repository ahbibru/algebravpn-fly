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

# Создаем config.json
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
echo ""

# Запускаем Xray
/usr/local/xray/xray -config /usr/local/xray/config.json
EOF

RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]