#!/usr/bin/env bash
# ==============================================================================
# Script de Compilación y Batería de Pruebas - UEM Actividad 3
# ==============================================================================
# Este script automatiza la limpieza, compilación y ejecución de la suite de pruebas
# validando las salidas estándar y de error frente a los requisitos establecidos.
# ==============================================================================

# Colores para salida en consola (compatibles con terminales Bash estándar)
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin color

echo -e "${BLUE}======================================================================${NC}"
echo -e "${BLUE}    UEM Actividad 3 - Automatización de Compilación y Pruebas${NC}"
echo -e "${BLUE}======================================================================${NC}"

# Ir al directorio raíz del proyecto (donde está el Makefile)
# Asumimos que el script está en scripts/
cd "$(dirname "$0")/.."

# 1. Limpieza y Compilación
echo -e "\n${YELLOW}[1/3] Limpiando y Compilando el Analizador Léxico-Sintáctico...${NC}"
make clean
if make; then
    echo -e "${GREEN}[+] Compilación exitosa. Ejecutable 'minilang' listo.${NC}"
else
    echo -e "${RED}[- -] ERROR CRÍTICO: La compilación ha fallado.${NC}"
    exit 1
fi

# Verificar la presencia del ejecutable
if [ ! -f ./minilang ]; then
    # Intentar con extensión .exe por si es Windows nativo / MSYS2
    if [ -f ./minilang.exe ]; then
        EXECUTABLE="./minilang.exe"
    else
        echo -e "${RED}[- -] ERROR CRÍTICO: No se encuentra el archivo ejecutable 'minilang'.${NC}"
        exit 1
    fi
else
    EXECUTABLE="./minilang"
fi

echo -e "[+] Usando ejecutable: ${EXECUTABLE}"

# Variables de control
TESTS_PASSED=0
TESTS_FAILED=0
TOTAL_TESTS=6

echo -e "\n${YELLOW}[2/3] Ejecutando Batería de Pruebas de Calidad...${NC}"
echo -e "------------------------------------------------------------"

# Función auxiliar para comprobar los resultados de los tests
run_test() {
    local test_file=$1
    local test_type=$2
    local expected_msg=$3
    local expected_code=$4

    if [ ! -f "$test_file" ]; then
        echo -e "${RED}[FALLO] Archivo de prueba no encontrado: $test_file${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return
    fi

    echo -n -e "Ejecutando $(basename "$test_file")... "

    # Capturar salida estándar, error y código de salida
    stdout_val=""
    stderr_val=""
    
    # Ejecutamos el compilador guardando stderr y stdout
    stdout_val=$($EXECUTABLE "$test_file" 2>&1 >/dev/null) # Captura de stderr (se redirige stdout a /dev/null y stderr se muestra)
    exit_code=$?
    
    # Si fue exitoso (código esperado 0), comprobamos stdout.
    # Pero minilang imprime en stdout "Analisis sintactico correcto" en caso de éxito.
    # Hagamos la captura de stdout y stderr de forma separada
    stdout_val=$($EXECUTABLE "$test_file" 2>/dev/null)
    stderr_val=$($EXECUTABLE "$test_file" 2>&1 >/dev/null)

    # Validaciones según el tipo de test
    local success=true

    if [ "$test_type" == "A" ]; then
        # Para Tipo A: Código debe ser 0 y stdout debe ser la cadena esperada
        if [ $exit_code -ne 0 ]; then
            success=false
            reason="Código de retorno incorrecto (esperado 0, obtenido $exit_code)"
        elif [[ "$stdout_val" != *"$expected_msg"* ]]; then
            success=false
            reason="Salida stdout incorrecta (esperada '$expected_msg', obtenida '$stdout_val')"
        fi
    else
        # Para Tipo B: Código debe ser 1 (o no-cero) y stderr debe contener "Error sintactico en la linea X"
        if [ $exit_code -eq 0 ]; then
            success=false
            reason="Código de retorno incorrecto (esperado distinto de 0, obtenido 0)"
        # Si se especifica una línea esperada, comprobamos si coincide
        elif [[ "$stderr_val" != *"Error sintactico en la linea"* ]]; then
            success=false
            reason="Salida stderr incorrecta (esperaba 'Error sintactico en la linea...', obtenida '$stderr_val')"
        fi
    fi

    if [ "$success" = true ]; then
        echo -e "${GREEN}[OK]${NC}"
        if [ "$test_type" == "A" ]; then
            echo -e "   -> Resultado: $stdout_val"
        else
            echo -e "   -> Resultado (Error controlado): $stderr_val"
        fi
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}[FALLÓ]${NC}"
        echo -e "   -> Razón del fallo: $reason"
        echo -e "   -> Stdout obtenido: '$stdout_val'"
        echo -e "   -> Stderr obtenido: '$stderr_val'"
        echo -e "   -> Código retorno: $exit_code"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    echo -e "------------------------------------------------------------"
}

# --- EJECUCIÓN DE PRUEBAS ---

# Pruebas Tipo A (Correctos)
run_test "pruebas/test_UEM_oficial.txt" "A" "Analisis sintactico correcto" 0
run_test "pruebas/test_A1.txt" "A" "Analisis sintactico correcto" 0
run_test "pruebas/test_A2.txt" "A" "Analisis sintactico correcto" 0
run_test "pruebas/test_A3.txt" "A" "Analisis sintactico correcto" 0

# Pruebas Tipo B (Errores Sintácticos)
run_test "pruebas/test_B1.txt" "B" "Error sintactico en la linea" 1
run_test "pruebas/test_B2.txt" "B" "Error sintactico en la linea" 1
run_test "pruebas/test_B3.txt" "B" "Error sintactico en la linea" 1

# 3. Reporte Final
echo -e "\n${YELLOW}[3/3] Reporte Final de Calidad:${NC}"
echo -e "============================================================"
echo -e " Pruebas Superadas: ${GREEN}$TESTS_PASSED${NC} / 7"
echo -e " Pruebas Falladas : ${RED}$TESTS_FAILED${NC} / 7"
echo -e "============================================================"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}¡Excelente! El compilador pasa satisfactoriamente el 100% de la batería de pruebas.${NC}\n"
    exit 0
else
    echo -e "${RED}Atención: Se han detectado fallos en las pruebas. Revise los logs anteriores.${NC}\n"
    exit 1
fi
