#!/usr/bin/env bash
# ==============================================================================
# tests/scaffold_smoke.sh
# Suite de humo de init_paper.sh (F0: higiene; F1: seguridad MCP; F2:
# plantillas variables).
#
# Verifica:
#   [1] Generacion en directorio temporal (mktemp -d) por cada tipo de
#       proyecto (PROJECT_TYPES) + post-condicion parametrizada: TODAS las
#       rutas de templates/common/postcheck.list y templates/<tipo>/
#       postcheck.list existen y no estan vacias.
#   [2] data/stats_summary.json parseable como JSON y data/workpackages.yaml
#       parseable como YAML (con python si esta disponible; si no, validacion
#       estructural minima en bash marcada con [WARN]).
#   [3] Comportamiento noclobber: re-ejecucion sin --force aborta (exit 1) y
#       con --force NO sobrescribe ficheros existentes no vacios (comparacion
#       byte a byte antes/despues con cmp).
#   [4] -h/--help terminan con exit 0; los argumentos invalidos (sin proyecto,
#       ruta con '-' o '..', dos proyectos, --type desconocido, --type sin
#       valor) abortan con exit 1.
#   [5] Todos los mensajes del scaffold son ASCII puro (sin acentos/emojis).
#   [6] Seguridad MCP (F1): templates/common/mcp.json (fuente trackeada del
#       repo y copiada a cada proyecto) sin claves API en claro, sin ruta
#       absoluta de interprete, sin --refresh-package (instalacion cacheada
#       de uv) y con las entradas de los 5 servidores (semantic-scholar-mcp,
#       fetch, arxiv, pubmedmcp, crossref). El .roo/mcp.json local de este
#       repo (gitignoreado, puede contener claves del usuario) NO se escanea.
#   [7] Consistencia LaTeX (F2): todo \input{...} / \include{...} presente en
#       los .tex del proyecto generado corresponde a un fichero existente.
#   [8] Retrocompatibilidad (F2): generar sin --type produce exactamente la
#       misma estructura y contenido que generar con --type imrad.
#   [9] F4 - motor de autonomia: los 4 ficheros de autonomia (data/
#       autonomy_state.json parseable, context/autonomy_journal.md,
#       context/escalation_queue.md y run_autonomy.sh con bash -n limpio)
#       presentes en cada tipo; el snapshot noclobber incluye autonomy_state.json
#       y run_autonomy.sh; el dry-run del supervisor sin CLI sale por MODO
#       MANUAL con exit 0 y, con una escalacion ABIERTA simulada, se niega a
#       relanzar (exit 0 imprimiendo la cola).
#   [10] F5 - tipo grant: artefactos propios parseables cuando el tipo los
#       define (data/consortium.yaml y data/budget.yaml como YAML; el resto
#       de parseabilidad del tipo lo cubren los checks generales anteriores
#       y la post-condicion parametrizada).
#   [11] Guard de .roomodes: el fichero fuente del repo es YAML parseable
#       (PyYAML) con los 5 modos academicos y campos minimos (fallback
#       estructural con [WARN] sin PyYAML) y la copia de .roomodes a cada
#       proyecto generado es identica byte a byte al fuente.
#
# Diseno:
#   - Parametrizable por tipo de proyecto: PROJECT_TYPES contiene el catalogo
#     nucleo; el resto del test itera sobre el array sin cambios.
#   - Dependencias: bash y binarios basicos (grep, cmp, head, rm para la
#     limpieza). python/python3/py es OPCIONAL (solo parseabilidad completa).
#
# Uso:    bash tests/scaffold_smoke.sh
# Salida: ASCII puro ([OK]/[WARN]/[ERROR]); exit 0 si todo pasa, exit 1 si no.
# ==============================================================================
set -euo pipefail

# ------------------------------------------------------------------------------
# [P] Parametros: tipos de proyecto a verificar (catalogo de F2 + F5: grant;
#     extensible sin tocar el resto del test).
# ------------------------------------------------------------------------------
PROJECT_TYPES=("imrad" "prisma" "thesis" "engineering" "grant")

SCRIPT_DIR=$(cd "$(dirname "$0")/.." && pwd)
INIT_SCRIPT="$SCRIPT_DIR/init_paper.sh"
TEMPLATE_ROOT="$SCRIPT_DIR/templates"

TMP_ROOT=$(mktemp -d)
trap 'rm -rf "$TMP_ROOT"' EXIT

