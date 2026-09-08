@echo off
title TechToolkit
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0TechToolkit.ps1"
if errorlevel 1 pause
