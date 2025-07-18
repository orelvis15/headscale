FROM headscale/headscale:0.26.1

# Copiamos la configuración
COPY ./config.yaml /etc/headscale/config.yaml

# Creamos los directorios necesarios para la base de datos y claves
RUN mkdir -p /var/lib/headscale

# Puerto donde escucha headscale
EXPOSE 8080

# Ejecuta el servidor correctamente
CMD ["headscale", "serve"]