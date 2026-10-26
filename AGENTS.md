# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Qué es este repo

BecarioGPT no contiene papers: contiene **un único script generador** (`init_paper.sh`, 389 líneas) que crea la estructura inicial de proyectos de papers académicos (LaTeX + workflow de investigación con agentes Roo) **según el tipo de contribución**. Las plantillas ya NO están embebidas como heredocs: viven como ficheros del repo en `templates/` — `templates/common/` (SSOT compartidos por todos los tipos + `postcheck.list` común + la configuración MCP trackeada `templates/common/mcp.json`) y un subdirectorio por tipo (`imrad`, `prisma`, `thesis`, `engineering`), cada uno con su esqueleto `src/`, sus artefactos y su `postcheck.list`.

## Uso

```bash
bash init_paper.sh nombre-del-proyecto                        # tipo por defecto (imrad)
bash init_paper.sh mi-revision --type prisma                  # revisión sistemática
bash init_paper.sh mi-tesis --type thesis                     # tesis/TFG/TFM
bash init_paper.sh mi-sistema --type engineering              # paper de ingeniería
bash init_paper.sh nombre-del-proyecto --type prisma --force  # completar sin sobrescribir
```

- Requiere **bash real** (Git Bash/WSL en Windows): el script usa `set -euo pipefail` (línea 34) y validaciones que no funcionan en sh/dash/cmd.exe.
- `--type` es opcional: por defecto `imrad` (retrocompatible con la versión anterior). El catálogo de tipos **no está hard-codeado**: se descubre de los subdirectorios de `templates/` excluido `common/` (bloque [2]), y `usage()` lista dinámicamente los tipos detectados (bloque [3]). Un tipo desconocido (o `--type` sin valor) muestra el uso y termina con `exit 1` (bloques [4]-[5]).
- `-h/--help` muestra el uso y termina con `exit 0`. Los demás argumentos inválidos (sin proyecto, ruta que empieza por `-`, ruta con `..`, dos proyectos) muestran el uso y terminan con `exit 1` (bloque [4]). **Nunca** usa `.` como proyecto por defecto.
- `--force` solo añade lo que falta: la guarda `[ -s ]` de `write_template()` (bloque [1]) y las guardas de las copias (bloque [8]) impiden sobrescribir ficheros existentes no vacíos (protege los SSOT ya editados). Re-ejecutar sin `--force` sobre un proyecto no vacío aborta con `exit 1` (bloque [6]).
- El script copia desde **este repo** `.roomodes`, `.roo/skills/`, `.roo/rules/rules.md` (íntegro, como `.roo/rules/00_academic_core.md`; **sin heredoc de respaldo**: si falta la fuente, aborta con `[ERROR]` y `exit 1`, bloque [8.3]) y la configuración MCP trackeada `templates/common/mcp.json` (bloque [8.4], destino `.roo/mcp.json` del proyecto). No hay paso manual de copia. La copia genérica de `templates/common/` excluye `mcp.json` y `postcheck.list` (para no duplicar el fichero en la raíz del proyecto).
- No hay build/test/lint ni manifests (no existe package.json). Binarios usados: `mkdir`, `cp`, `cat`, `find`, `ls`, `printf`, `echo`, `test` (`[ ... ]`), `dirname`.
- Antes de tocar el script, verifica con la suite de humo: `bash tests/scaffold_smoke.sh` (ver sección *Gestión del repo*).

## Estructura que GENERA (es el contrato con los papers, no contenido de este repo)

Núcleo común, idéntico para todos los tipos (bloque [9]: primero se copia `templates/common/` y después el overlay del tipo elegido; los `postcheck.list` son metadatos del repo y NO se copian al proyecto):

