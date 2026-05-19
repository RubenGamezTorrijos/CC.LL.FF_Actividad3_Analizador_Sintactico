#!/usr/bin/env bash
# ==============================================================================
# Script de configuración de dependencias de compilación - UEM Actividad 3
# ==============================================================================
set -e

echo "======================================================================"
echo " UEM Actividad 3 - Instalador de dependencias de desarrollo"
echo "======================================================================"

# Verificar privilegios de administrador si no se usa Homebrew
check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        echo "Aviso: Se requieren privilegios de superusuario (sudo) para instalar dependencias."
    fi
}

# Detectar gestor de paquetes e instalar dependencias
if command -v apt-get &> /dev/null; then
    echo "[+] Detectado gestor de paquetes: APT (Debian/Ubuntu/WSL)"
    check_sudo
    sudo apt-get update
    sudo apt-get install -y gcc make flex bison
elif command -v brew &> /dev/null; then
    echo "[+] Detectado gestor de paquetes: Homebrew (macOS)"
    brew install gcc make flex bison
elif command -v dnf &> /dev/null; then
    echo "[+] Detectado gestor de paquetes: DNF (Fedora/RHEL)"
    check_sudo
    sudo dnf install -y gcc make flex bison
elif command -v pacman &> /dev/null; then
    echo "[+] Detectado gestor de paquetes: Pacman (Arch Linux)"
    check_sudo
    sudo pacman -Syu --noconfirm gcc make flex bison
else
    echo "[!] No se detectó un gestor de paquetes compatible automáticamente (APT, Brew, DNF o Pacman)."
    echo "[!] Si está ejecutando bajo Windows puro (MSYS2/Git Bash), instale flex, bison y gcc de forma manual"
    echo "    usando pacman (e.g., 'pacman -S msys/flex msys/bison mingw-w64-x86_64-gcc make')."
    echo ""
    echo "Comprobando si las herramientas ya están presentes en el PATH..."
    
    MISSING=0
    for cmd in gcc make flex bison; do
        if ! command -v $cmd &> /dev/null; then
            echo "    [-] Falta herramienta: $cmd"
            MISSING=$((MISSING + 1))
        else
            echo "    [+] Presente: $cmd"
        fi
    done
    
    if [ $MISSING -eq 0 ]; then
        echo "[+] Todas las herramientas requeridas están instaladas. No se necesita acción adicional."
    else
        exit 1
    fi
fi

echo "[+] Configuración de dependencias completada satisfactoriamente."
