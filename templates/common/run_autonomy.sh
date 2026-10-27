#!/usr/bin/env bash
# ==============================================================================
# run_autonomy.sh
# Supervisor fino del motor de autonomia (F4) de BecarioGPT.
#
# Uso (en la raiz de un proyecto generado con init_paper.sh):
#   bash run_autonomy.sh [--project <dir>] [--max-iterations N]
#                        [--timeout-minutes M] [--cli <comando>] [--dry-run]
#
# Comportamiento:
#   - Precondiciones: data/workpackages.yaml existe, data/autonomy_state.json
#     es parseable y context/escalation_queue.md esta presente. Si falta algo,
#     [ERROR] y exit 1.
#   - Gate de escalaciones: si context/escalation_queue.md contiene filas
#     ABIERTAS (filas | ESC-<n> | ... ABIERTO ...) o el estado es
#     ESCALATED/BLOCKED, NO relanza: imprime lo pendiente y exit 0.
#   - Presupuesto: si iterations_used >= --max-iterations, no lanza sesiones
#     (sube --max-iterations para continuar). exit 0.
#   - Sin CLI disponible (ni autodetectada zoo/roo ni dada por --cli):
#     MODO MANUAL: imprime el PROMPT de continuacion para pegarlo en una
#     sesion interactiva del modo academic-orchestrator y exit 0.
#   - Con CLI: lanza sesiones headless (prompt como primer argumento) con
#     timeout GNU coreutils si esta disponible (si no, avisa y ejecuta sin
#     limite documentandolo); al terminar cada sesion relee
#     data/autonomy_state.json (status/iterations_used) y decide: continuar
#     mientras iteraciones < max y estado != ESCALATED/BLOCKED, parar por
#     presupuesto o parar por escalacion (nunca relanza con escalaciones
#     abiertas). El journal lo edita el agente, NUNCA este script.
#   - Seguros internos: tope de sesiones = --max-iterations (peor caso 1
#     iteracion por sesion) y parada si 3 sesiones consecutivas no dejan
#     ninguna huella en el estado (evita bucles infinitos con un CLI roto).
#   - Mensajes ASCII puro [OK]/[WARN]/[ERROR]; idempotente y seguro de
#     re-ejecutar. Requiere bash real (Git Bash/WSL en Windows).
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# [1] Mensajeria ASCII
# ------------------------------------------------------------------------------
msg_ok()   { printf '[OK]    %s\n' "$*"; }
msg_warn() { printf '[WARN]  %s\n' "$*"; }
msg_err()  { printf '[ERROR] %s\n' "$*" >&2; }

usage() {
    cat <<'USAGE_EOF'
run_autonomy.sh - Supervisor fino del motor de autonomia (bucle WP-driven).

Uso:
  bash run_autonomy.sh [--project <dir>] [--max-iterations N]
                       [--timeout-minutes M] [--cli <comando>] [--dry-run]

Argumentos:
  --project <dir>        Directorio del proyecto generado (por defecto: '.').
  --max-iterations N     Presupuesto duro de iteraciones (delegaciones new_task
                         acumuladas en data/autonomy_state.json). Por defecto 40.
  --timeout-minutes M    Timeout por sesion headless, en minutos. Por defecto 240.
                         Requiere 'timeout' de GNU coreutils; si no existe, la
                         sesion corre sin limite (con aviso).
  --cli <comando>        Comando de CLI headless del agente. Por defecto se
                         autodetecta 'zoo' o 'roo' con command -v. Si no hay
                         CLI, el supervisor entra en MODO MANUAL (imprime el
                         prompt de continuacion y sale sin lanzar nada).
  --dry-run              Muestra el plan (precondiciones, presupuesto, CLI y
                         prompt) sin lanzar ninguna sesion. Exit 0.
  -h, --help             Muestra esta ayuda y termina con codigo 0.

Salida: mensajes ASCII [OK]/[WARN]/[ERROR]. El estado de ejecucion vive en
data/autonomy_state.json; la narrativa en context/autonomy_journal.md; las
decisiones D3 en context/escalation_queue.md (una fila ABIERTA impide el
relanzamiento).
USAGE_EOF
}

# ------------------------------------------------------------------------------
# [2] Parseo y validacion de argumentos
# ------------------------------------------------------------------------------
PROJECT="."
MAX_ITER=40
TIMEOUT_MIN=240
CLI_ARG=""
DRY_RUN=0

