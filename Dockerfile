FROM headscale/headscale:0.26.1

COPY ./config.yaml /etc/headscale/config.yaml
RUN mkdir -p /var/lib/headscale
EXPOSE 8080

# Sobrescribir el entrypoint problemático
ENTRYPOINT []
CMD ["serve"]