FAILURES=0
LAST_RC=0
PYTHON_BIN=""

# ------------------------------------------------------------------------------
# [T] Utilidades de mensaje ASCII y ejecucion controlada
# ------------------------------------------------------------------------------
t_ok()   { printf '[OK]    %s\n' "$*"; }
t_warn() { printf '[WARN]  %s\n' "$*"; }
t_err()  { printf '[ERROR] %s\n' "$*" >&2; }

record_fail() {
    t_err "$*"
    FAILURES=$((FAILURES + 1))
}

run_scaffold() {
    # $1: fichero de log (stdout+stderr); resto: argumentos de init_paper.sh
    _log="$1"; shift
    set +e
    bash "$INIT_SCRIPT" "$@" > "$_log" 2>&1
    LAST_RC=$?
    set -e
}

check_run() {
    # $1: log; $2: exit code esperado; $3: descripcion; resto: args del scaffold
    _log="$1"; _want="$2"; _desc="$3"; shift 3
    run_scaffold "$_log" "$@"
    if [ "$LAST_RC" -eq "$_want" ]; then
        t_ok "$_desc (exit $_want)."
    else
        record_fail "$_desc: se esperaba exit $_want y se obtuvo exit $LAST_RC."
        cat "$_log" >&2
    fi
    check_ascii "$_log" "$_desc"
}

check_ascii() {
    # $1: log de salida del scaffold; $2: descripcion del check
    _log="$1"; _desc="$2"
    if [ ! -f "$_log" ]; then
        record_fail "$_desc: no hay log que inspeccionar."
        return 0
    fi
    if LC_ALL=C grep -q '[^[:print:][:space:]]' "$_log"; then
        record_fail "$_desc: la salida del scaffold contiene caracteres no ASCII:"
        LC_ALL=C grep -n '[^[:print:][:space:]]' "$_log" | head -n 5 >&2 || true
        return 0
    fi
    t_ok "$_desc: mensajes del scaffold en ASCII puro."
}

# ------------------------------------------------------------------------------
# [T] Checks del scaffold
# ------------------------------------------------------------------------------
check_postcondition() {
    # $1: proyecto; $2: tipo. Verifica TODAS las rutas de los postcheck.list
    # (nucleo comun + overlay del tipo) como ficheros no vacios.
    _proj="$1"; _type="$2"
    for _list in \
        "$TEMPLATE_ROOT/common/postcheck.list" \
        "$TEMPLATE_ROOT/$_type/postcheck.list"
    do
        if [ ! -f "$_list" ]; then
            record_fail "Post-condicion ($_type): falta el fichero $_list."
            continue
        fi
        while IFS= read -r _key || [ -n "$_key" ]; do
            case "$_key" in
                ''|\#*) continue ;;
            esac
            if [ -s "$_proj/$_key" ]; then
                t_ok "Post-condicion ($_type): existe y no esta vacio $_key"
            else
                record_fail "Post-condicion ($_type) incumplida: falta o esta vacio $_key"
            fi
        done < "$_list"
    done
}

# ------------------------------------------------------------------------------
# [T] Seguridad MCP: sin secretos en claro y arranque reproducible (F1)
# ------------------------------------------------------------------------------
check_mcp_security() {
    # $1: fichero mcp.json a auditar; $2: etiqueta descriptiva
    _file="$1"; _label="$2"
    if [ ! -s "$_file" ]; then
        record_fail "mcp.json ($_label): no existe o esta vacio ($_file)."
        return 0
    fi
    # (a) Ningun valor de campo JSON parece un secreto: string largo
    #     alfanumerico a la derecha de ':' (p. ej. un token en el bloque env).
    if grep -Eq ':[[:space:]]*"[A-Za-z0-9_.-]{20,}"' "$_file"; then
        record_fail "mcp.json ($_label): contiene un valor largo que parece una clave API:"
        grep -En ':[[:space:]]*"[A-Za-z0-9_.-]{20,}"' "$_file" | head -n 5 >&2 || true
    else
        t_ok "mcp.json ($_label): ningun valor parece una clave API en claro."
    fi
    # (b) Ningun token con el prefijo de formato de las claves de Semantic Scholar.
    if grep -Eq 's2k-' "$_file"; then
        record_fail "mcp.json ($_label): contiene un token con prefijo s2k-."
    else
        t_ok "mcp.json ($_label): sin tokens con prefijo s2k-."
    fi
    # (c) Modelo F1: la clave vive en la env var del sistema; el fichero no
    #     la referencia (ni como nombre de campo ni como valor).
    if grep -Fq 'SEMANTIC_SCHOLAR_API_KEY' "$_file"; then
        record_fail "mcp.json ($_label): referencia SEMANTIC_SCHOLAR_API_KEY; la clave debe definirse solo como variable de entorno del sistema."
    else
        t_ok "mcp.json ($_label): no referencia SEMANTIC_SCHOLAR_API_KEY (clave via entorno del sistema)."
    fi
    # (d) Arranque portable: command no es una ruta absoluta de interprete.
    if grep -Eq '"command"[[:space:]]*:[[:space:]]*"(/|[A-Za-z]:)' "$_file"; then
        record_fail "mcp.json ($_label): command usa una ruta absoluta."
    else
        t_ok "mcp.json ($_label): command es un comando portable (sin ruta absoluta)."
    fi
    # (e) Sin --refresh-package: uv no reinstala el paquete en cada arranque.
    if grep -Fq 'refresh-package' "$_file"; then
        record_fail "mcp.json ($_label): usa --refresh-package (reinstalacion en cada arranque)."
    else
        t_ok "mcp.json ($_label): sin --refresh-package (instalacion cacheada)."
    fi
}

