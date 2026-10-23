# Restricciones arquitectónicas (BecarioGPT)

- El scaffold debe seguir siendo UN script bash sin dependencias: nada de git init, gestores de paquetes ni binarios externos más allá de los ya usados: `mkdir`, `cp`, `cat`, `find`, `ls`, `printf`, `echo`, `test`.
- Requisito de bash real (`set -euo pipefail`, línea 22): no reintroducir construcciones sh/dash (brace expansion en `mkdir`, etc.).
- Los nombres de directorios generados (`.roo/`, `context/`, `data/`, `src/`, `reviews/`, `rag/`) son el contrato con los proyectos académicos posteriores: cambiarlos rompe el workflow de papers ya creados. `src/figures/` y `rag/{calls,past_projects,templates}` se crean con `mkdir -p` (líneas 153-162).
- La configuración de agentes de los proyectos generados vive en `.roomodes` (modos) y `.roo/` (reglas y skills): el script la copia íntegra desde este repo (líneas 170-238). La antigua convención `.zoocode/` ya no se usa; no reintroducirla.
- `data/stats_summary.json` y `data/workpackages.yaml` deben nacer SIEMPRE parseables (esqueleto JSON con `study_metadata`/`variables`, líneas 334-344; WP1 de ejemplo, líneas 347-363): el resto de agentes del proyecto generado dependen de ello.
- La post-condición (`test -f` sobre 5 ficheros clave, líneas 503-519) es parte del contrato de éxito: cualquier paso nuevo que pueda fallar debe decidir explícitamente si aborta o continúa.
- Este repo solo contiene el generador y su configuración: nunca escribas el contenido de un paper dentro de BecarioGPT.
