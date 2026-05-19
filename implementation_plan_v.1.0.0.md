# Plan de Implementación: Analizador Sintáctico (Flex + Bison) - UEM Actividad 3

Este documento detalla la planificación y arquitectura para la implementación del analizador sintáctico para un mini-lenguaje inspirado en Python con delimitadores de bloques explícitos (`endif`, `endwhile`).

## 1. Arquitectura y Estructura del Proyecto

El proyecto se estructurará de forma estricta según el enunciado del problema:

```
Actividad3_Compiladores/
├── src/
│   ├── scanner.l           # Analizador Léxico (Flex)
│   ├── parser.y            # Analizador Sintáctico (Bison)
│   └── main.c              # Punto de Entrada Principal (C)
├── pruebas/
│   ├── test_A1.txt         # Caso de éxito 1: Asignaciones simples + print
│   ├── test_A2.txt         # Caso de éxito 2: Condicional if con múltiples sentencias
│   ├── test_A3.txt         # Caso de éxito 3: Bucle while con múltiples sentencias
│   ├── test_B1.txt         # Caso de error 1: Falta de endif
│   ├── test_B2.txt         # Caso de error 2: Falta de dos puntos (:) en condicional
│   ├── test_B3.txt         # Caso de error 3: Paréntesis no cerrado en print
│   └── README.md           # Resultados esperados detallados
├── scripts/
│   ├── setup_deps.sh       # Script para instalar dependencias de desarrollo
│   └── build_and_test.sh   # Script para automatizar compilación y batería de pruebas
├── Makefile                # Reglas de construcción automatizada (con tabuladores reales)
├── README.md               # Guía rápida y notas de instalación/ejecución
├── Memoria_Actividad3.md   # Documentación académica oficial
└── .gitignore              # Archivos y artefactos generados excluidos del repositorio
```

---

## 2. Definición del Analizador Léxico (Flex - `scanner.l`)

El analizador léxico procesará el flujo de caracteres de entrada y producirá tokens. 

### Características Clave:
- Uso de `%option yylineno` para realizar el seguimiento automático de las líneas del código fuente.
- Uso de `%option noyywrap` para indicar que solo analizamos un único archivo.
- Gestión de comentarios estilo Python (`# ...`).
- Inclusión del archivo cabecera `parser.tab.h` para el intercambio de tokens con Bison.

### Tabla de Tokens y Expresiones Regulares:

| Token | Expresión Regular | Descripción |
|---|---|---|
| `PRINT` | `print` | Palabra clave para imprimir |
| `IF` | `if` | Palabra clave de condicional |
| `WHILE` | `while` | Palabra clave de bucle |
| `ENDIF` | `endif` | Palabra clave de cierre de `if` |
| `ENDWHILE` | `endwhile` | Palabra clave de cierre de `while` |
| `ID` | `[a-zA-Z_][a-zA-Z0-9_]*` | Identificador de variable |
| `NUMBER` | `[0-9]+(\.[0-9]+)?` | Valores numéricos (enteros y reales) |
| `=` | `=` | Operador de asignación |
| `+` | `\+` | Operador aritmético de suma |
| `-` | `-` | Operador aritmético de resta |
| `*` | `\*` | Operador aritmético de multiplicación |
| `/` | `/` | Operador aritmético de división |
| `(` | `\(` | Paréntesis de apertura |
| `)` | `\)` | Paréntesis de cierre |
| `:` | `:` | Delimitador de bloque (dos puntos) |
| `;` | `;` | Fin de sentencia |

Cualquier carácter no coincidente con estas reglas invocará un error léxico reportado como error sintáctico para cumplir el formato del enunciado:
`fprintf(stderr, "Error sintactico en la linea %d\n", yylineno); exit(1);`

---

## 3. Definición del Analizador Sintáctico (Bison - `parser.y`)

La gramática definida es una gramática LALR(1) no ambigua gracias a las directivas de precedencia de operadores.

### Directivas de Precedencia y Asociatividad:
```yacc
%left '+' '-'
%left '*' '/'
```

### Producciones de la Gramática:

1. **Programa y Lista de Sentencias:**
   - `program → statements`
   - `statements → ε | statements statement`

2. **Sentencias:**
   - `statement → assignment | print_stmt | if_stmt | while_stmt`
   - `assignment → ID '=' expr ';'`
   - `print_stmt → PRINT '(' expr ')' ';'`
   - `if_stmt → IF '(' expr ')' ':' statements ENDIF`
   - `while_stmt → WHILE '(' expr ')' ':' statements ENDWHILE`

3. **Expresiones Aritméticas (`expr`):**
   - `expr → expr '+' expr | expr '-' expr | expr '*' expr | expr '/' expr | '(' expr ')' | ID | NUMBER`

---

## 4. Integración y Punto de Entrada (`main.c`)

El archivo `main.c` coordinará la apertura del archivo de entrada, asignará el flujo a `yyin`, llamará al analizador sintáctico `yyparse()`, y se asegurará de imprimir el resultado de éxito si corresponde.

### Firma Clave:
```c
#include <stdio.h>
#include <stdlib.h>

extern int yyparse(void);
extern FILE* yyin;
```

---

## 5. Estrategia de Pruebas y Validación

1. **Automatización:** Se desarrollará un script robusto `scripts/build_and_test.sh` que compile el compilador `minilang` usando `Makefile` y ejecute cada archivo de prueba en `pruebas/`.
2. **Validación de Resultados:**
   - Para las pruebas de **Tipo A** (Correctas), se comprobará que la salida estándar sea exactamente `Analisis sintactico correcto` y el código de retorno sea `0`.
   - Para las pruebas de **Tipo B** (Erróneas), se comprobará que la salida de error estándar contenga exactamente `Error sintactico en la linea X` (con el número de línea correspondiente) y que el código de retorno sea `1`.

---

## 6. Plan de Trabajo Detallado

1. **Paso 1:** Crear los directorios necesarios (`src`, `pruebas`, `scripts`).
2. **Paso 2:** Crear el archivo de definición léxica `src/scanner.l`.
3. **Paso 3:** Crear el archivo de definición sintáctica `src/parser.y`.
4. **Paso 4:** Crear el punto de entrada principal `src/main.c`.
5. **Paso 5:** Crear el archivo de automatización `Makefile`.
6. **Paso 6:** Implementar la suite de pruebas (`pruebas/test_*.txt` y `pruebas/README.md`).
7. **Paso 7:** Implementar los scripts de inicialización y testing (`scripts/setup_deps.sh`, `scripts/build_and_test.sh`).
8. **Paso 8:** Generar la documentación del proyecto (`README.md`, `Memoria_Actividad3.md`, `.gitignore`).
9. **Paso 9:** Compilar el proyecto en el entorno local del usuario y verificar que todos los casos de prueba pasen satisfactoriamente.
10. **Paso 10:** Inicializar el repositorio Git local y realizar el commit inicial de los archivos de origen.
