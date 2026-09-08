-- ============================================================
-- MÓDULO 2: DATOS DE EJEMPLO - Librería Bookstore
-- ============================================================
-- Este script se ejecuta automáticamente DESPUÉS de 01_schema.sql
-- (Docker ejecuta los archivos de init en orden alfabético).
-- Insertamos datos reales para que los ejercicios sean tangibles.
-- ============================================================

-- Insertar autores
INSERT INTO autores (nombre, nacionalidad, anio_nacimiento) VALUES
    ('Gabriel García Márquez', 'Colombiana',   1927),
    ('Jorge Luis Borges',      'Argentina',    1899),
    ('Isabel Allende',         'Chilena',      1942),
    ('Mario Vargas Llosa',     'Peruana',      1936),
    ('Julio Cortázar',         'Argentina',    1914);

-- Insertar libros
INSERT INTO libros (titulo, autor_id, genero, precio, stock, anio_publicacion) VALUES
    ('Cien años de soledad',          1, 'Realismo mágico', 1850.00, 25, 1967),
    ('El amor en los tiempos del cólera', 1, 'Romance',     1650.00, 18, 1985),
    ('Ficciones',                     2, 'Fantástico',      1400.00, 30, 1944),
    ('El Aleph',                      2, 'Fantástico',      1200.00, 22, 1949),
    ('La casa de los espíritus',      3, 'Realismo mágico', 1750.00, 15, 1982),
    ('Eva Luna',                      3, 'Novela',          1550.00, 12, 1987),
    ('La ciudad y los perros',        4, 'Novela',          1600.00, 20, 1963),
    ('Conversación en La Catedral',   4, 'Novela',          1800.00, 10, 1969),
    ('Rayuela',                       5, 'Experimental',    2000.00, 35, 1963),
    ('Historias de Cronopios y Famas',5, 'Cuentos',        1100.00, 28, 1962);

-- Insertar ventas
INSERT INTO ventas (libro_id, cantidad, total, fecha_venta) VALUES
    (1, 3, 5550.00, '2026-08-01'),
    (1, 1, 1850.00, '2026-08-05'),
    (2, 2, 3300.00, '2026-08-10'),
    (3, 5, 7000.00, '2026-08-12'),
    (4, 2, 2400.00, '2026-08-15'),
    (5, 1, 1750.00, '2026-08-18'),
    (6, 3, 4650.00, '2026-08-20'),
    (7, 4, 6400.00, '2026-08-22'),
    (8, 1, 1800.00, '2026-08-25'),
    (9, 2, 4000.00, '2026-08-28'),
    (9, 3, 6000.00, '2026-09-01'),
    (10, 5, 5500.00, '2026-09-03'),
    (1, 2, 3700.00, '2026-09-05'),
    (3, 1, 1400.00, '2026-09-06'),
    (5, 2, 3500.00, '2026-09-07');
