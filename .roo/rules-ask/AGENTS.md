# Contexto documental (BecarioGPT)

- La documentación del repo son `README.md` (estructura, modos, skills, flujo de trabajo y guía de inicio) y `AGENTS.md` (guía técnica para agentes). La ayuda de uso del script está en la función `usage()` de `init_paper.sh` (bloque [3], líneas 129-159), visible con `-h/--help` (termina con `exit 0`).
- `init_paper.sh` es el único código: genera la estructura de proyectos de papers académicos y copia desde este repo `.roomodes`, `.roo/skills/` y `.roo/rules/rules.md` (como `00_academic_core.md`). No hay package.json ni manifests.
- Nombres engañosos de la estructura GENERADA (no de este repo): `src/` son secciones LaTeX del paper, no código; `reviews/` es revisión por pares académica ("Reviewer 2"), no code review; `context/` es estado de investigación (hipótesis/evidencia), no contexto de IA; `rag/` es la base de conocimiento local (convocatorias, proyectos pasados, plantillas).
- Los proyectos generados usan la convención estándar de Roo: `.roomodes` en la raíz y `.roo/` para reglas y skills. La antigua convención `.zoocode/` ya no existe.
- Los 4 modos académicos (research-architect, lit-synthesizer, academic-writer, reviewer-2) están definidos en `.roomodes` con permisos de edición por `fileRegex`; las 8 skills viven en `.roo/skills/`.
