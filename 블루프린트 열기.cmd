@echo off
cd /d "%~dp0"
py -3 tools\open_html_blueprint.py
if errorlevel 1 pause
