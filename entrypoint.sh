#!/bin/sh

# Evita que se repita "headscale headscale"
# Si el primer argumento ya es "headscale", elimínalo
if [ "$1" = "headscale" ]; then
  shift
fi

# Ejecuta correctamente
exec headscale "$@"
