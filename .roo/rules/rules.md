# REGLAS GLOBALES DE RIGOR CIENTÍFICO Y ACADÉMICO

Actúas dentro de un entorno de investigación científica e ingeniería. Estas directivas comprenden el rigor científico y académico (§1-§6) y el ciclo de autonomía del motor WP-driven (§7). Todas tus respuestas y ediciones de archivos deben cumplirlas estrictamente:

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

## 6. Búsqueda de artículos vía MCP (Semantic Scholar, arXiv, PubMed y CrossRef)
- El único modo que ejecuta búsquedas de artículos es `lit-synthesizer`, mediante los servidores MCP `semantic-scholar-mcp` (tools: `search_paper`, `get_paper`, `get_authors`, `get_citation`), `arxiv` (arxiv-mcp-server; tools: `search_papers`, `get_abstract`, `download_paper`, `read_paper`, `list_papers`), `pubmedmcp` (tool: `search_abstracts`) y `crossref` (crossref-mcp-server; tools: `crossref_search`, `crossref_title_search`, `crossref_author_search`, `crossref_doi_lookup`, `crossref_journal_search`, `crossref_journal_works`, `crossref_funder_search`, `crossref_references`, `crossref_export_ris`, `crossref_export_bibtex`).
- arXiv es la segunda fuente de literatura de `lit-synthesizer`, indicada para preprints y para ciencias de la computación e ingeniería eléctrica y electrónica (campos `cs.*` y `eess.*`). Al registrar un preprint, marca expresamente "preprint" en `context/evidence_notes.md`; un preprint NO sustituye a la versión publicada: si existe versión publicada (con DOI de revista o conferencia), esa es la que debe registrarse y citarse.
- PubMed (y Europe PMC) es la tercera fuente de literatura de `lit-synthesizer`, vía el servidor `pubmedmcp` (tool `search_abstracts`), indicada para biomedicina y revisiones sistemáticas (PRISMA). El API de NCBI admite ~3 peticiones/segundo sin clave y hasta 10 con la clave gratuita `NCBI_API_KEY`; esa clave es opcional y JAMÁS se escribe en ficheros trackeados: se define solo como variable de entorno del sistema. Los abstracts devueltos incluyen DOI/PMID: el registro es idéntico al resto de fuentes (evidencia en `context/evidence_notes.md` con DOI/PMID + fecha de acceso y entrada BibTeX verificada en `src/references.bib`).
- CrossRef es la cuarta fuente de literatura de `lit-synthesizer`, vía el servidor `crossref` (paquete PyPI `crossref-mcp-server`, API oficial api.crossref.org). Uso principal: verificación independiente de DOI y metadatos con `crossref_doi_lookup` como control anti-alucinación ANTES de registrar una entrada BibTeX en `src/references.bib`; `crossref_references` y `crossref_export_bibtex`/`crossref_export_ris` son apoyo en la construcción de entradas. El registro S5 (evidencia en `context/evidence_notes.md` con DOI + fecha de acceso y entrada BibTeX verificada en `src/references.bib`) sigue siendo obligatorio: un export de CrossRef no sustituye al registro.
- `academic-writer` y `reviewer-2` NO invocan la búsqueda directamente: delegan a `lit-synthesizer` mediante `new_task`, especificando tema, afirmación o sección a respaldar, criterios (años, campos, máximo de artículos) y propósito.
- `research-architect` usa únicamente el servidor `fetch` (mcp-server-fetch) para convocatorias y documentación; la búsqueda de literatura le está PROHIBIDA y la delega a `lit-synthesizer` mediante `new_task`.
- Toda cita insertada debe provenir de resultados reales del API con DOI, eprint u otro identificador verificado. Prohibido citar de memoria: si no hay evidencia, el marcador `\todo{CITA REQUERIDA}` permanece abierto.
- `lit-synthesizer` registra cada artículo antes de devolver claves: evidencia (DOI/URL + fecha de acceso) en `context/evidence_notes.md` y entrada BibTeX verificada en `src/references.bib`.
- Respeta los rate limits: Semantic Scholar ~1 petición/segundo (ante HTTP 429 espera 15-20 segundos antes de reintentar), arXiv ~1 petición cada 3 segundos y NCBI/PubMed ~3 peticiones/segundo (hasta 10 con `NCBI_API_KEY` en el entorno). CrossRef usa el API oficial api.crossref.org con un uso educado (evita ráfagas de peticiones que provoquen 402/429); la variable opcional `CROSSREF_MAILTO` (polite pool) se define solo como variable de entorno del sistema, JAMÁS en ficheros trackeados.
- OpenAlex fue descartada como fuente por decisión del usuario: no está integrada ni se planifica su integración.

