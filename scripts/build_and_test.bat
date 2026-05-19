@echo off
:: ==============================================================================
:: Script de Compilación y Batería de Pruebas para Windows - UEM Actividad 3
:: ==============================================================================

echo ======================================================================
echo     UEM Actividad 3 - Automatización de Compilación y Pruebas (Windows)
echo ======================================================================

:: Volver a la raíz del proyecto
cd /d "%~dp0.."

echo.
echo [1/3] Limpiando y Compilando el Analizador Léxico-Sintáctico...
call make clean 2>nul
call make

if not exist minilang.exe (
    if not exist minilang (
        echo.
        echo [ERROR] La compilación ha fallado o no se ha encontrado el ejecutable.
        echo Asegúrate de tener GCC, Flex, Bison y Make agregados al PATH de Windows.
        pause
        exit /b 1
    ) else (
        set EXECUTABLE=.\minilang
    )
) else (
    set EXECUTABLE=.\minilang.exe
)

echo [+] Usando ejecutable: %EXECUTABLE%
set /a TESTS_PASSED=0
set /a TESTS_FAILED=0

echo.
echo [2/3] Ejecutando Batería de Pruebas de Calidad...
echo ------------------------------------------------------------

:: --- PRUEBAS TIPO A ---
call :run_test pruebas\test_A1.txt A "Analisis sintactico correcto"
call :run_test pruebas\test_A2.txt A "Analisis sintactico correcto"
call :run_test pruebas\test_A3.txt A "Analisis sintactico correcto"

:: --- PRUEBAS TIPO B ---
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
    echo ¡Excelente! El compilador pasa satisfactoriamente el 100%% de las pruebas.
) else (
    echo Atención: Se han detectado fallos en las pruebas.
)
goto :eof

:run_test
set TEST_FILE=%1
set TEST_TYPE=%2
set EXPECTED_MSG=%3

if not exist "%TEST_FILE%" (
    echo [FALLO] Archivo de prueba no encontrado: %TEST_FILE%
    set /a TESTS_FAILED+=1
    exit /b
)

:: Crear archivos temporales en el directorio TEMP de Windows
set TEMP_OUT="%TEMP%\test_out.txt"
set TEMP_ERR="%TEMP%\test_err.txt"

:: Ejecutar el parser guardando stdout y stderr por separado
%EXECUTABLE% "%TEST_FILE%" > %TEMP_OUT% 2> %TEMP_ERR%
set EXIT_CODE=%ERRORLEVEL%

set SUCCESS=true

if "%TEST_TYPE%"=="A" (
    if %EXIT_CODE% neq 0 (
        set SUCCESS=false
        set REASON=Codigo de retorno incorrecto (esperado 0, obtenido %EXIT_CODE%^)
    ) else (
        findstr /c:%EXPECTED_MSG% %TEMP_OUT% >nul
        if errorlevel 1 (
            set SUCCESS=false
            set REASON=Salida stdout incorrecta (se esperaba '%EXPECTED_MSG%'^)
        )
    )
) else (
    if %EXIT_CODE% equ 0 (
        set SUCCESS=false
        set REASON=Codigo de retorno incorrecto (esperado distinto de 0, obtenido 0^)
    ) else (
        findstr /c:"Error sintactico en la linea" %TEMP_ERR% >nul
        if errorlevel 1 (
            set SUCCESS=false
            set REASON=Salida stderr incorrecta (se esperaba 'Error sintactico en la linea...'^)
        )
    )
)

if "%SUCCESS%"=="true" (
    echo Ejecutando %TEST_FILE%... [OK]
    if "%TEST_TYPE%"=="A" (
        for /f "usebackq delims=" %%i in (%TEMP_OUT%) do echo    -^> Resultado: %%i
    ) else (
        for /f "usebackq delims=" %%i in (%TEMP_ERR%) do echo    -^> Resultado (Error controlado): %%i
    )
    set /a TESTS_PASSED+=1
) else (
    echo Ejecutando %TEST_FILE%... [FALLO]
    echo    -^> Razon del fallo: %REASON%
    set /a TESTS_FAILED+=1
)

del %TEMP_OUT% %TEMP_ERR% 2>nul
echo ------------------------------------------------------------
exit /b
