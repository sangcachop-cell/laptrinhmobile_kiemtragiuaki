@echo off
title ASP.NET Core Backend (Port 5283) - TOEIC Reading
echo ========================================================
echo   Starting Backend API at http://localhost:5283
echo   MSSV: 2380601899 - Nguyen Tan Sang
echo ========================================================
cd /d "%~dp0backend\src\_2380601899.Web.Mvc"
dotnet run --launch-profile "http"
pause
