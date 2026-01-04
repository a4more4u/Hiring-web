@echo off
echo ========================================
echo   HireSphere - Starting All Services
echo ========================================
echo.

echo [1/2] Starting Backend Server...
start cmd /k "cd server && npm run start:dev"
timeout /t 3 /nobreak >nul

echo [2/2] Starting Frontend Client...
start cmd /k "cd client && npm run dev"
timeout /t 2 /nobreak >nul

echo.
echo ========================================
echo   HireSphere is starting!
echo ========================================
echo.
echo Backend:  http://localhost:4000
echo Frontend: http://localhost:3000
echo.
echo Press any key to exit this window...
pause >nul
