@echo off
setlocal
cd /d "%~dp0"

git status --short
git add README.md .gitignore reels tools *.cmd
git commit -m "Update reels host files"
git push

echo.
echo Done. If git says "nothing to commit", that is OK.
pause

