#!/usr/bin/env bash
# ==============================================================================
# init_paper.sh
# Generador de la estructura inicial de proyectos de papers academicos
# (LaTeX + workflow de investigacion con agentes Roo).
#
# Uso:
#   bash init_paper.sh <nombre-proyecto> [--force]
#
# Comportamiento clave:
#   - Requiere bash real (Git Bash / WSL). NO compatible con sh/dash/cmd.exe.
#   - Copia INTEGRO el marco academico del repo (.roo/rules/rules.md) al
#     proyecto como .roo/rules/00_academic_core.md; ademas copia .roomodes y
#     las skills (.roo/skills). El heredoc embebido es solo respaldo.
#   - Idempotente: con --force crea solo lo que falta y NUNCA sobrescribe
#     ficheros existentes no vacios (protege los SSOT ya editados).
#   - Sin argumentos, con -h/--help o con rutas invalidas: usage y exit 1
#     (nunca usa '.' como proyecto por defecto).
#   - Mensajes de consola en ASCII puro (compatibilidad cmd/cp1252).
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# [1] Utilidades: mensajeria ASCII, usage y helpers de copia/escritura
# ------------------------------------------------------------------------------
msg_ok()   { printf '[OK]    %s\n' "$*"; }
msg_warn() { printf '[WARN]  %s\n' "$*"; }
msg_err()  { printf '[ERROR] %s\n' "$*" >&2; }

usage() {
    cat <<'USAGE_EOF'
init_paper.sh - Generador de estructura para proyectos de papers academicos.

Uso:
  bash init_paper.sh <nombre-proyecto> [--force]

Argumentos:
  <nombre-proyecto>  Ruta del directorio a crear (relativa o absoluta).
                     No puede empezar por '-' ni contener '..'.
  --force            Re-ejecuta sobre un proyecto existente: crea solo lo
                     que falta y NUNCA sobrescribe ficheros no vacios.
  -h, --help         Muestra esta ayuda y termina con codigo 1.

Ejemplos:
  bash init_paper.sh mi-paper
  bash init_paper.sh papers/mi-paper
  bash init_paper.sh mi-paper --force
USAGE_EOF
}

# Copia un arbol de ficheros sin sobrescribir destinos existentes no vacios
# (equivalente explicito a 'cp -n', sin depender de la variante de cp).
copy_tree_noclobber() {
    _src_root="$1"
    _dst_root="$2"
    find "$_src_root" -type f | while IFS= read -r _src_file; do
        _rel_path=${_src_file#"$_src_root"/}
        _dst_file="$_dst_root/$_rel_path"
        if [ -s "$_dst_file" ]; then
            continue
        fi
        mkdir -p "$(dirname "$_dst_file")"
        cp "$_src_file" "$_dst_file"
    done
}

# Escribe una plantilla en "_path" SOLO si no existe o esta vacio.
# El contenido llega por stdin (heredoc en el punto de llamada).
write_template() {
    _path="$1"
    if [ -s "$_path" ]; then
        msg_warn "Se omite $_path (ya existe y no esta vacio)."
        return 0
    fi
    cat > "$_path"
    msg_ok "Creado $_path"
}

# ------------------------------------------------------------------------------
# [2] Parseo y validacion de argumentos
# ------------------------------------------------------------------------------
FORCE=0
PROJECT_DIR=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        --force)
            FORCE=1
            shift
            ;;
        -h|--help)
            usage
            exit 1
            ;;
        -*)
            msg_err "Argumento no reconocido o ruta invalida: '$1'"
            msg_err "Las rutas no pueden empezar por '-'. Uso correcto:"
            usage
            exit 1
            ;;
        *..*)
            msg_err "Ruta invalida: '$1' (no puede contener '..')"
            exit 1
            ;;
        *)
            if [ -n "$PROJECT_DIR" ]; then
                msg_err "Se recibieron dos proyectos ('$PROJECT_DIR' y '$1'): solo se permite uno."
                exit 1
            fi
            PROJECT_DIR="$1"
            shift
            ;;
    esac
