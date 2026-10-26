# 📚 Workspace Académico y de Investigación (Zoo Code / Roo Code)

BecarioGPT es un repositorio base para la **redacción de artículos científicos (IMRaD)** y la **preparación de propuestas de proyectos de investigación competitivos** con asistentes de IA basados en agentes (Zoo Code / Roo Code).

Su único contenido ejecutable es `init_paper.sh`: un script que genera la estructura inicial de cada proyecto de paper (LaTeX + workflow de investigación) **según el tipo de contribución** (`--type`: `imrad` por defecto, `prisma`, `thesis` o `engineering`) y copia a cada proyecto la configuración de agentes de este repo (`.roomodes`, `.roo/rules/`, `.roo/skills/`, `.roo/mcp.json`).

El sistema está diseñado bajo el principio de **Separación de Responsabilidades y Single Source of Truth (SSOT)** para evitar alucinaciones bibliográficas, desajustes metodológicos y errores de formato.

---

## 📁 Estructura de ESTE repositorio

```text
.
├── init_paper.sh              # Único script: genera la estructura de un proyecto nuevo
├── README.md                  # Esta documentación
├── AGENTS.md                  # Guía técnica para agentes de código
├── .roomodes                  # Definición de los 4 modos académicos (se copia a cada proyecto)
├── templates/                 # Catálogo de plantillas por tipo de proyecto (con postcheck.list por tipo)
│   ├── common/                # SSOT comunes a todos los tipos (más postcheck.list común)
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
│   ├── mcp.json               # Configuración del servidor MCP semantic-scholar-mcp (se copia a cada proyecto; sin claves API en claro)
│   └── skills/                # 8 skills de agentes (se copian a cada proyecto)
├── tests/
│   └── scaffold_smoke.sh      # Suite de humo: post-condición, noclobber, seguridad MCP, retrocompatibilidad
├── plans/                     # Diseño de evolución del repo (roadmap F3/F4 pendiente)
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
│   ├── mcp.json                   # Configuración MCP (semantic-scholar-mcp) copiada del repo (sin claves API)
│   └── skills/                    # Las 8 skills copiadas del repo
├── context/
│   ├── call_guidelines.md     # Requisitos de la revista/convocatoria (SSOT)
│   ├── hypothesis_matrix.md   # Objetivos, hipótesis y variables (SSOT, con Changelog)
│   └── evidence_notes.md      # Registro de evidencia (con DOI + fecha de acceso)
├── data/
│   ├── stats_summary.json     # Nace parseable: project_type + study_metadata{design, n, preregistration_url} + variables
│   └── workpackages.yaml      # Nace parseable, con un WP1 de ejemplo
├── src/
│   ├── main.tex               # Documento raíz LaTeX compilable (esqueleto según el tipo)
│   ├── references.bib         # Única base bibliográfica (solo la edita lit-synthesizer)
│   └── figures/
├── reviews/
│   └── peer_review_log.md     # Registro de auditoría (reviewer-2) con tabla y severidades
├── rag/
│   ├── calls/                 # Estrategias de búsqueda y convocatorias
│   ├── past_projects/
│   └── templates/
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

Antes de declarar el éxito, el script verifica con `test -f` todas las rutas listadas en `templates/common/postcheck.list` y en `templates/<tipo>/postcheck.list` (los seis ficheros del núcleo común: `src/main.tex`, `.roo/rules/00_academic_core.md`, `context/hypothesis_matrix.md`, `data/stats_summary.json`, `reviews/peer_review_log.md` y `.roo/mcp.json`). Si falta alguna, termina con `[ERROR]` y `exit 1`.

## 🤖 Modos y permisos

Los 4 modos académicos están definidos en `.roomodes`. Cada uno restringe su edición con un `fileRegex`:

| Modo | Ficheros editables (fileRegex) | Role |
|------|-------------------------------|------|
| 📐 Arquitecto de Estructura (`research-architect`) | `^(context/.*\|data/.*\|rag/calls/.*)$` | Traduce ideas, hipótesis y requisitos de convocatoria en matrices de trazabilidad (`hypothesis_matrix.md`), paquetes de trabajo (`workpackages.yaml`) y estrategias de búsqueda (`rag/calls/`). Cierra los marcadores `\todo{DATO PENDIENTE}` registrando el dato en su ámbito. |
| 📚 Sintetizador Bibliográfico (`lit-synthesizer`) | `^(context/evidence_notes\.md\|src/references\.bib)$` | Único modo con acceso al MCP `semantic-scholar-mcp`: búsqueda sistemática de evidencia, registro en `evidence_notes.md` y gestión de BibTeX verificada en `references.bib`. Cierra los marcadores `\todo{CITA REQUERIDA}`. |
| ✍️ Redactor Científico (`academic-writer`) | `^(src/.*\.(tex\|md)\|src/figures/.*)$` | Redacta el manuscrito LaTeX en `src/`. Prohibido editar `references.bib`: solo usa `\cite{clave}` de claves existentes o inserta `\todo{CITA REQUERIDA}`. Las búsquedas de artículos las delega a `lit-synthesizer` vía `new_task`. Al iniciar sesión, lee `reviews/peer_review_log.md` y subsana los hallazgos ABIERTOS. |
| 🔍 Auditor Peer-Review (`reviewer-2`) | `^reviews/.*\.md$` | Solo lectura sobre `src/` y `context/`. Audita la coherencia, verifica los `\todo{}` con `grep` y registra hallazgos con severidad en `reviews/peer_review_log.md`. Las búsquedas de artículos las delega a `lit-synthesizer` vía `new_task`. Usa la checklist de `.roo/skills/peer-audit/SKILL.md`. |

## 🛠️ Skills (`.roo/skills/`)

| Skill | Modos | Descripción |
|-------|-------|-------------|
| `project-init` | research-architect | Onboarding guiado: diagnóstico de la estructura, interrogatorio al investigador y autogeneración asistida de matrices y ficheros iniciales. |
| `prisma-synthesis` | lit-synthesizer | Flujo PRISMA 2020 completo en 7 fases (F0-F6: protocolo, búsqueda, screening, extracción, riesgo de sesgo, síntesis con GRADE, checklist de 27 ítems) + variante narrativa (patrón CCLG) para el Estado del Arte. |
| `methods-reporting` | academic-writer | Estructura obligatoria de la sección de Métodos, checklist EQUATOR según diseño (CONSORT, STROBE, TRIPOD+AI, CARE, STARD, PRISMA, SPIRIT), power analysis, pre-registro, datos faltantes, reproducibilidad y declaraciones (CRediT, COI). |
| `grant-workpackages` | research-architect | Contrato y reglas de construcción de `data/workpackages.yaml` (WPs con objectives, deliverables, milestones, effort_pm, risks); el YAML debe permanecer parseable. |
| `latex-tables` | academic-writer | Tablas con `booktabs` exclusivamente: sin líneas verticales ni `\hline`, convenciones numéricas y estadísticas, plantilla base. |
| `peer-audit` | reviewer-2 | Checklist de auditoría en 6 fases (A1-A6): trazabilidad O/H, deuda `\todo`, integridad bibliográfica, fidelidad de datos, estilo y reporting EQUATOR. |
| `style-defluff` | academic-writer | Purga de muletillas de IA con linter `grep` en dos pasadas, excepciones técnicas y jerarquía normativa (gana `rules.md`). |
| `s2-search` | lit-synthesizer | Búsqueda y verificación de artículos vía el MCP `semantic-scholar-mcp` (fases S0-S6): `search_paper`, `get_paper` (verificación de DOI), `get_authors` y `get_citation` (bibtex). |

## 🔄 Flujo de trabajo recomendado

1. **research-architect**: define objetivos e hipótesis en `context/hypothesis_matrix.md`, registra la convocatoria en `context/call_guidelines.md` y las estrategias de búsqueda en `rag/calls/`.
2. **lit-synthesizer**: ejecuta la búsqueda y registra la evidencia en `context/evidence_notes.md` y las referencias verificadas en `src/references.bib`.
3. **academic-writer**: redacta las secciones en `src/` usando exclusivamente los datos de `data/stats_summary.json` y `context/hypothesis_matrix.md`, y las citas de `src/references.bib`.
4. **reviewer-2**: audita con `.roo/skills/peer-audit/SKILL.md` y registra los hallazgos en `reviews/peer_review_log.md`.

**Solicitud de artículos (MCP Semantic Scholar).** Cuando `academic-writer` necesita respaldar una afirmación (p. ej., la definición de *presencia* en realidad virtual), delega a **lit-synthesizer** vía `new_task`; este busca con `semantic-scholar-mcp` (`search_paper` → `get_paper` para verificar el DOI → `get_citation` en bibtex), registra la evidencia (DOI + fecha de acceso) en `context/evidence_notes.md` y la entrada verificada en `src/references.bib`, y devuelve las claves BibTeX; `academic-writer` inserta `\cite{clave}`. Si no hay evidencia verificable, el marcador `\todo{CITA REQUERIDA}` permanece abierto.

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

## ⚙️ Requisitos

- **bash real** (Git Bash o WSL en Windows): el script usa `set -euo pipefail`; no funciona en sh/dash/cmd.exe.
- Sin dependencias externas: solo usa binarios estándar (`mkdir`, `cp`, `cat`, `find`, `ls`, `printf`, `echo`, `test`, `dirname`).
- Para el MCP `semantic-scholar-mcp` (búsquedas de `lit-synthesizer`): el servidor se arranca con `python -m uv tool run --from git+https://github.com/adborgon/semantic-scholar-mcp.git semantic-scholar-mcp serve`. Requiere `python` en el `PATH` con el paquete `uv` instalado (`pip install uv`); `uv tool run` cachea el paquete y NO reinstala en cada arranque (sin `--refresh-package`). El API admite ~1 petición/segundo: ante HTTP 429, esperar 15-20 s antes de reintentar.
- **Seguridad**: `.roo/mcp.json` no contiene ninguna clave API en claro: el servidor hereda la variable de entorno `SEMANTIC_SCHOLAR_API_KEY` del sistema (ver sección siguiente). No publiques este repo (ni los proyectos generados) en repositorios públicos y no reintroduzcas la clave en ningún fichero versionado.
- Para compilar el manuscrito generado: `pdflatex` + `bibtex` (fuera del alcance del script).

### 🔑 Configuración de la clave API (SEMANTIC_SCHOLAR_API_KEY)

`.roo/mcp.json` **no incluye ninguna clave API**: el proceso del servidor MCP hereda la variable de entorno `SEMANTIC_SCHOLAR_API_KEY` del sistema. Si la variable no está definida, el servidor no se autentica y las búsquedas de `lit-synthesizer` fallarán (es un paso de configuración, no un fallo del scaffold).

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

**Advertencia de seguridad**: no escribas la clave en ningún fichero del repositorio (`.roo/mcp.json`, scripts, documentación…) y no publiques este repo ni los proyectos generados en repositorios públicos. La clave vive únicamente en el entorno del sistema.
