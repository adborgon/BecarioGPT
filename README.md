# 📚 Workspace Académico y de Investigación (Zoo Code / Roo Code)

BecarioGPT es un repositorio base para la **redacción de artículos científicos (IMRaD)** y la **preparación de propuestas de proyectos de investigación competitivos** con asistentes de IA basados en agentes (Zoo Code / Roo Code).

Su único contenido ejecutable es `init_paper.sh`: un script que genera la estructura inicial de cada proyecto de paper (LaTeX + workflow de investigación) **según el tipo de contribución** (`--type`: `imrad` por defecto, `prisma`, `thesis` o `engineering`) y copia a cada proyecto la configuración de agentes de este repo (`.roomodes`, `.roo/rules/`, `.roo/skills/` y la configuración MCP trackeada `templates/common/mcp.json` → `.roo/mcp.json` del proyecto). Cada proyecto incluye además el **motor de autonomía (F4)**: el 5º modo `academic-orchestrator` (bucle WP-driven con checkpoints por paso y escalado D1-D3) y el supervisor `run_autonomy.sh` (presupuesto duro, gate de escalaciones y modo manual).

El sistema está diseñado bajo el principio de **Separación de Responsabilidades y Single Source of Truth (SSOT)** para evitar alucinaciones bibliográficas, desajustes metodológicos y errores de formato.

---

## 📁 Estructura de ESTE repositorio

```text
.
├── init_paper.sh              # Único script: genera la estructura de un proyecto nuevo
├── README.md                  # Esta documentación
├── AGENTS.md                  # Guía técnica para agentes de código
├── .gitignore                 # Ignora .roo/mcp.json (config MCP local), __pycache__/, *.pyc y rag/cache/
├── .roomodes                  # Definición de los 5 modos académicos (se copia a cada proyecto)
├── templates/                 # Catálogo de plantillas por tipo de proyecto (con postcheck.list por tipo)
│   ├── common/                # SSOT comunes a todos los tipos (postcheck.list común + mcp.json trackeada, sin claves + artefactos de autonomía: autonomy_state.json, autonomy_journal.md, escalation_queue.md, run_autonomy.sh)
│   ├── imrad/                 # Artículo empírico IMRaD (tipo por defecto)
│   ├── prisma/                # Revisión sistemática PRISMA 2020
│   ├── thesis/                # Tesis/TFG/TFM por capítulos (clase report)
│   └── engineering/           # Paper de ingeniería / evaluación experimental
├── .roo/
│   ├── rules/
│   │   └── rules.md           # Marco académico global (ÚNICO fichero de rules/ que el script copia a los proyectos, como 00_academic_core.md)
│   ├── rules-code/            # Reglas para el modo Code (solo de este repo; NO se copia a los proyectos)
│   ├── rules-debug/           # Reglas para el modo Debug (solo de este repo; NO se copia)
│   ├── rules-ask/             # Reglas para el modo Ask (solo de este repo; NO se copia)
│   ├── rules-architect/       # Reglas para el modo Architect (solo de este repo; NO se copia)
│   ├── rules-research-architect/  # Reglas adicionales de research-architect (solo de este repo; NO se copia)
│   ├── mcp.json               # Configuración MCP LOCAL de este repo (gitignoreada; puede contener claves; JAMÁS se commitea)
│   └── skills/                # 8 skills de agentes (se copian a cada proyecto)
├── tests/
│   └── scaffold_smoke.sh      # Suite de humo: post-condición, noclobber, seguridad MCP, retrocompatibilidad y supervisor F4 en seco
├── plans/                     # Diseño de evolución del repo (roadmap F0-F4 completo)
├── context/                   # Estado de investigación del repo (matrices SSOT de trabajo)
├── data/                      # Datos estructurados del repo
└── rag/                       # Base de conocimiento local (RAG)
    ├── calls/                 # Convocatorias y estrategias de búsqueda documentadas
    ├── past_projects/         # Memorias de proyectos anteriores de referencia
    └── templates/             # Plantillas institucionales y CVs
```

