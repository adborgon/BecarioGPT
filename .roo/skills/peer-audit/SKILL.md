---
name: peer-audit
description: Activa esta skill cuando reviewer-2 deba auditar el manuscrito o el estado del repositorio antes de dar el visto bueno. Ejecuta la checklist de 6 fases (A1-A6) con sus verificaciones concretas, registra cada hallazgo en reviews/peer_review_log.md con severidad y solo aprueba si no quedan hallazgos [CRÍTICO - Bloqueante] abiertos.
modeSlugs:
  - reviewer-2
---

# Peer Audit

## Norma de Registro

Toda verificación se anota en `reviews/peer_review_log.md` con la tabla existente: ID (A1.1, A2.3, ...), Severidad ([CRÍTICO - Bloqueante] / [MAYOR] / [MENOR]), Fichero:Línea, Descripción, Estado (ABIERTO/RESUELTO), Responsable y Fecha. Prohibido borrar o reescribir hallazgos históricos: los cierres se marcan cambiando el Estado a RESUELTO.

## A1 — Trazabilidad de Objetivos e Hipótesis

1. `grep -rnE "O[0-9]" src --include=*.tex` y `grep -rnE "H[0-9]" src --include=*.tex`: cada objetivo e hipótesis de `context/hypothesis_matrix.md` debe aparecer en `src/` (búsqueda recursiva, compatible con estructuras anidadas como `src/chapters/`).
2. Cada resultado presentado en Resultados o Discusión debe enlazar a una hipótesis (Hx) u objetivo (Ox) explícito de la matriz.
3. Severidades: objetivo o hipótesis sin aparecer en `src/` → [MAYOR]; resultado sin hipótesis u objetivo asociado → [MAYOR].

## A2 — Deuda Académica (\todo)

1. Ejecuta:

```bash
grep -n '\\\\todo' src/*.tex
```

2. Registra cada marcador abierto en el log con su severidad: CITA REQUERIDA y DATO PENDIENTE son [MAYOR] por defecto; [CRÍTICO - Bloqueante] si afectan a un resultado central del manuscrito.
3. Verifica el ciclo de cierre asignado: CITA REQUERIDA → lit-synthesizer (evidencia en `context/evidence_notes.md` y BibTeX en `src/references.bib`); DATO PENDIENTE → research-architect (dato en `data/stats_summary.json` o `context/hypothesis_matrix.md`).

## A3 — Integridad Bibliográfica

1. Extrae las claves citadas y comprueba su existencia en `src/references.bib`:

```bash
grep -noE '\\\\cite\{[^}]+\}' src/*.tex
```

2. Clave citada inexistente en el `.bib` → [CRÍTICO - Bloqueante] (alucinación bibliográfica; ver `.roo/rules/rules.md`).
3. Entradas del `.bib` no citadas en ningún `.tex` → candidatas a eliminar, [MENOR].
4. Entradas sin DOI/URL ni fecha de acceso → [MAYOR]: la integridad no es verificable.

## A4 — Fidelidad de Datos

1. Lista los números reportados en `src/` ($N$, medias, DE, $p$-valores, $\eta^2$, $d$, IC 95%, porcentajes) y verifica que cada uno procede de `data/stats_summary.json` o `context/hypothesis_matrix.md`.
2. Número no trazable o discrepante con la fuente → [CRÍTICO - Bloqueante]. Sin excepciones.

## A5 — Estilo Anti-Fluff

1. Ejecuta la primera pasada con la lista unificada de `.roo/rules/rules.md` + `.roo/skills/style-defluff/SKILL.md`:

```bash
grep -Ein "delve|delving|tapestry|crucial|paramount|groundbreaking|revolution|realm|beacon|underscore|testament|rapidly evolving|vertiginoso|revolucionari|sin precedentes|tapiz|piedra angular|paradigma disruptivo|exhaustiv" src/*.tex
```

2. Antes de abrir hallazgo, contrasta cada coincidencia con las excepciones técnicas de `.roo/skills/style-defluff/SKILL.md`; el uso técnico no se penaliza. Uso promocional → [MENOR] (o [MAYOR] si aparece en Abstract o Introducción).
3. Revisa oraciones de más de 40 palabras y acrónimos sin definir en su primera aparición → [MENOR].

## A6 — Reporting (EQUATOR)

1. Lee el diseño del estudio en `data/stats_summary.json` (`study_metadata.design`).
2. Identifica la checklist EQUATOR aplicable en la tabla de `.roo/skills/methods-reporting/SKILL.md` (CONSORT 2010, STROBE, TRIPOD+AI, CARE, STARD, PRISMA 2020, SPIRIT).
3. Verifica los ítems de esa checklist en `src/`; ítem no cubierto → [MAYOR].
4. `study_metadata.design` ausente → [MAYOR]: solicita a research-architect su registro.

## Norma de Cierre

Solo se emite visto bueno con **0 hallazgos [CRÍTICO - Bloqueante] ABIERTOS**. Los [MAYOR] deben tener responsable y plan de cierre asignados en el log. Al reauditar, verifica que cada hallazgo RESUELTO lo está realmente (la evidencia o el dato correspondiente existe en el repositorio) antes de dar por cerrada la auditoría.
