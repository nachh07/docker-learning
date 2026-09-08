# 🐘 Módulo 1: PostgreSQL con Docker

Aprenderás a levantar una base de datos PostgreSQL real usando Docker, con una interfaz web (pgAdmin) para visualizarla, todo sin instalar nada más allá de Docker en tu máquina.

---

## 📦 ¿Qué vas a aprender?

| Concepto | ¿Para qué sirve? |
|---|---|
| **Volúmenes** | Persistir datos aunque el contenedor se detenga |
| **Puertos** | Exponer servicios del contenedor al host |
| **Redes** | Comunicación aislada entre contenedores |
| **Comandos** | Gestionar el ciclo de vida del contenedor |

---

## 📁 Estructura del módulo

```
postgresql/
├── .env                  → Variables de entorno (usuario, contraseña, puertos)
├── docker-compose.yml    → Definición de los servicios
├── init/
│   ├── 01_schema.sql     → Se ejecuta al primer arranque: crea las tablas
│   └── 02_seed.sql       → Se ejecuta al primer arranque: inserta datos
└── ejercicios/
    ├── 01_volumenes.md
    ├── 02_puertos.md
    ├── 03_comandos.md
    └── 04_redes.md
```

---

## ✅ Requisitos previos

- Docker Desktop instalado y corriendo
- Terminal (PowerShell, CMD, bash)

Verificá que Docker esté disponible:
```bash
docker --version
docker compose version
```

---

## 🚀 Levantar el entorno

Desde la carpeta `postgresql/`:

```bash
# Levantar todos los servicios en segundo plano (-d = detached)
docker compose up -d
```

Docker va a:
1. Descargar las imágenes `postgres:16` y `dpage/pgadmin4` (solo la primera vez)
2. Crear la red `bookstore-network`
3. Crear los volúmenes `bookstore-pgdata` y `bookstore-pgadmin-data`
4. Arrancar el contenedor de PostgreSQL y ejecutar los scripts de `init/`
5. Esperar que postgres esté sano y luego arrancar pgAdmin

Verificá que todo esté corriendo:
```bash
docker compose ps
```

---

## 🌐 Acceder a pgAdmin

1. Abrí el navegador en: **http://localhost:8080**
2. Ingresá con:
   - **Email:** `admin@bookstore.com`
   - **Contraseña:** `pgadmin123`
3. Para conectar al servidor de PostgreSQL:
   - Click en *Add New Server*
   - **Name:** `Bookstore`
   - Tab **Connection:**
     - **Host:** `postgres` ← Este es el nombre del servicio en la red Docker
     - **Port:** `5432`
     - **Database:** `bookstore`
     - **Username:** `admin`
     - **Password:** `admin123`

> ⚠️ El hostname es `postgres` (nombre del servicio) y NO `localhost`, porque pgAdmin está dentro de la red Docker y se comunica con PostgreSQL a través de ella.

---

## 💻 Conectarse por terminal

```bash
# Ejecutar psql dentro del contenedor
docker exec -it bookstore-postgres psql -U admin -d bookstore

# Comandos útiles dentro de psql:
\dt          -- listar tablas
\d autores   -- describir la tabla autores
\q           -- salir
```

Consultas de prueba:
```sql
-- Ver todos los autores
SELECT * FROM autores;

-- Ver libros con su autor
SELECT l.titulo, a.nombre AS autor, l.precio, l.stock
FROM libros l
JOIN autores a ON l.autor_id = a.id;

-- Ventas totales por libro
SELECT l.titulo, SUM(v.cantidad) AS unidades, SUM(v.total) AS ingresos
FROM ventas v
JOIN libros l ON v.libro_id = l.id
GROUP BY l.titulo
ORDER BY ingresos DESC;
```

---

## 🛑 Detener el entorno

```bash
# Detener los contenedores (los datos se conservan en el volumen)
docker compose down

# Detener Y eliminar los volúmenes (¡borra todos los datos!)
docker compose down -v
```

---

## 📚 Ejercicios

Completá los ejercicios en orden dentro de la carpeta `ejercicios/`:

1. [01 - Volúmenes](./ejercicios/01_volumenes.md)
2. [02 - Puertos](./ejercicios/02_puertos.md)
3. [03 - Comandos básicos](./ejercicios/03_comandos.md)
4. [04 - Redes](./ejercicios/04_redes.md)