## 📁 Estructura de un proyecto GENERADO (lo que crea `init_paper.sh`)

El núcleo común es idéntico para todos los tipos; lo que cambia es el esqueleto de `src/` y los artefactos propios del tipo elegido con `--type`.

```text
nombre-del-proyecto/
├── .roomodes                  # Copiado íntegro del repo
├── .roo/
│   ├── rules/
│   │   └── 00_academic_core.md    # Copia íntegra de .roo/rules/rules.md
│   ├── mcp.json                   # Configuración MCP (5 servidores: semantic-scholar-mcp, fetch, arxiv, pubmedmcp, crossref) copiada de templates/common/mcp.json (sin claves API)
│   └── skills/                    # Las 8 skills copiadas del repo
├── context/
│   ├── call_guidelines.md     # Requisitos de la revista/convocatoria (SSOT)
│   ├── hypothesis_matrix.md   # Objetivos, hipótesis y variables (SSOT, con Changelog)
│   ├── evidence_notes.md      # Registro de evidencia (con DOI + fecha de acceso)
│   ├── autonomy_journal.md    # Narrativa append-only del bucle de autonomía (eventos por paso)
│   └── escalation_queue.md    # Decisiones D3 pendientes del investigador (filas ESC-NNN)
├── data/
│   ├── stats_summary.json     # Nace parseable: project_type + study_metadata{design, n, preregistration_url} + variables
│   ├── workpackages.yaml      # Nace parseable, con un WP1 de ejemplo
│   └── autonomy_state.json    # Espejo de estado del bucle WP-driven (budget 40 iter / 240 min, status PENDING)
├── src/
│   ├── main.tex               # Documento raíz LaTeX compilable (esqueleto según el tipo)
│   ├── references.bib         # Única base bibliográfica (solo la edita lit-synthesizer)
│   └── figures/
├── reviews/
│   └── peer_review_log.md     # Registro de auditoría (reviewer-2) con tabla y severidades
├── run_autonomy.sh              # Supervisor del motor de autonomía: presupuesto, gate de escalaciones, modo manual
├── rag/
│   ├── calls/                 # Estrategias de búsqueda y convocatorias
│   ├── past_projects/
│   ├── templates/
│   └── cache/papers/          # Caché de papers del servidor MCP arxiv
└── .gitignore                 # LaTeX + Python/R
```

Sobre `src/`, cada tipo genera un esqueleto distinto (catálogo en `templates/`):

| Tipo | Clase LaTeX | Esqueleto `src/` | Artefactos extra |
|------|-------------|------------------|------------------|
| `imrad` (por defecto) | `article` | Secciones `01_introduction` → `04_discussion` (IMRaD; el orden lo fija la numeración) | — |
| `prisma` | `article` | `01_introduction`, `02_methods` (protocolo, búsqueda, screening, extracción, riesgo de sesgo, síntesis), `03_results`, `04_discussion` | `data/extraction_sheet.csv` (hoja de extracción), `src/figures/prisma_flow.tex` (diagrama PRISMA como tabla), `context/prisma_checklist.md` (27 ítems) |
| `thesis` | `report` | Capítulos con `\chapter` en `src/chapters/` (portada/índice/resumen, glosario, introducción → conclusiones) + `src/appendices/` | `context/thesis_outline.md` (capitulación SSOT) |
| `engineering` | `article` | `01_introduction`, `02_related_work`, `03_architecture`, `04_implementation`, `05_evaluation` (tabla de experimentos `booktabs`), `06_conclusion` (con Limitations) + `src/appendices/` | — |

La lista de tipos no está hard-codeada: se descubre de los subdirectorios de `templates/` (excluido `common/`); añadir un tipo nuevo es crear `templates/<tipo>/` con su `src/` y su `postcheck.list`.

