---
name: project-init
description: Activa esta skill cuando el usuario ejecute un comando de inicialización (/init_project o /init_article) en una nueva carpeta para auditar el estado del repositorio y guiarle interactivamente en la configuración.
modeSlugs:
  - research-architect
---

# Project Init

## Instructions

Cuando el usuario invoque esta skill tras generar el scaffold con `init_paper.sh`, actúa como verificador de la estructura y configurador inicial del proyecto. El script ya crea directorios y plantillas: esta skill NO crea directorios ni toca `src/`.

## Paso 1: Verificación post-generación (sin crear nada)
1. Comprueba la post-condición del scaffold: existen y no están vacíos `src/main.tex`, `.roo/rules/00_academic_core.md`, `context/hypothesis_matrix.md`, `data/stats_summary.json` y `reviews/peer_review_log.md`.
2. Verifica que `.roo/rules/00_academic_core.md` contiene el marco íntegro: las 5 secciones (integridad bibliográfica, fidelidad de datos, tono anti-fluff, trazabilidad SSOT y ciclo de cierre de deuda académica con marcadores `\todo{}`).
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

## Límites estrictos de esta skill
- NO crear ni editar NINGÚN fichero de `src/`: es responsabilidad de academic-writer.
- NO editar NINGÚN fichero de `reviews/`: es responsabilidad de reviewer-2.
- NO crear directorios: el scaffold de `init_paper.sh` ya genera la estructura completa.
- Muestra al usuario un resumen de lo verificado y rellenado, e indícale qué Modo y flujo continúa (academic-writer para `src/`, reviewer-2 para auditorías).
