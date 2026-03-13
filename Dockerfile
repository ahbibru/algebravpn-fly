FROM alpine:latest

# Устанавливаем простой веб-сервер для теста
RUN apk add --no-cache netcat-openbsd

# Открываем порт
EXPOSE 8080

# Запускаем простейший HTTP-сервер
CMD while true; do \
  echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nOK" | nc -l -p 8080 -q 1; \
done