Antes de declarar el éxito, el script verifica con `test -f` todas las rutas listadas en `templates/common/postcheck.list` y en `templates/<tipo>/postcheck.list` (los diez ficheros del núcleo común: `src/main.tex`, `.roo/rules/00_academic_core.md`, `context/hypothesis_matrix.md`, `data/stats_summary.json`, `reviews/peer_review_log.md`, `.roo/mcp.json`, `data/autonomy_state.json`, `context/autonomy_journal.md`, `context/escalation_queue.md` y `run_autonomy.sh`). Si falta alguna, termina con `[ERROR]` y `exit 1`.

## 🤖 Modos y permisos

Los 5 modos académicos están definidos en `.roomodes`. Cada uno restringe su edición con un `fileRegex`:

| Modo | Ficheros editables (fileRegex) | Role |
|------|-------------------------------|------|
| 📐 Arquitecto de Estructura (`research-architect`) | `^(context/.*\|data/.*\|rag/calls/.*)$` | Traduce ideas, hipótesis y requisitos de convocatoria en matrices de trazabilidad (`hypothesis_matrix.md`), paquetes de trabajo (`workpackages.yaml`) y estrategias de búsqueda (`rag/calls/`). Cierra los marcadores `\todo{DATO PENDIENTE}` registrando el dato en su ámbito. |
| 📚 Sintetizador Bibliográfico (`lit-synthesizer`) | `^(context/evidence_notes\.md\|src/references\.bib)$` | Único modo con acceso a los MCP `semantic-scholar-mcp`, `arxiv` (arxiv-mcp-server), `pubmedmcp` (PubMed/Europe PMC) y `crossref` (crossref-mcp-server): búsqueda sistemática de evidencia, registro en `evidence_notes.md` y gestión de BibTeX verificada en `references.bib`. Cierra los marcadores `\todo{CITA REQUERIDA}`. |
| ✍️ Redactor Científico (`academic-writer`) | `^(src/.*\.(tex\|md)\|src/figures/.*)$` | Redacta el manuscrito LaTeX en `src/`. Prohibido editar `references.bib`: solo usa `\cite{clave}` de claves existentes o inserta `\todo{CITA REQUERIDA}`. Las búsquedas de artículos las delega a `lit-synthesizer` vía `new_task`. Al iniciar sesión, lee `reviews/peer_review_log.md` y subsana los hallazgos ABIERTOS. |
| 🔍 Auditor Peer-Review (`reviewer-2`) | `^reviews/.*\.md$` | Solo lectura sobre `src/` y `context/`. Audita la coherencia, verifica los `\todo{}` con `grep` y registra hallazgos con severidad en `reviews/peer_review_log.md`. Las búsquedas de artículos las delega a `lit-synthesizer` vía `new_task`. Usa la checklist de `.roo/skills/peer-audit/SKILL.md`. |
| 🧭 Orquestador de Autonomía (`academic-orchestrator`) | `^(data/autonomy_state\.json\|context/autonomy_journal\.md\|context/escalation_queue\.md\|rag/calls/.*)$` | Único consumidor del bucle WP-driven (F4): lee el plan (`workpackages.yaml`) y el espejo de estado, delega cada paso a los 4 modos académicos vía `new_task`, verifica el criterio de aceptación (`test -s`, `grep`, `latexmk`) y hace checkpoint por paso (journal + escritura atómica del estado). Sin grupo MCP: toda búsqueda la delega en `lit-synthesizer`. Las decisiones D3 van a `escalation_queue.md`. |

## 🧭 Motor de autonomía (F4)

Cada proyecto generado incluye el bucle WP-driven completo (contrato en §7 del marco académico `.roo/rules/00_academic_core.md`):