while [ "$#" -gt 0 ]; do
    case "$1" in
        --project)
            if [ "$#" -lt 2 ]; then
                msg_err "La opcion --project requiere un valor (directorio del proyecto)."
                exit 1
            fi
            PROJECT="$2"
            shift 2
            ;;
        --max-iterations)
            if [ "$#" -lt 2 ]; then
                msg_err "La opcion --max-iterations requiere un valor numerico N."
                exit 1
            fi
            case "$2" in
                ''|*[!0-9]*)
                    msg_err "--max-iterations debe ser un entero positivo (recibido: '$2')."
                    exit 1
                    ;;
            esac
            MAX_ITER="$2"
            shift 2
            ;;
        --timeout-minutes)
            if [ "$#" -lt 2 ]; then
                msg_err "La opcion --timeout-minutes requiere un valor numerico M."
                exit 1
            fi
            case "$2" in
                ''|*[!0-9]*)
                    msg_err "--timeout-minutes debe ser un entero positivo (recibido: '$2')."
                    exit 1
                    ;;
            esac
            TIMEOUT_MIN="$2"
            shift 2
            ;;
        --cli)
            if [ "$#" -lt 2 ]; then
                msg_err "La opcion --cli requiere un valor (comando de CLI headless)."
                exit 1
            fi
            CLI_ARG="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            msg_err "Argumento no reconocido: '$1'"
            echo
            usage
            exit 1
            ;;
    esac
done

if [ "$MAX_ITER" -lt 1 ] || [ "$TIMEOUT_MIN" -lt 1 ]; then
    msg_err "--max-iterations y --timeout-minutes deben ser mayores que cero."
    exit 1
fi

# ------------------------------------------------------------------------------
# [3] Localizacion del proyecto y precondiciones
# ------------------------------------------------------------------------------
if [ ! -d "$PROJECT" ]; then
    msg_err "El directorio del proyecto no existe: $PROJECT"
    exit 1
fi
PROJECT_ABS=$(cd "$PROJECT" && pwd)

WP_FILE="$PROJECT_ABS/data/workpackages.yaml"
STATE_FILE="$PROJECT_ABS/data/autonomy_state.json"
QUEUE_FILE="$PROJECT_ABS/context/escalation_queue.md"

if [ ! -s "$WP_FILE" ]; then
    msg_err "Falta $WP_FILE (SSOT del plan; no se lanza el bucle)."
    exit 1
fi
if [ ! -f "$QUEUE_FILE" ] || [ ! -s "$QUEUE_FILE" ]; then
    msg_err "Falta o esta vacio $QUEUE_FILE (cola de escalado D3)."
    exit 1
fi

# Python opcional: con el, parseo JSON completo; sin el, validacion estructural.
PYTHON_BIN=""
if command -v python >/dev/null 2>&1; then
    PYTHON_BIN=python
elif command -v python3 >/dev/null 2>&1; then
    PYTHON_BIN=python3
elif command -v py >/dev/null 2>&1; then
    PYTHON_BIN=py
fi

