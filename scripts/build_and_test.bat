@echo off
rem ==============================================================================
rem Script de Compilacion y Bateria de Pruebas para Windows - UEM Actividad 3
rem ==============================================================================

echo ======================================================================
echo     UEM Actividad 3 - Automatizacion de Compilacion y Pruebas (Windows)
echo ======================================================================

rem Volver a la raiz del proyecto
cd /d "%~dp0.."

rem Comprobar si existe 'make' de forma nativa
make --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [!] 'make' nativo no detectado en el PATH de Windows.
    echo [+] Buscando entorno WSL Linux Subsystem...
    wsl --help >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] No se encontro 'make' ni 'wsl'. Por favor instala MSYS2 o habilita WSL.
        pause
        exit /b 1
    ) else (
        echo [+] Entorno WSL detectado. Delegando ejecucion a Linux de forma transparente...
        echo.
        wsl bash scripts/build_and_test.sh
        pause
        exit /b 0
    )
)

echo.
echo [1/3] Limpiando y Compilando el Analizador Lexico-Sintactico...
call make clean >nul 2>nul
call make

if exist minilang.exe (
    set EXECUTABLE=.\minilang.exe
) else (
    echo.
    echo [ERROR] La compilacion nativa ha fallado o no se ha encontrado el ejecutable (minilang.exe).
    echo Asegurate de tener GCC, Flex, Bison y Make agregados al PATH de Windows.
    pause
    exit /b 1
)

echo [+] Usando ejecutable nativo: %EXECUTABLE%
set TESTS_PASSED=0
set TESTS_FAILED=0

echo.
echo [2/3] Ejecutando Bateria de Pruebas...
echo ------------------------------------------------------------

rem --- PRUEBAS TIPO A ---
call :run_test pruebas\test_UEM_oficial.txt A "Analisis sintactico correcto"
call :run_test pruebas\test_A1.txt A "Analisis sintactico correcto"
call :run_test pruebas\test_A2.txt A "Analisis sintactico correcto"
call :run_test pruebas\test_A3.txt A "Analisis sintactico correcto"

rem --- PRUEBAS TIPO B ---
call :run_test pruebas\test_B1.txt B "Error sintactico en la linea 4"
call :run_test pruebas\test_B2.txt B "Error sintactico en la linea 3"
call :run_test pruebas\test_B3.txt B "Error sintactico en la linea 1"

echo.
echo [3/3] Reporte Final de Calidad:
echo ============================================================
echo  Pruebas Superadas: %TESTS_PASSED% / 6
echo  Pruebas Falladas : %TESTS_FAILED% / 6
echo ============================================================

if %TESTS_FAILED% equ 0 (
    echo Excelente! El compilador pasa el 100%% de las pruebas.
) else (
    echo Atencion: Se han detectado fallos en las pruebas.
)
pause
exit /b 0

:run_test
set TEST_FILE=%1
set TEST_TYPE=%2
set EXPECTED_MSG=%3

if not exist "%TEST_FILE%" (
    echo [FALLO] Archivo de prueba no encontrado: %TEST_FILE%
    set /a TESTS_FAILED+=1
    exit /b
)

set TEMP_OUT="%TEMP%\test_out.txt"
set TEMP_ERR="%TEMP%\test_err.txt"

%EXECUTABLE% "%TEST_FILE%" > %TEMP_OUT% 2> %TEMP_ERR%
set EXIT_CODE=%ERRORLEVEL%

set SUCCESS=true

if "%TEST_TYPE%"=="A" (
    if %EXIT_CODE% neq 0 (
        set SUCCESS=false
        set REASON=Codigo de retorno incorrecto - esperado 0, obtenido %EXIT_CODE%
    ) else (
        findstr /c:%EXPECTED_MSG% %TEMP_OUT% >nul
        if errorlevel 1 (
            set SUCCESS=false
            set REASON=Salida stdout incorrecta - se esperaba %EXPECTED_MSG%
        )
    )
) else (
    if %EXIT_CODE% equ 0 (
        set SUCCESS=false
        set REASON=Codigo de retorno incorrecto - esperado distinto de 0, obtenido 0
    ) else (
        findstr /c:"Error sintactico en la linea" %TEMP_ERR% >nul
        if errorlevel 1 (
            set SUCCESS=false
            set REASON=Salida stderr incorrecta - se esperaba 'Error sintactico en la linea...'
        )
    )
)

if "%SUCCESS%"=="true" (
    echo Ejecutando %TEST_FILE%... [OK]
    if "%TEST_TYPE%"=="A" (
        for /f "usebackq delims=" %%i in (%TEMP_OUT%) do echo    -^> Resultado: %%i
    ) else (
        for /f "usebackq delims=" %%i in (%TEMP_ERR%) do echo    -^> Resultado - Error controlado: %%i
    )
    set /a TESTS_PASSED+=1
) else (
    echo Ejecutando %TEST_FILE%... [FALLO]
    echo    -^> Razon del fallo: %REASON%
    set /a TESTS_FAILED+=1
)

del %TEMP_OUT% %TEMP_ERR% >nul 2>nul
echo ------------------------------------------------------------
exit /b
