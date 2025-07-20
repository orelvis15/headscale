# Guía Completa de Configuración Headscale con Docker

Esta guía documenta la configuración completa de Headscale (servidor de coordinación Tailscale auto-hospedado) usando Docker, incluyendo la creación de usuarios y configuración de dispositivos Android.

## Archivos de Configuración

### 1. Dockerfile

```dockerfile
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
```

### 2. config.yaml

```yaml
# Cambia esto por tu IP real (NO localhost)
server_url: http://192.168.0.169:8080

listen_addr: 0.0.0.0:8080
metrics_listen_addr: 0.0.0.0:9090
grpc_listen_addr: 0.0.0.0:50443

private_key_path: /var/lib/headscale/private.key

noise:
  private_key_path: /var/lib/headscale/noise_private.key

prefixes:
  v4: 100.64.0.0/10
  v6: fd7a:115c:a1e0::/48
  allocation: sequential

database:
  type: sqlite
  sqlite:
    path: /var/lib/headscale/db.sqlite
    write_ahead_log: true

dns:
  magic_dns: true
  override_local_dns: true
  base_domain: example.com
  nameservers:
    global:
      - 1.1.1.1
      - 8.8.8.8

derp:
  urls:
    - https://controlplane.tailscale.com/derpmap/default
  auto_update_enabled: true
  update_frequency: 24h

log:
  level: info
  format: text

# Habilitar API para comandos
api_key: ""
```

> **⚠️ Importante:** Cambia `192.168.0.169` por la IP real de tu servidor.

## Comandos de Instalación y Configuración

### 1. Limpieza Completa de Docker (Opcional)

```bash
# Limpiar todo Docker (CUIDADO: elimina todo)
docker stop $(docker ps -aq) 2>/dev/null || true && \
docker rm $(docker ps -aq) 2>/dev/null || true && \
docker rmi $(docker images -q) 2>/dev/null || true && \
docker system prune -a -f
```

### 2. Construcción y Ejecución del Contenedor

```bash
# Construir la imagen
docker build -t headscale .

# Ejecutar headscale
docker run -d \
  --name headscale \
  -p 8080:8080 \
  -p 50443:50443 \
  -v headscale_data:/var/lib/headscale \
  headscale

# Ver logs para verificar que funciona
docker logs headscale
```

### 3. Gestión de Usuarios

```bash
# Crear un usuario
docker exec headscale headscale users create miusuario

# Listar usuarios para ver IDs
docker exec headscale headscale users list
# Output ejemplo:
# ID | Name | Username  | Email | Created
# 1  |      | miusuario |       | 2025-07-19 20:20:28
```

### 4. Generar Claves de Pre-autenticación

```bash
# Generar clave usando el ID del usuario (normalmente 1)
docker exec headscale headscale preauthkeys create --user 1 --expiration 24h

# Para clave reutilizable
docker exec headscale headscale preauthkeys create --user 1 --expiration 24h --reusable

# Listar claves generadas
docker exec headscale headscale preauthkeys list
```

## Configuración de Dispositivos Android

### 1. Instalar y Configurar Tailscale

1. **Descargar** Tailscale desde Google Play Store o F-Droid
2. **Abrir la app** y hacer tap múltiples veces en los "tres puntos" (esquina superior derecha)
3. **Aparecerá "Change server"**, hacer tap
4. **Introducir URL**: `http://192.168.0.169:8080` (cambia por tu IP)
5. **Tap "Save and restart"**

### 2. Autenticación

#### Método 1: Manual (Webview)
1. **Tap "Sign in with other"**
2. **Se abrirá webview** con comando como:
   ```
   headscale nodes register --user USERNAME --key MNXFzY7qXvqfeasEByqeYn9P
   ```
3. **Ejecutar en servidor** (usar ID numérico, no nombre):
   ```bash
   docker exec headscale headscale nodes register --user 1 --key MNXFzY7qXvqfeasEByqeYn9P
   ```

#### Método 2: Con Clave Pre-autenticada
1. **Generar clave** en servidor:
   ```bash
   docker exec headscale headscale preauthkeys create --user 1 --expiration 24h
   ```
2. **En Android**, usar "Sign in with auth key"
3. **Pegar la clave** generada

## Comandos de Verificación

```bash
# Ver nodos conectados
docker exec headscale headscale nodes list

# Ver usuarios
docker exec headscale headscale users list

# Ver claves de pre-autenticación
docker exec headscale headscale preauthkeys list

# Ver logs del contenedor
docker logs headscale

# Verificar desde navegador
# Visitar: http://192.168.0.169:8080
```

## Configuración de Exit Nodes (Nodos de Salida)

### En Android (configurar como exit node):
1. **En la app Tailscale**, ir a "Exit Node"
2. **Seleccionar "Run as exit node"**

### En el servidor (aprobar exit node):
```bash
# Ver rutas anunciadas
docker exec headscale headscale routes list

# Habilitar rutas de exit node (reemplazar ID según output anterior)
docker exec headscale headscale routes enable -r 1  # IPv4
docker exec headscale headscale routes enable -r 2  # IPv6

# Verificar que están habilitadas
docker exec headscale headscale routes list
```

### En otros dispositivos (usar exit node):
```bash
# Ver exit nodes disponibles
tailscale exit-node list

# Usar exit node específico
tailscale set --exit-node <IP_DEL_ANDROID>

# Desactivar exit node
tailscale set --exit-node=
```

## Solución de Problemas Comunes

### Error: "user not found"
```bash
# Verificar que el usuario existe
docker exec headscale headscale users list

# Usar ID numérico, no nombre de usuario
docker exec headscale headscale nodes register --user 1 --key <CLAVE>
```

### Error: "localhost:8080" en Android
- **Problema**: `server_url` en config.yaml está como `localhost`
- **Solución**: Cambiar a IP real del servidor y reconstruir contenedor

### Verificar conectividad
```bash
# Verificar que el puerto está abierto
sudo ufw allow 8080/tcp
sudo ufw status

# Test desde navegador
curl http://192.168.0.169:8080
```

## Estructura de Archivos del Proyecto

```
headscale/
├── Dockerfile
├── config.yaml
└── README.md (este archivo)
```

## Comandos de Mantenimiento

```bash
# Reiniciar contenedor
docker restart headscale

# Ver logs en tiempo real
docker logs -f headscale

# Backup de datos
docker cp headscale:/var/lib/headscale ./backup/

# Eliminar y recrear (PIERDE DATOS)
docker stop headscale
docker rm headscale
docker volume rm headscale_data
# Luego reconstruir...
```

## Notas Importantes

- **Firewall**: Asegúrate de que el puerto 8080 esté abierto
- **IP Estática**: Usa IP estática para el servidor o configura DNS
- **Rendimiento**: Android como exit node tiene limitaciones de rendimiento
- **Batería**: Exit nodes en Android consumen más batería
- **Persistencia**: Los datos se guardan en el volumen Docker `headscale_data`

---

**✅ Estado de la Configuración:**
- ✅ Headscale funcionando en Docker
- ✅ Usuario creado y verificado
- ✅ Android conectado exitosamente
- ✅ Exit node configurado (opcional)

**📱 Dispositivos Conectados:** Verificar con `docker exec headscale headscale nodes list`