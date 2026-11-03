@echo off
title Build Restic Documentation
echo ========================================================
echo Building Restic Documentation Site (Strict Mode)
echo ========================================================

cd /d "%~dp0"

if not exist "venv\Scripts\activate.bat" (
    echo [ERROR] Virtual environment not found in %~dp0venv!
    pause
    exit /b 1
)

call venv\Scripts\activate.bat

echo.
echo Running mkdocs build --strict...
mkdocs build --strict

if %ERRORLEVEL% equ 0 (
    echo.
    echo ========================================================
    echo [SUCCESS] Site built successfully into "site/" directory!
    echo ========================================================
) else (
    echo.
    echo [ERROR] Build failed! Check the error log above.
)

pause
