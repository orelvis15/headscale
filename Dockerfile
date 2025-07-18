FROM headscale/headscale:0.26.1

# Copiamos la configuración
COPY ./config.yaml /etc/headscale/config.yaml

# Creamos los directorios necesarios para la base de datos y claves
RUN mkdir -p /var/lib/headscale

# Puerto donde escucha headscale
EXPOSE 8080

# Especificamos el comando completo como lo hacen en docker-compose
CMD ["headscale", "serve"]