# Cola de escalado a humano (context/escalation_queue.md)

Registro de decisiones D3 (de fondo) que SOLO el investigador puede resolver.
El bucle de autonomia (academic-orchestrator) y el supervisor (run_autonomy.sh)
se detienen mientras exista al menos una fila ABIERTA: run_autonomy.sh NO
relanza sesiones con escalaciones abiertas.

## Reglas de uso

- Los modos academicos ABREN filas: ID secuencial (ESC-001, ESC-002, ...)
  y Estado inicial ABIERTO. Toda fila empieza por `| ESC-<numero> |` (el
  supervisor la detecta con ese patron).
- SOLO el investigador resuelve: escribe la Resolucion y cambia el Estado a
  RESUELTO. PROHIBIDO borrar filas (historial append-only).
- Clases de decision:
  - D1 operativa: reversible y sin impacto cientifico; la resuelve el modo
    delegado por si mismo y NO llega a esta cola.
  - D2 metodologica reversible: se resuelve y se documenta en
    context/autonomy_journal.md; NO llega a esta cola.
  - D3 de fondo: SIEMPRE aqui (hipotesis nuevas, cambio de alcance o diseno,
    presupuesto, autoria, destino de envio).
- Mientras haya filas ABIERTAS, los WPs afectados quedan con status BLOCKED
  (o ESCALATED) en data/autonomy_state.json y el supervisor imprime esta cola
  y termina sin relanzar.

| ID | Fecha (UTC) | WP | Clase | Pregunta / Decision requerida | Contexto | Resolucion (investigador) | Estado |
|----|-------------|----|-------|-------------------------------|----------|---------------------------|--------|
