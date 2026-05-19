# Informe de Auditoría y Cumplimiento de Requisitos
### Proyecto: Analizador Sintáctico con Bison y Flex (UEM Actividad 3)
**Estado del Análisis:** ⚠️ Requiere Ajustes de Robustez Académica (No destructivos)  
**Fecha:** 25 de Mayo de 2026  
**Autor:** Rubén Gámez Torrijos (Auditoría técnica preventiva)

---

## 🎯 Resumen Ejecutivo
Se ha realizado un análisis exhaustivo y riguroso de todo el proyecto actual frente a los requisitos explícitos e implícitos del enunciado de la **Universidad Europea de Madrid (UEM)**. 

El proyecto actual **compila y funciona al 100%** bajo los escenarios de pruebas actuales (Tipo A y Tipo B creados previamente). Sin embargo, al contrastar la gramática implementada con la captura visual del programa de ejemplo provisto en el PDF de la UEM, se han identificado **tres discrepancias de alta prioridad** que podrían causar que el evaluador califique negativamente el compilador si prueba el código de ejemplo del enunciado.

> [!WARNING]
> Si el profesor copia y pega exactamente el ejemplo del enunciado (`if x < y:` o `while x < 10:` sin paréntesis y sin puntos y comas), el compilador actual **fallará con un error sintáctico**.

A continuación se detallan los hallazgos y se propone un **Plan de Acción No Destructivo** que añadirá soporte total para el ejemplo oficial sin romper ninguna de las pruebas existentes.

---

## 🔍 Matriz de Cumplimiento de Requisitos

| Requisito del Enunciado | Estado Actual | Observación Técnica |
| :--- | :---: | :--- |
| **Asignaciones** |  | Soportadas mediante `ID '=' expr ';'`. |
| **Expresiones aritméticas** |  | Suma, resta, multiplicación y división con precedencia y asociatividad izquierda correctas. |
| **Llamadas a `print`** |  | Soportadas mediante `PRINT '(' expr ')' ';'`. |
| **Estructuras `if-endif` con bloque interno** |  | Soportadas con múltiples instrucciones dentro. |
| **Estructuras `while-endwhile` con bloque interno** |  | Soportadas con múltiples instrucciones dentro. |
| **Formato de salida de éxito** |  | Imprime exactamente `"Analisis sintactico correcto"` en stdout (retorno `0`). |
| **Formato de salida de error** |  | Imprime exactamente `"Error sintactico en la linea N"` en stderr (retorno `1`). |
| **Estructura del ZIP** |  | Listo. Carpetas `src/` y `pruebas/` en la raíz del proyecto. |
| **Batería de Pruebas** |  | 3 pruebas correctas (Tipo A) y 3 incorrectas (Tipo B) documentadas y operativas. |
| **Memoria Académica y Manual** |  | Redactada, estructurada y personalizada al 100% sin referencias externas. |

---

## ⚠️ Hallazgos y Desviaciones Críticas Detectadas

### 1. Ausencia de Operadores Relacionales (Comparadores)
*   **Problema:** El programa de ejemplo provisto por la UEM contiene expresiones booleanas de comparación en las estructuras condicionales y bucles:
    *   `if x < y:`
    *   `while x < 10:`
*   **Estado actual:** La gramática del analizador sintáctico (`src/parser.y`) y el analizador léxico (`src/scanner.l`) solo admiten expresiones puramente aritméticas (`+`, `-`, `*`, `/`). No reconocen caracteres de comparación como `<`, `>`, `<=`, `>=`, `==` o `!=`.
*   **Impacto:** El analizador generará un error sintáctico inmediato al leer el carácter `<`.

### 2. Obligatoriedad de Paréntesis en Condiciones
*   **Problema:** En el ejemplo del PDF, las condiciones del `if` y el `while` se escriben de forma natural y limpia: `if x < y:` y `while x < 10:`.
*   **Estado actual:** Las reglas de la gramática exigen estrictamente el uso de paréntesis alrededor de la condición:
    *   `if_stmt : IF '(' expr ')' ':' statements ENDIF`
*   **Impacto:** Si se pasa el programa del PDF tal cual, fallará porque espera un paréntesis de apertura `(` inmediatamente después de la palabra reservada `if`.