- **Estado y narrativa**: `data/autonomy_state.json` (espejo de estado: `budget` 40 iteraciones / 240 min por defecto, `current.status`, `iterations_used`), `context/autonomy_journal.md` (narrativa append-only con eventos DELEGADO/VERIFICADO/FALLO/ESCALADO/CHECKPOINT/SESION_FIN) y `context/escalation_queue.md` (decisiones D3 para el investigador).
- **Bucle**: el modo 🧭 Orquestador de Autonomía (`academic-orchestrator`) lee estado + journal + plan, elige la siguiente tarea del WP corriente, delega UN paso por `new_task` al modo responsable con criterio de aceptación explícito, verifica el criterio (`test -s`, `grep`, `latexmk`) y hace checkpoint por paso (journal + escritura atómica del estado; nunca a mitad de una escritura SSOT). Cada delegación suma 1 iteración al presupuesto. El plan (`data/workpackages.yaml`) NUNCA lo edita.
- **Decisiones D1-D3**: D1 operativa la resuelve el modo delegado; D2 metodológica reversible se resuelve y se documenta en el journal; D3 de fondo (hipótesis nuevas, cambio de alcance o diseño, presupuesto, autoría o envío) SOLO la decide el investigador vía `context/escalation_queue.md` (fila `| ESC-NNN | ... | ABIERTO |`).
- **Supervisor** `run_autonomy.sh` (en la raíz del proyecto): aplica el presupuesto duro (`--max-iterations`, `--timeout-minutes`), se niega a relanzar con escalaciones ABIERTAS (imprime la cola y sale con 0), degrada a **modo manual** imprimiendo el prompt de continuación si no hay CLI headless (`zoo`/`roo` en el PATH o forzada con `--cli`) y lanza sesiones con `timeout` de GNU coreutils si existe (si no, corre sin límite documentándolo). Tras cada sesión relee el estado y decide continuar o parar (presupuesto, escalación o bloqueo). Seguros internos: tope de sesiones = `--max-iterations` y parada si 3 sesiones consecutivas no dejan huella en el estado.
- **Backoff por fuente** (§7): ante error/HTTP 429, Semantic Scholar espera 20/40/80/160 s (máx. 4), arXiv 10/30/90 s (máx. 3), PubMed 10/30 s (máx. 3) y CrossRef 5/15/45 s (máx. 3); al agotar, se registra D1 en `escalation_queue.md` y el marcador `\todo{}` queda abierto (nunca se cierra aproximando).

**Lanzamiento** (Git Bash, dentro del proyecto generado):

```bash
bash run_autonomy.sh --dry-run                     # plan del supervisor sin lanzar nada
bash run_autonomy.sh                               # MODO MANUAL si no hay zoo/roo en el PATH
bash run_autonomy.sh --max-iterations 80 --timeout-minutes 300
bash run_autonomy.sh --cli roo                     # CLI headless explícita
```

El journal y el estado los escribe el agente; el supervisor nunca los edita.

## 🛠️ Skills (`.roo/skills/`)

| Skill | Modos | Descripción |
|-------|-------|-------------|
| `project-init` | research-architect | Onboarding guiado: diagnóstico de la estructura, interrogatorio al investigador y autogeneración asistida de matrices y ficheros iniciales. Incluye el bootstrap de autonomía (F4): rellena `project_type` y presupuesto en `data/autonomy_state.json` y verifica `autonomy_journal.md` / `escalation_queue.md` operativos. |
| `prisma-synthesis` | lit-synthesizer | Flujo PRISMA 2020 completo en 7 fases (F0-F6: protocolo, búsqueda, screening, extracción, riesgo de sesgo, síntesis con GRADE, checklist de 27 ítems) + variante narrativa (patrón CCLG) para el Estado del Arte. |
| `methods-reporting` | academic-writer | Estructura obligatoria de la sección de Métodos, checklist EQUATOR según diseño (CONSORT, STROBE, TRIPOD+AI, CARE, STARD, PRISMA, SPIRIT), power analysis, pre-registro, datos faltantes, reproducibilidad y declaraciones (CRediT, COI). |
| `grant-workpackages` | research-architect | Contrato y reglas de construcción de `data/workpackages.yaml` (WPs con objectives, deliverables, milestones, effort_pm, risks); el YAML debe permanecer parseable. |
| `latex-tables` | academic-writer | Tablas con `booktabs` exclusivamente: sin líneas verticales ni `\hline`, convenciones numéricas y estadísticas, plantilla base. |
| `peer-audit` | reviewer-2 | Checklist de auditoría en 6 fases (A1-A6): trazabilidad O/H, deuda `\todo`, integridad bibliográfica, fidelidad de datos, estilo y reporting EQUATOR. El visto bueno exige además 0 escalaciones ABIERTAS en `context/escalation_queue.md`. |
| `style-defluff` | academic-writer | Purga de muletillas de IA con linter `grep` en dos pasadas, excepciones técnicas y jerarquía normativa (gana `rules.md`). |
| `s2-search` | lit-synthesizer | Búsqueda y verificación de artículos vía el MCP `semantic-scholar-mcp` (fases S0-S6): `search_paper`, `get_paper` (verificación de DOI), `get_authors` y `get_citation` (bibtex). Fuentes adicionales: `arxiv` para preprints y campos CS/EE, `pubmedmcp` (`search_abstracts`) para biomedicina/PRISMA y `crossref` (`crossref_doi_lookup`, export BibTeX/RIS) para verificación independiente de DOI/metadata. Backoff por fuente (§7): al agotar reintentos, registra D1 en `escalation_queue.md` y deja el `\todo{}` abierto. |

