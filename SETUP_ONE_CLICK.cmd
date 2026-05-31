@echo off
setlocal
set "REPO_DIR=%~dp0"
set "REPO_DIR=%REPO_DIR:~0,-1%"
set "ENV_FILE=D:\LY\Mark-XXXV-main\.env"
set "REPO_NAME=lu-reels-video-host"

echo LU Reels GitHub host setup
echo Repo dir: %REPO_DIR%
echo Env file: %ENV_FILE%
echo.

where git >nul 2>nul
if errorlevel 1 (
  echo ERROR: git is not installed or not in PATH.
  pause
  exit /b 1
)

cd /d "%REPO_DIR%"
if not exist ".git" (
  git init
  git branch -M main
)

git add README.md .gitignore reels tools *.cmd
git commit -m "Initialize LU reels video host" >nul 2>nul

where gh >nul 2>nul
if not errorlevel 1 (
  echo GitHub CLI found. Trying to create/push public repo automatically...
  gh repo create "%REPO_NAME%" --public --source . --remote origin --push
  if not errorlevel 1 goto after_remote
  echo.
  echo Automatic GitHub creation failed. Continuing with manual URL mode.
  echo.
)

echo If the browser opens, create a PUBLIC repo named:
echo   %REPO_NAME%
echo.
echo IMPORTANT: do not initialize it with README/gitignore/license.
echo.
start "" "https://github.com/new?name=lu-reels-video-host&visibility=public"
echo Paste your GitHub repo URL here after creating it.
echo Example: https://github.com/YOUR_LOGIN/lu-reels-video-host.git
set /p REMOTE_URL=Repo URL: 

if "%REMOTE_URL%"=="" (
  echo ERROR: empty repo URL.
  pause
  exit /b 1
)

git remote remove origin >nul 2>nul
git remote add origin "%REMOTE_URL%"
git push -u origin main
if errorlevel 1 (
  echo ERROR: git push failed. Check GitHub login/permissions.
  pause
  exit /b 1
)

:after_remote
for /f "usebackq tokens=*" %%i in (`git remote get-url origin`) do set "ORIGIN=%%i"
set "OWNER_REPO=%ORIGIN%"
set "OWNER_REPO=%OWNER_REPO:https://github.com/=%"
set "OWNER_REPO=%OWNER_REPO:http://github.com/=%"
set "OWNER_REPO=%OWNER_REPO:git@github.com:=%"
set "OWNER_REPO=%OWNER_REPO:.git=%"
set "OWNER_REPO=%OWNER_REPO:/=\%"

for /f "tokens=1,2 delims=\" %%a in ("%OWNER_REPO%") do (
  set "GH_OWNER=%%a"
  set "GH_REPO=%%b"
)

if "%GH_OWNER%"=="" (
  echo ERROR: could not parse GitHub owner from origin: %ORIGIN%
  pause
  exit /b 1
)
if "%GH_REPO%"=="" (
  echo ERROR: could not parse GitHub repo from origin: %ORIGIN%
  pause
  exit /b 1
)

set "PUBLIC_BASE=https://raw.githubusercontent.com/%GH_OWNER%/%GH_REPO%/main/reels"

powershell -NoProfile -ExecutionPolicy Bypass -File "%REPO_DIR%\tools\update-mark-env.ps1" -EnvFile "%ENV_FILE%" -RepoDir "%REPO_DIR%" -PublicBaseUrl "%PUBLIC_BASE%"
if errorlevel 1 (
  echo ERROR: failed to update .env.
  pause
  exit /b 1
)

echo.
echo OK. Hermes/Mark-XXXV hosting is configured:
echo LU_REELS_REPO_DIR=%REPO_DIR%
echo LU_REELS_PUBLIC_BASE_URL=%PUBLIC_BASE%
echo.
echo Next: restart Hermes gateway so it rereads skills/env.
pause

