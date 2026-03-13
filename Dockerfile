FROM alpine:latest

# Устанавливаем Xray
RUN apk add --no-cache bash curl wget unzip && \
    mkdir -p /usr/local/xray && \
    cd /usr/local/xray && \
    wget -O xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip xray.zip && \
    rm xray.zip && \
    chmod +x xray

# Создаём config.json прямо в Dockerfile (если файла нет)
RUN echo '{\n\
  "log": {\n\
    "loglevel": "warning"\n\
  },\n\
  "inbounds": [\n\
    {\n\
      "port": 8080,\n\
      "protocol": "vless",\n\
      "settings": {\n\
        "clients": [\n\
          {\n\
            "id": "30a587b7-ef47-4706-bc55-f9f7d34b468a",\n\
            "flow": ""\n\
          }\n\
        ],\n\
        "decryption": "none"\n\
      },\n\
      "streamSettings": {\n\
        "network": "ws",\n\
        "wsSettings": {\n\
          "path": "/vless"\n\
        }\n\
      }\n\
    }\n\
  ],\n\
  "outbounds": [\n\
    {\n\
      "protocol": "freedom"\n\
    }\n\
  ]\n\
}' > /usr/local/xray/config.json

# Порты
EXPOSE 8080

# Запуск
CMD /usr/local/xray/xray -config /usr/local/xray/config.json