# read_state "$STATE_FILE": deja STATE_STATUS y STATE_ITER; aborta si el JSON
# no es parseable (con python) o carece de la estructura minima (sin python).
read_state() {
    _f="$1"
    STATE_STATUS=""
    STATE_ITER=0
    if [ -n "$PYTHON_BIN" ]; then
        set +e
        _out=$("$PYTHON_BIN" -c "import json,sys
d=json.load(open(sys.argv[1], encoding='utf-8'))
print((d.get('current') or {}).get('status') or '')
print(int(d.get('iterations_used') or 0))" "$_f" 2>/dev/null)
        _rc=$?
        set -e
        if [ "$_rc" -ne 0 ]; then
            msg_err "$_f no es JSON parseable (validado con python)."
            exit 1
        fi
        STATE_STATUS=$(printf '%s\n' "$_out" | sed -n '1p')
        STATE_ITER=$(printf '%s\n' "$_out" | sed -n '2p')
    else
        if ! grep -q '"schema_version"' "$_f" || ! grep -q '"status"' "$_f" \
            || ! grep -q '"iterations_used"' "$_f"; then
            msg_err "$_f carece de la estructura minima esperada (sin python para validar el JSON completo)."
            exit 1
        fi
        msg_warn "python no disponible: validacion estructural de $_f (sin parseo JSON completo)."
        STATE_STATUS=$(LC_ALL=C grep -Eo '"status"[[:space:]]*:[[:space:]]*"[A-Z_]+"' "$_f" | head -n 1 | cut -d '"' -f 4)
        _it=$(LC_ALL=C grep -Eo '"iterations_used"[[:space:]]*:[[:space:]]*[0-9]+' "$_f" | head -n 1 | tr -dc '0-9')
        if [ -n "$_it" ]; then
            STATE_ITER=$_it
        fi
    fi
    if [ -z "$STATE_STATUS" ]; then
        STATE_STATUS="PENDING"
    fi
}

read_state "$STATE_FILE"
msg_ok "Proyecto: $PROJECT_ABS"
msg_ok "Estado actual: status=$STATE_STATUS iterations_used=$STATE_ITER"

# ------------------------------------------------------------------------------
# [4] Gate de escalaciones: NUNCA relanzar con filas ABIERTAS ni estado bloqueado
# ------------------------------------------------------------------------------
count_open_escalations() {
    _f="$1"
    _n=$(LC_ALL=C grep -E '^\| ESC-[0-9]+' "$_f" 2>/dev/null | LC_ALL=C grep -cw 'ABIERTO' || true)
    printf '%s' "${_n:-0}"
}

OPEN_ESCALATIONS=$(count_open_escalations "$QUEUE_FILE")

print_open_escalations() {
    echo "Filas ABIERTAS detectadas en context/escalation_queue.md:"
    LC_ALL=C grep -E '^\| ESC-[0-9]+' "$QUEUE_FILE" 2>/dev/null | LC_ALL=C grep -w 'ABIERTO' || true
}

if [ "$OPEN_ESCALATIONS" -gt 0 ]; then
    msg_warn "ESCALACIONES ABIERTAS: $OPEN_ESCALATIONS fila(s). No se relanza ningun sesion."
    print_open_escalations
    echo
    echo "Instrucciones: resuelve cada decision D3 en context/escalation_queue.md"
    echo "(escribe la Resolucion y cambia el Estado a RESUELTO; solo el investigador"
    echo "puede hacerlo) y re-ejecuta run_autonomy.sh para continuar."
    exit 0
fi

if [ "$STATE_STATUS" = "ESCALATED" ] || [ "$STATE_STATUS" = "BLOCKED" ]; then
    msg_warn "Estado del proyecto: $STATE_STATUS. Espera al investigador (D3) antes de continuar."
    echo "Instrucciones: revisa context/escalation_queue.md y context/autonomy_journal.md;"
    echo "cuando el bloqueo quede resuelto, pon current.status=IN_PROGRESS en"
    echo "data/autonomy_state.json y re-ejecuta run_autonomy.sh."
    exit 0
fi

REMAINING_ITER=$((MAX_ITER - STATE_ITER))
if [ "$REMAINING_ITER" -le 0 ]; then
    msg_warn "Presupuesto agotado: iterations_used=$STATE_ITER >= --max-iterations=$MAX_ITER."
    echo "Instrucciones: para continuar el bucle, re-ejecuta con un presupuesto mayor"
    echo "(p. ej. --max-iterations $((STATE_ITER + 40)))."
    exit 0
fi

# ------------------------------------------------------------------------------
# [5] CLI: autodeteccion o argumento; 'timeout' de GNU coreutils si existe
# ------------------------------------------------------------------------------
CLI_BIN=""
if [ -n "$CLI_ARG" ]; then
    if command -v "$CLI_ARG" >/dev/null 2>&1; then
        CLI_BIN="$CLI_ARG"
        msg_ok "CLI headless (fijada por --cli): $CLI_BIN"
    else
        msg_warn "La CLI indicada ('$CLI_ARG') no existe en el PATH: se degrada a MODO MANUAL."
    fi
else
    for _c in zoo roo; do
        if command -v "$_c" >/dev/null 2>&1; then
            CLI_BIN="$_c"
            break
        fi
    done
    if [ -n "$CLI_BIN" ]; then
        msg_ok "CLI headless autodetectada: $CLI_BIN"
    else
        msg_warn "No se ha detectado CLI headless (zoo/roo) en el PATH: MODO MANUAL."
    fi
fi

TIMEOUT_BIN=""
if [ -x /usr/bin/timeout ]; then
    TIMEOUT_BIN=/usr/bin/timeout
elif command -v timeout >/dev/null 2>&1; then
    if command -v timeout >/dev/null 2>&1 && timeout --version >/dev/null 2>&1; then
        TIMEOUT_BIN=$(command -v timeout)
    fi
fi
if [ -n "$TIMEOUT_BIN" ]; then
    msg_ok "Timeout por sesion: $TIMEOUT_MIN minutos (GNU coreutils)."
else
    msg_warn "No se encontro 'timeout' de GNU coreutils: las sesiones correran SIN limite de tiempo (documentado)."
fi

# ------------------------------------------------------------------------------
# [6] Prompt de continuacion (el mismo para sesion headless y modo manual)
# ------------------------------------------------------------------------------
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
PROMPT_FILE="$TMP_DIR/continuation_prompt.txt"

cat > "$PROMPT_FILE" <<PROMPT_EOF
Continua el bucle WP-driven del motor de autonomia de BecarioGPT en el modo
academic-orchestrator.

PROYECTO: $PROJECT_ABS
PRESUPUESTO DE ESTA SESION: $REMAINING_ITER iteraciones restantes (usadas $STATE_ITER de $MAX_ITER); timeout de sesion: $TIMEOUT_MIN minutos.

Contrato completo: .roo/rules/00_academic_core.md seccion 7 (ciclo de autonomia).
Instrucciones:
1. Lee data/autonomy_state.json, context/autonomy_journal.md, data/workpackages.yaml y context/hypothesis_matrix.md.
2. Si hay filas ABIERTAS en context/escalation_queue.md o current.status es ESCALATED/BLOCKED: NO delegates nada; registra SESION_FIN (wait_human) en el journal y termina.
3. Elige la siguiente tarea pendiente del WP corriente (respetando dependencias) y delega UN paso por new_task al modo academico responsable (lit-synthesizer: evidencia/citas; academic-writer: src/; reviewer-2: auditoria; research-architect: datos/diseno/plan) con criterio de aceptacion explicito.
4. Verifica el criterio de aceptacion del paso (test -s, grep, latexmk). Si falla, reintenta o escala; NUNCA inventes datos ni citas (reglas 1-2 del marco academico).
5. Checkpoint por paso: append en context/autonomy_journal.md (tabla; eventos DELEGADO/VERIFICADO/FALLO/ESCALADO/CHECKPOINT/SESION_FIN) + escritura ATOMICA de data/autonomy_state.json (current, completed, iterations_used, updated_at). Nunca a mitad de una escritura SSOT.
6. Cada delegacion new_task suma 1 iteracion (iterations_used). Al agotar las $REMAINING_ITER iteraciones de esta sesion: cierra limpio (status BUDGET_EXHAUSTED + SESION_FIN) y termina.
7. Decisiones: D1 las resuelve el modo delegado; D2 las resuelves tu documentando la justificacion en el journal; D3 van SIEMPRE a context/escalation_queue.md (fila nueva | ESC-NNN | ... | ABIERTO |) y el WP queda BLOCKED en el espejo de estado.
8. Al terminar la sesion: SESION_FIN en el journal y current.status actualizado (IN_PROGRESS/BLOCKED/ESCALATED/BUDGET_EXHAUSTED/DONE).
PROMPT_EOF

# ------------------------------------------------------------------------------
# [7] Dry-run: mostrar el plan y salir sin lanzar nada
# ------------------------------------------------------------------------------
if [ "$DRY_RUN" -eq 1 ]; then
    msg_ok "DRY-RUN: plan del supervisor (no se lanza ninguna sesion)."
    echo "  - Precondiciones: OK (workpackages.yaml, autonomy_state.json, escalation_queue.md)."
    echo "  - Escalaciones ABIERTAS: $OPEN_ESCALATIONS."
    echo "  - Estado: status=$STATE_STATUS iterations_used=$STATE_ITER."
    echo "  - Presupuesto: --max-iterations=$MAX_ITER (restan $REMAINING_ITER); timeout por sesion: $TIMEOUT_MIN min ($([ -n "$TIMEOUT_BIN" ] || echo 'SIN timeout coreutils'))."
    if [ -n "$CLI_BIN" ]; then
        echo "  - CLI headless: $CLI_BIN (sesiones lanzadas como: $CLI_BIN <prompt>)."
        echo "  - Tope de sesiones: $MAX_ITER (peor caso 1 iteracion por sesion)."
    else
        echo "  - CLI headless: NO DISPONIBLE -> MODO MANUAL (prompt de continuacion abajo)."
    fi
    echo
    echo "--- PROMPT DE CONTINUACION (pega esto en una sesion del modo academic-orchestrator) ---"
    cat "$PROMPT_FILE"
    echo "----------------------------- FIN DEL PROMPT -------------------------------------------"
    msg_ok "DRY-RUN completado: no se ha lanzado ninguna sesion."
    exit 0
fi

# ------------------------------------------------------------------------------
# [8] MODO MANUAL: sin CLI, imprimir el prompt y salir (degradacion elegante)
# ------------------------------------------------------------------------------
if [ -z "$CLI_BIN" ]; then
    echo
    echo "================ MODO MANUAL: PROMPT DE CONTINUACION ================"
    echo "No hay CLI headless disponible. Abre una sesion interactiva del modo"
    echo "academic-orchestrator en el proyecto y pega el siguiente prompt:"
    echo
    cat "$PROMPT_FILE"
    echo "====================================================================="
    msg_ok "MODO MANUAL mostrado: el bucle continua cuando el agente escriba los checkpoints."
    exit 0
fi

# ------------------------------------------------------------------------------
# [9] Bucle de sesiones headless: lanzar, releer estado y decidir
# ------------------------------------------------------------------------------
SESSION=0
MAX_SESSIONS=$MAX_ITER
STALL_COUNT=0
STOP_REASON=""

while [ "$SESSION" -lt "$MAX_SESSIONS" ]; do
    SESSION=$((SESSION + 1))
    msg_ok "Sesion $SESSION/$MAX_SESSIONS: lanzando $CLI_BIN (timeout: $TIMEOUT_MIN min) ..."

    set +e
    if [ -n "$TIMEOUT_BIN" ]; then
        "$TIMEOUT_BIN" "$((TIMEOUT_MIN * 60))" "$CLI_BIN" "$(cat "$PROMPT_FILE")"
        SESSION_RC=$?
    else
        "$CLI_BIN" "$(cat "$PROMPT_FILE")"
        SESSION_RC=$?
    fi
    set -e

    if [ "$SESSION_RC" -eq 124 ]; then
        msg_warn "Sesion $SESSION cortada por timeout ($TIMEOUT_MIN min)."
    elif [ "$SESSION_RC" -ne 0 ]; then
        msg_warn "Sesion $SESSION termino con codigo $SESSION_RC; se relee el estado antes de decidir."
    else
        msg_ok "Sesion $SESSION terminada correctamente (codigo 0)."
    fi

    PRE_ITER=$STATE_ITER
    PRE_STATUS=$STATE_STATUS
    read_state "$STATE_FILE"

    OPEN_ESCALATIONS=$(count_open_escalations "$QUEUE_FILE")
    if [ "$OPEN_ESCALATIONS" -gt 0 ]; then
        STOP_REASON="escalacion"
        msg_warn "La sesion abrio $OPEN_ESCALATIONS escalacion(es) ABIERTA(S): no se relanza."
        print_open_escalations
        break
    fi
    if [ "$STATE_STATUS" = "ESCALATED" ] || [ "$STATE_STATUS" = "BLOCKED" ]; then
        STOP_REASON="bloqueo (status $STATE_STATUS)"
        msg_warn "Estado $STATE_STATUS tras la sesion $SESSION: se detiene el bucle (espera al investigador)."
        break
    fi
    if [ "$STATE_ITER" -ge "$MAX_ITER" ]; then
        STOP_REASON="presupuesto"
        msg_ok "Presupuesto agotado: iterations_used=$STATE_ITER >= $MAX_ITER."
        break
    fi
    if [ "$STATE_ITER" -eq "$PRE_ITER" ] && [ "$STATE_STATUS" = "$PRE_STATUS" ]; then
        STALL_COUNT=$((STALL_COUNT + 1))
        if [ "$STALL_COUNT" -ge 3 ]; then
            STOP_REASON="sin progreso"
            msg_err "3 sesiones consecutivas sin cambios en data/autonomy_state.json: se detiene el bucle."
            msg_err "Revisa la CLI ('$CLI_BIN'), el prompt y que el agente escriba checkpoints."
            exit 1
        fi
        msg_warn "Sesion $SESSION sin progreso observable en el estado ($STALL_COUNT/3)."
    else
        STALL_COUNT=0
    fi
    REMAINING_ITER=$((MAX_ITER - STATE_ITER))
    msg_ok "Sesion $SESSION verificada: status=$STATE_STATUS iterations_used=$STATE_ITER (restan $REMAINING_ITER)."
done

if [ -z "$STOP_REASON" ]; then
    STOP_REASON="tope de sesiones ($MAX_SESSIONS)"
    msg_warn "Se alcanzo el tope de sesiones ($MAX_SESSIONS) sin motivo de parada del estado."
fi

msg_ok "Supervision terminada: motivo='$STOP_REASON' status=$STATE_STATUS iterations_used=$STATE_ITER sesiones=$SESSION."
echo "Siguiente paso: revisa context/autonomy_journal.md y data/autonomy_state.json;"
echo "para continuar, re-ejecuta run_autonomy.sh."
exit 0
