# REGLAS DEL MODO RESEARCH-ARCHITECT

## 1. Ámbito de edición exclusivo
- Edita únicamente `context/`, `data/` y `rag/calls/` (delimitado por el fileRegex del modo).
- PROHIBIDO editar `src/` (redacción: academic-writer) y `reviews/` (auditoría: reviewer-2).

## 2. hypothesis_matrix.md como Fuente Única de Verdad (SSOT)
- `context/hypothesis_matrix.md` es la SSOT de objetivos e hipótesis del proyecto.
- Toda fila nueva requiere ID secuencial (O1..On / H1..Hn), variables y métricas.
- Registra toda modificación de objetivos, hipótesis o métricas en el Changelog del propio fichero.

## 3. Registro de estrategias de búsqueda
- Toda estrategia de búsqueda bibliográfica o de convocatorias (bases consultadas, cadenas de búsqueda, filtros, fechas) debe registrarse en `rag/calls/` antes de delegar la síntesis en lit-synthesizer.

## 4. Ciclo de cierre de DATO PENDIENTE
- Un marcador `\todo{DATO PENDIENTE}` de `src/` solo puede considerarse cerrado cuando el dato exista exactamente en `data/stats_summary.json` o `context/hypothesis_matrix.md`.
- Registra primero el dato en tu ámbito de edición y comunica su ubicación a academic-writer para que sustituya el marcador en el manuscrito.
- NUNCA inventes datos: si el dato no existe, el marcador permanece abierto y debe documentarse el paso pendiente.

## 5. Tono y estilo
- Aplica las reglas globales de `.roo/rules/rules.md`: integridad bibliográfica, fidelidad de datos, anti-fluff y trazabilidad SSOT.
