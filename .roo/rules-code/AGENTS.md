# Reglas de código (BecarioGPT)

- `init_paper.sh` (527 líneas) es el único código del repo. Edítalo con bash estricto: `set -euo pipefail` en la línea 22. En Windows, lanzar con Git Bash/WSL.
- Estructura del script: mensajería ASCII `[OK]/[WARN]/[ERROR]` con `printf` (líneas 27-29), `usage()` por heredoc (líneas 31-50), `copy_tree_noclobber()` con `find` + `cp` (líneas 54-66), `write_template()` con guarda `[ -s ]` (líneas 70-78).
- Parseo de argumentos (líneas 86-122): acepta `--force` y `-h/--help` (el help termina con `exit 1`); rechaza rutas que empiezan por `-`, que contienen `..` o un segundo proyecto; **nunca** usa `.` como proyecto por defecto (líneas 117-122).
- `mkdir -p` con las 9 rutas separadas y entrecomilladas (líneas 153-162): NO reintroduzcas brace expansion `{a,b}` (no existe en sh/dash/cmd.exe).
- Copias íntegras desde el repo con guardas de no-sobrescritura `[ -s ]`: `.roomodes` (líneas 170-179), `.roo/skills/` vía `cp -r` o `copy_tree_noclobber` si `--force` (líneas 182-191) y `.roo/rules/rules.md` → `.roo/rules/00_academic_core.md` (líneas 195-238; el heredoc embebido de las líneas 209-235 es solo respaldo si falta el fichero fuente).
- `write_template()` (líneas 70-78) escribe SOLO si el destino no existe o está vacío; con `--force` avisa con `[WARN]` y no sobrescribe. Las 12 plantillas van de la línea 245 a la 498.
- `data/stats_summary.json` nace con esqueleto **válido y parseable** (`study_metadata{design, n, preregistration_url}` + `variables`, líneas 334-344); `data/workpackages.yaml` nace con un WP1 de ejemplo (líneas 347-363). Todo nuevo `.json`/`.yaml` del scaffold debe nacer parseable.
- La numeración `src/01_introduction.tex`…`04_discussion.tex` (líneas 401-426) codifica el orden de secciones del paper que `src/main.tex` incluye con `\input` (líneas 389-392): al añadir una, usa el número siguiente; no reordenes las existentes.
- Post-condición (líneas 503-519): `test -f` sobre 5 ficheros clave (`src/main.tex`, `.roo/rules/00_academic_core.md`, `context/hypothesis_matrix.md`, `data/stats_summary.json`, `reviews/peer_review_log.md`); si falta alguno, `[ERROR]` y `exit 1`. El éxito real son las líneas 524-525 (`[OK] Estructura academica generada en ...`).
- Binarios usados: `mkdir`, `cp`, `cat`, `find`, `ls`, `printf`, `echo`, `test`. No uses binarios adicionales sin justificarlo.
- Toda ruta debe ir entrecomillada y anclada a `"$PROJECT_DIR"` (o a `"$SCRIPT_DIR"` para las fuentes, línea 127); nunca dependas del CWD.
- Test manual antes de tocar el script: ejecutarlo en un directorio temporal y comprobar estructura generada, mensajes ASCII y post-condición.
