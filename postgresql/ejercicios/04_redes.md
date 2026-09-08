# 🌐 Ejercicio 4: Redes en Docker

## ¿Qué es una red en Docker?

Docker crea redes virtuales que permiten que los contenedores se comuniquen entre sí de forma **aislada** del resto del sistema. Cada red tiene su propio espacio de direcciones IP y resolución DNS interna.

```
Sin red personalizada:           Con red personalizada (nuestro caso):
┌──────────────┐                 ┌──────────────────────────────────────┐
│ postgres     │  no se ven      │         bookstore-network            │
│ pgadmin      │  entre sí       │  ┌─────────────┐  ┌───────────────┐ │
└──────────────┘                 │  │  postgres   │◄─►│   pgadmin     │ │
                                 │  │ 172.20.0.2  │  │ 172.20.0.3   │ │
                                 │  └─────────────┘  └───────────────┘ │
                                 └──────────────────────────────────────┘
```

### Tipos de redes en Docker

| Driver | Descripción | Uso típico |
|---|---|---|
| `bridge` | Red interna privada entre contenedores | Desarrollo local (nuestro caso) |
| `host` | El contenedor usa directamente la red del host | Rendimiento máximo, sin aislamiento |
| `none` | Sin red | Contenedores completamente aislados |
| `overlay` | Red distribuida entre múltiples hosts | Docker Swarm / producción |

---

## 🔑 Resolución DNS entre contenedores

Cuando dos contenedores están en la **misma red**, pueden referenciarse por el **nombre del servicio** como si fuera un hostname. Docker hace de servidor DNS internamente.

En nuestro proyecto:
- `pgadmin` puede alcanzar a `postgres` usando el hostname `postgres`
- No necesita conocer la IP (que puede cambiar en cada arranque)

Por eso en pgAdmin configuramos:
```
Host: postgres   ← nombre del servicio, no localhost ni una IP
Port: 5432
```

---

## 🧪 Demostración 1: Ver la red y los contenedores conectados

```bash
# Listar todas las redes
docker network ls

# Ver detalles de nuestra red personalizada
docker network inspect bookstore-network
```

La salida de `inspect` muestra:
- El driver (`bridge`)
- El rango de IPs (`Subnet`)
- Los contenedores conectados y sus IPs

---

## 🧪 Demostración 2: Resolución DNS interna

Entrá al contenedor de pgAdmin y probá que puede resolver el hostname `postgres`:

```bash
# Entrar al contenedor de pgAdmin
docker exec -it bookstore-pgadmin sh

# Dentro del contenedor, probar la resolución DNS
nslookup postgres

# También podés probar conectividad
ping postgres

# Salir
exit
```

Ahora intentá desde pgAdmin resolver `localhost`:
```bash
docker exec -it bookstore-pgadmin sh -c "nslookup localhost"
```
Esto resuelve a la IP del propio contenedor, no al host.

---

## 🧪 Demostración 3: Aislamiento de red

Vamos a crear un **contenedor externo** que intente conectarse a nuestra base de datos **sin estar en la red**:

```bash
# Contenedor temporal fuera de bookstore-network
docker run --rm postgres:16 psql -h postgres -U admin -d bookstore -c "SELECT 1;"
```

❌ **Falla.** El contenedor no puede resolver el hostname `postgres` porque no está en `bookstore-network`.

Ahora conectamos ese contenedor a nuestra red:
```bash
# Mismo contenedor pero conectado a bookstore-network
docker run --rm \
  --network bookstore-network \
  postgres:16 \
  psql -h postgres -U admin -d bookstore -c "SELECT COUNT(*) FROM libros;"
```

✅ **Funciona.** Al estar en la misma red, la resolución DNS interna funciona.

---

## 🧪 Demostración 4: Conectar un contenedor existente a una red

```bash
# Desconectar pgAdmin de la red
docker network disconnect bookstore-network bookstore-pgadmin

# Intentar conectarse a postgres desde pgAdmin ahora falla
# (probarlo desde la UI en http://localhost:8080)

# Volver a conectar
docker network connect bookstore-network bookstore-pgadmin
```

---

## 🔍 Comandos de redes

```bash
# Listar redes
docker network ls

# Crear una red manualmente
docker network create mi-red

# Inspeccionar una red
docker network inspect bookstore-network

# Conectar un contenedor a una red
docker network connect bookstore-network mi-contenedor

# Desconectar un contenedor de una red
docker network disconnect bookstore-network mi-contenedor

# Eliminar una red (debe estar sin contenedores)
docker network rm mi-red

# Eliminar redes sin uso
docker network prune
```

---

## 💡 ¿Por qué usar una red personalizada en lugar de la red por defecto?

Docker crea una red `bridge` por defecto, pero tiene limitaciones:
- Los contenedores en la red default **no se resuelven por nombre de servicio** (solo por IP o `--link`, que está deprecado)
- No permite distinguir entornos (dev, staging, prod) fácilmente
- Con una red personalizada tenés **DNS automático** y **aislamiento explícito**

Por eso siempre conviene definir tus propias redes en `docker-compose.yml`.

---

## ✅ Preguntas de reflexión

1. ¿Por qué pgAdmin usa `postgres` como hostname y no `localhost`?
2. ¿Qué pasaría si tuvieras dos proyectos corriendo al mismo tiempo con el mismo nombre de servicio pero en redes distintas?
3. ¿Qué ventaja tiene usar una red `bridge` personalizada sobre la red por defecto de Docker?
4. ¿Cómo harías para que un contenedor de una aplicación web se conecte a la base de datos de este proyecto sin modificar el `docker-compose.yml`?
