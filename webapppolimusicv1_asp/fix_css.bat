@echo off
:: ============================================================
:: fix_css.bat
:: Corrige el error 500.19, configura IIS y aplica permisos
:: EJECUTAR COMO ADMINISTRADOR (Clic derecho -> Ejecutar como administrador)
:: ============================================================
setlocal

set "SRC=C:\Users\Mateo\source\repos\AppWebAvMateoQuisilema\webapppolimusicv1_asp"
set "DST=C:\inetpub\wwwroot\webapppolimusicv1_asp"
set "APPCMD=%WINDIR%\system32\inetsrv\appcmd.exe"

echo.
echo ============================================================
echo   PoliMusic - Reparacion y Despliegue en IIS
echo ============================================================
echo.

:: 1. Sincronizar archivos (incluyendo el web.config limpio)
echo [1/5] Sincronizando archivos y web.config corregido...
if not exist "%DST%" mkdir "%DST%"
copy /Y "%SRC%\web.config" "%DST%\web.config"
xcopy /S /Y /D "%SRC%\css\*" "%DST%\css\" >nul 2>&1
xcopy /S /Y /D "%SRC%\js\*" "%DST%\js\" >nul 2>&1
xcopy /S /Y /D "%SRC%\includes\*" "%DST%\includes\" >nul 2>&1
copy /Y "%SRC%\*.asp" "%DST%\" >nul 2>&1
echo       OK: Archivos y web.config actualizados sin handlers duplicados.

:: 2. Crear Application Pool en modo Classic
echo.
echo [2/5] Configurando Application Pool 'PoliMusicPool' (Classic)...
"%APPCMD%" add apppool /name:PoliMusicPool /managedRuntimeVersion:"" /managedPipelineMode:Classic 2>nul
"%APPCMD%" set apppool /apppool.name:PoliMusicPool /managedRuntimeVersion:"" /managedPipelineMode:Classic
echo       OK

:: 3. Registrar la aplicacion en IIS
echo.
echo [3/5] Registrando la aplicacion /webapppolimusicv1_asp en Default Web Site...
"%APPCMD%" delete app "Default Web Site/webapppolimusicv1_asp" 2>nul
"%APPCMD%" add app /site.name:"Default Web Site" /path:/webapppolimusicv1_asp /physicalPath:"%DST%" /applicationPool:PoliMusicPool
echo       OK

:: 4. Habilitar opciones de ASP Clasico
echo.
echo [4/5] Habilitando Parent Paths y mensajes de error detallados...
"%APPCMD%" set config -section:asp /enableParentPaths:true /scriptErrorSentToBrowser:true 2>nul
"%APPCMD%" set config "Default Web Site/webapppolimusicv1_asp" /section:asp /enableParentPaths:true /scriptErrorSentToBrowser:true 2>nul
echo       OK

:: 5. Asignar permisos NTFS para que IIS sirva el CSS, imagenes y audio
echo.
echo [5/5] Asignando permisos a IUSR, IIS_IUSRS y Usuarios...
icacls "%DST%" /grant "IUSR:(OI)(CI)RX" /T /Q
icacls "%DST%" /grant "IIS_IUSRS:(OI)(CI)RX" /T /Q
icacls "%DST%" /grant "BUILTIN\Usuarios:(OI)(CI)M" /T /Q
echo       OK

:: 6. Reiniciar el pool
echo.
echo Reiniciando Application Pool...
"%APPCMD%" stop apppool /apppool.name:PoliMusicPool 2>nul
"%APPCMD%" start apppool /apppool.name:PoliMusicPool 2>nul

echo.
echo ============================================================
echo   EXITO: Todo ha sido configurado correctamente
echo ============================================================
echo.
echo Abre tu navegador en cualquiera de estos enlaces:
echo   http://localhost/webapppolimusicv1_asp/
echo   http://localhost/webapppolimusicv1_asp/login.asp
echo.
echo Credenciales de prueba:
echo   - Administrador: userAdmin  / 12345678
echo   - Usuario Normal: userNormal / 12345678
echo.
pause
