# ⌨️ Ejercicio 3: Comandos básicos de Docker

## Referencia rápida (Cheat Sheet)

### Gestión del ciclo de vida (con Docker Compose)

| Comando | Descripción |
|---|---|
| `docker compose up -d` | Levanta todos los servicios en segundo plano |
| `docker compose down` | Detiene y elimina contenedores y redes |
| `docker compose down -v` | Idem + elimina volúmenes |
| `docker compose stop` | Detiene los contenedores (sin eliminarlos) |
| `docker compose start` | Inicia contenedores ya creados |
| `docker compose restart` | Reinicia los servicios |
| `docker compose ps` | Estado de los servicios |
| `docker compose logs` | Ver logs de todos los servicios |
| `docker compose logs -f postgres` | Seguir logs en tiempo real de un servicio |

### Gestión de contenedores individuales

| Comando | Descripción |
|---|---|
| `docker ps` | Contenedores en ejecución |
| `docker ps -a` | Todos los contenedores (incluye detenidos) |
| `docker stop bookstore-postgres` | Detiene el contenedor |
| `docker start bookstore-postgres` | Inicia el contenedor |
| `docker restart bookstore-postgres` | Reinicia el contenedor |
| `docker rm bookstore-postgres` | Elimina el contenedor (debe estar detenido) |
| `docker logs bookstore-postgres` | Ver logs del contenedor |
| `docker logs -f bookstore-postgres` | Seguir logs en tiempo real |
| `docker inspect bookstore-postgres` | Información detallada del contenedor |

### Ejecutar comandos dentro del contenedor

| Comando | Descripción |
|---|---|
| `docker exec -it bookstore-postgres bash` | Abrir terminal bash interactiva |
| `docker exec -it bookstore-postgres psql -U admin -d bookstore` | Abrir psql directamente |
| `docker exec bookstore-postgres pg_isready` | Verificar si postgres está listo |

---

## 🧪 Ejercicios prácticos

### Ejercicio A: Ciclo de vida completo

Ejecutá estos comandos uno por uno y observá el resultado de cada uno:

```bash
# 1. Levantar
docker compose up -d

# 2. Ver el estado
docker compose ps

# 3. Ver los logs de arranque de postgres
docker compose logs postgres

# 4. Detener sin eliminar
docker compose stop

# 5. Ver que los contenedores siguen existiendo (estado: exited)
docker ps -a

# 6. Volver a iniciar
docker compose start

# 7. Verificar que están corriendo
docker ps
```

### Ejercicio B: Inspeccionar un contenedor

```bash
# Ver toda la información del contenedor
docker inspect bookstore-postgres

# Obtener solo la IP del contenedor en la red bookstore-network
docker inspect bookstore-postgres \
  --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'

# Ver variables de entorno del contenedor
docker inspect bookstore-postgres \
  --format '{{range .Config.Env}}{{println .}}{{end}}'
```

### Ejercicio C: Interactuar con psql dentro del contenedor

```bash
# Entrar al contenedor con bash
docker exec -it bookstore-postgres bash

# Ya dentro del contenedor, podés ejecutar:
psql -U admin -d bookstore

# Explorar:
\dt          -- tablas disponibles
\d libros    -- estructura de la tabla libros
SELECT * FROM autores;
\q           -- salir de psql
exit         -- salir del contenedor
```

### Ejercicio D: Logs en tiempo real

Abrí **dos terminales**:

**Terminal 1:** Seguir los logs
```bash
docker compose logs -f postgres
```

**Terminal 2:** Hacer una consulta
```bash
docker exec -it bookstore-postgres psql -U admin -d bookstore -c "SELECT NOW();"
```

Observá cómo aparecen entradas en el log de la Terminal 1.

---

## 🔍 Comandos de limpieza general

```bash
# Eliminar todos los contenedores detenidos
docker container prune

# Eliminar imágenes sin uso
docker image prune

# Eliminar volúmenes sin uso
docker volume prune

# Limpieza total: contenedores detenidos + redes sin uso + imágenes colgadas + caché
docker system prune

# Ver cuánto espacio ocupa Docker
docker system df
```

> ⚠️ Los comandos `prune` son destructivos. Usalos solo cuando sepas qué están eliminando.

---

## ✅ Preguntas de reflexión

1. ¿Cuál es la diferencia entre `docker compose stop` y `docker compose down`?
2. ¿Para qué sirve el flag `-it` en `docker exec -it`?
3. ¿Qué ventaja tiene `docker compose logs -f` sobre `docker logs`?
4. ¿Qué información útil encontrás en `docker inspect`?