# ------------------------------------------------------------------------------
# [T] Presencia de los 5 servidores MCP en la configuracion
#     (F3-P0 + F3-P1a + F3-P1b)
# ------------------------------------------------------------------------------
check_mcp_servers() {
    # $1: fichero mcp.json a auditar; $2: etiqueta descriptiva
    _file="$1"; _label="$2"
    if [ ! -s "$_file" ]; then
        record_fail "mcp.json ($_label): no existe o esta vacio ($_file)."
        return 0
    fi
    for _srv in semantic-scholar-mcp fetch arxiv pubmedmcp crossref; do
        if grep -Eq "\"$_srv\"[[:space:]]*:[[:space:]]*\{" "$_file"; then
            t_ok "mcp.json ($_label): servidor $_srv presente."
        else
            record_fail "mcp.json ($_label): falta el servidor $_srv."
        fi
    done
}

detect_python() {
    if command -v python >/dev/null 2>&1; then
        PYTHON_BIN=python
    elif command -v python3 >/dev/null 2>&1; then
        PYTHON_BIN=python3
    elif command -v py >/dev/null 2>&1; then
        PYTHON_BIN=py
    else
        PYTHON_BIN=""
    fi
}

check_json() {
    # $1: data/stats_summary.json del proyecto generado
    _file="$1"
    if [ -n "$PYTHON_BIN" ]; then
        if "$PYTHON_BIN" -c "import json,sys; json.load(open(sys.argv[1], encoding='utf-8'))" "$_file" > /dev/null 2>&1; then
            t_ok "stats_summary.json parseable como JSON ($PYTHON_BIN)."
        else
            record_fail "stats_summary.json NO es JSON parseable."
        fi
    else
        if [ -s "$_file" ] && grep -q '"study_metadata"' "$_file" && grep -q '"variables"' "$_file"; then
            t_warn "stats_summary.json: python no disponible; validacion estructural minima (no parsea JSON completo)."
        else
            record_fail "stats_summary.json: estructura minima (study_metadata/variables) no encontrada."
        fi
    fi
}

check_yaml() {
    # $1: data/workpackages.yaml del proyecto generado
    _file="$1"
    if [ -n "$PYTHON_BIN" ] && "$PYTHON_BIN" -c "import yaml" > /dev/null 2>&1; then
        if "$PYTHON_BIN" -c "import yaml,sys; yaml.safe_load(open(sys.argv[1], encoding='utf-8'))" "$_file" > /dev/null 2>&1; then
            t_ok "workpackages.yaml parseable como YAML (PyYAML)."
        else
            record_fail "workpackages.yaml NO es YAML parseable."
        fi
    else
        if [ -n "$PYTHON_BIN" ]; then
            t_warn "PyYAML no esta instalado: se aplica validacion estructural minima a workpackages.yaml."
        else
            t_warn "python no disponible: se aplica validacion estructural minima a workpackages.yaml."
        fi
        if [ -s "$_file" ] && grep -q '^workpackages:' "$_file" && grep -q '^  - id: WP1' "$_file"; then
            t_ok "workpackages.yaml: estructura minima presente (workpackages: / - id: WP1)."
        else
            record_fail "workpackages.yaml: estructura minima (workpackages: / - id: WP1) no encontrada."
        fi
    fi
}

