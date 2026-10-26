# Restricciones arquitectónicas (BecarioGPT)

- El scaffold debe seguir siendo UN script bash sin dependencias: nada de git init, gestores de paquetes ni binarios externos más allá de los ya usados: `mkdir`, `cp`, `cat`, `find`, `ls`, `printf`, `echo`, `test`, `dirname`.
- Requisito de bash real (`set -euo pipefail`, línea 34): no reintroducir construcciones sh/dash (brace expansion en `mkdir`, etc.).
- Los nombres de directorios generados (`.roo/`, `context/`, `data/`, `src/`, `reviews/`, `rag/`) son el contrato con los proyectos académicos posteriores: cambiarlos rompe el workflow de papers ya creados. `src/figures/` y `rag/{calls,past_projects,templates}` se crean con `mkdir -p` (bloque [7], líneas 264-273).
- La configuración de agentes de los proyectos generados vive en `.roomodes` (modos) y `.roo/` (reglas y skills): el script la copia íntegra desde este repo (bloque [8], líneas 275-337). La antigua convención `.zoocode/` ya no se usa; no reintroducirla.
- `data/stats_summary.json` y `data/workpackages.yaml` deben nacer SIEMPRE parseables: `stats_summary.json` vive en el overlay de cada tipo (`templates/<tipo>/data/`) con `project_type` + `study_metadata{design, n, preregistration_url}` + `variables`; `workpackages.yaml` vive en `templates/common/data/` con un WP1 de ejemplo. El resto de agentes del proyecto generado dependen de ello.
- La post-condición parametrizada (bloque [10], líneas 353-376: todas las rutas de `templates/common/postcheck.list` y de `templates/<tipo>/postcheck.list`) es parte del contrato de éxito: cualquier paso nuevo que pueda fallar debe decidir explícitamente si aborta o continúa.
- Este repo solo contiene el generador y su configuración: nunca escribas el contenido de un paper dentro de BecarioGPT.
