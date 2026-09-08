-- ============================================================
-- MÓDULO 1: ESQUEMA DE LA BASE DE DATOS - Librería Bookstore
-- ============================================================
-- Este script se ejecuta automáticamente cuando el contenedor
-- arranca por PRIMERA VEZ (gracias al bind mount sobre
-- /docker-entrypoint-initdb.d/).
-- Si el volumen ya existe con datos, este script NO se vuelve
-- a ejecutar. Eso es exactamente la persistencia en acción.
-- ============================================================

-- Tabla de autores
CREATE TABLE IF NOT EXISTS autores (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    nacionalidad VARCHAR(50),
    anio_nacimiento INT,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de libros
CREATE TABLE IF NOT EXISTS libros (
    id          SERIAL PRIMARY KEY,
    titulo      VARCHAR(200) NOT NULL,
    autor_id    INT REFERENCES autores(id) ON DELETE SET NULL,
    genero      VARCHAR(50),
    precio      NUMERIC(8, 2) NOT NULL,
    stock       INT DEFAULT 0,
    anio_publicacion INT,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de ventas
CREATE TABLE IF NOT EXISTS ventas (
    id          SERIAL PRIMARY KEY,
    libro_id    INT REFERENCES libros(id) ON DELETE CASCADE,
    cantidad    INT NOT NULL CHECK (cantidad > 0),
    total       NUMERIC(10, 2),
    fecha_venta DATE DEFAULT CURRENT_DATE,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
