#!/usr/bin/env bash
# ==============================================================================
# init_paper.sh
# Generador de la estructura inicial de proyectos de papers academicos
# (LaTeX + workflow de investigacion con agentes Roo).
#
# Uso:
#   bash init_paper.sh <nombre-proyecto> [--type <tipo>] [--force]
#
# Comportamiento clave:
#   - Requiere bash real (Git Bash / WSL). NO compatible con sh/dash/cmd.exe.
#   - Estructura por TIPO de proyecto (--type): las plantillas viven en el
#     directorio templates/ del repo. templates/common/ contiene los SSOT
#     compartidos por todos los tipos; templates/<tipo>/ contiene el esqueleto
#     LaTeX y los artefactos propios del tipo. El catalogo NO esta hard-codeado:
#     se descubre de los subdirectorios de templates/ (excluido common/).
#     Tipo por defecto: imrad (retrocompatible con la version anterior).
#   - Copia INTEGRO el marco academico del repo (.roo/rules/rules.md) al
#     proyecto como .roo/rules/00_academic_core.md; ademas copia .roomodes,
#     las skills (.roo/skills) y la configuracion MCP trackeada
#     (templates/common/mcp.json -> .roo/mcp.json). Sin heredoc de respaldo:
#     si falta rules.md y hay que generarlo, el scaffold aborta con [ERROR]
#     (fail-fast).
#   - Idempotente: con --force crea solo lo que falta y NUNCA sobrescribe
#     ficheros existentes no vacios (protege los SSOT ya editados).
#   - Post-condicion parametrizada: verifica TODAS las rutas listadas en
#     templates/common/postcheck.list y templates/<tipo>/postcheck.list; si
#     falta alguna, [ERROR] y exit 1.
#   - -h/--help: usage y exit 0. Con argumentos invalidos (sin proyecto, tipo
#     desconocido, ruta con '-' o '..', o dos proyectos): usage y exit 1
#     (nunca usa '.' como proyecto por defecto).
#   - Mensajes de consola en ASCII puro (compatibilidad cmd/cp1252).
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# [1] Utilidades: mensajeria ASCII y helpers de copia/escritura
# ------------------------------------------------------------------------------
msg_ok()   { printf '[OK]    %s\n' "$*"; }
msg_warn() { printf '[WARN]  %s\n' "$*"; }
msg_err()  { printf '[ERROR] %s\n' "$*" >&2; }

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
# El contenido llega por stdin (copiado desde templates/ con '<' en el punto
# de llamada, o via heredoc si se invoca desde una prueba).
write_template() {
    _path="$1"
    if [ -s "$_path" ]; then
        msg_warn "Se omite $_path (ya existe y no esta vacio)."
        return 0
    fi
    cat > "$_path"
    msg_ok "Creado $_path"
}

# Copia los ficheros de un directorio de plantillas al proyecto (guarda
# noclobber de write_template). Los ficheros postcheck.list son metadatos del
# repo y NO se copian al proyecto; mcp.json tampoco se copia aqui (se copia
# aparte, desde templates/common/mcp.json a .roo/mcp.json del proyecto).
# $1: raiz de plantillas; $2: subdirectorio (common o tipo); $3: proyecto.
copy_templates() {
    _tpl_root="$1"
    _tpl_kind="$2"
    _proj="$3"
    find "$_tpl_root/$_tpl_kind" -type f | while IFS= read -r _src_file; do
        _rel_path=${_src_file#"$_tpl_root/$_tpl_kind/"}
        case "$_rel_path" in
            postcheck.list|mcp.json) continue ;;
        esac
        mkdir -p "$_proj/$(dirname "$_rel_path")"
        write_template "$_proj/$_rel_path" < "$_src_file"
    done
}

# ------------------------------------------------------------------------------
# [2] Raiz del repo y catalogo de tipos (subdirectorios de templates/,
#     excluido common/). Anadir un tipo nuevo = crear templates/<tipo>/.
# ------------------------------------------------------------------------------
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
TEMPLATE_ROOT="$SCRIPT_DIR/templates"

