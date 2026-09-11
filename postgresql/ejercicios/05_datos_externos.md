# 📥 Ejercicio 5: Cargar archivos externos con volúmenes

## Concepto

Hasta ahora los scripts de `init/` se ejecutaron automáticamente al primer arranque. Pero en el mundo real muchas veces necesitás **cargar archivos de datos externos** (CSV, dumps, exports) dentro de un contenedor PostgreSQL.

La solución es usar un **bind mount**: compartís una carpeta de tu host con el contenedor, y desde adentro usás el comando `COPY` de PostgreSQL para cargar los datos.

```
Tu PC (host)                          Contenedor postgres
┌──────────────────────────┐          ┌──────────────────────────────┐
│  postgresql/             │          │                              │
│  └── data/               │          │  /data/                      │
│      ├── clientes.csv  ──┼──────────┼──► clientes.csv             │
│      └── pedidos.csv   ──┼──────────┼──► pedidos.csv              │
│                          │  VOLUME  │                              │
└──────────────────────────┘          └──────────────────────────────┘
                                             ↓  COPY
                                       Tablas de PostgreSQL
```

### ¿Por qué es útil?

| Situación | Cómo ayuda el bind mount |
|---|---|
| Recibís un CSV nuevo cada día | Lo copiás a `./data/` y lo cargás sin tocar el contenedor |
| Querés recargar datos sin reconstruir | Solo corrés `COPY` de nuevo |
| Trabajás en equipo | Los CSV van en el repo, todos tienen los mismos datos |

---

## 📁 Estructura del ejercicio

En la carpeta `postgresql/data/` ya tenés dos archivos sintéticos listos:

```
postgresql/
└── data/
    ├── clientes.csv   → 20 clientes de Latinoamérica
    └── pedidos.csv    → 30 pedidos que vinculan clientes con libros
```

Estos archivos están montados en `/data` dentro del contenedor (configurado en `docker-compose.yml`).

---

## 🧪 Paso 1: Verificar el bind mount

Levantá el entorno si no está corriendo:
```bash
docker compose up -d
```

Confirmá que los archivos son visibles **dentro** del contenedor:
```bash
docker exec -it bookstore-postgres ls /data
```

Deberías ver:
```
clientes.csv  pedidos.csv
```

También podés ver el contenido de un CSV desde adentro del contenedor:
```bash
docker exec -it bookstore-postgres head -5 /data/clientes.csv
```

---

## 🧪 Paso 2: Crear las tablas nuevas

Conectate a psql:
```bash
docker exec -it bookstore-postgres psql -U admin -d bookstore
```

Ejecutá el DDL de las nuevas tablas:
```sql
-- Tabla de clientes
CREATE TABLE IF NOT EXISTS clientes (
    id               SERIAL PRIMARY KEY,
    nombre           VARCHAR(100) NOT NULL,
    email            VARCHAR(150) UNIQUE,
    ciudad           VARCHAR(80),
    pais             VARCHAR(50),
    fecha_registro   DATE
);

-- Tabla de pedidos (relaciona clientes con libros)
CREATE TABLE IF NOT EXISTS pedidos (
    id               SERIAL PRIMARY KEY,
    cliente_id       INT REFERENCES clientes(id),
    libro_id         INT REFERENCES libros(id),
    cantidad         INT NOT NULL CHECK (cantidad > 0),
    precio_unitario  NUMERIC(10, 2),
    fecha_pedido     DATE,
    estado           VARCHAR(20) CHECK (estado IN ('pendiente', 'enviado', 'entregado'))
);
```

Verificá que se crearon:
```sql
\dt
```

---

## 🧪 Paso 3: Cargar los CSV con COPY

El comando `COPY` de PostgreSQL lee archivos **desde la perspectiva del servidor** (el contenedor), por eso usamos la ruta `/data/` y no `./data/`.

```sql
-- Cargar clientes (omitimos la primera fila que es el encabezado)
COPY clientes (id, nombre, email, ciudad, pais, fecha_registro)
FROM '/data/clientes.csv'
DELIMITER ','
CSV HEADER;

-- Cargar pedidos
COPY pedidos (id, cliente_id, libro_id, cantidad, precio_unitario, fecha_pedido, estado)
FROM '/data/pedidos.csv'
DELIMITER ','
CSV HEADER;
```

