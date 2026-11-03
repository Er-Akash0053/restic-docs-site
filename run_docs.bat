@echo off
title Restic Documentation Server
echo ========================================================
echo Starting Restic Documentation Server (Topic-Based Site)
echo ========================================================

:: Switch to script directory on D: drive
cd /d "%~dp0"

if not exist "venv\Scripts\activate.bat" (
    echo [ERROR] Virtual environment not found in %~dp0venv!
    echo Please run setup first.
    pause
    exit /b 1
)

call venv\Scripts\activate.bat

echo.
echo Launching browser at http://127.0.0.1:8000/restic-docs-site/ ...
start "" "http://127.0.0.1:8000/restic-docs-site/"

echo.
echo Running mkdocs serve... (Press Ctrl+C to stop)
mkdocs serve

pause
