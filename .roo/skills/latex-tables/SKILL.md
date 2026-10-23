---
name: latex-tables
description: Activa esta skill cuando debas generar o actualizar tablas de resultados, demográficas o comparativas en LaTeX a partir de data/stats_summary.json.
modeSlugs:
  - academic-writer
---

# Latex Tables

## Instructions

Usa exclusivamente el paquete `booktabs` (`\toprule`, `\midrule`, `\bottomrule`).

## 1. Prohibiciones de Formato
- NUNCA uses líneas verticales (`|`) en la definición de columnas de `tabular`.
- NUNCA uses `\hline` ni dobles barras horizontales `\hline\hline`.
- Usa `\cmidrule(lr){x-y}` para agrupar subcolumnas (por ejemplo, separar condiciones "Pre" y "Post" o "Grupo Control" y "Grupo Experimental").

## 2. Convenciones Numéricas y Estadísticas
- **Precisión decimal consistente:** Mantén el mismo número de decimales por columna (normalmente 2 decimales para medias, desviaciones típicas y estadísticos; 3 decimales para $p$-valores).
- **Reporte de distribución:**
  - Variables normales: `Media $\pm$ DE` (ej. `45.20 $\pm$ 6.14`).
  - Variables no normales: `Mediana (RIC)` o `Mediana [Q1, Q3]` (ej. `42.50 (8.25)`).
- **Valores $p$:**
  - No escribas `p = 0.000`. Si es menor que una milésima, escribe `$p < 0.001$`.
  - Resalta en **negrita** (`\textbf{...}`) los valores $p$ estadísticamente significativos ($p < 0.05$) o añade asteriscos estandarizados (`*`, `**`) explicados al pie.

## 3. Plantilla Base Obligatoria
```latex
\begin{table}[htbp]
\centering
\caption{Título descriptivo y autónomo de la tabla (arriba de la tabla).}
\label{tab:identificador_unico}
\begin{tabular}{lcccc}
\toprule
\textbf{Variable} & \textbf{Grupo A ($n = X$)} & \textbf{Grupo B ($n = Y$)} & \textbf{Estadístico ($F / t / U$)} & \textbf{$p$-valor ($\eta_p^2 / d$)} \\
\midrule
Métrica 1 (unidades) & 0.00 $\pm$ 0.00 & 0.00 $\pm$ 0.00 & 0.00 & \textbf{0.012} (0.14) \\
\bottomrule
\end{tabular}
\par\smallskip
\footnotesize{\textit{Nota:} Valores expresados como media $\pm$ desviación estándar. Negrita indica $p < 0.05$.}
\end{table}
```

## 4. Buenas Prácticas booktabs

- Jerarquía de reglas: `\toprule` al inicio de la cabecera, `\midrule` para separadores internos y `\bottomrule` para cerrar la tabla. Nunca las combines con `\hline`.
- Sin líneas verticales: prohibido usar `|` en la especificación de columnas; agrupa subcolumnas con `\cmidrule(lr){...}`.
- Añade `\usepackage{booktabs}` al preámbulo; el paquete no se carga por defecto.
