# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Qué es este repo

BecarioGPT no contiene papers: contiene **un único script generador** (`init_paper.sh`, 527 líneas) que crea la estructura inicial de proyectos de papers académicos (LaTeX + workflow de investigación con agentes Roo).

## Uso

```bash
bash init_paper.sh nombre-del-proyecto           # crea ./nombre-del-proyecto/...
bash init_paper.sh nombre-del-proyecto --force   # completa un proyecto existente sin sobrescribir
```

- Requiere **bash real** (Git Bash/WSL en Windows): el script usa `set -euo pipefail` (línea 22) y validaciones que no funcionan en sh/dash/cmd.exe. La brace expansion de `mkdir` ya no se usa (las rutas van separadas, líneas 153-162), pero el requisito de bash persiste.
- Sin argumento, con `-h/--help`, con rutas que empiezan por `-` o contienen `..`, o con dos proyectos, el script muestra el uso y termina con `exit 1` (líneas 86-122). **Nunca** usa `.` como proyecto por defecto.
- `--force` solo añade lo que falta: las guardas `[ -s ]` en `write_template()` (líneas 70-78) y en las copias (líneas 170-238) impiden sobrescribir ficheros existentes no vacíos.
- El script copia `.roomodes`, `.roo/skills/` y `.roo/rules/rules.md` (como `.roo/rules/00_academic_core.md`) desde **este repo**; no hay paso manual de copia.
- No hay build/test/lint ni manifests (no existe package.json). Binarios usados: `mkdir`, `cp`, `cat`, `find`, `ls`, `printf`, `echo`, `test` (`[ ... ]`).
- Test manual recomendado antes de tocar el script: ejecutarlo en un directorio temporal y comprobar la estructura generada y la post-condición.

## Estructura que GENERA (es el contrato con los papers, no contenido de este repo)

- `.roomodes` — definición de los 4 modos académicos (copiado íntegro del repo, líneas 170-179).
- `.roo/rules/00_academic_core.md` — copia íntegra de `.roo/rules/rules.md` (líneas 195-238); el heredoc embebido es solo respaldo si falta el fichero fuente.
- `.roo/skills/` — las 7 skills de agentes (líneas 182-191).
- `context/` — estado de investigación: `call_guidelines.md`, `hypothesis_matrix.md` (con Changelog), `evidence_notes.md` (con DOI + fecha de acceso).
- `data/` — `stats_summary.json` nace con esqueleto **válido y parseable** (`study_metadata{design, n, preregistration_url}` + `variables`, líneas 334-344); `workpackages.yaml` nace con un WP1 de ejemplo (líneas 347-363). Todo nuevo `.json`/`.yaml` del scaffold debe nacer parseable.
- `src/` — `main.tex` compilable (líneas 366-398) más secciones LaTeX con orden fijado por numeración: `01_introduction.tex` → `04_discussion.tex` (líneas 401-426), `references.bib` (líneas 429-449) y `figures/`.
- `reviews/peer_review_log.md` — registro de auditoría académica con tabla y severidades (líneas 452-469).
- `rag/calls`, `rag/past_projects`, `rag/templates` — base de conocimiento local (líneas 160-162).
- `.gitignore` — LaTeX + Python/R (líneas 472-498).

## Post-condición y éxito

Antes de declarar éxito, el script verifica con `test -f` cinco ficheros clave (`src/main.tex`, `.roo/rules/00_academic_core.md`, `context/hypothesis_matrix.md`, `data/stats_summary.json`, `reviews/peer_review_log.md`; líneas 503-519) y termina con `exit 1` si falta alguno. El mensaje de éxito real está en las líneas 524-525 (`[OK] Estructura academica generada en ...`). Los mensajes de consola son ASCII puro: `[OK]`, `[WARN]`, `[ERROR]`.

## Gestión del repo

La fase de análisis y el plan de acción de la actualización del sistema (fases 1-4: script reescrito, `.roomodes`, reglas y skills, y sincronización de documentación) quedaron registrados en el historial de trabajo del proyecto; esta documentación está sincronizada con el código vigente.
