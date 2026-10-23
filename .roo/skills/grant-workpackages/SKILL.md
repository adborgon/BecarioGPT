---
name: grant-workpackages
description: Activa esta skill cuando trabajes en memorias de proyectos de investigación para estructurar o redactar Paquetes de Trabajo (Work Packages), Tareas, Entregables, Hitos (Milestones) y Matrices de Contingencia/Riesgos.
modeSlugs:
  - research-architect
---

# Grant Workpackages

## Objetivo

Construir y mantener `data/workpackages.yaml`. La estructura de contrato (definida en el scaffold de `init_paper.sh`) es:

```yaml
workpackages:
  - id: WP1
    title: Título del paquete de trabajo
    objectives: []      # IDs O1..On / H1..Hn de context/hypothesis_matrix.md
    deliverables: []    # verificables, con criterio de aceptación
    milestones: []      # con dependencias explícitas
    effort_pm: 0        # esfuerzo en persona-meses
    risks: []           # con probabilidad, impacto y mitigación
```

## Reglas de Construcción

1. **Trazabilidad con objetivos:** cada objetivo o hipótesis de `context/hypothesis_matrix.md` (O1..On, H1..Hn) debe mapearse a al menos un WP; cita los IDs explícitos en el campo `objectives`. Antes de dar por cerrado el fichero, verifica la cobertura ID a ID.
2. **Entregables verificables:** cada `deliverable` debe poder aceptarse o rechazarse; vincula un criterio de aceptación medible (documento entregable, prototipo funcional, resultado registrado en `data/stats_summary.json`, sección de `src/`).
3. **Hitos con dependencias:** cada `milestone` declara de qué WP o hito previo depende y en qué mes del proyecto se prevé alcanzarlo, según la duración indicada en `context/call_guidelines.md`.
4. **Esfuerzo coherente:** los `effort_pm` deben sumar un total realista y no duplicar el esfuerzo del mismo personal en WPs paralelos; documenta los supuestos de asignación.
5. **Riesgos completos:** cada riesgo declara descripción, probabilidad, impacto y mitigación. No se admiten riesgos sin mitigación.
6. **YAML siempre parseable:** tras cada edición valida que el fichero sigue siendo YAML válido (p. ej. `python -c "import yaml; yaml.safe_load(open('data/workpackages.yaml', encoding='utf-8'))"`). Un YAML roto bloquea al resto de agentes; si una edición no puede validarse, reviértela.
7. **No inventar convocatoria:** presupuesto, duración y fechas del calendario proceden de `context/call_guidelines.md`. Si no constan ahí, déjalos como valores pendientes documentados (`todo: ...`) y genera en la memoria correspondiente `\todo{DATO PENDIENTE: [dato de la convocatoria]}`; nunca inventes cifras de presupuesto ni fechas.

## Flujo de Trabajo

1. Lee `context/hypothesis_matrix.md` (objetivos e hipótesis con ID) y `context/call_guidelines.md` (requisitos, duración y presupuesto de la convocatoria).
2. Diseña los WPs cubriendo todos los objetivos; comprueba la cobertura ID a ID (regla 1).
3. Escribe o actualiza `data/workpackages.yaml` y valida el parseo (regla 6).
4. La redacción de la memoria (Gantt, tablas de entregables) corresponde a academic-writer y debe derivarse del YAML. Prohibido introducir cambios de estructura o cifras directamente en la memoria sin actualizar antes el YAML (fuente única de verdad).

## Ejemplo Mínimo de WP Bien Formado

```yaml
workpackages:
  - id: WP1
    title: Revisión sistemática y definición de requisitos
    objectives:
      - "O1: caracterizar el estado del arte de X (H1)"
    deliverables:
      - "D1.1: informe de revisión con diagrama de flujo PRISMA (criterio de aceptación: checklist F6 verificada y evidencia registrada en context/evidence_notes.md)"
    milestones:
      - "M1: protocolo registrado y estrategia de búsqueda documentada en rag/calls/ (depende de: inicio del proyecto; mes 2)"
    effort_pm: 4
    risks:
      - description: Acceso incompleto a textos completos
        probability: media
        impact: medio
        mitigation: Préstamo interbibliotecario y uso de preprints
```
