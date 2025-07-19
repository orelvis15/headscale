FROM juanfont/headscale:latest

COPY config.yaml /etc/headscale/config.yaml

# No ENTRYPOINT
# Usamos CMD con el comando completo
CMD ["headscale", "serve"]
