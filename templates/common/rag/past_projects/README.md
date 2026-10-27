# rag/past_projects/ - Proyectos parecidos y memorias previas (intake)

Directorio de INTAKE de **proyectos parecidos** (otros consorcios, papers y
memorias publicadas de proyectos similares) y **memorias previas del propio
laboratorio o consorcio** (propuestas ganadas y perdidas). Es la base de
conocimiento para: estado del arte contextual, estructura de laboratorio y de
consorcio (roles, PI, capacidades, mecanismos de coordinacion) y datos de
partida ya recolectados.

## Que subir

- Memorias y propuestas del propio laboratorio/consorcio (ganadas y no
  ganadas: ambas ensenan).
- Proyectos de terceros parecidos: memorias publicadas, informes finales,
  descripciones de consorcio (lo que sea publico o legado al usuario).
- Articulos y reportes del dominio que sirvan de referencia estructural.

## Convencion de nombres

`YYYY_fuente_titulo.md|pdf` (p. ej. `2024_ue_horizon_memoria_consortium.pdf`
o `2023_laboratorio_propuesta_x.md`). MD preferido (se puede anotar y
buscar); PDF aceptable.

## Como lo usan los agentes

- **research-architect**: extrae estructura de laboratorio y de consorcio
  (entidades, roles, PI, capacidades), patrones de WPs e indicadores; los
  propone en `data/consortium.yaml`, `data/workpackages.yaml` y
  `context/hypothesis_matrix.md`. Para el estado del arte de la propuesta
  (src/01_contexto.tex y src/03_excellence.tex) apoya a lit-synthesizer
  encargandole via `new_task` la verificacion en las 4 fuentes MCP (seccion
  6 del marco academico): lo recogido aqui es contexto, no evidencia citable
  por si solo.
- **lit-synthesizer**: usa este material como pista de busqueda y lo
  convierte en evidencia verificada (`src/references.bib` +
  `context/evidence_notes.md`).
- **academic-writer**: se inspira en el estilo y la estructura de las
  memorias; los datos que cite provienen del SSOT, no de estos ficheros.

## Reglas duras (seccion 8 del marco academico)

- **Re-verificacion SSOT**: cualquier dato tomado de un proyecto previo
  (cifras, capacidades, resultados) debe re-verificarse contra el SSOT
  actual antes de usarse: NUNCA se presenta un dato viejo como actual sin
  re-verificacion; si no se puede re-verificar, `\todo{DATO PENDIENTE}`.
- **Inspiracion, no copia**: prohibido copiar texto verbatim de memorias
  ajenas (plagio). Estilo y estructura si; texto, no.