## 🔄 Flujo de trabajo recomendado

1. **research-architect**: define objetivos e hipótesis en `context/hypothesis_matrix.md`, registra la convocatoria en `context/call_guidelines.md` y las estrategias de búsqueda en `rag/calls/`.
2. **lit-synthesizer**: ejecuta la búsqueda y registra la evidencia en `context/evidence_notes.md` y las referencias verificadas en `src/references.bib`.
3. **academic-writer**: redacta las secciones en `src/` usando exclusivamente los datos de `data/stats_summary.json` y `context/hypothesis_matrix.md`, y las citas de `src/references.bib`.
4. **reviewer-2**: audita con `.roo/skills/peer-audit/SKILL.md` y registra los hallazgos en `reviews/peer_review_log.md`.

**Solicitud de artículos (MCP Semantic Scholar, arXiv, PubMed y CrossRef).** Cuando `academic-writer` necesita respaldar una afirmación (p. ej., la definición de *presencia* en realidad virtual), delega a **lit-synthesizer** vía `new_task`; este busca con `semantic-scholar-mcp` (`search_paper` → `get_paper` para verificar el DOI → `get_citation` en bibtex), con `arxiv` para preprints/CS/EE, con `pubmedmcp` (`search_abstracts`) para biomedicina/PRISMA o con `crossref` (`crossref_doi_lookup` como verificación independiente anti-alucinación; `crossref_export_bibtex` como apoyo), registra la evidencia (DOI + fecha de acceso) en `context/evidence_notes.md` y la entrada verificada en `src/references.bib`, y devuelve las claves BibTeX; `academic-writer` inserta `\cite{clave}`. Si no hay evidencia verificable, el marcador `\todo{CITA REQUERIDA}` permanece abierto.

El ciclo de deuda académica cierra los marcadores `\todo{}`:
- `\todo{CITA REQUERIDA}` → lo cierra **lit-synthesizer** (evidencia con DOI + fecha en `evidence_notes.md` y BibTeX en `references.bib`); **academic-writer** sustituye el marcador por `\cite{clave}`.
- `\todo{DATO PENDIENTE}` → lo cierra **research-architect** (dato en `stats_summary.json` o `hypothesis_matrix.md`); **academic-writer** sustituye el marcador por el valor registrado.
- **reviewer-2** verifica con `grep` que no queden marcadores abiertos antes de dar el visto bueno.

## 🚀 Guía de inicio

1. **Crear un proyecto** (requiere bash real; en Windows usar Git Bash o WSL):

   ```bash
   bash init_paper.sh nombre-del-proyecto                     # tipo por defecto (imrad)
   bash init_paper.sh mi-revision --type prisma               # revisión sistemática
   bash init_paper.sh mi-tesis --type thesis                  # tesis/TFG/TFM
   bash init_paper.sh mi-sistema --type engineering           # paper de ingeniería
   ```

   Para completar un proyecto existente sin sobrescribir nada:

   ```bash
   bash init_paper.sh nombre-del-proyecto --type prisma --force
   ```

   El script rechaza ejecutarse sin nombre de proyecto (nunca usa `.`), con rutas que empiezan por `-`, que contienen `..`, con más de un proyecto, o con un `--type` desconocido (la lista de tipos válidos se descubre de los subdirectorios de `templates/`, excluido `common/`, y se muestra en la ayuda `--help`).

