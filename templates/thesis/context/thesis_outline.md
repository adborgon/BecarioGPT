# Capitulacion de la Tesis (SSOT)

> Fuente de verdad de la estructura por capitulos. Toda decision de estructura
> (anadir, reordenar o renombrar capitulos) se decide AQUI primero; despues se
> refleja en src/main.tex y en los ficheros de src/chapters/. La tabla la
> mantiene research-architect; el contenido de cada capitulo lo redacta
> academic-writer.

## Capitulos

| Orden | Fichero                        | Titulo                     | Estado   | Notas                     |
|-------|--------------------------------|----------------------------|----------|---------------------------|
| Front | src/chapters/00_front.tex      | Portada, resumen e indice  | definida | front matter, sin numerar |
| Front | src/chapters/glossary.tex      | Glossary of Acronyms       | definida | front matter, sin numerar |
| 1     | src/chapters/01_introduction.tex | Introduction             | definida | TODO                      |
| 2     | src/chapters/02_background.tex | Background                 | definida | TODO                      |
| 3     | src/chapters/03_methodology.tex | Methodology               | definida | TODO                      |
| 4     | src/chapters/04_results.tex    | Results                    | definida | TODO                      |
| 5     | src/chapters/05_conclusions.tex | Conclusions               | definida | TODO                      |
| Ap. A | src/appendices/appendix_a.tex  | TODO: titulo del apendice  | definida | material complementario   |

## Reglas

- Cada capitulo nuevo usa el numero siguiente; no reordenar los existentes.
- El estado replica los valores de context/hypothesis_matrix.md:
  definida | validada | reportada.
- Los \input de src/main.tex deben corresponder exactamente a las filas de
  esta tabla (la post-condicion del scaffold y peer-audit verifican esto).

## Changelog

| Fecha      | Cambio                        | Autor |
|------------|-------------------------------|-------|
| AAAA-MM-DD | Creacion de la capitulacion   | TODO  |
