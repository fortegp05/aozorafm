@echo off
cd /d "%~dp0"
powershell -NoExit -Command "docker compose up"
