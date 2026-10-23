# 📚 Workspace Académico y de Investigación (Zoo Code / Roo Code)

BecarioGPT es un repositorio base para la **redacción de artículos científicos (IMRaD)** y la **preparación de propuestas de proyectos de investigación competitivos** con asistentes de IA basados en agentes (Zoo Code / Roo Code).

Su único contenido ejecutable es `init_paper.sh`: un script que genera la estructura inicial de cada proyecto de paper (LaTeX + workflow de investigación) y copia a cada proyecto la configuración de agentes de este repo (`.roomodes`, `.roo/rules/`, `.roo/skills/`).

El sistema está diseñado bajo el principio de **Separación de Responsabilidades y Single Source of Truth (SSOT)** para evitar alucinaciones bibliográficas, desajustes metodológicos y errores de formato.

---

## 📁 Estructura de ESTE repositorio

```text
.
├── init_paper.sh              # Único script: genera la estructura de un proyecto nuevo
├── README.md                  # Esta documentación
├── AGENTS.md                  # Guía técnica para agentes de código
├── .roomodes                  # Definición de los 4 modos académicos (se copia a cada proyecto)
├── .roo/
│   ├── rules/
│   │   └── rules.md           # Marco académico global (se copia como 00_academic_core.md)
│   ├── rules-code/            # Reglas para el modo Code
│   ├── rules-debug/           # Reglas para el modo Debug
│   ├── rules-ask/             # Reglas para el modo Ask
│   ├── rules-architect/       # Reglas para el modo Architect
│   ├── rules-research-architect/  # Reglas adicionales del modo research-architect
│   └── skills/                # 7 skills de agentes (se copian a cada proyecto)
├── context/                   # Estado de investigación del repo (matrices SSOT de trabajo)
├── data/                      # Datos estructurados del repo
└── rag/                       # Base de conocimiento local (RAG)
    ├── calls/                 # Convocatorias y estrategias de búsqueda documentadas
    ├── past_projects/         # Memorias de proyectos anteriores de referencia
    └── templates/             # Plantillas institucionales y CVs
```

## 📁 Estructura de un proyecto GENERADO (lo que crea `init_paper.sh`)

