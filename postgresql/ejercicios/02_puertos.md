# 🔌 Ejercicio 2: Puertos en Docker

## ¿Qué es el mapeo de puertos?

Los contenedores Docker viven en una red **aislada**. Para que una aplicación del host (tu PC) pueda hablar con un servicio dentro del contenedor, necesitás **mapear un puerto del host a un puerto del contenedor**.

```
TU PC (host)                     Contenedor Docker
┌─────────────────────────┐      ┌──────────────────────────┐
│                         │      │                          │
│  psql / DBeaver / etc.  │      │  PostgreSQL escucha      │
│  → conecta a            │      │  SIEMPRE en el           │
│    localhost:5432  ─────┼──────┼─► puerto 5432            │
│                         │      │                          │
└─────────────────────────┘      └──────────────────────────┘
        HOST PORT                       CONTAINER PORT
```

La sintaxis en `docker-compose.yml` es:
```yaml
ports:
  - "HOST_PORT:CONTAINER_PORT"
```

> El contenedor siempre escucha en el mismo puerto interno. Vos controlás con qué puerto del host querés conectarte.

---

## 📋 Nuestro mapeo actual

En el archivo `.env`:
```
POSTGRES_PORT=5432   → el host expone el puerto 5432
PGADMIN_PORT=8080    → el host expone el puerto 8080
```

En `docker-compose.yml`:
```yaml
# PostgreSQL
ports:
  - "${POSTGRES_PORT}:5432"   # localhost:5432 → contenedor:5432

# pgAdmin
ports:
  - "${PGADMIN_PORT}:80"      # localhost:8080 → contenedor:80
```

---

## 🧪 Demostración 1: Cambiar el puerto del host

¿Qué pasa si el puerto 5432 ya está en uso? Cambiémoslo.

### Paso 1: Modificar el `.env`

```env
POSTGRES_PORT=5433
```

### Paso 2: Recrear el contenedor con el nuevo puerto

```bash
docker compose down
docker compose up -d
```

### Paso 3: Conectarse al nuevo puerto

```bash
# Ahora el host escucha en 5433
docker exec -it bookstore-postgres psql -U admin -d bookstore
```

O desde un cliente externo (DBeaver, pgAdmin local):
- **Host:** `localhost`
- **Puerto:** `5433`  ← cambió en el host
- **Database:** `bookstore`

> 💡 El Puerto 5432 **dentro** del contenedor no cambió. Solo cambió cómo el host "publica" ese puerto hacia afuera.

---

## 🧪 Demostración 2: ¿Qué pasa si el puerto ya está en uso?

Si tenés PostgreSQL instalado localmente en el puerto 5432, vas a obtener un error como:

```
Error response from daemon: driver failed programming external
connectivity on endpoint bookstore-postgres: Bind for 0.0.0.0:5432
failed: port is already allocated
```

**Solución:** Cambiar `POSTGRES_PORT` a otro valor libre (ej: `5433`, `5434`).

---

## 🧪 Demostración 3: Contenedor SIN puerto mapeado

Editá temporalmente el `docker-compose.yml` y comentá la sección de ports de postgres:

```yaml
# ports:
#   - "${POSTGRES_PORT}:5432"
```

```bash
docker compose down
docker compose up -d
```

Intentá conectarte desde el host:
```bash
psql -h localhost -U admin -d bookstore
```

❌ **Falla.** No hay acceso desde el host. Sin embargo, **pgAdmin sí puede conectarse** porque está dentro de la misma red Docker (`bookstore-network`) y no necesita el puerto del host para comunicarse con postgres.

Restaurá el puerto cuando termines.

---

## 🔍 Comandos de inspección de puertos

```bash
# Ver qué puertos tiene mapeados cada contenedor
docker compose ps

# Ver detalles completos del contenedor (incluye puertos y red)
docker inspect bookstore-postgres

# Filtrar solo la sección de puertos
docker inspect bookstore-postgres --format '{{json .NetworkSettings.Ports}}' 

# Ver qué proceso del host usa un puerto (Windows PowerShell)
netstat -ano | findstr :5432
```

---

## ✅ Preguntas de reflexión

1. ¿Cuál es la diferencia entre el puerto del host y el puerto del contenedor?
2. ¿Por qué pgAdmin usa `postgres` como hostname y no `localhost`?
3. Si cambiás `POSTGRES_PORT=5433`, ¿necesitás cambiar algo dentro del contenedor?
4. ¿Podés tener dos contenedores de PostgreSQL corriendo al mismo tiempo? ¿Cómo?
