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

## Fuente adicional: arXiv

- Cuándo usarla: preprints, ciencias de la computación (campos `cs.*`) e ingeniería eléctrica y electrónica (`eess.*`), o cuando `semantic-scholar-mcp` no arroje evidencia suficiente para el mismo tema. Las fases S0-S6 no cambian: en S1-S4 usa las tools de `arxiv` (`search_papers`, `get_abstract`, `download_paper`, `read_paper`, `list_papers`) en lugar de las de Semantic Scholar.
- Registro (idéntico a S5): evidencia en `context/evidence_notes.md` y entrada BibTeX verificada en `src/references.bib`; incluye el eprint ID (o el DOI de la versión publicada si existe). Marca expresamente "preprint" en la nota de evidencia: un preprint NO sustituye a la versión publicada, por lo que si existe versión con DOI de revista o conferencia, registra y devuelve esa.
- Rate limit: ~1 petición cada 3 segundos al API de arXiv; ante error o HTTP 429 sigue la escalera de backoff del marco académico §7 (esperar 10 s, 30 s, 90 s; máx. 3 intentos) y, al agotar, registra el bloqueo (D1) en `context/escalation_queue.md` dejando el marcador `\todo{}` abierto.

## Fuente adicional: PubMed (pubmedmcp)

- Cuándo usarla: biomedicina y revisiones sistemáticas (PRISMA), o cuando `semantic-scholar-mcp` no arroja evidencia suficiente para el mismo tema. Las fases S0-S6 no cambian: en S1 usa el servidor `pubmedmcp` con su tool `search_abstracts` (término en `term`; `retmax` moderado, p. ej. 10-20) en lugar de las de Semantic Scholar.
- Registro (idéntico a S5): evidencia en `context/evidence_notes.md` y entrada BibTeX verificada en `src/references.bib`; los abstracts devueltos incluyen DOI/PMID: registra el DOI de la versión publicada (o el PMID si no hay DOI) con su fecha de acceso.
- Rate limit: ~3 peticiones/segundo al API de NCBI sin clave (hasta 10 con la clave gratuita `NCBI_API_KEY`, definida solo como variable de entorno del sistema, nunca en ficheros trackeados).

## Fuente adicional: CrossRef (crossref-mcp-server)

- Cuándo usarla: verificación independiente de DOI/metadata y apoyo bibliográfico, o cuando las fuentes anteriores no arrojen evidencia suficiente para el mismo tema. Las fases S0-S6 no cambian: en S3 usa el servidor `crossref` con su tool `crossref_doi_lookup` para confirmar de forma independiente el DOI y los metadatos (título, autores, año, revista) antes de registrar; `crossref_references` y `crossref_export_bibtex`/`crossref_export_ris` apoyan la construcción de la entrada.
- Registro (idéntico a S5): evidencia en `context/evidence_notes.md` y entrada BibTeX verificada en `src/references.bib`. El export de CrossRef NO sustituye al registro S5: la entrada que añadas a `src/references.bib` debe seguir verificada y citando el DOI real.
- Rate limit: uso educado del API oficial api.crossref.org (evita ráfagas que provoquen 402/429); `CROSSREF_MAILTO` opcional solo como variable de entorno del sistema (polite pool), nunca en ficheros trackeados.

## Reglas transversales
- Backoff ante HTTP 429 (escalera del marco académico §7): respeta la cortesía de ~1 petición/segundo y, ante 429, espera 20 s, 40 s, 80 s y 160 s (máx. 4 intentos). Al agotar los intentos: registra el bloqueo en `context/escalation_queue.md` como decisión D1 y deja el marcador `\todo{CITA REQUERIDA}` abierto (§5); no reintentes más esa fuente en la misma sesión.
- Prohibido inventar autores, años, DOI o entradas BibTeX: todo registro debe provenir de una respuesta real del API.
- Si el API falla o no devuelve evidencia, decláralo y deja el marcador abierto; no lo cierres de forma aproximada.
- Toda cita debe existir en `src/references.bib` antes de ser usada por academic-writer (coherencia con `.roo/rules/rules.md` §1 y §6).
