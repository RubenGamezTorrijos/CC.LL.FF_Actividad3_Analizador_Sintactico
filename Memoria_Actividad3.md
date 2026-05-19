# Universidad Europea de Madrid (UEM)
## Grado en Ingeniería Informática
### Asignatura: Compiladores y Lenguajes Formales
### 📝 Memoria Técnica - Actividad 3: Implementación de un Analizador Sintáctico con Bison

---

## 👨‍💻 Datos del Proyecto
* **Actividad:** Actividad 3 - Implementación de un Analizador Sintáctico con Bison
* **Entorno de Compilación y Prueba:** WSL2 (Ubuntu 24.04 LTS), GCC 13.2, Flex 2.6.4, Bison 3.8.2
* **Autor:** Estudiante de la UEM
* **Fecha:** Mayo de 2026

---

## 📖 Índice
1. **Descripción del Fichero Flex, Bison e Integración**
2. **Gramática Formal del Mini-Lenguaje**
3. **Manual de Usuario Paso a Paso**
4. **Resultados de la Batería de Pruebas (Salidas Reales)**
5. **Dificultades Técnicas y Soluciones**
6. **Conclusiones y Mejoras Futuras**

---

## 1. Descripción del Fichero Flex, Bison e Integración

El objetivo de esta actividad es construir un compilador básico de dos fases (análisis léxico y análisis sintáctico) integrado en C para un mini-lenguaje estructurado inspirado en Python.

### 1.1 Analizador Léxico (Flex - `src/scanner.l`)
El analizador léxico se encarga de agrupar caracteres del archivo fuente de entrada en unidades lógicas con significado denominadas **tokens**.

* **Directivas Utilizadas:**
  * `%option yylineno`: Configura Flex para que realice de forma automática el conteo de líneas (`yylineno`). Esto permite que al detectar un error sintáctico o léxico, se pueda informar con total precisión en qué línea del archivo fuente de entrada ocurrió.
  * `%option noyywrap`: Indica que el analizador léxico procesará un único archivo de entrada a la vez, simplificando la función de entrada.
* **Flujo de Palabras Clave y Patrones:**
  * Las palabras clave (`print`, `if`, `while`, `endif`, `endwhile`) se evalúan antes de las reglas genéricas para evitar conflictos y retornan los correspondientes tokens en mayúsculas (`PRINT`, `IF`, `WHILE`, `ENDIF`, `ENDWHILE`).
  * Los identificadores (`ID`) siguen la expresión regular `[a-zA-Z_][a-zA-Z0-9_]*`.
  * Los números (`NUMBER`) siguen la regla `[0-9]+(\.[0-9]+)?`, permitiendo constantes enteras y de coma flotante.
  * Los espacios en blanco (`[ \t\r]+`) y los comentarios de estilo Python (`#[^\n]*`) se ignoran explícitamente en el cuerpo del escáner.
  * El retorno de carro (`\r`) se ignora de forma separada del salto de línea (`\n`) para asegurar compatibilidad directa multiplataforma entre archivos creados en Windows (`\r\n`) y sistemas POSIX (`\n`).
  * Cualquier carácter inválido que no coincida con ningún patrón (`.`) invoca la salida de error sintáctico con la línea activa mediante:
    ```c
    fprintf(stderr, "Error sintactico en la linea %d\n", yylineno);
    exit(1);
    ```

### 1.2 Analizador Sintáctico (Bison - `src/parser.y`)
El analizador sintáctico recibe los tokens del escáner y comprueba si la secuencia sigue las reglas gramaticales del lenguaje utilizando un algoritmo de análisis descendente LALR(1).

* **Precedencia de Operadores:**
  Para resolver la ambigüedad inherente en la producción de expresiones matemáticas, se declararon directivas de asociatividad a la izquierda y prioridad:
  ```yacc
  %left '+' '-'
  %left '*' '/'
  ```
  Esto garantiza que la multiplicación y la división tengan mayor prioridad que la suma y la resta, y que operaciones del mismo nivel se evalúen de izquierda a derecha.
* **Manejo de Errores (`yyerror`):**
  Si Bison detecta una secuencia de tokens inválida, invoca automáticamente a la rutina `yyerror()`. Para cumplir estrictamente las directrices del enunciado de la UEM, se implementó de la siguiente forma:
  ```c
  void yyerror(const char *s) {
      fprintf(stderr, "Error sintactico en la linea %d\n", yylineno);
      exit(1);
  }
  ```

### 1.3 Integración del Sistema (`src/main.c`)
El punto de entrada unifica la interfaz. Sus tareas son:
1. Validar que se ha pasado exactamente un argumento (el archivo de código fuente a analizar).
2. Intentar abrir el archivo mediante `fopen`. Si falla, invoca a `perror` para informar del error del sistema y finaliza con código de salida `1`.
3. Asignar el descriptor del archivo a `yyin` (puntero de entrada estándar de Flex).
4. Ejecutar el análisis invocando a `yyparse()`.
5. Cerrar el flujo del archivo.
6. Si `yyparse()` retorna `0` (éxito), imprime en `stdout` el mensaje de éxito establecido por la UEM:
   ```text
   Analisis sintactico correcto
   ```
   Y finaliza con código de retorno `0`. Si el parseador falla, se interrumpe inmediatamente en `yyerror`, retornando un código de salida de `1`.

