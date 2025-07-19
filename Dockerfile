# Imagen base con Headscale preinstalado
FROM juanfont/headscale:latest

# Copiamos el archivo de configuración (ajusta la ruta si es necesario)
COPY config.yaml /etc/headscale/config.yaml

# Copiamos el script de entrada personalizado
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Usamos el script como punto de entrada
ENTRYPOINT ["/entrypoint.sh"]

# Comando por defecto
CMD ["serve"]