TEMPLATE_TYPES=""
if [ -d "$TEMPLATE_ROOT" ]; then
    for _dir in "$TEMPLATE_ROOT"/*/; do
        if [ ! -d "$_dir" ]; then
            continue
        fi
        _type_name=${_dir#"$TEMPLATE_ROOT"/}
        _type_name=${_type_name%/}
        if [ "$_type_name" = "common" ]; then
            continue
        fi
        if [ -z "$TEMPLATE_TYPES" ]; then
            TEMPLATE_TYPES="$_type_name"
        else
            TEMPLATE_TYPES="$TEMPLATE_TYPES $_type_name"
        fi
    done
fi

# Lista separada por comas para mostrar en usage() y en los errores.
TYPE_LIST_DISPLAY=""
for _t in $TEMPLATE_TYPES; do
    if [ -z "$TYPE_LIST_DISPLAY" ]; then
        TYPE_LIST_DISPLAY="$_t"
    else
        TYPE_LIST_DISPLAY="$TYPE_LIST_DISPLAY, $_t"
    fi
done

# ------------------------------------------------------------------------------
# [3] Usage (la lista de tipos se descubre, no se hard-codea)
# ------------------------------------------------------------------------------
usage() {
    cat <<'USAGE_EOF'
init_paper.sh - Generador de estructura para proyectos de papers academicos.

Uso:
  bash init_paper.sh <nombre-proyecto> [--type <tipo>] [--force]

Argumentos:
  <nombre-proyecto>  Ruta del directorio a crear (relativa o absoluta).
                     No puede empezar por '-' ni contener '..'.
  --type <tipo>      Tipo de estructura a generar (por defecto: imrad).
                     Los tipos se descubren de los subdirectorios del
                     directorio templates/ del repo (excluido common/).
  --force            Re-ejecuta sobre un proyecto existente: crea solo lo
                     que falta y NUNCA sobrescribe ficheros no vacios.
  -h, --help         Muestra esta ayuda y termina con codigo 0.
USAGE_EOF
    if [ -n "$TYPE_LIST_DISPLAY" ]; then
        printf 'Tipos disponibles: %s\n' "$TYPE_LIST_DISPLAY"
    else
        printf 'Tipos disponibles: (ninguno detectado; falta templates/ en el repo)\n'
    fi
    cat <<'USAGE_EOF'

Ejemplos:
  bash init_paper.sh mi-paper                     # tipo por defecto (imrad)
  bash init_paper.sh mi-revision --type prisma    # revision sistematica
  bash init_paper.sh mi-tesis --type thesis       # tesis/TFG/TFM
  bash init_paper.sh mi-ppc --type grant          # propuesta competitiva/PPC
  bash init_paper.sh mi-paper --force             # completar sin sobrescribir
USAGE_EOF
}

# ------------------------------------------------------------------------------
# [4] Parseo y validacion de argumentos
# ------------------------------------------------------------------------------
FORCE=0
PROJECT_DIR=""
TYPE="imrad"

while [ "$#" -gt 0 ]; do
    case "$1" in
        --force)
            FORCE=1
            shift
            ;;
        --type)
            if [ "$#" -lt 2 ]; then
                msg_err "La opcion --type requiere un valor (tipo de proyecto)."
                echo
                usage
                exit 1
            fi
            TYPE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
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

# ------------------------------------------------------------------------------
# [5] Validacion del tipo elegido contra el catalogo descubierto
# ------------------------------------------------------------------------------
if [ -z "$TEMPLATE_TYPES" ]; then
    msg_err "No se detectaron tipos de proyecto en $TEMPLATE_ROOT."
    msg_err "Crea al menos un subdirectorio de plantillas (excluido common/) y re-ejecuta."
    exit 1
fi

TYPE_VALID=0
for _t in $TEMPLATE_TYPES; do
    if [ "$_t" = "$TYPE" ]; then
        TYPE_VALID=1
    fi
done
if [ "$TYPE_VALID" -eq 0 ]; then
    msg_err "Tipo de proyecto desconocido: '$TYPE'."
    msg_err "Tipos disponibles: $TYPE_LIST_DISPLAY"
    echo
    usage
    exit 1
fi

if [ -z "$PROJECT_DIR" ]; then
    msg_err "Falta el nombre del proyecto."
    echo
    usage
    exit 1
fi

# ------------------------------------------------------------------------------
# [6] Validacion del directorio destino (abortar si existe y no esta vacio,
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
# [7] Creacion de la estructura de directorios (mkdir -p con rutas citadas;
#     sin brace expansion, incompatible con sh/dash). Los directorios extra
#     de cada tipo (p. ej. src/chapters) los crea copy_templates.
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
    "$PROJECT_DIR/rag/templates" \
    "$PROJECT_DIR/rag/cache/papers"

# ------------------------------------------------------------------------------
# [8] Copia INTEGRA del marco academico y de los agentes desde el repo
#     (con guardas de no-sobrescritura para el modo --force)
# ------------------------------------------------------------------------------

# [8.1] .roomodes: definicion de los modos Roo del proyecto
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

# [8.2] Skills de agentes (.roo/skills del repo -> proyecto)
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

# [8.3] Marco academico integro: se copia el fichero completo del repo
#       (no una version reducida). Unica fuente de verdad (SSOT): NO existe
#       heredoc de respaldo; si falta rules.md y hay que generarlo, el
#       scaffold aborta con [ERROR] para no producir reglas divergentes.
RULE_SRC="$SCRIPT_DIR/.roo/rules/rules.md"
RULE_DST="$PROJECT_DIR/.roo/rules/00_academic_core.md"
if [ -s "$RULE_DST" ]; then
    msg_warn "Se omite .roo/rules/00_academic_core.md (ya existe y no esta vacio)."
elif [ ! -f "$RULE_SRC" ]; then
    msg_err "Fuente unica del marco academico no encontrada: $RULE_SRC"
    msg_err "Restaura .roo/rules/rules.md en el repo y re-ejecuta; no hay respaldo embebido."
    exit 1
else
    cp "$RULE_SRC" "$RULE_DST"
    msg_ok "Marco academico integro copiado a .roo/rules/00_academic_core.md."
fi

# [8.4] Configuracion MCP (plantilla trackeada templates/common/mcp.json ->
#       .roo/mcp.json del proyecto). La plantilla NO contiene claves API: el
#       servidor semantic-scholar-mcp hereda la variable de entorno
#       SEMANTIC_SCHOLAR_API_KEY del sistema del usuario. La cache del
#       servidor arXiv usa la ruta relativa ./rag/cache/papers (creada en el
#       bloque [7]).
MCP_SRC="$TEMPLATE_ROOT/common/mcp.json"
MCP_DST="$PROJECT_DIR/.roo/mcp.json"
if [ -f "$MCP_SRC" ]; then
    if [ -s "$MCP_DST" ]; then
        msg_warn "Se omite .roo/mcp.json (ya existe y no esta vacio)."
    else
        cp "$MCP_SRC" "$MCP_DST"
        msg_ok "Copiado .roo/mcp.json al proyecto."
        msg_warn "mcp.json no incluye claves API: define SEMANTIC_SCHOLAR_API_KEY como variable de entorno del sistema para autenticar el servidor MCP."
        msg_warn "No publiques este repositorio ni los proyectos generados en repositorios publicos."
    fi
else
    msg_warn "templates/common/mcp.json no encontrado en $TEMPLATE_ROOT: el proyecto no tendra servidores MCP configurados."
fi

# ------------------------------------------------------------------------------
# [9] Plantillas del proyecto: copia parametrizada desde templates/.
#     Primero el nucleo comun y despues el overlay del tipo elegido; la guarda
#     noclobber de write_template impide sobrescribir ficheros ya editados.
# ------------------------------------------------------------------------------
msg_ok "Generando plantillas (tipo: $TYPE) ..."
copy_templates "$TEMPLATE_ROOT" "common" "$PROJECT_DIR"
copy_templates "$TEMPLATE_ROOT" "$TYPE" "$PROJECT_DIR"

# ------------------------------------------------------------------------------
# [10] Post-condicion parametrizada: el proyecto debe contener TODAS las
#      rutas listadas en templates/common/postcheck.list y en
#      templates/<tipo>/postcheck.list antes de declarar exito.
# ------------------------------------------------------------------------------
POSTCHECK_FAIL=0
for _postcheck_file in \
    "$TEMPLATE_ROOT/common/postcheck.list" \
    "$TEMPLATE_ROOT/$TYPE/postcheck.list"
do
    if [ ! -f "$_postcheck_file" ]; then
        msg_err "Falta el fichero de post-condicion: $_postcheck_file"
        exit 1
    fi
    while IFS= read -r _required || [ -n "$_required" ]; do
        case "$_required" in
            ''|\#*) continue ;;
        esac
        if [ ! -f "$PROJECT_DIR/$_required" ]; then
            msg_err "Post-condicion incumplida: no existe $PROJECT_DIR/$_required"
            POSTCHECK_FAIL=1
        fi
    done < "$_postcheck_file"
done
if [ "$POSTCHECK_FAIL" -ne 0 ]; then
    msg_err "La generacion no se completo correctamente; revisa los errores anteriores."
    exit 1
fi
msg_ok "Post-condicion verificada (tipo: $TYPE)."

# ------------------------------------------------------------------------------
# [11] Exito
# ------------------------------------------------------------------------------
msg_ok "Estructura academica generada en '$PROJECT_DIR' (tipo: $TYPE)."
msg_ok "Siguiente paso: rellenar context/call_guidelines.md y context/hypothesis_matrix.md (marcadores TODO)."
exit 0