Verificá la carga:
```sql
SELECT COUNT(*) FROM clientes;   -- debe dar 20
SELECT COUNT(*) FROM pedidos;    -- debe dar 30
```

---

## 🧪 Paso 4: Consultas con los datos cargados

Ahora que tenés clientes, pedidos y libros, podés hacer consultas completas:

```sql
-- ¿Qué libros pidió cada cliente?
SELECT
    c.nombre        AS cliente,
    l.titulo        AS libro,
    p.cantidad,
    p.precio_unitario,
    p.estado
FROM pedidos p
JOIN clientes c ON p.cliente_id = c.id
JOIN libros   l ON p.libro_id   = l.id
ORDER BY c.nombre;

-- Top clientes por gasto total
SELECT
    c.nombre,
    c.pais,
    COUNT(p.id)                          AS pedidos,
    SUM(p.cantidad * p.precio_unitario)  AS gasto_total
FROM pedidos p
JOIN clientes c ON p.cliente_id = c.id
GROUP BY c.id, c.nombre, c.pais
ORDER BY gasto_total DESC
LIMIT 5;

-- Pedidos pendientes
SELECT
    c.nombre   AS cliente,
    c.email,
    l.titulo   AS libro,
    p.fecha_pedido
FROM pedidos p
JOIN clientes c ON p.cliente_id = c.id
JOIN libros   l ON p.libro_id   = l.id
WHERE p.estado = 'pendiente'
ORDER BY p.fecha_pedido;
```

---

## 🧪 Paso 5: Agregar un archivo nuevo en caliente

Esta es la magia del bind mount: **no necesitás reiniciar el contenedor** para que vea un archivo nuevo.

1. Creá un archivo `postgresql/data/test.csv` en tu PC con cualquier contenido
2. Verificá que ya está disponible en el contenedor sin reiniciar:
```bash
docker exec -it bookstore-postgres ls /data
```

El archivo aparece inmediatamente porque la carpeta está **compartida en tiempo real**.

---

## 🔄 Paso 6: Recargar datos (truncate + copy)

Si los CSVs cambian y querés recargar:

```sql
-- Limpiar primero (respetar el orden por las FK)
TRUNCATE pedidos;
TRUNCATE clientes;

-- Volver a cargar
COPY clientes (id, nombre, email, ciudad, pais, fecha_registro)
FROM '/data/clientes.csv' DELIMITER ',' CSV HEADER;

COPY pedidos (id, cliente_id, libro_id, cantidad, precio_unitario, fecha_pedido, estado)
FROM '/data/pedidos.csv' DELIMITER ',' CSV HEADER;
```

---

## 💡 `COPY` vs `\copy`

| | `COPY` (servidor) | `\copy` (cliente psql) |
|---|---|---|
| **Lee el archivo desde** | El contenedor (`/data/`) | Tu PC local |
| **Necesita** | Ruta dentro del contenedor | Ruta en tu host |
| **Permisos** | Superusuario | Cualquier usuario |
| **Uso** | Dentro de psql conectado al server | Desde la terminal local |

```bash
# Alternativa con \copy (ejecutar desde tu terminal, no desde psql):
docker exec -i bookstore-postgres psql -U admin -d bookstore \
  -c "\copy clientes FROM '/data/clientes.csv' CSV HEADER"
```

---

## ✅ Preguntas de reflexión

1. ¿Qué diferencia hay entre el bind mount de `./init` y el de `./data`? ¿Por qué uno se ejecuta automáticamente y el otro no?
2. Si agregás un CSV nuevo a `./data/`, ¿necesitás reiniciar el contenedor? ¿Por qué?
3. ¿Qué pasa si hacés `docker compose down -v` y volvés a levantar? ¿Los datos cargados con `COPY` siguen?
4. ¿En qué escenario real usarías este patrón (CSV + bind mount + COPY)?