2. **Arrancar el onboarding**: abre Zoo Code en el proyecto generado, selecciona el modo 📐 Arquitecto de Estructura y escribe: *"Usa la skill project-init para guiarme en la configuración inicial de este nuevo [artículo / proyecto]."*

3. **Rellenar los SSOT**: `context/call_guidelines.md` y `context/hypothesis_matrix.md` (el script lo indica en su mensaje final).

4. **Seguir el ciclo iterativo**: research-architect → lit-synthesizer → academic-writer → reviewer-2 (ver flujo anterior).

5. **Opcional — Motor de autonomía (F4)**: ejecuta el bucle WP-driven con el supervisor: `bash run_autonomy.sh --dry-run` (plan en seco) y `bash run_autonomy.sh` (bucle; entra en MODO MANUAL si no hay CLI headless, o fuerza una con `--cli roo` / `--cli zoo`). Las decisiones D3 aparecen en `context/escalation_queue.md` y detienen el relanzamiento hasta que el investigador las resuelva (Estado → RESUELTO).

## ⚙️ Requisitos

- **bash real** (Git Bash o WSL en Windows): `init_paper.sh` y `run_autonomy.sh` usan `set -euo pipefail`; no funcionan en sh/dash/cmd.exe.
- Sin dependencias externas: solo usa binarios estándar (`mkdir`, `cp`, `cat`, `find`, `ls`, `printf`, `echo`, `test`, `dirname`).
- Para el MCP `semantic-scholar-mcp` (búsquedas de `lit-synthesizer`): el servidor se arranca con `python -m uv tool run --from git+https://github.com/adborgon/semantic-scholar-mcp.git semantic-scholar-mcp serve`. Requiere `python` en el `PATH` con el paquete `uv` instalado (`pip install uv`); `uv tool run` cachea el paquete y NO reinstala en cada arranque (sin `--refresh-package`). El API admite ~1 petición/segundo: ante HTTP 429, esperar 15-20 s antes de reintentar.
- Para el MCP `arxiv` (segunda fuente de `lit-synthesizer`): el servidor se arranca con `python -m uv tool run arxiv-mcp-server --storage-path ./rag/cache/papers` (~1 petición cada 3 s); su caché de papers vive en `rag/cache/papers` del proyecto.
- Para el MCP `pubmedmcp` (tercera fuente de `lit-synthesizer`, biomedicina/PRISMA): **instalación persistente única por máquina** `python -m uv tool install --from git+https://github.com/dartmouth/pubmedmcp --with "mcp<2" pubmedmcp` y, en la config MCP, arranque `python -m uv tool run pubmedmcp` (vía el API oficial de E-utilities de NCBI, ~3 peticiones/segundo sin clave; hasta 10 con `NCBI_API_KEY` definida solo como variable de entorno del sistema). El pin `--with "mcp<2"` va SOLO en la instalación: el paquete arrastra mcp 2.x, que renombró FastMCP a MCPServer y sin ese cap el servidor crashea al arrancar. **Causa raíz del bug de activación**: la config anterior repetía `--from git+... --with "mcp<2"` en cada arranque del server; todo launcher que concatene los args a través de `cmd.exe` interpreta el `<` como redirección (`El sistema no puede encontrar el archivo especificado.`) y el server no llega a arrancar; la config final no contiene metacaracteres y, con la tool instalada, arranca en ~1 s.
- Para el MCP `crossref` (cuarta fuente de `lit-synthesizer`, verificación de DOI/metadata y export BibTeX/RIS): **instalación persistente única por máquina** `python -m uv tool install crossref-mcp-server --with "mcp<2"` y, en la config MCP, arranque `python -m uv tool run crossref-mcp-server` (vía el API oficial api.crossref.org, 10 tools read-only; sin claves — la variable opcional `CROSSREF_MAILTO` del polite pool se define solo como variable de entorno del sistema). El cap `--with "mcp<2"` va SOLO en la instalación: sin él el paquete arrastra mcp 2.x (renombró FastMCP a MCPServer) y el servidor crashea al arrancar; la invocación de la config NO lleva metacaracteres (mismo patrón que pubmedmcp).
- Para el MCP `fetch` (único servidor de `research-architect`): `python -m uv tool run mcp-server-fetch`.
- **Fuentes descartadas**: Google Scholar (ecosistema `google-scholar-mcp`): sin licencia clara, transporte HTTP y scraping de Google con alto riesgo de CAPTCHA/ban en uso autónomo prolongado → no viable, NO integrado. PubMed-MCP-Server (JackKuo666): usa el API E-utilities, pero no tiene punto de entrada ni build-system, arrastra el backport `asyncio` de PyPI, sus metadatos carecen de DOI y hace N+1 peticiones sin batching → se mantiene dartmouth/pubmedmcp. crossref-MCP-Server (JackKuo666): candidato inicial de CrossRef, NO integrable: sin pyproject/setup.py (la instalación git+ falla), sin LICENSE, abandonado (3 commits; último push 2025-04-05), `mcp>=0.1.0` sin cap (crashea con mcp 2.x) y con un `sci_hub_server.py` roto que contamina la procedencia académica → se usa el paquete PyPI `crossref-mcp-server` 1.0.0 (SMABoundless, MIT). OpenAlex: descartada por decisión del usuario; no está integrada ni se planifica su integración.
- **Seguridad** (config local / tracked): los proyectos generados reciben la plantilla trackeada `templates/common/mcp.json`, que **no contiene ninguna clave API**: el servidor S2 hereda la variable de entorno `SEMANTIC_SCHOLAR_API_KEY` del sistema. El `.roo/mcp.json` de ESTE repo es configuración local: está en `.gitignore` y **NUNCA se commitea**. No publiques este repo (ni los proyectos generados) en repositorios públicos.
- Para compilar el manuscrito generado: `pdflatex` + `bibtex` (fuera del alcance del script).