- `.roomodes` — definición de los 4 modos académicos (copiado íntegro del repo, bloque [8.1]).
- `.roo/rules/00_academic_core.md` — copia íntegra de `.roo/rules/rules.md` (bloque [8.3], fail-fast).
- `.roo/skills/` — las 8 skills de agentes (bloque [8.2]), incluida `s2-search` (búsqueda vía MCP).
- `.roo/mcp.json` — configuración MCP con **4 servidores** (`semantic-scholar-mcp`, `fetch` = mcp-server-fetch, `arxiv` = arxiv-mcp-server y `pubmedmcp`; bloque [8.4]): copiada sin sobrescribir destinos no vacíos desde la plantilla trackeada `templates/common/mcp.json`. **NO contiene claves API**: el servidor S2 hereda `SEMANTIC_SCHOLAR_API_KEY` del entorno del sistema y la caché de arXiv apunta a la ruta relativa `./rag/cache/papers`. Sí forma parte de la post-condición.
- `context/` — estado de investigación: `call_guidelines.md`, `hypothesis_matrix.md` (con Changelog) y `evidence_notes.md` (con DOI + fecha de acceso).
- `data/` — `workpackages.yaml` (con un WP1 de ejemplo). `stats_summary.json` vive en el overlay de cada tipo y nace con `project_type` + `study_metadata{design, n, preregistration_url}` + `variables`; el `design` es compatible con la skill `methods-reporting` (p. ej. `systematic_review` en prisma). Todo `.json`/`.yaml` del scaffold nace parseable.
- `src/` — `main.tex` compilable, `references.bib` (única base bibliográfica, solo la edita `lit-synthesizer`) y `figures/`.
- `reviews/peer_review_log.md` — registro de auditoría académica con tabla y severidades.
- `rag/calls`, `rag/past_projects`, `rag/templates` — base de conocimiento local; `rag/cache/papers` (creada por el scaffold) es la caché de papers del servidor `arxiv`.
- `.gitignore` — LaTeX + Python/R.

Esqueleto y artefactos propios de cada tipo (viven en `templates/<tipo>/`):

| Tipo | Esqueleto `src/` | Artefactos propios |
|------|------------------|--------------------|
| `imrad` (por defecto) | `01_introduction` → `04_discussion` (el orden lo fija la numeración) | — |
| `prisma` | `01_introduction`, `02_methods`, `03_results`, `04_discussion` | `data/extraction_sheet.csv` (hoja de extracción), `src/figures/prisma_flow.tex` (diagrama PRISMA) y `context/prisma_checklist.md` (27 ítems) |
| `thesis` | `src/chapters/` (`00_front` → `05_conclusions` + `glossary`, clase `report`) y `src/appendices/appendix_a` | `context/thesis_outline.md` (capitulación SSOT) |
| `engineering` | `01_introduction` → `06_conclusion` y `src/appendices/appendix_a` | — |

## Post-condición y éxito

El éxito NO verifica una lista fija: el bloque [10] lee **todas las rutas** listadas en `templates/common/postcheck.list` (6 ficheros: `src/main.tex`, `.roo/rules/00_academic_core.md`, `context/hypothesis_matrix.md`, `data/stats_summary.json`, `reviews/peer_review_log.md`, `.roo/mcp.json`) y en `templates/<tipo>/postcheck.list` (4 en `imrad`, 7 en `prisma`, 9 en `thesis`, 7 en `engineering`), y termina con `[ERROR]` y `exit 1` si falta alguna. El mensaje de éxito está en el bloque [11]: `[OK] Estructura academica generada en '<proyecto>' (tipo: <tipo>).` Los mensajes de consola son ASCII puro: `[OK]`, `[WARN]`, `[ERROR]`.

## Conectividad MCP (Semantic Scholar, arXiv, PubMed y fetch)

El scaffold copia a cada proyecto la plantilla trackeada `templates/common/mcp.json` con **4 servidores** (bloque [8.4]):

- `semantic-scholar-mcp` (`python -m uv tool run --from git+https://github.com/adborgon/semantic-scholar-mcp.git semantic-scholar-mcp serve`): buscado por `lit-synthesizer`; la clave viaja por herencia de `SEMANTIC_SCHOLAR_API_KEY` del entorno (el fichero NO contiene claves). ~1 petición/segundo.
- `arxiv` (`python -m uv tool run arxiv-mcp-server --storage-path ./rag/cache/papers`): segunda fuente de `lit-synthesizer` (preprints, CS/EE); su caché vive en `rag/cache/papers` del proyecto (creada por el scaffold). ~1 petición cada 3 s. Un preprint NO sustituye a la versión publicada.
- `pubmedmcp` (`python -m uv tool run --from git+https://github.com/dartmouth/pubmedmcp --with "mcp<2" pubmedmcp`): tercera fuente de `lit-synthesizer` (biomedicina, PRISMA) vía el API oficial de E-utilities de NCBI. Requiere el pin `--with "mcp<2"` en la invocación: el paquete arrastra mcp 2.x, que renombró FastMCP a MCPServer y sin ese cap el servidor crashea al arrancar (la primera ejecución compila el paquete; después uv cachea y arranca en segundos). ~3 peticiones/segundo sin clave (hasta 10 con `NCBI_API_KEY` en el entorno; la clave JAMÁS se escribe en ficheros trackeados).
- `fetch` (`python -m uv tool run mcp-server-fetch`): convocatorias y documentación; es el único servidor de `research-architect` (la búsqueda de literatura le está PROHIBIDA y la delega a `lit-synthesizer`).

