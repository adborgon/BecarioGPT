---
name: project-init
description: Activa esta skill cuando el usuario invoque la inicialización de un proyecto nuevo (generado con `bash init_paper.sh <proyecto>`) para auditar el estado del repositorio y guiarle interactivamente en la configuración.
modeSlugs:
  - research-architect
---

# Project Init

## Instructions

Cuando el usuario invoque esta skill tras generar el scaffold con `init_paper.sh`, actúa como verificador de la estructura y configurador inicial del proyecto. El script ya crea directorios y plantillas: esta skill NO crea directorios ni toca `src/`.

## Paso 1: Verificación post-generación (sin crear nada)
1. Comprueba la post-condición parametrizada del scaffold: TODAS las rutas listadas en `templates/common/postcheck.list` y en `templates/<tipo>/postcheck.list` del repositorio base (núcleo común + overlay del `--type` usado al generar) existen y no están vacíos en el proyecto. El tipo generado lo indica el campo `project_type` de `data/stats_summary.json`; si se desconoce, dedúcelo de ahí o pregúntalo al usuario antes de re-ejecutar. Como mínimo (ficheros comunes), deben existir y no estar vacíos `src/main.tex`, `.roo/rules/00_academic_core.md`, `context/hypothesis_matrix.md`, `data/stats_summary.json`, `reviews/peer_review_log.md`, `.roo/mcp.json`, `data/autonomy_state.json`, `context/autonomy_journal.md`, `context/escalation_queue.md` y `run_autonomy.sh`.
2. Verifica que `.roo/rules/00_academic_core.md` contiene el marco íntegro: las 8 secciones (integridad bibliográfica, fidelidad de datos, tono anti-fluff, trazabilidad SSOT, ciclo de cierre de deuda académica con marcadores `\todo{}`, búsqueda de artículos vía MCP, ciclo de autonomía y conocimiento local `rag/`).
3. Si falta o está incompleto algún elemento, indica al usuario re-ejecutar `bash init_paper.sh <proyecto> --force` (completa sin sobrescribir). NO reconstruyas ficheros a mano.

## Paso 2: Interrogatorio guiado al investigador
Pregunta al usuario de forma clara y directa. Los datos de hipótesis, variables y métricas los aporta SIEMPRE el usuario: NUNCA los inventes.
1. **¿Qué tipo de trabajo es?** (¿Artículo científico IMRaD o memoria de proyecto competitivo para una convocatoria?).
2. **¿De qué trata brevemente?** (Pide un párrafo con el objetivo principal).
3. **¿Cuál es la revista o convocatoria objetivo?** (Nombre, URL y fecha de consulta; recuérdale que puede depositar las bases en `rag/calls/` y material de referencia en `rag/past_projects/`).
4. **¿Qué objetivos iniciales (O1, O2...) e hipótesis (H1...) quiere registrar?**

## Paso 3: Primer llenado (solo en tus permisos: context/, data/ y rag/calls/)
1. Rellena la cabecera de `context/call_guidelines.md`: revista/convocatoria, tipo de contribución, alcance y temáticas, criterios de evaluación y límites de formato (con fecha de consulta AAAA-MM-DD).
2. Añade la PRIMERA fila de `context/hypothesis_matrix.md`: IDs (O1, H1), variables y métricas, exclusivamente con los datos aportados en el Paso 2; si falta un dato, deja el marcador `\todo{DATO PENDIENTE: [metrica]}` en lugar de inventarlo.
3. Registra la estrategia de búsqueda inicial en `rag/calls/` (p. ej. `rag/calls/search_strategy.md`): fuentes, consultas previstas, criterios de inclusión/exclusión y fecha.

## Paso 3-bis: Rama grant (solo proyectos grant / PPC)

Si el proyecto es una propuesta competitiva (`--type grant`; `project_type: "grant"` en `data/stats_summary.json`), añade a los pasos anteriores:

1. **Capturar la convocatoria**: pide al investigador el PDF o la URL de las bases y deposítalos en `rag/calls/` (convención de nombres `YYYY_fuente_titulo.md|pdf` en su README). Sin convocatoria real subida, NO se registran requisitos: se escala (D1) pidiéndosela.
2. **Checklist de convocatoria**: rellena `context/convocatoria_checklist.md` requisito a requisito desde las bases (ID, sección donde se aborda, peso y estado PENDIENTE); ajusta las filas orientativas del scaffold a los requisitos EXACTOS de la convocatoria.
3. **Bootstrap de consorcio y presupuesto**: rellena `data/consortium.yaml` (entidades, tipo public/private, rol, PI, capacidades) y `data/budget.yaml` (categorías: personal, costes externos, equipamiento, costes indirectos, total; y aportación privada si las bases la exigen) con los datos que dé el investigador; donde falte dato, déjalo como `"PENDIENTE: ..."`/`"PENDIENTE"` — NUNCA inventes nombres ni euros.
4. **Duración y calendario**: registra la duración de la convocatoria en `context/call_guidelines.md` y derivará los plazos de los hitos de `data/workpackages.yaml` (grant-workpackages); si la convocatoria no define calendario, escalado D1.
5. **Intake de referencia**: pide al investigador proyectos parecidos (`rag/past_projects/`) y memorias de convocatorias anteriores (`rag/templates/`) para estructura de consorcio, estado del arte contextual y estilo de escritura (reglas §8: re-verificación SSOT y estilo sí, texto no).

## Paso 4: Bootstrap de autonomía (F4)
1. Inicializa `data/autonomy_state.json`: confirma que el JSON es parseable y que contiene `schema_version`, `budget` y `current`; fija `project_type` leyéndolo de `data/stats_summary.json` (la plantilla nace con `null` y el scaffold no interpola) y ajusta `budget` (`max_iterations`, `timeout_minutes`) al que pida el investigador; por defecto, el de la plantilla (40 iteraciones / 240 min por sesión).
2. Verifica que `context/autonomy_journal.md` y `context/escalation_queue.md` están operativos y vacíos: el journal con su tabla de eventos (sin entradas aún) y la cola sin ninguna fila ABIERTA.
3. Recuerda al investigador el arranque del bucle de autonomía: `bash run_autonomy.sh --dry-run` para ver el plan sin lanzar nada y `bash run_autonomy.sh` para el bucle (o el MODO MANUAL si no hay CLI headless).

## Límites estrictos de esta skill
- NO crear ni editar NINGÚN fichero de `src/`: es responsabilidad de academic-writer.
- NO editar NINGÚN fichero de `reviews/`: es responsabilidad de reviewer-2.
- NO crear directorios: el scaffold de `init_paper.sh` ya genera la estructura completa.
- Muestra al usuario un resumen de lo verificado y rellenado, e indícale qué Modo y flujo continúa (academic-writer para `src/`, reviewer-2 para auditorías).