done

if [ -z "$PROJECT_DIR" ]; then
    msg_err "Falta el nombre del proyecto."
    echo
    usage
    exit 1
fi

# ------------------------------------------------------------------------------
# [3] Localizacion de la raiz del repo (fuente de las copias integras)
# ------------------------------------------------------------------------------
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# ------------------------------------------------------------------------------
# [4] Validacion del directorio destino (abortar si existe y no esta vacio,
#     salvo --force)
# ------------------------------------------------------------------------------
if [ -e "$PROJECT_DIR" ] && [ ! -d "$PROJECT_DIR" ]; then
    msg_err "'$PROJECT_DIR' existe pero no es un directorio."
    exit 1
fi

if [ -n "$(ls -A "$PROJECT_DIR" 2>/dev/null)" ]; then
    if [ "$FORCE" -eq 1 ]; then
        msg_warn "'$PROJECT_DIR' ya existe: modo --force activo (solo se anadira lo que falte)."
    else
        msg_err "El directorio '$PROJECT_DIR' ya existe y no esta vacio."
        msg_err "Re-ejecuta con --force para completar la estructura sin sobrescribir nada."
        exit 1
    fi
fi

# ------------------------------------------------------------------------------
# [5] Creacion de la estructura de directorios (mkdir -p con rutas citadas;
#     sin brace expansion, incompatible con sh/dash)
# ------------------------------------------------------------------------------
msg_ok "Creando estructura de directorios en $PROJECT_DIR ..."
mkdir -p \
    "$PROJECT_DIR/.roo/rules" \
    "$PROJECT_DIR/.roo/skills" \
    "$PROJECT_DIR/context" \
    "$PROJECT_DIR/data" \
    "$PROJECT_DIR/src/figures" \
    "$PROJECT_DIR/reviews" \
    "$PROJECT_DIR/rag/calls" \
    "$PROJECT_DIR/rag/past_projects" \
    "$PROJECT_DIR/rag/templates"

# ------------------------------------------------------------------------------
# [6] Copia INTEGRA del marco academico y de los agentes desde el repo
#     (con guardas de no-sobrescritura para el modo --force)
# ------------------------------------------------------------------------------

# [6.1] .roomodes: definicion de los modos Roo del proyecto
if [ -f "$SCRIPT_DIR/.roomodes" ]; then
    if [ -s "$PROJECT_DIR/.roomodes" ]; then
        msg_warn "Se omite .roomodes (ya existe y no esta vacio)."
    else
        cp "$SCRIPT_DIR/.roomodes" "$PROJECT_DIR/.roomodes"
        msg_ok "Copiado .roomodes al proyecto."
    fi
else
    msg_warn ".roomodes no encontrado en $SCRIPT_DIR: el proyecto no tendra modos Roo."
fi

# [6.2] Skills de agentes (.roo/skills del repo -> proyecto)
if [ -d "$SCRIPT_DIR/.roo/skills" ]; then
    if [ "$FORCE" -eq 1 ]; then
        copy_tree_noclobber "$SCRIPT_DIR/.roo/skills" "$PROJECT_DIR/.roo/skills"
    else
        cp -r "$SCRIPT_DIR/.roo/skills/." "$PROJECT_DIR/.roo/skills/"
    fi
    msg_ok "Skills de agentes copiadas a .roo/skills/."
else
    msg_warn ".roo/skills no encontrado en $SCRIPT_DIR: el proyecto no tendra skills."
fi

# [6.3] Marco academico integro: se copia el fichero completo del repo
#       (no una version reducida); el heredoc embebido es solo respaldo.
RULE_SRC="$SCRIPT_DIR/.roo/rules/rules.md"
RULE_DST="$PROJECT_DIR/.roo/rules/00_academic_core.md"
if [ -f "$RULE_SRC" ]; then
    if [ -s "$RULE_DST" ]; then
        msg_warn "Se omite .roo/rules/00_academic_core.md (ya existe y no esta vacio)."
    else
        cp "$RULE_SRC" "$RULE_DST"
        msg_ok "Marco academico integro copiado a .roo/rules/00_academic_core.md."
    fi
