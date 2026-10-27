# Checklist de la convocatoria (SSOT del tipo grant)

> La estructura de una propuesta la DICTA LA CONVOCATORIA, no una plantilla
> academica generica. Esta checklist es la SSOT de requisitos: la rellena
> research-architect leyendo las bases depositadas en rag/calls/ (una fila
> por requisito, con el peso que le de el evaluador) y la verifica
> reviewer-2 (peer-audit A7): todo requisito PENDIENTE es un hallazgo
> [MAYOR] y bloquea el visto bueno. NO hay checklist EQUATOR en grant
> (ver .roo/skills/methods-reporting/SKILL.md).
> Convencion: Estado = PENDIENTE (aun no abordado) / CUBIERTO (abordado en
> src/ y verificado). Las filas iniciales son una estructura orientativa
> tipica de convocatorias: AJUSTARLAS a los requisitos EXACTOS de la
> convocatoria leida (no inventar requisitos ni pesos).

## Origen de la convocatoria

- Convocatoria: TODO (nombre y organismo)
- Fuentes: rag/calls/ (PDF/bases subidos por el investigador; convencion de
  nombres en rag/calls/README.md)
- Fecha de consulta: TODO (AAAA-MM-DD)
- Fecha limite de envio: TODO (AAAA-MM-DD)

## Checklist

| ID | Requisito | Seccion donde se aborda | Peso | Estado |
|----|-----------|-------------------------|------|--------|
| R1 | Resumen ejecutivo dentro del limite de la convocatoria | src/00_resumen.tex | TODO | PENDIENTE |
| R2 | Contexto y estado del arte con referencias verificadas | src/01_contexto.tex | TODO | PENDIENTE |
| R3 | Objetivos explicitos y medibles (O1..On) | src/02_objetivos.tex | TODO | PENDIENTE |
| R4 | Excelencia e innovacion frente al estado del arte | src/03_excellence.tex | TODO | PENDIENTE |
| R5 | Impacto, explotacion y divulgacion con KPI | src/04_impact.tex | TODO | PENDIENTE |
| R6 | Plan de trabajo: WPs, entregables, hitos y Gantt | src/05_wps.tex | TODO | PENDIENTE |
| R7 | Composicion y capacidades del consorcio (PPC) | src/06_consortium.tex | TODO | PENDIENTE |
| R8 | Presupuesto justificado y dentro de los maximos | src/07_budget.tex | TODO | PENDIENTE |
| R9 | Riesgos, etica y seguridad cubiertos | src/08_risks.tex | TODO | PENDIENTE |
| R10 | Aportacion propia del socio privado (si las bases la exigen) | src/07_budget.tex | TODO | PENDIENTE |
| R11 | Formato: limite de paginas, plantilla institucional y anexos | TODO | TODO | PENDIENTE |
| R12 | Requisitos administrativos del formulario (CVs, cartas de compromiso) | TODO | TODO | PENDIENTE |

## Reglas

- Un requisito SOLO pasa a CUBIERTO cuando la seccion indicada existe y
  contiene lo que las bases exigen; reviewer-2 lo verifica antes del visto
  bueno (peer-audit A7).
- Ningun requisito de la convocatoria se inventa: si las bases no se han
  leido/subido a rag/calls/, las filas quedan PENDIENTE y se escala (D1 en
  context/escalation_queue.md) pidiendolas al investigador.
- Los datos que alimentan las secciones (presupuesto, consorcio, plan)
  provienen de data/budget.yaml, data/consortium.yaml y
  data/workpackages.yaml (SSOT): la checklist audita cobertura, no datos.
