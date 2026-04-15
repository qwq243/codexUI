@echo off
if /i not "%~1"=="__run__" (
  start "CodexUI Launcher" cmd /k ""%~f0" __run__ %*"
  exit /b
)

setlocal EnableExtensions
shift

cd /d "%~dp0"

set "REQUESTED_PORT=%CODEXUI_PORT%"
if not defined REQUESTED_PORT set "REQUESTED_PORT=5900"
set "FORCE_BUILD=0"
set "PASSTHRU_ARGS="

:parse_args
if "%~1"=="" goto args_done
if /i "%~1"=="--build" (
  set "FORCE_BUILD=1"
  shift
  goto parse_args
)
if /i "%~1"=="--port" (
  if "%~2"=="" (
    echo [ERROR] --port requires a value.
    pause
    exit /b 1
  )
  set "REQUESTED_PORT=%~2"
  shift
  shift
  goto parse_args
)
if /i "%~1"=="-p" (
  if "%~2"=="" (
    echo [ERROR] -p requires a value.
    pause
    exit /b 1
  )
  set "REQUESTED_PORT=%~2"
  shift
  shift
  goto parse_args
)
set "PASSTHRU_ARGS=%PASSTHRU_ARGS% "%~1""
shift
goto parse_args

:args_done

where node >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Node.js was not found. Install Node.js 18+ first.
  pause
  exit /b 1
)

where pnpm >nul 2>nul
if errorlevel 1 (
  echo [ERROR] pnpm was not found. Install pnpm first.
  pause
  exit /b 1
)

if "%FORCE_BUILD%"=="1" goto build_app
if not exist "dist\index.html" goto build_app
if not exist "dist-cli\index.js" goto build_app
echo Using existing build output. Pass --build to rebuild.
goto start_app

:build_app
echo Building CodexUI...
call pnpm run build
if errorlevel 1 (
  echo Build failed.
  pause
  exit /b 1
)

:start_app
echo Starting CodexUI...
echo Requested port: %REQUESTED_PORT%
echo The CLI will print the final URL if it needs to fall back to another port.
set "CODEXUI_SANDBOX_MODE=danger-full-access"
set "CODEXUI_APPROVAL_POLICY=never"
node dist-cli/index.js . --port %REQUESTED_PORT% --no-tunnel --no-login --sandbox-mode danger-full-access --approval-policy never %PASSTHRU_ARGS%

set "EXIT_CODE=%ERRORLEVEL%"
echo.
if not "%EXIT_CODE%"=="0" (
  echo CodexUI exited with code: %EXIT_CODE%
)
exit /b %EXIT_CODE%
