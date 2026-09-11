# 📂 Ejercicio 1: Volúmenes en Docker

## ¿Qué es un volumen?

Un **contenedor Docker es efímero por naturaleza**: si lo eliminás, todo lo que estaba dentro desaparece. Los volúmenes son la solución de Docker para **persistir datos fuera del ciclo de vida del contenedor**.

```
SIN volumen:                    CON volumen:
┌─────────────┐                 ┌─────────────┐    ┌──────────────┐
│ Contenedor  │                 │ Contenedor  │◄──►│   Volumen    │
│  (datos)    │  ← se borra     │             │    │  (en el host)│
└─────────────┘                 └─────────────┘    └──────────────┘
      ↓ eliminar                      ↓ eliminar         ↓
  datos perdidos                  datos perdidos    datos INTACTOS
```

### Tipos de volúmenes

| Tipo | Sintaxis en compose | ¿Quién gestiona la ubicación? |
|---|---|---|
| **Volumen nombrado** | `pgdata:/ruta/en/contenedor` | Docker (recomendado) |
| **Bind mount** | `./carpeta:/ruta/en/contenedor` | Vos (ruta del host explícita) |

En nuestro `docker-compose.yml` usamos **ambos**:
- `pgdata` → volumen nombrado para los datos de PostgreSQL
- `./init` → bind mount para los scripts SQL de inicialización

---

## 🧪 Demostración: Los datos persisten

### Paso 1: Levantar el entorno y crear datos

```bash
docker compose up -d
```

Conectate y verificá que los datos de ejemplo estén cargados:
```bash
docker exec -it bookstore-postgres psql -U admin -d bookstore -c "SELECT COUNT(*) FROM libros;"
```
Deberías ver `10` libros.

Ahora insertá un libro nuevo para identificarlo después:
```bash
docker exec -it bookstore-postgres psql -U admin -d bookstore -c \
  "INSERT INTO libros (titulo, autor_id, genero, precio, stock) VALUES ('Mi libro de prueba', 1, 'Test', 100.00, 1);"
```

### Paso 2: Detener y eliminar el contenedor

```bash
# Detenemos y ELIMINAMOS el contenedor (pero NO el volumen)
docker compose down
```

Verificá que el contenedor ya no existe:
```bash
docker ps -a
```

### Paso 3: Volver a levantar

```bash
docker compose up -d
```

### Paso 4: Verificar que los datos siguen ahí

```bash
docker exec -it bookstore-postgres psql -U admin -d bookstore -c "SELECT titulo FROM libros WHERE titulo = 'Mi libro de prueba';"
```

✅ **El libro sigue existiendo.** El volumen sobrevivió al contenedor.

---

## 🧪 Demostración inversa: Eliminar el volumen

```bash
# -v elimina también los volúmenes asociados
docker compose down -v
```

Volvé a levantar:
```bash
docker compose up -d
```

Verificá:
```bash
docker exec -it bookstore-postgres psql -U admin -d bookstore -c "SELECT titulo FROM libros WHERE titulo = 'Mi libro de prueba';"
```

❌ **El libro ya no existe.** El volumen fue eliminado y los datos de inicialización se volvieron a ejecutar desde cero.

---

## 🔍 Comandos de inspección de volúmenes

```bash
# Listar todos los volúmenes en el sistema
docker volume ls

# Ver detalles de un volumen específico (incluye ruta física en el host)
docker volume inspect bookstore-pgdata

# Eliminar un volumen manualmente (solo funciona si no está en uso)
docker volume rm bookstore-pgdata

# Eliminar todos los volúmenes sin uso (¡cuidado!)
docker volume prune
```

---

## 💡 ¿Dónde están los datos físicamente?

Al ejecutar `docker volume inspect bookstore-pgdata`, vas a ver un campo `Mountpoint` con la ruta real en tu sistema operativo. En Windows con Docker Desktop, esto apunta a una ruta dentro de la VM de Linux que usa Docker internamente.

---

## ✅ Preguntas de reflexión

1. ¿Qué diferencia hay entre `docker compose down` y `docker compose down -v`?
2. ¿Para qué sirve el bind mount de `./init`? ¿Por qué se ejecuta solo la primera vez?
3. ¿Cuándo usarías un bind mount en lugar de un volumen nombrado?