Fuentes descartadas: **Google Scholar** (ecosistema `google-scholar-mcp`): sin licencia clara, transporte HTTP y scraping de Google con alto riesgo de CAPTCHA/ban en uso autónomo prolongado → no viable, NO integrado. **PubMed-MCP-Server (JackKuo666)**: usa el API E-utilities, pero su empaquetado no tiene punto de entrada ni build-system, arrastra el backport `asyncio` de PyPI, sus metadatos carecen de DOI y hace N+1 peticiones sin batching → se mantiene dartmouth/pubmedmcp.

`lit-synthesizer` es el único modo que busca artículos (skill `s2-search`, fases S0-S6). `academic-writer` y `reviewer-2` no tienen grupo MCP: delegan las solicitudes a `lit-synthesizer` vía `new_task`. Cada artículo se registra antes de devolver claves: evidencia (DOI/URL + fecha de acceso) en `context/evidence_notes.md` y entrada BibTeX verificada en `src/references.bib`. La sección §6 del marco académico (`.roo/rules/rules.md`, replicada como `00_academic_core.md`) regula este flujo.

Seguridad (separación config local / tracked): **la plantilla trackeada `templates/common/mcp.json` no contiene ninguna clave API** y es lo que el scaffold copia a los proyectos y lo que escanea la suite de humo. El fichero `.roo/mcp.json` de ESTE repo es configuración **local**: está en `.gitignore`, puede contener la clave del usuario y **NUNCA se commitea** (si estuviera trackeado de una versión anterior, des-trackearlo con `git rm --cached .roo/mcp.json`). No publicar este repo (ni los proyectos generados) en repositorios públicos.

## Gestión del repo

- Suite de humo: `bash tests/scaffold_smoke.sh`. Cubre, por cada tipo de `PROJECT_TYPES` (cabecera del test): generación en directorio temporal y post-condición parametrizada, parseabilidad JSON/YAML (con `python` si está disponible; validación estructural mínima si no), noclobber (re-ejecutar sin `--force` aborta; con `--force` no sobrescribe, comparación byte a byte), `-h/--help` con exit 0 y argumentos inválidos con exit 1 (incluido `--type` desconocido o sin valor), salida ASCII pura, seguridad MCP sobre la fuente trackeada `templates/common/mcp.json` y sobre el mcp.json generado en cada proyecto (sin claves `s2k-`, sin `SEMANTIC_SCHOLAR_API_KEY`, sin ruta absoluta de intérprete, sin `--refresh-package`, con las entradas de los 4 servidores (semantic-scholar-mcp, fetch, arxiv y pubmedmcp); el `.roo/mcp.json` local de este repo NO se escanea), consistencia LaTeX (`\input`/`\include` resolubles) y retrocompatibilidad (generar sin `--type` produce exactamente lo mismo que `--type imrad`).
- Añadir un tipo nuevo: crear `templates/<tipo>/` con su esqueleto `src/`, sus artefactos y su `postcheck.list` → el script lo autodescubrirá (bloque [2]) y lo listará en `usage()`. Añadir además el tipo al array `PROJECT_TYPES` de la cabecera de `tests/scaffold_smoke.sh` (el resto del test no se toca). Documentar el tipo en este fichero y en `README.md`.
- Roadmap: F0 (higiene: `-h` exit 0, sin heredoc de respaldo, suite de humo), F1 (seguridad MCP: clave en env, arranque portable) y F2 (plantillas por tipo en `templates/`) están implementadas y verificadas. **F3-P0 (conectividad MCP: `fetch` + `arxiv` con separación config local/tracked) y F3-P1a (servidor `pubmedmcp`: PubMed/Europe PMC vía E-utilities; dartmouth/pubmedmcp con pin `mcp<2` aplicado en la invocación) están implementadas y verificadas**. El resto de F3 (OpenAlex, CrossRef) y F4 (motor de autonomía) NO están implementadas: solo existen como diseño en `plans/diseno_evolucion_becariogpt.md`. No documentes características de F3/F4 pendientes como si existieran.
