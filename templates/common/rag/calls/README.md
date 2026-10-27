# rag/calls/ - Convocatoria vigente (intake)

Directorio de INTAKE de la convocatoria a la que se presenta la propuesta.
Todo lo que el investigador suba aqui es material primario para los agentes:
sin convocatoria leida, la checklist y la memoria no se rellenan (requisitos
inventados = prohibido).

## Que subir

- PDF o bases oficiales de la convocatoria (reglas, criterios de evaluacion
  con su PESO, formularios, limites de paginas y presupuesto).
- Anexos administrativos: plantilla de CV, modelos de cartas de compromiso,
  formularios del organismo.
- Notas propias del investigador sobre la convocatoria (p. ej. aclaraciones
  telefonicas o de la sesion informativa).

## Convencion de nombres

`YYYY_fuente_titulo.md|pdf` (p. ej. `2026_cdti_proyecto_ppc_bases.pdf` o
`2026_ministerio_sesion_informativa_notas.md`). Un fichero por documento;
sin espacios en el nombre.

## Como lo usan los agentes

- **research-architect** (dueno de este directorio): extrae requisitos,
  criterios con pesos, limites y calendario; los registra en
  `context/convocatoria_checklist.md` (una fila por requisito), en
  `context/call_guidelines.md` (resumen operativo) y deriva plazos a
  `data/workpackages.yaml` (hitos casados con el calendario real). Aqui
  documentar tambien las cadenas de busqueda que encargue (ver seccion 6
  del marco academico:
  la busqueda de literatura la ejecuta lit-synthesizer).
- **reviewer-2** (peer-audit A7): audita que cada requisito PENDIENTE de la
  checklist este cubierto antes del visto bueno.
- **academic-orchestrator**: no edita aqui; consulta las rutas al planificar
  el bucle WP-driven.

## Reglas

- Solo material REAL: nada de requisitos recordados de memoria. Si un dato
  de la convocatoria falta, se escala (D1 en `context/escalation_queue.md`)
  en lugar de suponerlo.
- Si el material es una URL, guardarla con fecha de acceso
  (`context/call_guidelines.md`) o descargarla aqui.
