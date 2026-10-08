# Línea Base de Tiempos y Diagnóstico de Consultas (Sin Índices)

## Medición de Tiempos Iniciales (Práctica 6)

| Consulta | Execution Time (ms) | ¿Aparece Seq Scan? ¿Sobre qué tabla? | Hipótesis de Columna a Indexar |
| :--- | :--- | :--- | :--- |
| **C4 (Subconsulta en WHERE)** | `18.42 ms` | Sí, `Seq Scan` sobre `cotizacion` | `cotizacion(costo_aprox)` para acelerar el cálculo del promedio y el filtrado por costo. |
| **C7 (Tendencia temporal)** | `24.15 ms` | Sí, `Seq Scan` sobre `cotizacion` | `cotizacion(fecha_viaje)` para agilizar el agrupamiento mensual con `DATE_TRUNC`. |
| **C8 (Función de ventana)** | `32.80 ms` | Sí, `Seq Scan` sobre `cotizacion` y `cliente` | `cotizacion(id_cliente, fecha_viaje)` para optimizar el `PARTITION BY` y la unión con `cliente`. |

---

## Diagnóstico 7 oct

### Veredicto de Consultas y Columnas Candidatas
- **C7 (Tendencia en el tiempo):**
  - **Veredicto:** El `Seq Scan` es correcto ya que la consulta requiere el 100% de los datos de la tabla para agrupar las tendencias del año.
  - **Candidata:** No se recomienda índice B-Tree simple para la agregación global.

- **C4 (Filtro por costo medio con ORDER BY + LIMIT):**
  - **Veredicto:** Presenta 5,053 `Rows Removed by Filter`. Un índice evitaría escanear toda la tabla para encontrar los valores más altos.
  - **Candidata:** Crear índice B-Tree en `cotizacion(costo_aprox DESC)`.

- **C1 (JOIN de 3+ tablas con Foreign Keys desprotegidas):**
  - **Veredicto:** Realiza `Seq Scan` sobre la tabla grande para construir `Hash Joins` al carecer de índices en las llaves foráneas.
  - **Candidata:** Crear índices B-Tree en las Foreign Keys `cotizacion(id_hospedaje)` y `cotizacion(id_cliente)`.
