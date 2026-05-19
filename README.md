# Mini-Python Parser v.1.0.0
### Analizador Sintáctico en Flex + Bison para Mini-Python - Compiladores y Lenguajes Formales
![Status](https://img.shields.io/badge/status-active-green.svg)
![Language](https://img.shields.io/badge/language-C-blue.svg)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20WSL2-lightgrey.svg)

Este proyecto implementa un analizador sintáctico (parser) completo y profesional desarrollado en Flex (Lex), Bison (Yacc) y C. Procesa ficheros con código de un mini-lenguaje estructurado inspirado en la sintaxis de Python (con delimitadores explícitos de fin de bloque `endif` y `endwhile`), validando de manera precisa la estructura sintáctica de las instrucciones y expresiones complejas, administrando la asociatividad aritmética mediante directivas de precedencia y reportando de forma elegante y robusta los errores de sintaxis con parada inmediata del flujo indicando la línea exacta del fallo.

---

## 🚀 Características (Novedades v.1.0.0)
*   **Especificación Léxica de Flex Profesional:** Reglas léxicas ordenadas de manera estratégica para respetar la precedencia correcta (palabras clave antes que identificadores) y conteo dinámico de líneas automáticas con `%option yylineno`.
*   **Gramática Estricta LALR(1) con Bison:** Definición inequívoca y formal de la gramática del mini-lenguaje para evaluar asignaciones simples, llamadas a funciones (`print`), condicionales (`if-endif`) y bucles (`while-endwhile`).
*   **Asociatividad y Precedencia de Operadores:** Resolución limpia de la ambigüedad en las expresiones aritméticas declarando precedencia y asociatividad a la izquierda para los operadores de suma/resta (`+`, `-`) y multiplicación/división (`*`, `/`), eliminando conflictos de desplazamiento/reducción.
*   **Punto de Entrada en C Robusto (main.c):** Validación segura de argumentos de línea de comandos, gestión de errores de apertura de ficheros con `perror`, redireccionamiento a `yyin`, llamada al motor sintáctico `yyparse()` y control de códigos de salida (`0` para éxito, `1` para error).
*   **Gestión de Errores Sintácticos Críticos:** Captura y procesamiento robusto de fallos sintácticos a través de la función `yyerror`, reportando de forma unificada e interrumpiendo inmediatamente la ejecución (`exit(1)`) imprimiendo: `Error sintactico en la linea <N>` en `stderr`.
*   **Soporte Multiplataforma Inteligente:** Regla de filtrado explícito para retornos de carro (`\r`) que previene falsos positivos en el conteo de líneas de archivos formateados en sistemas Windows, sumando líneas exclusivamente con `\n`.
*   **Batería de Pruebas Automatizada (Calidad Local):** Casos de prueba correctos (Tipo A) y de error sintáctico (Tipo B) con comprobación automática y generación de un reporte final visual sobre el compilador en consola.

---

## 📂 Estructura del Proyecto
El repositorio está organizado directamente en el directorio raíz con la siguiente estructura modular:

```
.
├── src/                          # Código fuente del compilador
│   ├── scanner.l                 # Especificación del analizador léxico en Flex
│   ├── parser.y                  # Especificación del analizador sintáctico en Bison
│   └── main.c                    # Punto de entrada principal en C (función main)
├── pruebas/                      # Suite de casos de prueba del analizador
│   ├── test_A1.txt               # Caso de éxito 1: Asignaciones simples + print
│   ├── test_A2.txt               # Caso de éxito 2: Condicional if con bloque interno
│   ├── test_A3.txt               # Caso de éxito 3: Bucle while con sentencias compuestas
│   ├── test_B1.txt               # Caso de error 1: Omitir palabra clave 'endif'
│   ├── test_B2.txt               # Caso de error 2: Omitir dos puntos ':' en condicional
│   ├── test_B3.txt               # Caso de error 3: Paréntesis sin cerrar en print
│   └── README.md                 # Resultados y trazas esperadas de los casos de prueba
├── scripts/                      # Scripts de automatización y control de versiones
│   ├── setup_deps.sh             # Inicializador de dependencias en Linux/macOS
│   ├── build_and_test.sh         # Compilación y batería de pruebas en Linux/WSL2
│   └── build_and_test.bat        # Batería de pruebas automatizada nativa de Windows (CMD/PowerShell)
├── Makefile                      # Reglas de construcción de make multiplataforma
├── .gitignore                    # Archivo de exclusiones de Git para archivos temporales
├── Memoria_Actividad3.md         # Memoria técnica académica oficial
└── README.md                     # Documentación principal del proyecto (este archivo)
```

---

## 🛠️ Requisitos e Instalación

### Requisitos Previos
*   **Linux / WSL2 (Recomendado):** Distribución basada en Ubuntu/Debian con herramientas de desarrollo. Instalación rápida de dependencias:
    ```bash
    chmod +x scripts/setup_deps.sh
    ./scripts/setup_deps.sh
    ```
*   **Windows (Nativo):** Agrega las herramientas de desarrollo `gcc`, `flex`, `bison` y `make` (por ejemplo, a través de MSYS2 o MinGW) al PATH del sistema.
*   **Windows / Entorno Híbrido:** Es altamente recomendable contar con el entorno WSL2 o Git Bash/MSYS2 instalado. En MSYS2, puedes configurar las dependencias ejecutando:
    ```bash
    pacman -S msys/flex msys/bison mingw-w64-x86_64-gcc make
    ```

### Implementación y Testeo Rápido

*   **En Linux / WSL2 / Git Bash (Terminal Bash):**
    Otorga permisos de ejecución a los scripts y ejecútalos desde la raíz:
    ```bash
    chmod +x scripts/*.sh
    ./scripts/build_and_test.sh
    ```

*   **En Windows (Símbolo del sistema CMD o PowerShell):**
    Puedes ejecutar directamente el script de procesamiento nativo para Windows:
    ```cmd
    .\scripts\build_and_test.bat
    ```
    *(O simplemente haciendo doble clic en el archivo `build_and_test.bat` desde el explorador de archivos).*

El script correspondiente compilará de forma limpia, comprobará los códigos de salida y contenidos esperados para todas las pruebas e imprimirá un reporte detallado en pantalla.

---

## 🖥️ Guía de Uso del Analizador

Si deseas compilar o procesar un archivo fuente de manera manual, puedes invocar los siguientes comandos:

### Compilación Manual:
```bash
bison -d -o src/parser.tab.c src/parser.y
flex -o src/lex.yy.c src/scanner.l
gcc -Wall -Wno-unused-function -Isrc -o minilang src/parser.tab.c src/lex.yy.c src/main.c
```

### Ejecución Manual:
```bash
./minilang pruebas/test_A1.txt
```

### Formato de Salida en Caso de Éxito:
El analizador sintáctico imprimirá en consola estándar (`stdout`):
```text
Analisis sintactico correcto
```
*(Código de retorno: `0`)*

### Formato de Salida en Caso de Error:
El analizador reportará el fallo en el flujo de error estándar (`stderr`):
```text
Error sintactico en la linea 3
```
*(Código de retorno: `1`)*

---

## 📖 Análisis de la Actividad 3 (Compiladores y Lenguajes Formales)
El objetivo central de esta práctica es el diseño e implementación del motor central del Front-End de un traductor: el **Analizador Sintáctico**. En el desarrollo del parser con Bison y su integración léxica con Flex se demuestran los siguientes principios formales:

*   **Gramática LALR(1) No Ambigua:** El mini-lenguaje está regido por producciones que estructuran y delimitan de forma explícita las instrucciones de control. Bison comprueba dinámicamente si el flujo de tokens provisto pertenece al lenguaje recursivamente.
*   **Precedencia Operativa Explícita:** La declaración física de asociatividad izquierda sobre los tokens aritméticos resuelve la ambigüedad inherente de la gramática (por ejemplo, evaluando la multiplicación antes que la suma en expresiones como `a + b * c` de forma idéntica a los estándares matemáticos estándar).
*   **Manejo de Errores con yyerror:** La rutina de gestión de errores intercepta tokens inaceptables y aborta inmediatamente el análisis mediante `exit(1)` tras imprimir la línea afectada, previniendo que código sintácticamente incorrecto intente avanzar en las etapas del compilador.

---

## 👥 Créditos y Autoría
*   **Desarrollador:** Rubén Gámez Torrijos
*   **Actividad:** Actividad 3 - Implementación de un Analizador Sintáctico con Bison
*   **Asignatura:** Compiladores y Lenguajes Formales (CC.LL.FF.)
*   **Fecha:** 25 de Mayo de 2026
*   **Grado:** Ingeniería Informática
*   **Universidad:** Universidad Europea de Madrid (UEM)

Este proyecto ha sido desarrollado como parte de la Actividad Obligatoria 3 para la asignatura de Compiladores y Lenguajes Formales, sirviendo como una aplicación directa de la teoría de gramáticas formales, parser LALR(1) y herramientas de traducción industrial como Flex y Bison.
