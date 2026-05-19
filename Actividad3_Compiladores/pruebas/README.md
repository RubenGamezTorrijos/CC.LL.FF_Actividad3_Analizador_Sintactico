# Suite de Pruebas y Salidas Esperadas - UEM Actividad 3

Este directorio contiene una suite de pruebas representativa para validar el comportamiento del analizador léxico-sintáctico `minilang`. 

Las pruebas se dividen en dos grupos principales: **Tipo A (Correctos)** y **Tipo B (Errores Sintácticos)**.

---

## Pruebas de Tipo A (Entradas Correctas)

Estas pruebas corresponden a programas sintácticamente correctos de acuerdo con la gramática especificada. La salida esperada en la consola estándar (stdout) es exactamente:
`Analisis sintactico correcto`
Con un código de retorno `0`.

### 1. `test_A1.txt`
* **Descripción:** Asignaciones de valores simples con prioridades aritméticas e impresión final.
* **Código Fuente:**
  ```python
  x = 10;
  y = 20;
  z = x + y * 5;
  print(z);
  ```
* **Salida Esperada:** `Analisis sintactico correcto`
* **Código de salida:** `0`

### 2. `test_A2.txt`
* **Descripción:** Declaración condicional `if` con delimitador `:` y bloque interior de sentencias cerrado correctamente con `endif`.
* **Código Fuente:**
  ```python
  x = 5;
  if (x - 5):
      y = 10;
      print(y);
  endif
  ```
* **Salida Esperada:** `Analisis sintactico correcto`
* **Código de salida:** `0`

### 3. `test_A3.txt`
* **Descripción:** Estructura de bucle iterativo `while` con cuerpo compuesto y expresiones aritméticas anidadas.
* **Código Fuente:**
  ```python
  i = 0;
  limit = 10;
  while (limit - i):
      print(i);
      i = i + 1;
  endwhile
  ```
* **Salida Esperada:** `Analisis sintactico correcto`
* **Código de salida:** `0`

---

## Pruebas de Tipo B (Errores Sintácticos)

Estas pruebas contienen fallos de sintaxis específicos para evaluar el manejo de errores. La salida esperada en el canal de errores estándar (stderr) debe seguir exactamente el formato:
`Error sintactico en la linea X`
Con un código de retorno `1`.

### 1. `test_B1.txt`
* **Descripción:** Bucle condicional `if` iniciado correctamente pero sin la palabra clave de clausura `endif` al final del archivo.
* **Código Fuente:**
  ```python
  x = 5;
  if (x):
      y = 10;
  ```
* **Salida Esperada:** `Error sintactico en la linea 4` (El error se detecta en el fin de fichero tras el salto de línea)
* **Código de salida:** `1`

### 2. `test_B2.txt`
* **Descripción:** Estructura `if` que omite los dos puntos `:` obligatorios después del paréntesis de cierre de la expresión de control.
* **Código Fuente:**
  ```python
  x = 5;
  if (x)
      y = 10;
  endif
  ```
* **Salida Esperada:** `Error sintactico en la linea 3` (Al intentar leer la variable `y` como identificador de inicio de sentencia sin haber cerrado la cabecera del condicional con `:`)
* **Código de salida:** `1`

### 3. `test_B3.txt`
* **Descripción:** Llamada al método `print` en la cual falta el paréntesis de cierre `)` antes de la terminación de sentencia `;`.
* **Código Fuente:**
  ```python
  print(10;
  ```
* **Salida Esperada:** `Error sintactico en la linea 1` (Se esperaba un `)` y se encontró un `;`)
* **Código de salida:** `1`
