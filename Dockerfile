FROM alpine:3.20

RUN apk add --no-cache curl ca-certificates tzdata

ENV HEADSCALE_VERSION=0.26.1

# Instalar headscale
RUN curl -L https://github.com/juanfont/headscale/releases/download/v${HEADSCALE_VERSION}/headscale_${HEADSCALE_VERSION}_linux_amd64 \
    -o /usr/bin/headscale && chmod +x /usr/bin/headscale

# Crear directorios necesarios
RUN mkdir -p /var/lib/headscale /var/run/headscale

# Copiar configuración
COPY config.yaml /etc/headscale/config.yaml

EXPOSE 8080 50443

ENTRYPOINT ["headscale"]
CMD ["serve"]