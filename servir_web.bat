@echo off
rem Serve a versao web exportada em http://localhost:8060
rem (o Godot Web nao funciona abrindo index.html direto do disco).
if not exist "%~dp0build\web\index.html" (
  echo Exporte antes: Projeto ^> Exportar ^> Web, ou rode exportar_web.bat
  pause
  exit /b 1
)
start "" http://localhost:8060
python -m http.server 8060 --directory "%~dp0build\web"
