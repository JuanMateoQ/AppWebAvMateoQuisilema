@echo off
:: ============================================================
:: setup_iis.bat
:: Registra PoliMusic en IIS (ASP Clasico).
:: EJECUTAR COMO ADMINISTRADOR (clic derecho -> Ejecutar como administrador)
:: ============================================================
setlocal

set SITE_NAME=PoliMusic
set SITE_PORT=8080
set POOL_NAME=PoliMusicPool
set SITE_PATH=C:\Users\Mateo\source\repos\AppWebAvMateoQuisilema\webapppolimusicv1_asp
set APPCMD=%WINDIR%\system32\inetsrv\appcmd.exe

echo.
echo ===== Configuracion de PoliMusic en IIS =====
echo.

:: --- Application Pool (modo Classic para ASP clasico) ---
"%APPCMD%" add apppool /name:%POOL_NAME% /managedRuntimeVersion:"" /managedPipelineMode:Classic 2>nul
"%APPCMD%" set apppool /apppool.name:%POOL_NAME% /managedRuntimeVersion:"" /managedPipelineMode:Classic
echo Pool %POOL_NAME% configurado.

:: --- Elimina el sitio si ya existe ---
"%APPCMD%" delete site /site.name:%SITE_NAME% 2>nul

:: --- Crea el sitio ---
"%APPCMD%" add site /name:%SITE_NAME% /bindings:"http/*:%SITE_PORT%:" /physicalPath:"%SITE_PATH%"
echo Sitio %SITE_NAME% creado en el puerto %SITE_PORT%.

:: --- Asigna el pool ---
"%APPCMD%" set app "%SITE_NAME%/" /applicationPool:%POOL_NAME%

:: --- ASP: habilita parentPaths y errores detallados ---
"%APPCMD%" set config "%SITE_NAME%" /section:asp /enableParentPaths:true /scriptErrorSentToBrowser:true

:: --- Habilita el handler de ASP (.asp) ---
"%APPCMD%" unlock config /section:system.webServer/handlers 2>nul

:: --- Habilita ASP a nivel de sitio (si el feature esta desactivado globalmente) ---
dism /online /Enable-Feature /FeatureName:IIS-ASP /NoRestart 2>nul

:: --- Permisos de IUSR sobre la carpeta del proyecto ---
icacls "%SITE_PATH%" /grant "IUSR:(OI)(CI)RX" /T /Q

:: --- Inicia el sitio ---
"%APPCMD%" start site /site.name:%SITE_NAME%

echo.
echo ===== Configuracion completada =====
echo.
echo Abre tu navegador en:  http://localhost:%SITE_PORT%/
echo Usuario normal:   userNormal  / 12345678
echo Usuario admin:    userAdmin   / 12345678
echo.
pause