else
    msg_warn "$RULE_SRC no encontrado en el repo: se usa el marco embebido de respaldo."
    if [ -s "$RULE_DST" ]; then
        msg_warn "Se omite .roo/rules/00_academic_core.md (ya existe y no esta vacio)."
    else
        cat > "$RULE_DST" <<'ACADEMIC_CORE_EOF'
# REGLAS GLOBALES DE RIGOR CIENTIFICO Y ACADEMICO

Actuas dentro de un entorno de investigacion cientifica e ingenieria. Todas tus respuestas y ediciones de archivos deben cumplir estrictamente estas directivas:

## 1. Integridad Bibliografica (Tolerancia Cero a la Alucinacion)
- NUNCA inventes una referencia bibliografica, autor, ano, DOI o clave BibTeX.
- Solo puedes insertar comandos `\cite{clave}` o citas en formato Markdown `[@clave]` si la clave existe previamente en `src/references.bib` o esta documentada explicitamente en `context/evidence_notes.md`.
- Si una afirmacion requiere respaldo bibliografico y no existe la cita en el repositorio, inserta obligatoriamente el marcador: `\todo{CITA REQUERIDA: [breve descripcion de que evidencia se necesita]}`.

## 2. Fidelidad de Datos y Estadistica
- NUNCA inventes tamanos muestrales ($N$), medias, desviaciones tipicas, $p$-valores, tamanos del efecto ($\eta^2$, $d$ de Cohen) ni metricas de rendimiento.
- Todo dato numerico reportado en `src/` debe provenir exactamente de `data/stats_summary.json` o `context/hypothesis_matrix.md`.
- Si un dato aun no ha sido calculado, utiliza el marcador `\todo{DATO PENDIENTE: [nombre de la metrica]}`.

## 3. Tono y Estilo Linguistico (Anti-Fluff)
- Manten un estilo academico sobrio, preciso, objetivo y directo (tanto en ingles como en castellano).
- PROHIBIDO usar vocabulario promocional o muletillas tipicas de modelos de lenguaje:
  - En ingles: evita *delve into, testament, tapestry, crucial, paramount, groundbreaking, revolutionize, realm, beacon, underscore*.
  - En castellano: evita *en el vertiginoso mundo actual, revolucionario, sin precedentes, resulta crucial destacar, un tapiz de, piedra angular, paradigma disruptivo*.
- Prioriza verbos de accion tecnica y cientifica: *evaluar, cuantificar, validar, parametrizar, contrastar, observar, implementar*.
- Una idea principal por oracion. Evita subordinadas excesivamente largas.

## 4. Trazabilidad y Fuente Unica de Verdad (SSOT)
- Antes de redactar o modificar cualquier seccion en `src/`, verifica que este alineada con los objetivos e hipotesis definidos en `context/hypothesis_matrix.md`.
- Respeta estrictamente los permisos de tu Modo activo. No edites archivos fuera de tu ambito de responsabilidad.

## 5. Ciclo de cierre de deuda academica
- `\todo{CITA REQUERIDA}`: lo cierra lit-synthesizer, registrando la evidencia (con DOI o URL y fecha de acceso) en `context/evidence_notes.md` y la entrada BibTeX verificada en `src/references.bib`; academic-writer sustituye el marcador por `\cite{clave}`.
- `\todo{DATO PENDIENTE}`: lo cierra research-architect, unicamente cuando el dato ya este presente en `data/stats_summary.json` o `context/hypothesis_matrix.md`; academic-writer sustituye el marcador por el valor registrado.
- reviewer-2 verifica los marcadores abiertos de `src/` con grep antes de dar el visto bueno y los registra en `reviews/peer_review_log.md` con su severidad.
- PROHIBIDO eliminar un marcador `\todo{}` sin resolverlo realmente: cerrarlo exige que la evidencia o el dato correspondiente este en el repositorio.
ACADEMIC_CORE_EOF
        msg_ok "Marco academico embebido escrito en .roo/rules/00_academic_core.md."
    fi
