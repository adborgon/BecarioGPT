---
name: prisma-synthesis
description: Activa esta skill para conducir o auditar revisiones de literatura. Implementa el flujo PRISMA 2020 completo (protocolo, búsqueda, screening, extracción, riesgo de sesgo, síntesis con GRADE y checklist de 27 ítems) para revisiones sistemáticas, y conserva el patrón CCLG como variante para revisiones narrativas del Estado del Arte.
modeSlugs:
  - lit-synthesizer
  - research-architect
---

# PRISMA Synthesis

## Reparto de Responsabilidades

| Fase | Responsable | Registro de salida |
|------|-------------|--------------------|
| F0 Protocolo, F1 Búsqueda | research-architect | `rag/calls/` y `data/stats_summary.json` (`study_metadata.preregistration_url`) |
| F2 Screening, F3 Extracción, F4 Riesgo de sesgo, F5 Síntesis | lit-synthesizer | `context/evidence_notes.md` y `src/references.bib` |
| Redacción de secciones en `src/` | academic-writer | Secciones LaTeX a partir de los números ya registrados |

Regla transversal: ningún número (recuentos del diagrama de flujo, tamaños de efecto, $I^2$) puede aparecer en `src/` sin estar registrado previamente en `context/evidence_notes.md` o `data/stats_summary.json` (ver `.roo/rules/rules.md`).

## Flujo PRISMA 2020 (revisiones sistemáticas)

### F0 — Protocolo
1. Define la pregunta de revisión con un marco estructurado: PICO (efectividad de intervenciones), PICo (preguntas cualitativas) o SPIDER (diseños mixtos y ciencias sociales aplicadas).
2. Registra el protocolo **antes** de ejecutar la búsqueda: PROSPERO para revisiones de efectividad u OSF para el resto de dominios. Justifica la elección si no aplica ninguno de los dos.
3. Solicita a research-architect que registre la URL del protocolo en `data/stats_summary.json` (`study_metadata.preregistration_url`). Si aún no constan, inserta en `src/` el marcador `\todo{DATO PENDIENTE: preregistration_url}`.

### F1 — Búsqueda
1. Selecciona las bases según el dominio: PubMed (biomedicina), Scopus y Web of Science (multidisciplinares), IEEE Xplore y ACM DL (computación e ingeniería), PsycINFO (psicología). Justifica cada inclusión o exclusión.
2. Documenta la estrategia completa: cadenas booleanas, campos consultados (título/resumen/keywords), filtros aplicados y rango de fechas.
3. Registra la estrategia (bases, cadenas, fecha de ejecución, resultados crudos por base) en `rag/calls/` a cargo de research-architect **antes de ejecutar ninguna búsqueda**. Las búsquedas no documentadas no son utilizables en la revisión.

### F2 — Screening
1. Deduplicación entre bases; registra el número de duplicados eliminados.
2. Cribado por título y resumen contra los criterios de inclusión/exclusión predefinidos en el protocolo (F0). Después, cribado a texto completo.
3. Registra en cada etapa el recuento: identificados, duplicados eliminados, excluidos (con motivo) e incluidos.
4. El diagrama de flujo PRISMA se materializa como tabla LaTeX en `src/`: la redacta academic-writer exclusivamente a partir de los números registrados en `context/evidence_notes.md`; está prohibido inventar o ajustar recuentos.

### F3 — Extracción
1. Construye una hoja de extracción estructurada con variables predefinidas alineadas con las columnas de `context/hypothesis_matrix.md` (población, intervención/comparador, diseño, métricas, $N$, resultados).
2. Guarda cada extracto en `rag/` y, como mínimo, en `context/evidence_notes.md`, con su citekey correspondiente en `src/references.bib`.

### F4 — Riesgo de sesgo
1. Ensayos aleatorizados → RoB 2. Estudios observacionales → ROBINS-I. Otros diseños → herramienta equivalente específica, declarada y justificada.
2. Evalúa estudio por estudio: dominios evaluados y veredicto global (bajo / algunas preocupaciones / alto riesgo). Registra la evaluación en `context/evidence_notes.md`.

### F5 — Síntesis
1. Elige síntesis narrativa estructurada (agrupación temática con contraste empírico) o meta-análisis cuantitativo, según la homogeneidad de los estudios incluidos.
2. Para meta-análisis: tamaño de efecto con IC 95%, heterogeneidad ($I^2$) y justificación del modelo de efectos fijos o aleatorios. Todo número procede del análisis registrado; si falta un cálculo, inserta `\todo{DATO PENDIENTE: [métrica]}`.
3. Evalúa la certeza de la evidencia por resultado con GRADE (downgrading/upgrading documentado).
4. Los resultados se registran en `context/evidence_notes.md`; las referencias, en `src/references.bib`.

### F6 — Checklist PRISMA 2020 (27 ítems)
1. Recorre los 27 ítems de la checklist PRISMA 2020 antes de dar por cerrada la síntesis.
2. Verifica que cada estudio incluido tiene evidencia registrada en `context/evidence_notes.md`. Un estudio incluido sin registro genera en `src/` el marcador `\todo{CITA REQUERIDA: [descripción de la evidencia necesaria]}` y no puede usarse en la redacción hasta cerrarlo.
3. Documenta el resultado de la checklist en `context/evidence_notes.md`.

## Variante: Revisión Narrativa (NO sistemática)

Si el encargo es el Estado del Arte o la Introducción de un artículo (no una revisión sistemática), no apliques el flujo completo. Aplica la siguiente estructura narrativa, que sigue siendo obligatoria:

### Paso 1: Lectura y Agrupación Taxonómica
1. Lee `context/hypothesis_matrix.md` para identificar el hueco de investigación (*research gap*) y los objetivos del estudio.
2. Lee `context/evidence_notes.md` y verifica qué claves existen en `src/references.bib`.
3. No redactes una lista cronológica o secuencial de artículos individuales ("Autor A hizo X; Autor B hizo Y"). Agrupa las referencias en **2 a 4 corrientes temáticas o tecnológicas** (ej. sistemas basados en sensores ópticos vs. sistemas inerciales; enfoques estáticos vs. adaptativos).

### Paso 2: Estructura del Párrafo Comparativo (patrón CCLG)
Cada subsección o bloque temático del Estado del Arte debe seguir el patrón **CCLG**:
1. **Consenso / Tendencia:** Qué enfoque predomina en la literatura agrupando múltiples citas `\cite{clave1, clave2}`.
2. **Contraste Empírico:** Qué resultados cuantitativos, muestras o alcances lograron esos trabajos (usando solo datos registrados en `evidence_notes.md`).
3. **Limitación Metodológica o Técnica:** Dónde fallan esos trabajos (muestras pequeñas, falta de validación ecológica, alta latencia, ausencia de personalización).
4. **Gap (Conexión):** Cómo esa limitación justifica directamente uno de los objetivos (`O1`, `O2`...) de nuestro trabajo.

### Paso 3: Cierre de la Introducción
El último párrafo de la sección debe:
1. Enunciar explícitamente el objetivo principal del trabajo sin adelantar resultados ni conclusiones.
2. Enumerar las contribuciones principales o hipótesis de forma directa y trazable con `context/hypothesis_matrix.md`.
