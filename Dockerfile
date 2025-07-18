FROM headscale/headscale:0.26.1
COPY ./config.yaml /etc/headscale/config.yaml
EXPOSE 8080
CMD ["serve"]