```text
nombre-del-proyecto/
├── .roomodes                  # Copiado íntegro del repo
├── .roo/
│   ├── rules/
│   │   └── 00_academic_core.md    # Copia íntegra de .roo/rules/rules.md
│   └── skills/                    # Las 7 skills copiadas del repo
├── context/
│   ├── call_guidelines.md     # Requisitos de la revista/convocatoria (SSOT)
│   ├── hypothesis_matrix.md   # Objetivos, hipótesis y variables (SSOT, con Changelog)
│   └── evidence_notes.md      # Registro de evidencia (con DOI + fecha de acceso)
├── data/
│   ├── stats_summary.json     # Nace parseable: study_metadata{design, n, preregistration_url} + variables
│   └── workpackages.yaml      # Nace parseable, con un WP1 de ejemplo
├── src/
│   ├── main.tex               # Documento raíz LaTeX compilable (IMRaD)
│   ├── 01_introduction.tex
│   ├── 02_methodology.tex
│   ├── 03_results.tex
│   ├── 04_discussion.tex      # El orden de secciones lo fija la numeración 01..04
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

Antes de declarar el éxito, el script verifica con `test -f` cinco ficheros clave: `src/main.tex`, `.roo/rules/00_academic_core.md`, `context/hypothesis_matrix.md`, `data/stats_summary.json` y `reviews/peer_review_log.md`.

## 🤖 Modos y permisos

Los 4 modos académicos están definidos en `.roomodes`. Cada uno restringe su edición con un `fileRegex`:

| Modo | Ficheros editables (fileRegex) | Role |
|------|-------------------------------|------|
| 📐 Arquitecto de Estructura (`research-architect`) | `^(context/.*\|data/.*\|rag/calls/.*)$` | Traduce ideas, hipótesis y requisitos de convocatoria en matrices de trazabilidad (`hypothesis_matrix.md`), paquetes de trabajo (`workpackages.yaml`) y estrategias de búsqueda (`rag/calls/`). Cierra los marcadores `\todo{DATO PENDIENTE}` registrando el dato en su ámbito. |
| 📚 Sintetizador Bibliográfico (`lit-synthesizer`) | `^(context/evidence_notes\.md\|src/references\.bib)$` | Búsqueda sistemática de evidencia, registro en `evidence_notes.md` y gestión de BibTeX verificada en `references.bib`. Cierra los marcadores `\todo{CITA REQUERIDA}`. |
| ✍️ Redactor Científico (`academic-writer`) | `^(src/.*\.(tex\|md)\|src/figures/.*)$` | Redacta el manuscrito LaTeX en `src/`. Prohibido editar `references.bib`: solo usa `\cite{clave}` de claves existentes o inserta `\todo{CITA REQUERIDA}`. Al iniciar sesión, lee `reviews/peer_review_log.md` y subsana los hallazgos ABIERTOS. |
| 🔍 Auditor Peer-Review (`reviewer-2`) | `^reviews/.*\.md$` | Solo lectura sobre `src/` y `context/`. Audita la coherencia, verifica los `\todo{}` con `grep` y registra hallazgos con severidad en `reviews/peer_review_log.md`. Usa la checklist de `.roo/skills/peer-audit/SKILL.md`. |

## 🛠️ Skills (`.roo/skills/`)

| Skill | Modos | Descripción |
|-------|-------|-------------|
| `project-init` | academic-writer, research-architect | Onboarding guiado: diagnóstico de la estructura, interrogatorio al investigador y autogeneración asistida de matrices y ficheros iniciales. |
| `prisma-synthesis` | lit-synthesizer, research-architect | Flujo PRISMA 2020 completo en 7 fases (F0-F6: protocolo, búsqueda, screening, extracción, riesgo de sesgo, síntesis con GRADE, checklist de 27 ítems) + variante narrativa (patrón CCLG) para el Estado del Arte. |
| `methods-reporting` | academic-writer | Estructura obligatoria de la sección de Métodos, checklist EQUATOR según diseño (CONSORT, STROBE, TRIPOD+AI, CARE, STARD, PRISMA, SPIRIT), power analysis, pre-registro, datos faltantes, reproducibilidad y declaraciones (CRediT, COI). |
| `grant-workpackages` | research-architect | Contrato y reglas de construcción de `data/workpackages.yaml` (WPs con objectives, deliverables, milestones, effort_pm, risks); el YAML debe permanecer parseable. |
| `latex-tables` | academic-writer | Tablas con `booktabs` exclusivamente: sin líneas verticales ni `\hline`, convenciones numéricas y estadísticas, plantilla base. |
| `peer-audit` | reviewer-2 | Checklist de auditoría en 6 fases (A1-A6): trazabilidad O/H, deuda `\todo`, integridad bibliográfica, fidelidad de datos, estilo y reporting EQUATOR. |
| `style-defluff` | academic-writer | Purga de muletillas de IA con linter `grep` en dos pasadas, excepciones técnicas y jerarquía normativa (gana `rules.md`). |

## 🔄 Flujo de trabajo recomendado

1. **research-architect**: define objetivos e hipótesis en `context/hypothesis_matrix.md`, registra la convocatoria en `context/call_guidelines.md` y las estrategias de búsqueda en `rag/calls/`.
2. **lit-synthesizer**: ejecuta la búsqueda y registra la evidencia en `context/evidence_notes.md` y las referencias verificadas en `src/references.bib`.
3. **academic-writer**: redacta las secciones en `src/` usando exclusivamente los datos de `data/stats_summary.json` y `context/hypothesis_matrix.md`, y las citas de `src/references.bib`.
4. **reviewer-2**: audita con `.roo/skills/peer-audit/SKILL.md` y registra los hallazgos en `reviews/peer_review_log.md`.

El ciclo de deuda académica cierra los marcadores `\todo{}`:
- `\todo{CITA REQUERIDA}` → lo cierra **lit-synthesizer** (evidencia con DOI + fecha en `evidence_notes.md` y BibTeX en `references.bib`); **academic-writer** sustituye el marcador por `\cite{clave}`.
- `\todo{DATO PENDIENTE}` → lo cierra **research-architect** (dato en `stats_summary.json` o `hypothesis_matrix.md`); **academic-writer** sustituye el marcador por el valor registrado.
- **reviewer-2** verifica con `grep` que no queden marcadores abiertos antes de dar el visto bueno.

## 🚀 Guía de inicio

1. **Crear un proyecto** (requiere bash real; en Windows usar Git Bash o WSL):

   ```bash
   bash init_paper.sh nombre-del-proyecto
   ```

   Para completar un proyecto existente sin sobrescribir nada:

   ```bash
   bash init_paper.sh nombre-del-proyecto --force
   ```

   El script rechaza ejecutarse sin nombre de proyecto (nunca usa `.`), con rutas que empiezan por `-`, que contienen `..`, o con más de un proyecto.

2. **Arrancar el onboarding**: abre Zoo Code en el proyecto generado, selecciona el modo 📐 Arquitecto de Estructura y escribe: *"Usa la skill project-init para guiarme en la configuración inicial de este nuevo [artículo / proyecto]."*

3. **Rellenar los SSOT**: `context/call_guidelines.md` y `context/hypothesis_matrix.md` (el script lo indica en su mensaje final).

4. **Seguir el ciclo iterativo**: research-architect → lit-synthesizer → academic-writer → reviewer-2 (ver flujo anterior).

## ⚙️ Requisitos

- **bash real** (Git Bash o WSL en Windows): el script usa `set -euo pipefail`; no funciona en sh/dash/cmd.exe.
- Sin dependencias externas: solo usa binarios estándar (`mkdir`, `cp`, `cat`, `find`, `ls`, `printf`, `echo`).
- Para compilar el manuscrito generado: `pdflatex` + `bibtex` (fuera del alcance del script).