## 7. Ciclo de autonomía (motor WP-driven)

El avance en modo autónomo vive en tres ficheros: `data/autonomy_state.json` (espejo de estado), `context/autonomy_journal.md` (narrativa append-only) y `context/escalation_queue.md` (decisiones D3 para el investigador). `data/workpackages.yaml` sigue siendo el SSOT del plan: el orquestador NUNCA lo edita.

- Bucle WP-driven: leer estado + journal + plan → elegir la siguiente tarea del WP corriente (respetando dependencias) → delegar UN paso por `new_task` al modo responsable con criterio de aceptación explícito → verificar el criterio (`test -s`, `grep`, `latexmk`) → checkpoint (append al journal + escritura atómica del estado) → repetir. Cada delegación `new_task` suma 1 iteración al presupuesto (`budget` en `data/autonomy_state.json`: por defecto 40 iteraciones / 240 min por sesión; configurable con `run_autonomy.sh --max-iterations / --timeout-minutes`).
- Disciplina de checkpoint: NUNCA interrumpir una escritura SSOT a mitad. El checkpoint se hace antes y después de cada paso, con el proyecto en estado estable.
- Clasificación de decisiones: D1 operativa (reversible, sin impacto científico) la resuelve el modo delegado; D2 metodológica reversible se resuelve y se documenta en `context/autonomy_journal.md`; D3 de fondo (hipótesis nuevas, cambio de alcance o diseño, presupuesto, autoría o envío) SOLO la decide el investigador: se registra en `context/escalation_queue.md` (fila `| ESC-NNN | ... | ABIERTO |`) y el WP afectado queda BLOCKED. Mientras haya filas ABIERTAS, el supervisor `run_autonomy.sh` NO relanza sesiones.
- El supervisor `run_autonomy.sh` aplica el presupuesto duro (timeout por sesión con `timeout` de GNU coreutils si existe), impide relanzar con escalaciones abiertas y, sin CLI headless, degrada a modo manual imprimiendo el prompt de continuación. El journal y el estado los edita el agente, NUNCA el script.
- El freno anti-alucinación (§1, §2 y §5) permanece íntegro en modo autónomo: sin evidencia o dato registrado en el repositorio, ningún marcador `\todo{}` se cierra.

### Backoff por fuente (obligatorio para todas las búsquedas de `lit-synthesizer`)

| Fuente | Cortesía previa | Ante error / HTTP 429 | Máx. intentos | Al agotar |
|---|---|---|---|---|
| `semantic-scholar-mcp` | ~1 petición/segundo | esperar 20 s, 40 s, 80 s, 160 s | 4 | ESCALADO (D1 en `escalation_queue.md`) + marcador `\todo{CITA REQUERIDA}` abierto (§5) |
| `arxiv` | 3 s entre peticiones | esperar 10 s, 30 s, 90 s | 3 | ESCALADO (D1) + marcador abierto |
| `pubmedmcp` | ~3 peticiones/segundo (hasta 10 con `NCBI_API_KEY`) | esperar 10 s, 30 s | 3 | ESCALADO (D1) + marcador abierto |
| `crossref` | uso educado (sin ráfagas que provoquen 402/429) | esperar 5 s, 15 s, 45 s | 3 | el marcador permanece abierto: NUNCA se cierra aproximando (§5) |

Regla transversal: tras agotar los reintentos de una fuente, registra el bloqueo y deja el marcador `\todo{}` abierto; no reintentes más esa fuente en la misma sesión (evita quemar presupuesto en una fuente caída). Las claves (`SEMANTIC_SCHOLAR_API_KEY`, `NCBI_API_KEY`, `CROSSREF_MAILTO`) viajan solo como variables de entorno del sistema, JAMÁS en ficheros trackeados.