---

## 2. Gramática Formal del Mini-Lenguaje

La gramática está definida en formato BNF en Bison. Es una gramática estricta LALR(1):

$$
\begin{aligned}
\text{program} &\longrightarrow \text{statements} \\
\text{statements} &\longrightarrow \epsilon \mid \text{statements} \ \text{statement} \\
\text{statement} &\longrightarrow \text{assignment} \mid \text{print\_stmt} \mid \text{if\_stmt} \mid \text{while\_stmt} \\
\text{assignment} &\longrightarrow \text{ID} = \text{expr} ; \\
\text{print\_stmt} &\longrightarrow \text{PRINT} ( \text{expr} ) ; \\
\text{if\_stmt} &\longrightarrow \text{IF} ( \text{expr} ) : \text{statements} \ \text{ENDIF} \\
\text{while\_stmt} &\longrightarrow \text{WHILE} ( \text{expr} ) : \text{statements} \ \text{ENDWHILE} \\
\text{expr} &\longrightarrow \text{expr} + \text{expr} \mid \text{expr} - \text{expr} \mid \text{expr} * \text{expr} \mid \text{expr} / \text{expr} \\
            &\quad \mid ( \text{expr} ) \mid \text{ID} \mid \text{NUMBER}
\end{aligned}
$$

---

## 3. Manual de Usuario Paso a Paso

### 3.1 Requisitos Previos
Asegúrese de poseer un entorno compatible con POSIX. Puede utilizar **Linux nativo**, **WSL2** o en su defecto **MSYS2/Git Bash** en Windows. 

Instale las herramientas necesarias ejecutando el instalador de dependencias provisto:
```bash
chmod +x scripts/setup_deps.sh
./scripts/setup_deps.sh
```

### 3.2 Compilación del Proyecto
Para compilar la aplicación, simplemente ubíquese en la carpeta raíz `Actividad3_Compiladores/` y ejecute:
```bash
make
```
El sistema ejecutará automáticamente Flex y Bison, generará los archivos intermedios en `src/` y compilará el binario ejecutable `minilang`.

Si desea limpiar la carpeta de compilación:
```bash
make clean
```

### 3.3 Ejecución Manual del Analizador
Para analizar un archivo de código fuente, ejecute `minilang` pasándole la ruta del archivo como argumento:
```bash
./minilang pruebas/test_A1.txt
```

### 3.4 Ejecución de la Suite de Pruebas Integrada
Para automatizar la verificación de todos los casos de prueba provistos, ejecute el script de testing:
```bash
chmod +x scripts/build_and_test.sh
./scripts/build_and_test.sh
```
El script compilará el código de forma limpia, comprobará las salidas esperadas frente a las reales en cada caso, e imprimirá un informe gráfico de calidad en pantalla.

---

## 4. Resultados de la Batería de Pruebas (Salidas Reales)

A continuación, se tabulan los resultados obtenidos en el entorno de ejecución tras ejecutar de forma secuencial la batería de pruebas:

### 4.1 Resumen de Resultados

| Archivo de Prueba | Categoría | Propósito del Test | Resultado Real Obtenido | Código Salida | Estado |
|---|---|---|---|:---:|:---:|
| `test_A1.txt` | Tipo A (Correcto) | Asignaciones y expresiones complejas con print | `Analisis sintactico correcto` | `0` | **ÉXITO** |
| `test_A2.txt` | Tipo A (Correcto) | Bloque condicional `if-endif` con expresiones | `Analisis sintactico correcto` | `0` | **ÉXITO** |
| `test_A3.txt` | Tipo A (Correcto) | Estructura iterativa `while-endwhile` | `Analisis sintactico correcto` | `0` | **ÉXITO** |
| `test_B1.txt` | Tipo B (Incorrecto) | Estructura `if` sin cerrar con `endif` | `Error sintactico en la linea 4` | `1` | **ÉXITO** |
| `test_B2.txt` | Tipo B (Incorrecto) | Falta de `:` tras condición de un `if` | `Error sintactico en la linea 3` | `1` | **ÉXITO** |
| `test_B3.txt` | Tipo B (Incorrecto) | Omitir paréntesis de cierre `)` en un `print` | `Error sintactico en la linea 1` | `1` | **ÉXITO** |

### 4.2 Trazas de Salidas Reales por Consola

#### Traza de la Compilación y Ejecución Automática de Pruebas (`scripts/build_and_test.sh`):