check_yaml_file() {
    # $1: fichero YAML del proyecto generado; $2: etiqueta descriptiva (F5).
    # Parseabilidad completa con PyYAML; si no esta disponible, validacion
    # estructural minima (existe y no esta vacio) marcada con [WARN].
    _file="$1"; _label="$2"
    if [ -n "$PYTHON_BIN" ] && "$PYTHON_BIN" -c "import yaml" > /dev/null 2>&1; then
        if "$PYTHON_BIN" -c "import yaml,sys; yaml.safe_load(open(sys.argv[1], encoding='utf-8'))" "$_file" > /dev/null 2>&1; then
            t_ok "$_label parseable como YAML (PyYAML)."
        else
            record_fail "$_label NO es YAML parseable."
        fi
    else
        if [ -s "$_file" ]; then
            t_warn "$_label: python/PyYAML no disponible; validacion estructural minima (existe y no esta vacio)."
        else
            record_fail "$_label: no existe o esta vacio."
        fi
    fi
}

# ------------------------------------------------------------------------------
# [T] Guard de .roomodes: parseabilidad del fuente y copia byte a byte
# ------------------------------------------------------------------------------
check_roomodes_source() {
    # Valida el .roomodes FUENTE del repo: (a) con PyYAML exige los 5 modos
    # academicos (por slug) y campos minimos en cada uno (roleDefinition,
    # description, customInstructions, groups, source) ademas de un fileRegex
    # en el grupo edit de research-architect; (b) sin PyYAML, validacion
    # estructural minima (conteo de entradas - slug) marcada con [WARN].
    _file="$SCRIPT_DIR/.roomodes"
    if [ ! -s "$_file" ]; then
        record_fail ".roomodes fuente: no existe o esta vacio ($_file)."
        return 0
    fi
    if [ -n "$PYTHON_BIN" ] && "$PYTHON_BIN" -c "import yaml" > /dev/null 2>&1; then
        if "$PYTHON_BIN" -c "import yaml,sys; d=yaml.safe_load(open(sys.argv[1], encoding='utf-8')); modes=d['customModes']; assert sorted(m.get('slug') for m in modes)==sorted(['lit-synthesizer','academic-writer','reviewer-2','research-architect','academic-orchestrator']), modes; assert all(all(k in m for k in ('roleDefinition','description','customInstructions','groups','source')) for m in modes), modes; ra=next(m for m in modes if m.get('slug')=='research-architect'); assert any(isinstance(g,list) and len(g)>1 and isinstance(g[1],dict) and g[0]=='edit' and g[1].get('fileRegex') for g in ra['groups']), ra['groups']" "$_file" > /dev/null 2>&1; then
            t_ok ".roomodes fuente: YAML parseable (PyYAML) con los 5 modos academicos y campos minimos."
        else
            record_fail ".roomodes fuente: NO es YAML parseable o no tiene los 5 modos academicos con campos minimos."
        fi
    else
        if [ "$(grep -c '^[[:space:]]*- slug:' "$_file")" -eq 5 ] && grep -q 'roleDefinition:' "$_file" && grep -q 'fileRegex:' "$_file"; then
            t_warn ".roomodes fuente: python/PyYAML no disponible; validacion estructural minima (5 - slug con roleDefinition/fileRegex)."
        else
            record_fail ".roomodes fuente: estructura minima (5 - slug con roleDefinition/fileRegex) no encontrada."
        fi
    fi
}

check_roomodes_copy() {
    # $1: proyecto; $2: tipo. La copia de .roomodes en el proyecto generado
    # debe ser identica byte a byte al fuente del repo (el scaffold la copia
    # integro, sin interpolar nada).
    _proj="$1"; _type="$2"
    if [ ! -s "$_proj/.roomodes" ]; then
        record_fail "roomodes ($_type): falta o esta vacio el .roomodes copiado al proyecto."
        return 0
    fi
    if cmp -s "$SCRIPT_DIR/.roomodes" "$_proj/.roomodes"; then
        t_ok "roomodes ($_type): copia identica byte a byte al fuente del repo."
    else
        record_fail "roomodes ($_type): la copia de .roomodes difiere del fuente del repo."
    fi
}