fi

# ------------------------------------------------------------------------------
# [7] Plantillas de ficheros del proyecto (idempotentes via write_template)
# ------------------------------------------------------------------------------

# [7.1] Directrices de la convocatoria
write_template "$PROJECT_DIR/context/call_guidelines.md" <<'GUIDELINES_EOF'
# Directrices de la Convocatoria (SSOT)

> Fuente de verdad de los requisitos de la revista o convocatoria objetivo.
> Rellenar ANTES de planificar secciones o experimentos.

## Revista / Convocatoria

- **Nombre:** TODO
- **Tipo de contribucion:** TODO (articulo original | revision sistematica | short paper)
- **URL de la convocatoria:** TODO
- **Fecha de consulta de la convocatoria:** TODO (AAAA-MM-DD)

## Alcance y tematicas

- TODO: tematicas de la convocatoria relevantes para este paper.

## Criterios de evaluacion

- TODO: criterios declarados (novelacion, rigor metodologico, reproducibilidad, ...).

## Limites de formato

| Concepto          | Limite |
|-------------------|--------|
| Palabras (cuerpo) | TODO   |
| Figuras           | TODO   |
| Tablas            | TODO   |
| Referencias       | TODO   |

## Fechas clave

| Hito                  | Fecha |
|-----------------------|-------|
| Deadline de envio     | TODO  |
| Notificacion estimada | TODO  |

## Notas adicionales

- TODO: plantilla obligatoria, doble columna, anonimizado, limites de anexos, etc.
GUIDELINES_EOF

# [7.2] Matriz de objetivos e hipotesis
write_template "$PROJECT_DIR/context/hypothesis_matrix.md" <<'MATRIX_EOF'
# Matriz de Objetivos e Hipotesis (SSOT)

> Fuente de verdad de objetivos, hipotesis, diseno y estado de validacion.
> Todo dato reportado en src/ debe trazarse a una fila de esta matriz.
> Estados validos de la columna Estado: definida | validada | reportada.

## Matriz

| ID | Objetivo | Hipotesis | Variables | Metricas / Variables de salida | Diseno | Estado | Resultado |
|----|----------|-----------|-----------|--------------------------------|--------|--------|-----------|
| O1 | TODO: objetivo principal | H1: TODO: hipotesis contrastable | TODO: variables independientes y dependientes | TODO: metricas cuantitativas | TODO: diseno experimental | definida | TODO: pendiente de validacion |

## Changelog

| Fecha      | Cambio                        | Autor |
|------------|-------------------------------|-------|
| AAAA-MM-DD | Creacion de la matriz inicial | TODO  |
MATRIX_EOF

# [7.3] Registro de evidencia
write_template "$PROJECT_DIR/context/evidence_notes.md" <<'EVIDENCE_EOF'
# Registro de Evidencia

> Notas de lectura por fuente. Solo se permiten claves cite que existan aqui
> o en src/references.bib (seccion 1 del marco academico).

## Reglas de uso

- Un bloque por fuente; no mezclar fuentes en un mismo registro.
- Ningun campo obligatorio puede quedar vacio para poder citar la fuente.
- Toda cifra copiada debe indicar su origen (tabla, figura o pagina).

## Plantilla (duplicar por cada fuente)

```
- **citekey:** TODO (clave BibTeX)
- **Titulo / Autor / Ano:** TODO
- **DOI o URL + fecha de acceso:** TODO (https://doi.org/... ; consultado AAAA-MM-DD)
- **Metodologia:** TODO (diseno, muestra, instrumentos)
- **Resultados clave:** TODO (valores exactos; nunca de memoria)
- **Limitaciones:** TODO
```
EVIDENCE_EOF

