# -*- coding: utf-8 -*-
"""Commit + push de F5 con pre-chequeo HEAD, escaneo de secretos y verificacion remota."""
import re
import sys

sys.path.insert(0, r"C:\Adborgon")

from git import Repo  # noqa: E402
from Core.tools.git_local_manager import GitLocalManager  # noqa: E402

REPO = r"c:/Users/adborgon/Desktop/BecarioGPT"
REPORT = "_f5_git_report.txt"
log_lines = []


def log(msg):
    log_lines.append(str(msg))


def finish(code, extra):
    log(extra)
    open(REPORT, "w", encoding="utf-8").write("\n".join(log_lines))
    sys.exit(code)


SECRET_PATTERNS = [
    (re.compile(r"s2k-[A-Za-z0-9_-]{8,}"), "token s2k- (Semantic Scholar)"),
    (re.compile(r'SEMANTIC_SCHOLAR_API_KEY\s*[:=]\s*["\']?[A-Za-z0-9]{8,}'), "clave SEMANTIC_SCHOLAR_API_KEY en claro"),
    (re.compile(r':\s*"[A-Za-z0-9_.-]{20,}"'), "valor largo tipo clave API en JSON"),
]
BINARY_EXT = (".png", ".jpg", ".jpeg", ".gif", ".pdf", ".zip", ".ico")

repo = Repo(REPO)
mgr = GitLocalManager(REPO)

# --- 0) Rama actual -------------------------------------------------------
branch = mgr.current_branch()
log("BRANCH=%s" % branch)
if branch != "main":
    finish(2, "ABORT: la rama activa es %s (se esperaba main)" % branch)

# --- 1) Pre-chequeo HEAD con fetch (verificar SHA real) -------------------
repo.remotes.origin.fetch()
origin_sha = repo.commit("origin/main").hexsha
head_sha = repo.head.commit.hexsha
log("HEAD_REAL=%s" % head_sha[:12])
log("ORIGIN_MAIN=%s" % origin_sha[:12])
if origin_sha != head_sha and not repo.is_ancestor(origin_sha, head_sha):
    finish(2, "ABORT: origin/main (%s) no es ancestro de HEAD (%s): integra el remoto primero" % (origin_sha[:12], head_sha[:12]))
log("PRECHECK_OK: HEAD en main contiene origin/main")

# --- 2) Stage -------------------------------------------------------------
mgr.stage(["."])
staged = repo.git.diff("--cached", "--name-only").splitlines()
log("STAGED_FILES=%d" % len(staged))
for p in sorted(staged):
    log("  + %s" % p)

# --- 3) .roo/mcp.json local NUNCA en el indice ----------------------------
if ".roo/mcp.json" in staged:
    finish(2, "ABORT: .roo/mcp.json (config local con posible clave) esta staged")

# --- 4) Escaneo de secretos sobre los blobs staged ------------------------
leaks = []
for path in staged:
    if path.lower().endswith(BINARY_EXT):
        continue
    try:
        with open(REPO + "/" + path, "rb") as fh:
            text = fh.read().decode("utf-8", "replace")
    except OSError:
        continue
    for pattern, label in SECRET_PATTERNS:
        for m in pattern.finditer(text):
            snippet = text[max(0, m.start() - 25):m.end() + 10].replace("\n", " ")
            leaks.append("%s :: %s :: ...%s..." % (path, label, snippet))
if leaks:
    log("SECRETO_REAL_DETECTADO: ABORT sin commit")
    for l in leaks:
        log("  LEAK: %s" % l)
    finish(2, "REDACTADO EN REPORT")
log("SECRET_SCAN_OK: %d ficheros staged sin secretos reales" % len(staged))

# --- 5) Commit ------------------------------------------------------------
title = "feat: F5 \u2014 tipo grant (propuestas competitivas/PPC) y sistema de conocimiento local RAG"
body = "\n".join([
    "Memoria PPC de 9 secciones (00_resumen -> 08_risks) con Gantt booktabs en 05_wps.",
    "SSOT del tipo: data/consortium.yaml, data/budget.yaml (importes PENDIENTE) y context/convocatoria_checklist.md.",
    "Skills: peer-audit A7 (cobertura de convocatoria), methods-reporting sin EQUATOR en grant, project-init con rama grant y grant-workpackages reforzado (hitos anclados a la convocatoria, KPI a 04_impact).",
    "Sistema de conocimiento local RAG: READMEs de intake en templates/common/rag/{calls,past_projects,templates} y seccion 8 del marco academico; fileRegex de research-architect ampliado a todo rag/.",
    "Suite de humo con 5 tipos (grant incluido) y retrocompatibilidad default==imrad intacta.",
])
sha = mgr.commit(title + "\n\n" + body)
log("COMMIT_SHA=%s" % sha)

# --- 6) Push fast-forward -------------------------------------------------
infos = mgr.push()
for info in infos:
    log("PUSH: %s (flags=%s)" % (info.summary.strip(), info.flags))

# --- 7) Verificacion remota: origin/main == HEAD y blobs sin secretos -----
repo.remotes.origin.fetch()
new_origin = repo.commit("origin/main").hexsha
if new_origin != repo.head.commit.hexsha:
    finish(2, "ABORT POST-PUSH: origin/main (%s) != HEAD (%s)" % (new_origin[:12], repo.head.commit.hexsha[:12]))
log("POSTPUSH_OK: origin/main == HEAD (%s)" % new_origin[:12])

tree = repo.commit("origin/main").tree
remote_leaks = []
for path in staged:
    if path.lower().endswith(BINARY_EXT):
        continue
    try:
        blob = tree / path
    except KeyError:
        continue
    text = blob.data_stream.read().decode("utf-8", "replace")
    for pattern, label in SECRET_PATTERNS:
        if pattern.search(text):
            remote_leaks.append("%s :: %s" % (path, label))
if remote_leaks:
    log("ALERTA: secretos en blobs remotos (REVISAR YA):")
    for l in remote_leaks:
        log("  REMOTE_LEAK: %s" % l)
    finish(2, "REDACTADO EN REPORT")
log("REMOTE_BLOB_SCAN_OK: blobs remotos del commit sin secretos")

finish(0, "F5_PUBLICADO_OK")