# ------------------------------------------------------------------------------
# [T] F4: ficheros de autonomia presentes y estado parseable
# ------------------------------------------------------------------------------
check_autonomy_files() {
    # $1: proyecto; $2: tipo. Verifica los 4 ficheros de autonomia + bash -n
    # del supervisor copiado.
    _proj="$1"; _type="$2"
    for _f in data/autonomy_state.json context/autonomy_journal.md context/escalation_queue.md run_autonomy.sh; do
        if [ -s "$_proj/$_f" ]; then
            t_ok "autonomia ($_type): existe y no esta vacio $_f"
        else
            record_fail "autonomia ($_type): falta o esta vacio $_f"
        fi
    done
    if bash -n "$_proj/run_autonomy.sh" 2>/dev/null; then
        t_ok "autonomia ($_type): run_autonomy.sh pasa bash -n."
    else
        record_fail "autonomia ($_type): run_autonomy.sh falla bash -n."
    fi
}

check_state_json() {
    # $1: data/autonomy_state.json del proyecto generado; $2: tipo.
    _file="$1"; _type="$2"
    if [ -n "$PYTHON_BIN" ]; then
        if "$PYTHON_BIN" -c "import json,sys; d=json.load(open(sys.argv[1], encoding='utf-8')); assert d['schema_version']==1 and d['budget']['max_iterations']>0 and d['budget']['timeout_minutes']>0 and d['current']['status']=='PENDING' and isinstance(d['completed'], list) and isinstance(d['sessions'], list)" "$_file" > /dev/null 2>&1; then
            t_ok "autonomy_state.json ($_type) parseable como JSON con estructura valida."
        else
            record_fail "autonomy_state.json ($_type) NO es JSON parseable o carece de la estructura minima."
        fi
    else
        if [ -s "$_file" ] && grep -q '"schema_version"' "$_file" && grep -q '"current"' "$_file" && grep -q '"iterations_used"' "$_file"; then
            t_warn "autonomy_state.json ($_type): python no disponible; validacion estructural minima."
        else
            record_fail "autonomy_state.json ($_type): estructura minima (schema_version/current/iterations_used) no encontrada."
        fi
    fi
}

# ------------------------------------------------------------------------------
# [T] Consistencia LaTeX (F2): todo \input/\include debe existir en el proyecto
# ------------------------------------------------------------------------------
check_latex_consistency() {
    # $1: proyecto; $2: etiqueta (tipo)
    _proj="$1"; _label="$2"
    _inputs_file="$TMP_ROOT/latex-inputs-$_label.txt"
    find "$_proj/src" -type f -name '*.tex' 2>/dev/null | while IFS= read -r _tex; do
        grep -hoE '\\(input|include)\{[^}]+\}' "$_tex" || true
    done > "$_inputs_file"

    _n_inputs=0
    _fail=0
    while IFS= read -r _match; do
        if [ -z "$_match" ]; then
            continue
        fi
        _arg=${_match#*\{}
        _arg=${_arg%\}}
        _n_inputs=$((_n_inputs + 1))
        case "$_arg" in
            *.tex) _target="$_proj/$_arg" ;;
            *)     _target="$_proj/$_arg.tex" ;;
        esac
        if [ ! -f "$_target" ]; then
            record_fail "consistencia LaTeX ($_label): el \\input{$_arg} no corresponde a un fichero generado ($_target)."
            _fail=1
        fi
    done < "$_inputs_file"
    if [ "$_fail" -eq 0 ]; then
        t_ok "consistencia LaTeX ($_label): $_n_inputs \\input/\\include verificados, todos resueltos."
    fi
}

# ------------------------------------------------------------------------------
# [T] Retrocompatibilidad (F2): dos arboles identicos (mismos ficheros, mismo
#     contenido byte a byte con cmp, sin ordenar la salida de find)
# ------------------------------------------------------------------------------
check_same_tree() {
    _pa="$1"; _pb="$2"; _label="$3"
    _mismatch=0
    while IFS= read -r _rel; do
        if [ ! -f "$_pb/$_rel" ]; then
            record_fail "$_label: existe solo en A: $_rel"
            _mismatch=1
        elif ! cmp -s "$_pa/$_rel" "$_pb/$_rel"; then
            record_fail "$_label: contenido distinto en $_rel"
            _mismatch=1
        fi
    done < <(cd "$_pa" && find . -type f)
    while IFS= read -r _rel; do
        if [ ! -f "$_pa/$_rel" ]; then
            record_fail "$_label: existe solo en B: $_rel"
            _mismatch=1
        fi
    done < <(cd "$_pb" && find . -type f)
    if [ "$_mismatch" -eq 0 ]; then
        t_ok "$_label: los dos proyectos son identicos (mismos ficheros y contenido)."
    fi
}