### 3. Obligatoriedad de Puntos y Comas (`;`)
*   **Problema:** El programa de ejemplo de la UEM no utiliza puntos y comas al final de las asignaciones ni de las sentencias `print`. Es sintaxis pura de Python.
*   **Estado actual:** La gramática requiere obligatoriamente un punto y coma al final de cada asignación y llamada a print:
    *   `assignment : ID '=' expr ';'`
*   **Impacto:** El código del PDF fallará por ausencia de `;`.

### 4. Bug en la Regla de Comentarios de Flex
*   **Problema:** En `src/scanner.l` (Línea 31), la regla de descarte de comentarios está declarada como `"#[^\n]*"`.
*   **Explicación técnica:** Al rodear el patrón de comillas dobles, Flex interpreta la expresión regular como una **cadena literal**. Es decir, solo ignorará comentarios si el código fuente contiene literalmente el texto `#[^\n]*`. Si el usuario escribe un comentario real (ej. `# Asignacion inicial`), Flex no lo reconocerá e intentará procesar el símbolo `#`, produciendo un error léxico-sintáctico.
*   **Solución:** Quitar las comillas dobles en Flex para que se evalúe como expresión regular real: `#[^\n]*`.

---

## 🛠️ Plan de Acción Propuesto (100% No Destructivo)
Para hacer que el compilador sea **verdaderamente robusto, profesional y cumpla con el 100% de los requisitos implícitos del PDF de la UEM**, sugiero realizar los siguientes ajustes no destructivos:

### A. Mejoras en el Analizador Léxico (`src/scanner.l`)
1. **Soporte de Operadores Relacionales:** Definir los tokens para operadores relacionales de comparación:
   ```lex
   "<"                 { return '<'; }
   ">"                 { return '>'; }
   "<="                { return LE; }
   ">="                { return GE; }
   "=="                { return EQ; }
   "!="                { return NE; }
   ```
2. **Corrección de Comentarios:** Quitar las comillas de la regla de comentarios para que funcione correctamente:
   ```lex
   #[^\n]*             { /* Ignorar comentarios estilo Python */ }
   ```

### B. Mejoras en la Gramática (`src/parser.y`)
1. **Opcionalidad del Punto y Coma (`;`):** Modificar la gramática para que el punto y coma sea opcional en asignaciones y llamadas `print` (así mantendremos compatibilidad con los tests existentes `test_A1.txt`, etc., y daremos soporte al ejemplo del PDF):
   ```yacc
   assignment : ID '=' expr ';'
              | ID '=' expr
              ;
   
   print_stmt : PRINT '(' expr ')' ';'
              | PRINT '(' expr ')'
              ;
   ```
2. **Opcionalidad de los Paréntesis en Condiciones:** Modificar las producciones de `if` y `while` para aceptar la condición con o sin paréntesis:
   ```yacc
   if_stmt : IF expr ':' statements ENDIF
           | IF '(' expr ')' ':' statements ENDIF
           ;
   
   while_stmt : WHILE expr ':' statements ENDWHILE
              | WHILE '(' expr ')' ':' statements ENDWHILE
              ;
   ```
3. **Integración de Expresiones Relacionales:** Permitir que una expresión (`expr`) pueda contener comparaciones aritméticas:
   ```yacc
   %token LE GE EQ NE
   
   expr : expr '+' expr
        | expr '-' expr
        | expr '*' expr
        | expr '/' expr
        | expr '<' expr
        | expr '>' expr
        | expr LE expr
        | expr GE expr
        | expr EQ expr
        | expr NE expr
        | '(' expr ')'
        | ID
        | NUMBER
        ;
   ```

---

## 📬 Próximos Pasos (Esperando tu confirmación)

> [!IMPORTANT]
> **No he realizado ninguna modificación ni he guardado nada en Git local ni en GitHub**, cumpliendo estrictamente tu petición. 

Por favor, revisa esta propuesta. Si estás de acuerdo, confírmame y procederé a aplicar estas mejoras, asegurando que todos los archivos queden 100% robustos frente a la corrección del profesor, y luego actualizaré la batería de pruebas y los repositorios remotos.

¿Cómo deseas proceder?
