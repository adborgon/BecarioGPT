# rag/templates/ - Memorias y estructuras de convocatorias anteriores (intake)

Directorio de INTAKE de **memorias premiadas o ganadoras de convocatorias
anteriores** y de **plantillas/estructuras de propuestas** (esquemas
institucionales, formularios de anios anteriores, guias de estilo del
organismo). Es la base para aprender la ESTRUCTURA de la convocatoria y el
ESTILO de escritura que puntua.

## Que subir

- Memorias ganadoras de convocatorias anteriores (propias o publicas).
- Formularios y esquemas de anios anteriores del mismo organismo
  (la estructura suele repetirse con pequenas variaciones).
- Guias de estilo, FAQ del organismo y evaluaciones con feedback
  (informes de evaluacion recibidos: oro para no repetir errores).

## Convencion de nombres

`YYYY_fuente_titulo.md|pdf` (p. ej. `2025_organismo_memoria_ganadora.pdf` o
`2025_organismo_formulario_esquema.md`). MD preferido; PDF aceptable.

## Como lo usan los agentes

- **research-architect**: deduce la estructura que exige el organismo
  (secciones, orden, extension) y la refleja en
  `context/convocatoria_checklist.md` y en la capitulacion de la memoria;
  extrae el estilo que puntua (tono, nivel de detalle, como justifican
  presupuesto y consorcio las memorias exitosas).
- **academic-writer**: imita el ESTILO y la ESTRUCTURA de las memorias de
  referencia; nunca su contenido literal.
- **reviewer-2**: usa los feedbacks de evaluacion anteriores como criterio
  adicional de auditoria (hallazgos recurrentes del organismo).

## Reglas duras (seccion 8 del marco academico)

- **Prohibido copiar texto verbatim** de memorias ajenas (plagio y riesgo
  legal): imitar estilo y estructura SI, texto NO. Las frases propias de la
  convocatoria se parafrasean y citan su fuente en `context/call_guidelines.md`.
- Los datos numericos de memorias anteriores (presupuestos, importes,
  dedicaciones) son referencia historica: re-verificarlos contra el SSOT
  actual antes de usarlos (data/budget.yaml, data/consortium.yaml) y nunca
  presentarlos como vigentes sin re-verificacion.
