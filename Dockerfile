FROM alpine:3.20

# Instala herramientas necesarias
RUN apk add --no-cache curl ca-certificates tzdata

# Instala Headscale
ENV HEADSCALE_VERSION=0.22.3
RUN curl -L https://github.com/juanfont/headscale/releases/download/v${HEADSCALE_VERSION}/headscale_${HEADSCALE_VERSION}_linux_amd64 \
    -o /usr/bin/headscale && chmod +x /usr/bin/headscale

# Copia config y entrypoint
COPY config.yaml /etc/headscale/config.yaml
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Crea carpeta de datos
RUN mkdir -p /var/lib/headscale

# Puerto por defecto
EXPOSE 8080

# Script inteligente que corrige el comando
ENTRYPOINT ["/entrypoint.sh"]
