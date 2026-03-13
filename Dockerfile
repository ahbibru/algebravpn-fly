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

# Создаем config.json (ИСПРАВЛЕННЫЙ - с encryption:none)
RUN echo '{\
  "log": {\
    "loglevel": "warning"\
  },\
  "inbounds": [\
    {\
      "port": 8080,\
      "protocol": "vless",\
      "settings": {\
        "clients": [\
          {\
            "id": "30a587b7-ef47-4706-bc55-f9f7d34b468a",\
            "encryption": "none"\
          }\
        ],\
        "decryption": "none"\
      },\
      "streamSettings": {\
        "network": "ws",\
        "wsSettings": {\
          "path": "/vless"\
        }\
      }\
    }\
  ],\
  "outbounds": [\
    {\
      "protocol": "freedom"\
    }\
  ]\
}' > /usr/local/xray/config.json

# Проверяем что файл создался
RUN cat /usr/local/xray/config.json

# Создаем скрипт запуска
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'echo "=================================="' >> /start.sh && \
    echo 'echo "  AlgebraVPN запущен"' >> /start.sh && \
    echo 'echo "=================================="' >> /start.sh && \
    echo 'echo "Запускаем Xray на порту 8080..."' >> /start.sh && \
    echo '/usr/local/xray/xray -config /usr/local/xray/config.json' >> /start.sh

RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
