---
name: s2-search
description: 'Úsala cuando lit-synthesizer deba buscar artículos científicos reales con el MCP semantic-scholar-mcp: búsquedas sistemáticas, cierre de marcadores \todo{CITA REQUERIDA} o atención de solicitudes delegadas por academic-writer, reviewer-2 o research-architect vía new_task.'
modeSlugs: [lit-synthesizer]
---

# S2 Search

## Instrucciones

Ejecuta la búsqueda de evidencia bibliográfica real mediante el servidor MCP `semantic-scholar-mcp` (tools: `search_paper`, `get_paper`, `get_authors`, `get_citation`). Esta skill cubre tres escenarios: (a) búsqueda sistemática por iniciativa propia, (b) cierre de un marcador `\todo{CITA REQUERIDA}` de `src/` y (c) atención de una solicitud delegada por otro modo vía `new_task`. El flujo de fases S0-S6 es el mismo en los tres casos.

## Fases

### S0 — Interpretar la solicitud
1. Identifica el origen: el investigador directamente o un modo delegante (academic-writer, reviewer-2, research-architect) mediante `new_task`.
2. Extrae y confirma los cuatro elementos de la petición: consulta (tema exacto), afirmación o sección a respaldar, criterios (rango de años, campos de estudio, máximo de artículos) y propósito.
3. Si la solicitud cierra un marcador `\todo{CITA REQUERIDA}` de `src/`, localízalo (fichero y línea) y anota qué evidencia necesita exactamente; ese marcador solo se dará por cerrado cuando la evidencia quede registrada en el repositorio.
4. Si faltan criterios esenciales y el origen es una delegación, devuelve la solicitud con lo que hayas podido inferir e indica explícitamente las hipótesis que adoptaste; no inventes restricciones.

### S1 — Buscar con `search_paper`
1. Construye consultas técnicas y concisas: términos del dominio, sin frases conversacionales ni interrogativas.
2. Solicita los campos mínimos: `title, abstract, year, externalIds, venue, authors, citationCount`.
3. Usa los parámetros `year` y `fieldsOfStudy` cuando el solicitante los haya especificado.
4. Limita los resultados a 10-20 por consulta; si la primera consulta no arroja candidatos suficientes, reformula con sinónimos del dominio antes de dar por fallida la búsqueda.

### S2 — Filtrar candidatos
1. Valida relevancia por título y abstract contra la afirmación o sección a respaldar.
2. Valida calidad: venue, número de citas y tipo de publicación. Marca los preprints sin peer review como tales en la nota de evidencia.
3. Descarta duplicados entre consultas conservando la versión con metadatos más completos.

### S3 — Verificar metadatos con `get_paper`
1. Confirma para cada candidato el DOI u otro identificador real (`externalIds`).
2. Rechaza cualquier registro sin metadatos verificables: sin DOI u otro identificador no se registra.

### S4 — Obtener la entrada BibTeX con `get_citation`
1. Solicita la entrada en formato `bibtex` para cada artículo que pase S3.
2. Conserva la entrada verbatim; el único ajuste permitido es la citekey en caso de colisión con una clave ya existente en `src/references.bib`.

### S5 — Registrar
1. En `context/evidence_notes.md`: Citekey, DOI/URL, fecha de acceso, metodología/muestra, resultados cuantitativos clave y limitaciones. Para preprints, indica expresamente la ausencia de peer review.
2. En `src/references.bib`: la entrada BibTeX verificada.
3. Respeta los permisos de edición de tu modo: solo esos dos ficheros. Nada de `src/`, `data/` ni `reviews/`.

### S6 — Responder al solicitante
1. Devuelve la lista de claves BibTeX con una frase-resumen por artículo.
2. Indica qué marcadores `\todo{CITA REQUERIDA}` quedan cerrados con la evidencia registrada y si alguno sigue abierto por falta de evidencia.
3. Si la búsqueda no arroja evidencia suficiente, decláralo explícitamente al solicitante sin aproximar ni inventar citas.

## Reglas transversales
- Respeta el rate limit del API (~1 petición/segundo): ante HTTP 429 espera 15-20 segundos antes de reintentar.
- Prohibido inventar autores, años, DOI o entradas BibTeX: todo registro debe provenir de una respuesta real del API.
- Si el API falla o no devuelve evidencia, decláralo y deja el marcador abierto; no lo cierres de forma aproximada.
- Toda cita debe existir en `src/references.bib` antes de ser usada por academic-writer (coherencia con `.roo/rules/rules.md` §1 y §6).