# ------------------------------------------------------------------------------
# [T] noclobber: snapshot de ficheros SSOT y comparacion byte a byte
# ------------------------------------------------------------------------------
_cmp_pair() {
    _before="$1"; _after="$2"; _name="$3"
    if [ ! -s "$_before" ]; then
        return 0
    fi
    if [ ! -f "$_after" ]; then
        record_fail "noclobber: $_name desaparecio tras la re-ejecucion con --force."
        return 0
    fi
    if cmp -s "$_before" "$_after"; then
        t_ok "noclobber: $_name no fue sobrescrito por --force."
    else
        record_fail "noclobber: $_name fue modificado por la re-ejecucion con --force."
    fi
}

snapshot_ssot() {
    # $1: proyecto; $2: directorio snapshot
    _proj="$1"; _snap="$2"
    mkdir -p "$_snap"
    cp "$_proj/src/main.tex"                     "$_snap/src_main.tex"
    cp "$_proj/context/hypothesis_matrix.md"     "$_snap/hypothesis_matrix.md"
    cp "$_proj/data/stats_summary.json"          "$_snap/stats_summary.json"
    cp "$_proj/data/workpackages.yaml"           "$_snap/workpackages.yaml"
    cp "$_proj/reviews/peer_review_log.md"       "$_snap/peer_review_log.md"
    cp "$_proj/.roo/rules/00_academic_core.md"   "$_snap/00_academic_core.md"
    cp "$_proj/.roomodes"                        "$_snap/roomodes"
    cp "$_proj/.roo/mcp.json"                    "$_snap/mcp.json"
    cp "$_proj/data/autonomy_state.json"         "$_snap/autonomy_state.json"
    cp "$_proj/run_autonomy.sh"                  "$_snap/run_autonomy.sh"
}

check_noclobber() {
    # $1: proyecto; $2: directorio snapshot (contenido ANTES del --force)
    _proj="$1"; _snap="$2"
    _cmp_pair "$_snap/src_main.tex"         "$_proj/src/main.tex"                   "src/main.tex"
    _cmp_pair "$_snap/hypothesis_matrix.md" "$_proj/context/hypothesis_matrix.md"   "context/hypothesis_matrix.md"
    _cmp_pair "$_snap/stats_summary.json"   "$_proj/data/stats_summary.json"        "data/stats_summary.json"
    _cmp_pair "$_snap/workpackages.yaml"    "$_proj/data/workpackages.yaml"         "data/workpackages.yaml"
    _cmp_pair "$_snap/peer_review_log.md"   "$_proj/reviews/peer_review_log.md"     "reviews/peer_review_log.md"
    _cmp_pair "$_snap/00_academic_core.md"  "$_proj/.roo/rules/00_academic_core.md" ".roo/rules/00_academic_core.md"
    _cmp_pair "$_snap/roomodes"             "$_proj/.roomodes"                      ".roomodes"
    _cmp_pair "$_snap/mcp.json"             "$_proj/.roo/mcp.json"                  ".roo/mcp.json"
    _cmp_pair "$_snap/autonomy_state.json"  "$_proj/data/autonomy_state.json"       "data/autonomy_state.json"
    _cmp_pair "$_snap/run_autonomy.sh"      "$_proj/run_autonomy.sh"                "run_autonomy.sh"
}

# ==============================================================================
# Main
# ==============================================================================
if [ ! -f "$INIT_SCRIPT" ]; then
    t_err "No se encuentra init_paper.sh en $SCRIPT_DIR."
    exit 1
fi

detect_python
if [ -n "$PYTHON_BIN" ]; then
    t_ok "python disponible ($PYTHON_BIN): parseabilidad JSON/YAML completa."
else
    t_warn "python no disponible: la parseabilidad se valida de forma estructural (menos estricta)."
fi

t_ok "Directorio temporal de trabajo: $TMP_ROOT"

# Seguridad MCP sobre la fuente TRACKEADA del repo (proteccion anti-regresion).
# .roo/mcp.json es configuracion LOCAL de este repo (gitignoreada, puede
# contener claves del usuario) y deliberadamente NO se escanea aqui.
check_mcp_security "$TEMPLATE_ROOT/common/mcp.json" "fuente trackeada (templates/common)"
check_mcp_servers "$TEMPLATE_ROOT/common/mcp.json" "fuente trackeada (templates/common)"