### 🔑 Configuración de la clave API (SEMANTIC_SCHOLAR_API_KEY)

La plantilla trackeada `templates/common/mcp.json` (la que se copia a cada proyecto) **no incluye ninguna clave API**: el proceso del servidor hereda la variable de entorno `SEMANTIC_SCHOLAR_API_KEY` del sistema. Si la variable no está definida, el servidor no se autentica y las búsquedas de `lit-synthesizer` fallarán (es un paso de configuración, no un fallo del scaffold). El fichero `.roo/mcp.json` de este repo es configuración **local** (gitignoreado): puede contener la clave del usuario y jamás se commitea.

**Windows 11** (elige una opción):

- En una terminal (`cmd` o PowerShell), define la variable de usuario y **reinicia VS Code** (`setx` no afecta a la sesión en curso):

  ```bat
  setx SEMANTIC_SCHOLAR_API_KEY "TU_CLAVE_AQUI"
  ```

- O mediante la interfaz: `Win + R` → `sysdm.cpl` → pestaña **Opciones avanzadas** → **Variables de entorno…** → nueva *variable de usuario* `SEMANTIC_SCHOLAR_API_KEY` con el valor de la clave → reiniciar VS Code.

**Git Bash** (añádelo al perfil `~/.bashrc` para persistirlo entre sesiones):

```bash
export SEMANTIC_SCHOLAR_API_KEY="TU_CLAVE_AQUI"
```

**Advertencia de seguridad**: la única excepción permitida es el fichero local `.roo/mcp.json` de este repo (gitignoreado). No escribas la clave en ningún otro fichero del repositorio (scripts, documentación, plantillas…) y no publiques este repo ni los proyectos generados en repositorios públicos. La plantilla trackeada `templates/common/mcp.json` jamás debe contener claves.
