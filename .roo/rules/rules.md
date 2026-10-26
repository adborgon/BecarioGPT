# REGLAS GLOBALES DE RIGOR CIENTÍFICO Y ACADÉMICO

Actúas dentro de un entorno de investigación científica e ingeniería. Todas tus respuestas y ediciones de archivos deben cumplir estrictamente estas directivas:

## 1. Integridad Bibliográfica (Tolerancia Cero a la Alucinación)
- NUNCA inventes una referencia bibliográfica, autor, año, DOI o clave BibTeX.
- Solo puedes insertar comandos `\cite{clave}` o citas en formato Markdown `[@clave]` si la clave existe previamente en `src/references.bib` o está documentada explícitamente en `context/evidence_notes.md`.
- Si una afirmación requiere respaldo bibliográfico y no existe la cita en el repositorio, inserta obligatoriamente el marcador: `\todo{CITA REQUERIDA: [breve descripción de qué evidencia se necesita]}`.

## 2. Fidelidad de Datos y Estadística
- NUNCA inventes tamaños muestrales ($N$), medias, desviaciones típicas, $p$-valores, tamaños del efecto ($\eta^2$, $d$ de Cohen) ni métricas de rendimiento.
- Todo dato numérico reportado en `src/` debe provenir exactamente de `data/stats_summary.json` o `context/hypothesis_matrix.md`.
- Si un dato aún no ha sido calculado, utiliza el marcador `\todo{DATO PENDIENTE: [nombre de la métrica]}`.

## 3. Tono y Estilo Lingüístico (Anti-Fluff)
- Mantén un estilo académico sobrio, preciso, objetivo y directo (tanto en inglés como en castellano).
- PROHIBIDO usar vocabulario promocional o muletillas típicas de modelos de lenguaje:
  - En inglés: evita *delve into, testament, tapestry, crucial, paramount, groundbreaking, revolutionize, realm, beacon, underscore*.
  - En castellano: evita *en el vertiginoso mundo actual, revolucionario, sin precedentes, resulta crucial destacar, un tapiz de, piedra angular, paradigma disruptivo*.
- Prioriza verbos de acción técnica y científica: *evaluar, cuantificar, validar, parametrizar, contrastar, observar, implementar*.
- Una idea principal por oración. Evita subordinadas excesivamente largas.

## 4. Trazabilidad y Fuente Única de Verdad (SSOT)
- Antes de redactar o modificar cualquier sección en `src/`, verifica que esté alineada con los objetivos e hipótesis definidos en `context/hypothesis_matrix.md`.
- Respeta estrictamente los permisos de tu Modo activo. No edites archivos fuera de tu ámbito de responsabilidad.

## 5. Ciclo de cierre de deuda académica
- `\todo{CITA REQUERIDA}`: lo cierra lit-synthesizer, registrando la evidencia (con DOI o URL y fecha de acceso) en `context/evidence_notes.md` y la entrada BibTeX verificada en `src/references.bib`; academic-writer sustituye el marcador por `\cite{clave}`.
- `\todo{DATO PENDIENTE}`: lo cierra research-architect, únicamente cuando el dato ya esté presente en `data/stats_summary.json` o `context/hypothesis_matrix.md`; academic-writer sustituye el marcador por el valor registrado.
- reviewer-2 verifica los marcadores abiertos de `src/` con grep antes de dar el visto bueno y los registra en `reviews/peer_review_log.md` con su severidad.
- PROHIBIDO eliminar un marcador `\todo{}` sin resolverlo realmente: cerrarlo exige que la evidencia o el dato correspondiente esté en el repositorio.

## 6. Búsqueda de artículos vía MCP (Semantic Scholar, arXiv y PubMed)
- El único modo que ejecuta búsquedas de artículos es `lit-synthesizer`, mediante los servidores MCP `semantic-scholar-mcp` (tools: `search_paper`, `get_paper`, `get_authors`, `get_citation`), `arxiv` (arxiv-mcp-server; tools: `search_papers`, `get_abstract`, `download_paper`, `read_paper`, `list_papers`) y `pubmedmcp` (tool: `search_abstracts`).
- arXiv es la segunda fuente de literatura de `lit-synthesizer`, indicada para preprints y para ciencias de la computación e ingeniería eléctrica y electrónica (campos `cs.*` y `eess.*`). Al registrar un preprint, marca expresamente "preprint" en `context/evidence_notes.md`; un preprint NO sustituye a la versión publicada: si existe versión publicada (con DOI de revista o conferencia), esa es la que debe registrarse y citarse.
- PubMed (y Europe PMC) es la tercera fuente de literatura de `lit-synthesizer`, vía el servidor `pubmedmcp` (tool `search_abstracts`), indicada para biomedicina y revisiones sistemáticas (PRISMA). El API de NCBI admite ~3 peticiones/segundo sin clave y hasta 10 con la clave gratuita `NCBI_API_KEY`; esa clave es opcional y JAMÁS se escribe en ficheros trackeados: se define solo como variable de entorno del sistema. Los abstracts devueltos incluyen DOI/PMID: el registro es idéntico al resto de fuentes (evidencia en `context/evidence_notes.md` con DOI/PMID + fecha de acceso y entrada BibTeX verificada en `src/references.bib`).
- `academic-writer` y `reviewer-2` NO invocan la búsqueda directamente: delegan a `lit-synthesizer` mediante `new_task`, especificando tema, afirmación o sección a respaldar, criterios (años, campos, máximo de artículos) y propósito.
- `research-architect` usa únicamente el servidor `fetch` (mcp-server-fetch) para convocatorias y documentación; la búsqueda de literatura le está PROHIBIDA y la delega a `lit-synthesizer` mediante `new_task`.
- Toda cita insertada debe provenir de resultados reales del API con DOI, eprint u otro identificador verificado. Prohibido citar de memoria: si no hay evidencia, el marcador `\todo{CITA REQUERIDA}` permanece abierto.
- `lit-synthesizer` registra cada artículo antes de devolver claves: evidencia (DOI/URL + fecha de acceso) en `context/evidence_notes.md` y entrada BibTeX verificada en `src/references.bib`.
- Respeta los rate limits: Semantic Scholar ~1 petición/segundo (ante HTTP 429 espera 15-20 segundos antes de reintentar), arXiv ~1 petición cada 3 segundos y NCBI/PubMed ~3 peticiones/segundo (hasta 10 con `NCBI_API_KEY` en el entorno).