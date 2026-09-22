@echo off
cd /d "%~dp0"
py -3 tools\serve_html_blueprint.py --open
if errorlevel 1 pause