# Guard de .roomodes (parseabilidad + 5 modos): un YAML invalido aqui se
# propaga a TODOS los proyectos generados (el scaffold lo copia integro).
check_roomodes_source

# ------------------------------------------------------------------------------
# [1]-[3], [6]-[7] Por cada tipo de proyecto: generacion, post-condicion
#                 parametrizada, parseabilidad, consistencia LaTeX y noclobber
#                 (sin --force aborta; con --force no sobrescribe)
# ------------------------------------------------------------------------------
for TYPE in "${PROJECT_TYPES[@]}"; do
    t_ok "=== Tipo de proyecto: $TYPE ==="
    PROJ="$TMP_ROOT/proj-$TYPE"
    LOG_GEN="$TMP_ROOT/log-gen-$TYPE.txt"
    LOG_NOFORCE="$TMP_ROOT/log-noforce-$TYPE.txt"
    LOG_FORCE="$TMP_ROOT/log-force-$TYPE.txt"
    SNAP="$TMP_ROOT/snap-$TYPE"

    check_run "$LOG_GEN" 0 "generacion inicial ($TYPE)" "$PROJ" --type "$TYPE"
    check_postcondition "$PROJ" "$TYPE"
    check_mcp_security "$PROJ/.roo/mcp.json" "copiado al proyecto ($TYPE)"
    check_mcp_servers "$PROJ/.roo/mcp.json" "copiado al proyecto ($TYPE)"
    check_roomodes_copy "$PROJ" "$TYPE"
    check_json "$PROJ/data/stats_summary.json"
    check_yaml "$PROJ/data/workpackages.yaml"
   # F5: artefactos YAML propios del tipo (presentes solo en grant).
   if [ -f "$PROJ/data/consortium.yaml" ]; then
       check_yaml_file "$PROJ/data/consortium.yaml" "consortium.yaml ($TYPE)"
   fi
   if [ -f "$PROJ/data/budget.yaml" ]; then
       check_yaml_file "$PROJ/data/budget.yaml" "budget.yaml ($TYPE)"
   fi
    check_autonomy_files "$PROJ" "$TYPE"
    check_state_json "$PROJ/data/autonomy_state.json" "$TYPE"
    check_latex_consistency "$PROJ" "$TYPE"

    check_run "$LOG_NOFORCE" 1 "re-ejecucion sin --force aborta ($TYPE)" "$PROJ" --type "$TYPE"
    snapshot_ssot "$PROJ" "$SNAP"
    check_run "$LOG_FORCE" 0 "re-ejecucion con --force ($TYPE)" "$PROJ" --type "$TYPE" --force
    check_noclobber "$PROJ" "$SNAP"
done

# ------------------------------------------------------------------------------
# [8] Retrocompatibilidad: sin --type == --type imrad (F2)
# ------------------------------------------------------------------------------
t_ok "=== Retrocompatibilidad: default (sin --type) vs imrad ==="
PROJ_DEF="$TMP_ROOT/proj-default"
check_run "$TMP_ROOT/log-def.txt" 0 "generacion por defecto sin --type" "$PROJ_DEF"
check_postcondition "$PROJ_DEF" "imrad"
check_latex_consistency "$PROJ_DEF" "default"
check_same_tree "$PROJ_DEF" "$TMP_ROOT/proj-imrad" "default vs imrad"

# ------------------------------------------------------------------------------
# [9] F4: supervisor de autonomia (dry-run, MODO MANUAL sin CLI y gate de
#     escalaciones ABIERTAS con exit 0 en ambos casos)
# ------------------------------------------------------------------------------
t_ok "=== F4: supervisor run_autonomy.sh ==="
AUTO_PROJ="$TMP_ROOT/proj-imrad"
LOG_MANUAL="$TMP_ROOT/log-auto-manual.txt"
LOG_ESC="$TMP_ROOT/log-auto-escalation.txt"
LOG_HELP="$TMP_ROOT/log-auto-help.txt"

# (a) --help del supervisor: exit 0.
set +e
bash "$AUTO_PROJ/run_autonomy.sh" --help > "$LOG_HELP" 2>&1
AUTO_RC=$?
set -e
if [ "$AUTO_RC" -eq 0 ] && grep -q 'Supervisor fino' "$LOG_HELP"; then
    t_ok "run_autonomy --help: exit 0 con la ayuda."