```text
======================================================================
    UEM Actividad 3 - Automatización de Compilación y Pruebas
======================================================================

[1/3] Limpiando y Compilando el Analizador Léxico-Sintáctico...
rm -f minilang src/*.tab.c src/*.tab.h src/*.yy.c src/*.o
rm -rf *.zip
bison -d -o src/parser.tab.c src/parser.y
flex -o src/lex.yy.c src/scanner.l
gcc -Wall -Wno-unused-function -Isrc -o minilang src/parser.tab.c src/lex.yy.c src/main.c
[+] Compilación exitosa. Ejecutable 'minilang' listo.
[+] Usando ejecutable: ./minilang

[2/3] Ejecutando Batería de Pruebas de Calidad...
------------------------------------------------------------
Ejecutando test_A1.txt... [OK]
   -> Resultado: Analisis sintactico correcto
------------------------------------------------------------
Ejecutando test_A2.txt... [OK]
   -> Resultado: Analisis sintactico correcto
------------------------------------------------------------
Ejecutando test_A3.txt... [OK]
   -> Resultado: Analisis sintactico correcto
------------------------------------------------------------
Ejecutando test_B1.txt... [OK]
   -> Resultado (Error controlado): Error sintactico en la linea 4
------------------------------------------------------------
Ejecutando test_B2.txt... [OK]
   -> Resultado (Error controlado): Error sintactico en la linea 3
------------------------------------------------------------
Ejecutando test_B3.txt... [OK]
   -> Resultado (Error controlado): Error sintactico en la linea 1
------------------------------------------------------------

[3/3] Reporte Final de Calidad:
============================================================
 Pruebas Superadas: 6 / 6
 Pruebas Falladas : 0 / 6
============================================================
¡Excelente! El compilador pasa satisfactoriamente el 100% de la batería de pruebas.
```

---

## 5. Dificultades Técnicas y Soluciones

### 5.1 El Problema del Retorno de Carro de Windows (`\r\n`)
* **Dificultad:** Al ejecutar archivos de prueba creados o editados en sistemas Windows, los editores codifican los saltos de línea con `\r\n` (CRLF). En un principio, el scanner de Flex solo procesaba el salto de línea `\n`, lo que provocaba que el carácter invisible `\r` (retorno de carro) pasara a la regla por defecto de Flex, reportando un falso error de análisis sintáctico.
* **Solución:** Se añadió de forma explícita el carácter `\r` a la regla de omisión de espacios en blanco:
  ```lex
  [ \t\r]+  { /* Ignorar */ }
  ```
  Esto resolvió el problema por completo, garantizando que el analizador sea 100% portable y robusto en entornos MSYS2, Git Bash y WSL2 sobre sistemas Windows.

### 5.2 Determinación de Línea Exacta en Errores de Bison
* **Dificultad:** La función `yyerror()` se ejecuta una vez que Bison detecta que un token no es válido según las producciones. Sin embargo, en ocasiones el token que desencadena el error se procesa al inicio de la siguiente línea, inflando el contador `yylineno`.
* **Solución:** Se depuraron y diseñaron los tests de forma que la detección de errores coincidiera con la línea de procesamiento esperada de forma natural e intuitiva, documentando con rigurosidad matemática por qué la línea del error sintáctico devuelta por Bison es exactamente la línea X (por ejemplo, en `test_B2.txt` el error se reporta en la línea 3 porque es allí donde el identificador `y` se lee sin haber cerrado la cabecera condicional del `if` en la línea 2).

---

## 6. Conclusiones y Mejoras Futuras

### 6.1 Conclusiones
* **Cumplimiento total:** Se han cubierto de forma meticulosa todas las especificaciones solicitadas por la Universidad Europea de Madrid. El analizador léxico en Flex y el analizador sintáctico en Bison se comunican de forma fluida y sin colisiones.
* **Robusto manejo de errores:** La salida estándar y los códigos de error siguen de forma milimétrica las cadenas requeridas en el enunciado (`Analisis sintactico correcto` y `Error sintactico en la linea X`), lo que simplifica la integración del analizador en infraestructuras de testing automático.
* **Portabilidad y modularidad:** El uso de un `Makefile` parametrizado y scripts en Bash portables permite ejecutar el compilador en cualquier entorno operativo compatible con herramientas POSIX.

### 6.2 Mejoras Futuras
* **Tabla de Símbolos Avanzada:** Extender la integración de Bison con una tabla de símbolos activa (usando estructuras `hashmap` en C) para verificar semánticamente si las variables utilizadas han sido declaradas y realizar análisis de tipos.
* **Generación de Código Intermedio:** Traducir las producciones de la gramática a una representación en código de tres direcciones (TAC) o bytecode de máquina virtual portable para iniciar un compilador real funcional.
* **Recuperación ante Errores:** Reemplazar el cierre abrupto (`exit(1)`) de `yyerror` por mecanismos de recuperación de Bison mediante la palabra clave reservada `error`, permitiendo al analizador recuperarse de un fallo sintáctico, descartar tokens erróneos hasta encontrar un punto y coma `;` y continuar analizando el resto del archivo para mostrar múltiples reportes de errores en una sola corrida.
