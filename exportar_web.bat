@echo off
rem Exporta o jogo para build\web usando o preset "Web".
rem Requer os Export Templates do Godot (Editor > Gerenciar Templates de Exportacao).
if not exist "%~dp0build\web" mkdir "%~dp0build\web"
godot --headless --path "%~dp0." --export-release "Web" build/web/index.html
if errorlevel 1 (
  echo.
  echo Falhou. Instale os Export Templates da mesma versao do Godot e tente de novo.
  pause
  exit /b 1
)
echo Pronto. Rode servir_web.bat para jogar.
pause
