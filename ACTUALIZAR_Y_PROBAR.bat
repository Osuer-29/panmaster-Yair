@echo off
setlocal
cd /d "%~dp0"
title Actualizar y probar Hola Yair

echo ======================================================
echo   Hola Yair - Actualizar archivos web y comprobar build
echo ======================================================
echo.
echo [1/2] Revisando e instalando dependencias para Windows...
call npm install
if errorlevel 1 (
  echo.
  echo ERROR: npm install no termino correctamente.
  echo Verifica Node.js, npm y la conexion a Internet.
  pause
  exit /b 1
)
echo.
echo [2/2] Compilando y actualizando publicacion/panmaster.js...
call npm run build
if errorlevel 1 (
  echo.
  echo ERROR: El proyecto no pudo compilarse. Copia este mensaje y revisalo antes de publicar.
  pause
  exit /b 1
)
echo.
echo Listo. Los archivos de publicacion ya se actualizaron.
echo Para ejecutar el sistema desde VS Code: npm run dev
pause