else
    record_fail "run_autonomy --help: se esperaba exit 0 y se obtuvo $AUTO_RC."
    cat "$LOG_HELP" >&2
fi
check_ascii "$LOG_HELP" "run_autonomy --help"

# (b) Dry-run sin CLI (--cli apunta a un binario inexistente): MODO MANUAL con
#     prompt de continuacion y exit 0.
set +e
bash "$AUTO_PROJ/run_autonomy.sh" --project "$AUTO_PROJ" --cli "no-hay-cli-f4-xyz" --dry-run > "$LOG_MANUAL" 2>&1
AUTO_RC=$?
set -e
if [ "$AUTO_RC" -eq 0 ] && grep -q 'MODO MANUAL' "$LOG_MANUAL" && grep -q 'academic-orchestrator' "$LOG_MANUAL"; then
    t_ok "run_autonomy dry-run sin CLI: MODO MANUAL con prompt y exit 0."
else
    record_fail "run_autonomy dry-run sin CLI: se esperaba exit 0 con MODO MANUAL y prompt (rc=$AUTO_RC)."
    cat "$LOG_MANUAL" >&2
fi
check_ascii "$LOG_MANUAL" "run_autonomy dry-run (modo manual)"

# (c) Con una escalacion ABIERTA simulada: se niega a relanzar (exit 0, cola impresa).
printf '| ESC-999 | 2026-01-01 00:00 | WP1 | D3 | Pregunta simulada por la suite de humo | Contexto simulado | | ABIERTO |\n' >> "$AUTO_PROJ/context/escalation_queue.md"
set +e
bash "$AUTO_PROJ/run_autonomy.sh" --project "$AUTO_PROJ" --cli "no-hay-cli-f4-xyz" --dry-run > "$LOG_ESC" 2>&1
AUTO_RC=$?
set -e
if [ "$AUTO_RC" -eq 0 ] && grep -q 'ESCALACIONES ABIERTAS' "$LOG_ESC" && grep -q 'ESC-999' "$LOG_ESC"; then
    t_ok "run_autonomy con escalacion ABIERTA: se niega a relanzar (exit 0 imprimiendo la cola)."
else
    record_fail "run_autonomy con escalacion ABIERTA: se esperaba exit 0 negandose a relanzar (rc=$AUTO_RC)."
    cat "$LOG_ESC" >&2
fi
check_ascii "$LOG_ESC" "run_autonomy con escalacion ABIERTA"

# ------------------------------------------------------------------------------
# [4]-[5] -h/--help con exit 0 y rechazos de argumentos con exit 1
#         (check_ascii dentro de check_run valida la salida en todos los casos)
# ------------------------------------------------------------------------------
t_ok "=== Argumentos: -h/--help y rechazos ==="
check_run "$TMP_ROOT/log-h.txt"        0 "-h muestra la ayuda y sale con 0" -h
check_run "$TMP_ROOT/log-help.txt"     0 "--help muestra la ayuda y sale con 0" --help
check_run "$TMP_ROOT/log-noargs.txt"   1 "sin proyecto aborta con exit 1"
check_run "$TMP_ROOT/log-dash.txt"     1 "ruta que empieza por '-' aborta con exit 1" "-proyecto-invalido"
check_run "$TMP_ROOT/log-dots.txt"     1 "ruta con '..' aborta con exit 1" "proyecto..invalido"
check_run "$TMP_ROOT/log-two.txt"      1 "dos proyectos abortan con exit 1" "proyecto-a" "proyecto-b"
check_run "$TMP_ROOT/log-badtype.txt"  1 "--type desconocido aborta con exit 1" "proyecto-x" --type "tipo-inexistente"
check_run "$TMP_ROOT/log-typeempty.txt" 1 "--type sin valor aborta con exit 1" "proyecto-x" --type
check_run "$TMP_ROOT/log-typehelp.txt" 0 "--type con -h sigue mostrando la ayuda" --type "prisma" -h

# ------------------------------------------------------------------------------
# Resumen
# ------------------------------------------------------------------------------
if [ "$FAILURES" -eq 0 ]; then
    t_ok "SUITE DE HUMO COMPLETA: todos los checks pasaron."
    exit 0
else
    t_err "SUITE DE HUMO: $FAILURES check(s) fallidos."
    exit 1
fi
