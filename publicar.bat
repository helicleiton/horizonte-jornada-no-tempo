@echo off
rem Publica o jogo e o site. Duplo clique ou: publicar.bat "mensagem do commit"
"C:\Program Files\Git\bin\bash.exe" "%~dp0publicar.sh" %*
pause
