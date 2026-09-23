@echo off
cd /d "%~dp0"
python tools\open_html_blueprint.py
if errorlevel 1 pause
