-- C1 · autor: @IkxrMxra · ¿Qué clientes tienen cotizaciones y qué hospedaje y destino corresponden a cada una?
SELECT
    c.nombre_completo AS cliente,
    co.fecha_viaje,
    h.nombre_hotel AS hospedaje,
    d.nombre_destino AS destino,
    d.pais,
    co.costo_aprox,
    co.estado
FROM cotizacion co
JOIN cliente c ON c.id_cliente = co.id_cliente
JOIN hospedaje h ON h.id_hospedaje = co.id_hospedaje
JOIN destino d ON d.id_destino = h.id_destino
LIMIT 20;

-- C2 · autor: @salvadorGoros · ¿Qué clientes no tienen ninguna cotización registrada?
SELECT
    c.id_cliente,
    c.nombre_completo,
    COUNT(co.id_cotizacion) AS cotizaciones
FROM cliente c
LEFT JOIN cotizacion co ON co.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre_completo
HAVING COUNT(co.id_cotizacion) = 0
ORDER BY c.id_cliente;

-- C3 · autor: @BalamNieto · ¿Qué destinos tienen un costo promedio de cotización mayor a $30,000 MXN?
SELECT
    d.nombre_destino AS destino,
    d.pais,
    COUNT(co.id_cotizacion) AS total_cotizaciones,
    ROUND(AVG(co.costo_aprox), 2) AS costo_promedio
FROM cotizacion co
JOIN hospedaje h ON h.id_hospedaje = co.id_hospedaje
JOIN destino d ON d.id_destino = h.id_destino
GROUP BY d.id_destino, d.nombre_destino, d.pais
HAVING AVG(co.costo_aprox) > 30000
ORDER BY costo_promedio DESC;

-- C4 · autor: @salvadorGoros · ¿Qué cotizaciones tienen un costo mayor al promedio de todas las cotizaciones?
SELECT
    c.nombre_completo AS cliente,
    co.id_cotizacion,
    co.costo_aprox,
    co.estado
FROM cotizacion co
JOIN cliente c ON c.id_cliente = co.id_cliente
WHERE co.costo_aprox > (
    SELECT AVG(costo_aprox)
    FROM cotizacion
)
ORDER BY co.costo_aprox DESC
LIMIT 20;

-- C5 · autor: @BalamNieto · ¿Qué destinos tienen al menos una cotización registrada?
SELECT
    d.id_destino,
    d.nombre_destino AS destino,
    d.pais
FROM destino d
WHERE EXISTS (
    SELECT 1
    FROM hospedaje h
    JOIN cotizacion co ON co.id_hospedaje = h.id_hospedaje
    WHERE h.id_destino = d.id_destino
)
ORDER BY d.nombre_destino;

-- C6 · autor: @IkxrMxra · ¿Qué clientes tienen un monto total de cotizaciones superior al promedio de los clientes?
WITH total_por_cliente AS (
    SELECT
        c.id_cliente,
        c.nombre_completo AS cliente,
        SUM(co.costo_aprox) AS total_cotizaciones
    FROM cliente c
    JOIN cotizacion co ON co.id_cliente = c.id_cliente
    GROUP BY c.id_cliente, c.nombre_completo
)
SELECT
    cliente,
    ROUND(total_cotizaciones, 2) AS total_cotizaciones
FROM total_por_cliente
WHERE total_cotizaciones > (
    SELECT AVG(total_cotizaciones)
    FROM total_por_cliente
)
ORDER BY total_cotizaciones DESC;

-- C7 · autor: @salvadorGoros · ¿Cómo se distribuyen las cotizaciones por mes según la fecha de viaje?
SELECT
    DATE_TRUNC('month', fecha_viaje)::date AS mes,
    COUNT(*) AS cantidad_cotizaciones,
    ROUND(SUM(costo_aprox), 2) AS monto_total
FROM cotizacion
GROUP BY DATE_TRUNC('month', fecha_viaje)
ORDER BY mes;

-- C8 · autor: @BalamNieto · ¿Qué clientes tienen mayor gasto total en cotizaciones dentro de cada mes?
SELECT
    c.nombre_completo AS cliente,
    DATE_TRUNC('month', co.fecha_viaje)::date AS mes,
    ROUND(SUM(co.costo_aprox), 2) AS gasto,
    RANK() OVER (
        PARTITION BY DATE_TRUNC('month', co.fecha_viaje)
        ORDER BY SUM(co.costo_aprox) DESC
    ) AS lugar
FROM cotizacion co
JOIN cliente c ON c.id_cliente = co.id_cliente
GROUP BY c.id_cliente, c.nombre_completo, DATE_TRUNC('month', co.fecha_viaje)
ORDER BY mes, lugar;
