---
name: style-defluff
description: Activa esta skill como paso final de edición o revisión de cualquier texto en src/ para eliminar giros artificiales de IA, mejorar la concisión sintáctica y verificar la consistencia formal del manuscrito.
modeSlugs:
  - academic-writer
---

# Style Defluff

## Instructions

Revisa el archivo `.tex` o `.md` línea por línea aplicando estas transformaciones:

## 1. Purga de Muletillas y Adjetivos Hiperbólicos
Elimina o sustituye inmediatamente las siguientes estructuras típicas de LLMs:
- **Aperturas vacías:** Elimina frases como *"En los últimos años, X ha cobrado una importancia sin precedentes..."* o *"In the rapidly evolving landscape of..."*. Empieza directamente con el dato epidemiológico, el problema técnico o el marco teórico respaldado por `\cite{}`.
- **Adjetivos promocionales:** Sustituye *revolucionario, crucial, fundamental, exhaustivo, robusto (si no se ha demostrado estadísticamente), novedoso (salvo al definir la contribución exacta)* por descripciones cuantificables o neutras.
- **Conectores mecánicos repetitivos:** Evita encadenar párrafos empezando sistemáticamente por *"Además,", "Por otro lado,", "Asimismo,", "En conclusión,"* (*Furthermore, Moreover, Additionally, Delving deeper*). Deja que la progresión temática conecte las ideas.

## 2. Higiene Sintáctica y Técnica
- **Longitud oracional:** Divide cualquier oración que supere las 35-40 palabras y contenga más de dos cláusulas subordinadas.
- **Consistencia terminológica:** Elige un único término técnico para cada concepto (ej. no alternes aleatoriamente entre *sujetos, usuarios, pacientes, individuos y participantes* en la misma sección; usa *participantes* o *pacientes* según corresponda al estudio).
- **Acrónimos:** Verifica que todo acrónimo se defina la primera vez que aparece en el texto principal (y de forma independiente en el Abstract) y que a partir de ese punto se use solo la sigla.
- **Tiempos verbales:**
  - *Introducción / Estado del Arte:* Presente simple para hechos establecidos; pretérito perfecto/indefinido para estudios concretos previos.
  - *Metodología y Resultados:* Pasado simple (pretérito perfecto simple en castellano / *past tense* en inglés) para todo lo ejecutado y observado en el estudio.
  - *Discusión:* Pasado para recordar tus resultados; presente para interpretarlos y compararlos con la teoría.

## 3. Linter Manual (lista unificada)

Ejecuta sobre `src/*.tex` la primera pasada con la lista unificada de `.roo/rules/rules.md` + esta skill (raíces, insensible a mayúsculas, para capturar flexiones):

```bash
grep -Ein "delve|delving|tapestry|crucial|paramount|groundbreaking|revolution|realm|beacon|underscore|testament|rapidly evolving|vertiginoso|revolucionari|sin precedentes|tapiz|piedra angular|paradigma disruptivo|exhaustiv" src/*.tex
```

Segunda pasada, palabras que requieren revisión de contexto (legítimas en uso técnico, fluff en uso promocional):

```bash
grep -Ein "robust|fundamental|novel|novedos" src/*.tex
```

Apoyo para la revisión de acrónimos: extrae los que aparecen en mayúsculas y verifica su definición en la primera aparición (de forma independiente en el Abstract):

```bash
grep -noE "\b[A-Z]{2,5}\b" src/*.tex
```

## 4. Excepciones Técnicas (falsos positivos)

Antes de abrir un hallazgo, revisa el contexto de cada coincidencia: solo se penaliza el uso promocional, nunca el técnico.

- *robust/robustez/robustness:* legítimo en estadística (regresión robusta, test robusto a violaciones de normalidad) y en control (control robusto). Fluff como adjetivo hueco ("solución robusta").
- *crucial:* muletilla en castellano ("resulta crucial destacar") y adjetivo hiperbólico en inglés. "Cruciate ligament" (LCA) es término anatómico y no debe alterarse.
- *novel/novedoso:* aceptado en computación solo para artefactos nuevos con contribución demostrable y verificable; prohibido como hipérbole.
- *fundamental:* legítimo en teoremas, frecuencias fundamentales o dominios físicos; prohibido como intensificador ("importancia fundamental").
- *exhaustivo:* legítimo cuando el procedimiento cubre demostrablemente todos los casos; prohibido como adjetivo promocional de resultados.
- *underscore:* además de la muletilla verbal, es el nombre del carácter `_`; ignora las coincidencias referidas al carácter o a nombres de ficheros.

## 5. Jerarquía Normativa

- La lista de `.roo/rules/rules.md` es el **mínimo VINCULANTE** para todos los modos; esta skill la **EXTIENDE** con el linter y las excepciones anteriores.
- En caso de conflicto, gana `rules.md`.
- El grep de la fase A5 en `.roo/skills/peer-audit/SKILL.md` usa esta misma lista unificada.