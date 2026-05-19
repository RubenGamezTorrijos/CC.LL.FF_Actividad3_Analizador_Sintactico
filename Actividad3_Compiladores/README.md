# 🎯 Analizador Sintáctico en Flex + Bison - UEM Actividad 3

Este proyecto contiene la implementación de un analizador sintáctico para un mini-lenguaje estructurado inspirado en Python (con delimitadores de bloques explícitos `endif` y `endwhile`) desarrollado con las herramientas clásicas de teoría de autómatas y lenguajes formales: **Flex** (analizador léxico) y **Bison** (analizador sintáctico), integrado en **C**.

El desarrollo cumple estrictamente con las especificaciones y requisitos establecidos por la **Universidad Europea de Madrid (UEM)** para la Actividad 3 de la asignatura de Compiladores.

---

## 📁 Estructura del Proyecto

El repositorio está estructurado de la siguiente forma:

```
Actividad3_Compiladores/
├── src/
│   ├── scanner.l           # Analizador Léxico (Flex)
│   ├── parser.y            # Analizador Sintáctico (Bison)
│   └── main.c              # Punto de entrada principal en C
├── pruebas/
│   ├── test_A1.txt         # Entrada correcta 1: Asignaciones simples + print
│   ├── test_A2.txt         # Entrada correcta 2: Condicional if con bloque interno
│   ├── test_A3.txt         # Entrada correcta 3: Bucle while con sentencias anidadas
│   ├── test_B1.txt         # Entrada errónea 1: Falta palabra clave endif
│   ├── test_B2.txt         # Entrada errónea 2: Falta de delimitador ':' tras condicional
│   ├── test_B3.txt         # Entrada errónea 3: Paréntesis sin cerrar en llamada a print
│   └── README.md           # Explicación de los casos de prueba y salidas esperadas
├── scripts/
│   ├── setup_deps.sh       # Instalación automática de dependencias
│   └── build_and_test.sh   # Compilación y verificación automática de pruebas
├── Makefile                # Reglas de construcción de make (con tabuladores reales)
├── README.md               # Guía rápida del proyecto (este archivo)
├── Memoria_Actividad3.md   # Documentación académica y memoria técnica oficial
└── .gitignore              # Patrones de exclusión de git
```

---

## 🛠️ Requisitos del Sistema

Para compilar y ejecutar este compilador, su entorno debe poseer las siguientes herramientas:
- **GCC** (Compilador de C)
- **Flex** (Generador de analizadores léxicos)
- **Bison** (Generador de analizadores sintácticos)
- **Make** (Automatizador de construcción)
- **Bash** (Para ejecutar los scripts auxiliares en entornos tipo POSIX o Windows Git Bash/MSYS2)

---

## 🚀 Instalación y Compilación Rápida

### 1. Preparar dependencias

Si está utilizando una distribución Linux compatible (como Ubuntu, Debian, Arch Linux, Fedora) o macOS, puede instalar todas las dependencias requeridas ejecutando:

```bash
chmod +x scripts/setup_deps.sh
./scripts/setup_deps.sh
```

*(En Windows, se recomienda utilizar el entorno Git Bash o MSYS2. En MSYS2, puede instalar las dependencias mediante `pacman -S msys/flex msys/bison mingw-w64-x86_64-gcc make`).*

### 2. Compilar manualmente con `make`

Para compilar el proyecto y construir el ejecutable `minilang`, ejecute en la raíz:

```bash
make
```

Esto generará automáticamente los archivos de analizador intermedios (`src/parser.tab.c`, `src/parser.tab.h`, `src/lex.yy.c`) y compilará el binario ejecutable `minilang` (o `minilang.exe` en Windows).

Para limpiar el directorio de compilación:

```bash
make clean
```

---

## 🧪 Ejecución de Pruebas

### Ejecución Automática (Recomendado)

Se proporciona un script automatizado muy robusto para compilar y ejecutar de forma consecutiva todas las pruebas correctas y erróneas definidas en `pruebas/`. Ejecute:

```bash
chmod +x scripts/build_and_test.sh
./scripts/build_and_test.sh
```

El script mostrará un reporte detallado con colores informando sobre el estado de cada prueba.

### Ejecución Manual

Puede probar cualquier archivo de código de entrada ejecutando:

```bash
./minilang pruebas/test_A1.txt
```

#### Salida esperada en caso de programa correcto:
```text
Analisis sintactico correcto
```
*(Código de salida: `0`)*

#### Salida esperada en caso de error sintáctico (ej. `test_B3.txt`):
```text
Error sintactico en la linea 1
```
*(Código de salida: `1` e impresión en stderr)*

---

## 💻 Compatibilidad Multiplataforma

Este proyecto se ha diseñado teniendo en cuenta la máxima portabilidad:
1. **Linux Nativo y WSL2 (Windows Subsystem for Linux):** Totalmente compatible y probado. Las dependencias se instalan automáticamente mediante `apt-get` o el gestor de su distribución.
2. **Windows (Git Bash / MSYS2):** Compatible. El script `build_and_test.sh` y el `Makefile` detectan la presencia de `.exe` en los ejecutables de forma dinámica y evitan problemas de compatibilidad de terminación de línea (`\r\n`) ignorando explícitamente el retorno de carro (`\r`) en el scanner de Flex.
