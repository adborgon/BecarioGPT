# Checklist PRISMA 2020 (27 items) (SSOT)

> Referencia del estandar: PRISMA 2020 statement (Page MJ et al., 2021;
> https://www.prisma-statement.org/). Recorrer los 27 items antes de dar por
> cerrada la sintesis (prisma-synthesis F6). La columna "Ubicacion en src/"
> se rellena con la seccion/subseccion donde se reporta cada item.

## Hoja de extraccion (data/extraction_sheet.csv)

- La extraccion estructurada se realiza en `data/extraction_sheet.csv`.
- Columnas: study_id, citekey, author_year, population, intervention,
  comparator, study_design, n_total, metrics_outcomes, effect_estimate,
  risk_of_bias_tool, risk_of_bias_judgement, notes.
- Cada fila debe tener su citekey registrada en `src/references.bib` y su
  extracto en `context/evidence_notes.md` (prisma-synthesis F3).

## Checklist

| # | Seccion | Item PRISMA 2020 | Ubicacion en src/ | Estado |
|---|---------|------------------|-------------------|--------|
| 1 | TITLE | Title | TODO | PENDIENTE |
| 2 | ABSTRACT | Abstract | TODO | PENDIENTE |
| 3 | INTRODUCTION | Rationale | TODO | PENDIENTE |
| 4 | INTRODUCTION | Objectives | TODO | PENDIENTE |
| 5 | METHODS | Eligibility criteria | TODO | PENDIENTE |
| 6 | METHODS | Information sources | TODO | PENDIENTE |
| 7 | METHODS | Search strategy | TODO | PENDIENTE |
| 8 | METHODS | Selection process | TODO | PENDIENTE |
| 9 | METHODS | Data collection process | TODO | PENDIENTE |
| 10 | METHODS | Data items | TODO | PENDIENTE |
| 11 | METHODS | Study risk of bias assessment | TODO | PENDIENTE |
| 12 | METHODS | Effect measures | TODO | PENDIENTE |
| 13 | METHODS | Synthesis methods | TODO | PENDIENTE |
| 14 | METHODS | Reporting bias assessment | TODO | PENDIENTE |
| 15 | METHODS | Certainty assessment | TODO | PENDIENTE |
| 16 | RESULTS | Study selection | TODO | PENDIENTE |
| 17 | RESULTS | Study characteristics | TODO | PENDIENTE |
| 18 | RESULTS | Risk of bias in studies | TODO | PENDIENTE |
| 19 | RESULTS | Results of individual studies | TODO | PENDIENTE |
| 20 | RESULTS | Synthesis of results | TODO | PENDIENTE |
| 21 | RESULTS | Reporting biases | TODO | PENDIENTE |
| 22 | RESULTS | Certainty of evidence | TODO | PENDIENTE |
| 23 | DISCUSSION | Discussion | TODO | PENDIENTE |
| 24 | OTHER INFORMATION | Registration and protocol | TODO | PENDIENTE |
| 25 | OTHER INFORMATION | Support | TODO | PENDIENTE |
| 26 | OTHER INFORMATION | Competing interests | TODO | PENDIENTE |
| 27 | OTHER INFORMATION | Availability of data, code and other materials | TODO | PENDIENTE |

## Reglas

- Los recuentos del diagrama de flujo (item 16) se rellenan SOLO desde los
  numeros registrados en `context/evidence_notes.md` y `rag/calls/`;
  esta prohibido inventarlos o ajustarlos (prisma-synthesis F2).
- Los items no cubiertos se registran como hallazgos en
  `reviews/peer_review_log.md` (ver peer-audit A6).
