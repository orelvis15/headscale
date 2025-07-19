FROM alpine:3.20

# Instala herramientas necesarias
RUN apk add --no-cache curl ca-certificates tzdata

# Descarga la última versión de Headscale (ajusta la versión si es necesario)
ENV HEADSCALE_VERSION=0.22.3

RUN curl -L https://github.com/juanfont/headscale/releases/download/v${HEADSCALE_VERSION}/headscale_${HEADSCALE_VERSION}_linux_amd64 \
    -o /usr/bin/headscale && \
    chmod +x /usr/bin/headscale

# Copia la configuración
COPY config.yaml /etc/headscale/config.yaml

# Crea el directorio de datos
RUN mkdir -p /var/lib/headscale

EXPOSE 8080

CMD ["headscale", "serve"]