# [7.4] Resumen estadistico (JSON valido desde el primer momento)
write_template "$PROJECT_DIR/data/stats_summary.json" <<'STATS_EOF'
{
  "study_metadata": {
    "design": "TODO (p. ej., ensayo controlado aleatorizado, estudio transversal)",
    "n": null,
    "preregistration_url": "TODO (URL de preregistro)"
  },
  "variables": [],
  "notes": "Introducir en 'variables' solo datos ya calculados. Ejemplo de entrada: {\"id\": \"H1\", \"name\": \"TODO\", \"n\": null, \"mean\": null, \"sd\": null, \"p_value\": null, \"effect_size\": null}"
}
STATS_EOF

# [7.5] Paquetes de trabajo (YAML valido desde el primer momento)
write_template "$PROJECT_DIR/data/workpackages.yaml" <<'WORKPACKAGES_EOF'
# workpackages.yaml - Plan de trabajo del proyecto (SSOT).
# El modo grant-workpackages edita este fichero.

workpackages:
  - id: WP1
    title: "TODO: titulo del paquete de trabajo"
    objectives:
      - "TODO: objetivo 1 del WP1"
    deliverables:
      - "TODO: entregable 1 del WP1"
    milestones:
      - "TODO: hito 1 del WP1 (fecha AAAA-MM-DD)"
    effort_pm: 0.0
    risks:
      - "TODO: riesgo 1 y su mitigacion"
WORKPACKAGES_EOF

# [7.6] Documento raiz LaTeX (esqueleto compilable, IMRaD)
write_template "$PROJECT_DIR/src/main.tex" <<'MAIN_TEX_EOF'
% main.tex - Documento raiz del paper (IMRaD). Compilar con pdflatex + bibtex.
% El orden de secciones esta fijado por la numeracion de src/ (01..04).
\documentclass[11pt]{article}

\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage[margin=2.5cm]{geometry}
\usepackage{booktabs}
\usepackage{hyperref}

\title{TODO: titulo del paper}
\author{TODO: autor/es}
\date{TODO: fecha}

\begin{document}

\maketitle

\begin{abstract}
TODO: resumen de 150--250 palabras.
\end{abstract}

\input{src/01_introduction}
\input{src/02_methodology}
\input{src/03_results}
\input{src/04_discussion}

\bibliographystyle{plain}
\bibliography{src/references}

\end{document}
MAIN_TEX_EOF

# [7.7] Secciones LaTeX IMRaD (una seccion minima por fichero)
write_template "$PROJECT_DIR/src/01_introduction.tex" <<'INTRO_EOF'
% 01_introduction.tex - Seccion de introduccion.
\section{Introduction}
% TODO: motivacion, hueco de conocimiento (gap) y objetivos del estudio.
% Alinear cada objetivo con una fila de context/hypothesis_matrix.md.
INTRO_EOF

write_template "$PROJECT_DIR/src/02_methodology.tex" <<'METHODOLOGY_EOF'
% 02_methodology.tex - Seccion de metodologia.
\section{Methodology}
% TODO: diseno, participantes/muestra, instrumentos, procedimiento y analisis.
% El tamano muestral N debe provenir de data/stats_summary.json.
METHODOLOGY_EOF

write_template "$PROJECT_DIR/src/03_results.tex" <<'RESULTS_EOF'
% 03_results.tex - Seccion de resultados.
\section{Results}
% TODO: resultados ordenados segun las hipotesis de context/hypothesis_matrix.md.
% Todo valor numerico debe provenir de data/stats_summary.json.
RESULTS_EOF

write_template "$PROJECT_DIR/src/04_discussion.tex" <<'DISCUSSION_EOF'
% 04_discussion.tex - Seccion de discusion.
\section{Discussion}
% TODO: interpretacion, limitaciones y trabajo futuro.
DISCUSSION_EOF

