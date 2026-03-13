FROM alpine:latest

# Устанавливаем Xray
RUN apk add --no-cache bash curl wget unzip && \
    mkdir -p /usr/local/xray && \
    cd /usr/local/xray && \
    wget -O xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip xray.zip && \
    rm xray.zip && \
    chmod +x xray

# Конфиг
COPY config.json /usr/local/xray/config.json

# Порты
EXPOSE 8080

# Запуск
CMD /usr/local/xray/xray -config /usr/local/xray/config.json
