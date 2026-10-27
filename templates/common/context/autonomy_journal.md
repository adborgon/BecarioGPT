# Journal de autonomia (context/autonomy_journal.md)

Registro narrativo APPEND-ONLY de la ejecucion del bucle WP-driven del motor
de autonomia (modo academic-orchestrator + supervisor run_autonomy.sh).

## Reglas

- PROHIBIDO borrar o reescribir entradas existentes: los errores se corrigen
  con una entrada nueva (mismo patron que reviews/peer_review_log.md).
- Checkpoint OBLIGATORIO al cierre de cada paso delegado: una linea por evento.
- Nunca se escribe a mitad de una operacion SSOT: el checkpoint se hace con el
  proyecto en estado estable (antes y despues del paso delegado).
- El supervisor run_autonomy.sh NO edita este fichero: solo lo hace el agente.

## Formato de entrada (una linea por evento, bajo la tabla)

| Fecha (UTC) | WP | Evento | Detalle | Resultado |
|-------------|----|--------|---------|-----------|

- Fecha-hora en formato AAAA-MM-DD HH:MM (UTC).
- Eventos validos:
  - DELEGADO   : new_task emitido (indicar modo destinatario y paso).
  - VERIFICADO : criterio de aceptacion del paso comprobado (indicar como).
  - FALLO      : criterio de aceptacion incumplido (indicar motivo).
  - ESCALADO   : decision D3 registrada en context/escalation_queue.md (indicar ID).
  - CHECKPOINT : data/autonomy_state.json actualizado.
  - SESION_FIN : cierre de sesion con motivo (budget | wait_human | done | error).
- Decisiones D2 (metodologicas reversibles) se documentan en la columna
  Detalle del evento correspondiente; las D3 van a escalation_queue.md.