# [7.8] Bibliografia (solo la edita lit-synthesizer)
write_template "$PROJECT_DIR/src/references.bib" <<'REFERENCES_EOF'
% references.bib - UNICA fuente de verdad bibliografica del proyecto.
% Flujo: solo el modo lit-synthesizer edita este fichero. Los demas modos
% insertan \cite{clave} y solicitan el alta de referencias. Toda entrada
% debe estar documentada en context/evidence_notes.md antes de citarse.

% ======================= EJEMPLO-PLANTILLA: NO CITAR =========================
% Entrada de ejemplo para ilustrar el formato. SUSTITUIRLA por referencias
% reales verificadas; nunca citar esta clave.
@article{ejemplo_plantilla_borrar,
  author  = {Autor, Ejemplo},
  title   = {Titulo de ejemplo: sustituir por una referencia real},
  journal = {Revista de Ejemplo},
  year    = {2024},
  volume  = {1},
  number  = {1},
  pages   = {1--10},
  doi     = {10.0000/ejemplo.2024}
}
% ===================== FIN EJEMPLO-PLANTILLA: NO CITAR =======================
REFERENCES_EOF

# [7.9] Log de peer review (formato del modo reviewer-2)
write_template "$PROJECT_DIR/reviews/peer_review_log.md" <<'REVIEW_LOG_EOF'
# Log de Auditoria Academica (reviewer-2)

> Registro de hallazgos de la revision. Las severidades estan definidas en
> el modo reviewer-2 (ver .roomodes).

## Leyenda de severidades

- `CRITICO - Bloqueante`: invalida el envio; debe resolverse antes de enviar.
- `MAYOR`: afecta a la solidez o a la interpretabilidad; requiere accion.
- `MENOR`: estilo, redaccion o formato; no bloquea.

## Registro

| ID | Severidad | Fichero:Linea | Descripcion | Estado | Responsable | Fecha |
|----|-----------|---------------|-------------|--------|-------------|-------|
| R1 | MENOR | TODO | Plantilla inicial: sustituir esta fila por hallazgos reales. | ABIERTO | TODO | AAAA-MM-DD |
REVIEW_LOG_EOF

# [7.10] Gitignore (LaTeX + Python + R)
write_template "$PROJECT_DIR/.gitignore" <<'GITIGNORE_EOF'
# --- LaTeX ---
build/
*.aux
*.log
*.out
*.synctex.gz
*.bbl
*.blg
*.fls
*.fdb_latexmk
*.toc
*.lof
*.lot

# --- Python ---
__pycache__/
*.pyc

# --- R ---
.Rhistory
*.Rproj

# --- Sistema ---
Thumbs.db
.DS_Store
GITIGNORE_EOF

# ------------------------------------------------------------------------------
# [8] Post-condicion: los ficheros clave deben existir antes de dar exito
# ------------------------------------------------------------------------------
POSTCHECK_FAIL=0
for _key_file in \
    "$PROJECT_DIR/src/main.tex" \
    "$PROJECT_DIR/.roo/rules/00_academic_core.md" \
    "$PROJECT_DIR/context/hypothesis_matrix.md" \
    "$PROJECT_DIR/data/stats_summary.json" \
    "$PROJECT_DIR/reviews/peer_review_log.md"
do
    if [ ! -f "$_key_file" ]; then
        msg_err "Post-condicion incumplida: no existe $_key_file"
        POSTCHECK_FAIL=1
    fi
done
if [ "$POSTCHECK_FAIL" -ne 0 ]; then
    msg_err "La generacion no se completo correctamente; revisa los errores anteriores."
    exit 1
fi

# ------------------------------------------------------------------------------
# [9] Exito
# ------------------------------------------------------------------------------
msg_ok "Estructura academica generada en '$PROJECT_DIR'."
msg_ok "Siguiente paso: rellenar context/call_guidelines.md y context/hypothesis_matrix.md (marcadores TODO)."
exit 0
