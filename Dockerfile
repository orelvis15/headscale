# Dockerfile alternativo que descarga headscale directamente
FROM alpine:3.19

# Instalar dependencias
RUN apk add --no-cache wget ca-certificates

# Variables para la versión de headscale
ENV HEADSCALE_VERSION=0.26.1
ENV TARGETARCH=amd64

# Descargar headscale
RUN wget -O /usr/local/bin/headscale \
    "https://github.com/juanfont/headscale/releases/download/v${HEADSCALE_VERSION}/headscale_${HEADSCALE_VERSION}_linux_${TARGETARCH}" && \
    chmod +x /usr/local/bin/headscale

# Crear directorios necesarios
RUN mkdir -p /etc/headscale /var/lib/headscale

# Copiar configuración
COPY ./config.yaml /etc/headscale/config.yaml

# Puerto
EXPOSE 8080

# Usuario no root para seguridad
RUN adduser -D -s /bin/sh headscale
USER headscale

# Comando
CMD ["/usr/local/bin/headscale", "serve"]