---
name: methods-reporting
description: Activa esta skill al redactar o auditar la sección de Materiales y Métodos, Diseño Experimental, Arquitectura del Sistema o Análisis Estadístico en un artículo.
modeSlugs:
  - academic-writer
---

# Methods Reporting

## Instructions

Antes de redactar `src/02_methodology.tex` (o equivalente), cruza `context/hypothesis_matrix.md` con `data/stats_summary.json`.

## Estructura Obligatoria de Subsecciones

### 1. Participantes / Muestra o Dataset (`\subsection{Participants}`)
- Reporta tamaño muestral ($N$), distribución por grupos, datos demográficos (edad media $\pm$ DE, sexo) tomados de `data/stats_summary.json`.
- Especifica criterios de inclusión y exclusión.
- Incluye declaración de aprobación del comité ético y consentimiento informado (si no consta el código de comité, inserta `\todo{CÓDIGO COMITÉ ÉTICO}`).

### 2. Sistema Experimental / Arquitectura (`\subsection{Experimental Setup / System Architecture}`)
- Describe de forma desacoplada el **Hardware** (dispositivos de visualización, sensores, estaciones de trabajo) y el **Software** (motor, arquitectura modular, algoritmos o modelos empleados, frecuencia de muestreo/FPS).
- Si se describe un entorno interactivo o tarea experimental, detalla los parámetros configurables y el flujo de datos de entrada/salida.

### 3. Protocolo y Procedimiento (`\subsection{Procedure}`)
- Describe cronológicamente qué hizo el participante o cómo se ejecutó el experimento (fases de calibración/familiarización, duración en minutos, número de ensayos o sesiones, orden de condiciones y contrabalanceo).

### 4. Medidas y Variables (`\subsection{Outcome Measures}`)
- Divide claramente entre **Variables Objetivas / Rendimiento** (ej. tiempo de ejecución, error, precisión, cinemática) y **Variables Subjetivas / Clínicas** (cuestionarios validados con su cita original y rango de puntuación).
- Regla de trazabilidad: Toda métrica que exista en `data/stats_summary.json` DEBE quedar definida formalmente en esta subsección.

### 5. Análisis Estadístico (`\subsection{Statistical Analysis}`)
- Especifica cómo se comprobó la normalidad (ej. Shapiro-Wilk) y homocedasticidad (Levene).
- Indica qué pruebas paramétricas (t-test, ANOVA mixto, Pearson) o no paramétricas (Mann-Whitney U, Wilcoxon, Friedman, Spearman) se aplicaron según la distribución.
- Declara el nivel de significancia ($\alpha = 0.05$), las correcciones por comparaciones múltiples (ej. Bonferroni, Holm) y el estadístico de tamaño del efecto reportado ($\eta_p^2$, $d$ de Cohen, $r$).
- Indica el software estadístico utilizado y su versión.
- Reporta el intervalo de confianza al 95% (IC 95%) junto a cada $p$-valor; el $p$-valor aislado no constituye evidencia suficiente.
- Reporta el tamaño del efecto junto a la significancia ($d$ de Cohen, $\eta_p^2$, $r$) y su IC 95% cuando sea calculable.
- Distingue explícitamente entre análisis pre-registrados (confirmatorios) y análisis exploratorios declarados como tales.
- Fidelidad de datos (`.roo/rules/rules.md`): toda métrica usada en `src/` debe provenir exactamente de `data/stats_summary.json` o `context/hypothesis_matrix.md`. Si un dato aún no está calculado, inserta `\todo{DATO PENDIENTE: [nombre de la métrica]}`.

## Checklist según Diseño (EQUATOR)

Identifica el diseño del estudio registrado en `data/stats_summary.json` (`study_metadata.design`) y aplica la checklist EQUATOR correspondiente al redactar y al auditar:

| Diseño | Estándar EQUATOR |
|---|---|
| Ensayo controlado aleatorizado (RCT) | CONSORT 2010 |
| Estudio observacional (cohorte, casos y controles, transversal) | STROBE |
| Modelo de predicción (clínico o con IA) | TRIPOD (+AI) |
| Reporte de caso(s) | CARE |
| Exactitud diagnóstica | STARD |
| Revisión sistemática | PRISMA 2020 |
| Protocolo de ensayo | SPIRIT |

- Si `study_metadata.design` no está registrado, inserta `\todo{DATO PENDIENTE: study_metadata.design}` y solicita a research-architect su registro.
- Verifica la checklist del estándar ítem a ítem; los ítems no cubiertos se registran como hallazgos de auditoría (ver `.roo/skills/peer-audit/SKILL.md`).

## Justificación del Tamaño Muestral

- **Power analysis:** justifica el tamaño muestral con el tamaño del efecto esperado (y su fuente: meta-análisis previo o estudio piloto), el $\alpha$, la potencia objetivo ($\geq 0.80$; preferible $0.90$), la prueba estadística prevista y el software de cálculo con su versión.
- **Pre-registro:** si el estudio está pre-registrado (OSF, PROSPERO u otro registro), cita la URL registrada en `data/stats_summary.json` (`study_metadata.preregistration_url`) y qué análisis quedaron vinculados al registro. Si no existe registro, inserta `\todo{DATO PENDIENTE: preregistration_url}` en lugar de afirmarlo.

## Datos Faltantes y Atípicos

- Declara el mecanismo de datos faltantes asumido (MCAR, MAR o MNAR) y su justificación.
- Documenta el método de tratamiento o imputación empleado (p. ej. imputación múltiple, modelos de efectos mixtos) con sus parámetros.
- Define un criterio explícito de outliers (p. ej. $\pm 3$ DE o $1.5 \times$ RIC) aplicado de forma uniforme; las exclusiones ad hoc no reportadas están prohibidas.

## Reproducibilidad

- Registra las semillas aleatorias de todos los procesos estocásticos (asignación de participantes, imputación, inicialización de modelos).
- Reporta las versiones de software y paquetes utilizados, incluido el fichero de entorno o gestor de dependencias.
- Declara la disponibilidad del código de análisis: repositorio con DOI/URL, o restricción justificada.

## Declaraciones

- **Comité de ética y consentimiento informado:** ya declarados en la subsección Participantes; verifica que el código del comité conste (si no, `\todo{CÓDIGO COMITÉ ÉTICO}`).
- **Conflictos de interés:** declaración explícita, incluida la ausencia de conflictos cuando no los haya.
- **Financiación:** agencia, referencia de la convocatoria y papel del financiador; consulta `context/call_guidelines.md` si se trata de un proyecto competitivo.
- **Disponibilidad de datos y código:** repositorio con DOI/URL, o restricciones justificadas (p. ej. privacidad de los participantes).
- **Autoría:** atribución según la taxonomía CRediT (rol o roles de cada autor); sin autores de regalo ni autoría fantasma.
