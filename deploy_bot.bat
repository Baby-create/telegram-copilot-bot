@echo off
:: Telegram Copilot Bot - Automated Deployment Script
:: Double-click this file to automatically deploy the bot
:: No manual configuration required!

echo.
echo ========================================================
echo    Telegram Copilot Bot - Automated Deployment
echo ========================================================
echo.

:: Set script directory as working directory
cd /d "%~dp0"

:: Check if Docker is installed
echo [1/7] Checking Docker installation...
docker --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not installed or not in PATH!
    echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop
    echo.
    pause
    exit /b 1
)
echo ✓ Docker is installed

:: Check if Docker is running
echo [2/7] Checking if Docker is running...
docker info >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not running!
    echo Please start Docker Desktop and try again.
    echo.
    pause
    exit /b 1
)
echo ✓ Docker is running

:: Check if Git is installed (optional)
echo [3/7] Checking Git installation...
git --version >nul 2>&1
if errorlevel 1 (
    echo WARNING: Git is not installed. Repository updates will be skipped.
    set GIT_AVAILABLE=false
) else (
    echo ✓ Git is installed
    set GIT_AVAILABLE=true
)

:: Update repository if Git is available
if "%GIT_AVAILABLE%"=="true" (
    echo [4/7] Updating repository...
    git pull origin main 2>nul
    if errorlevel 1 (
        echo WARNING: Could not update repository. Continuing with current version.
    ) else (
        echo ✓ Repository updated
    )
) else (
    echo [4/7] Skipping repository update (Git not available)
)

:: Run configuration detection
echo [5/7] Detecting and configuring bot settings...
python detect_config.py
if errorlevel 1 (
    echo ERROR: Configuration detection failed!
    echo Please ensure Python is installed and try again.
    echo.
    pause
    exit /b 1
)
echo ✓ Configuration completed

:: Stop any existing containers
echo [6/7] Stopping existing bot instances...
docker-compose down 2>nul
echo ✓ Existing instances stopped

:: Build and start the bot
echo [7/7] Building and starting Telegram Copilot Bot...
docker-compose up --build -d
if errorlevel 1 (
    echo ERROR: Failed to start the bot!
    echo Please check the logs for more information:
    echo docker-compose logs telegram-copilot-bot
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================================
echo ✓ Telegram Copilot Bot deployed successfully!
echo ========================================================
echo.
echo The bot is now running in the background.
echo.
echo Useful commands:
echo   View logs:         docker-compose logs telegram-copilot-bot
echo   Stop bot:          docker-compose down
echo   Restart bot:       docker-compose restart
echo   Update and restart: double-click this script again
echo.
echo Check .env file for configuration details.
echo.

:: Check if .env file exists and show configuration status
if exist .env (
    echo Configuration file (.env) created successfully!
    echo.
    echo Please verify your configuration in .env file:
    echo - TELEGRAM_BOT_TOKEN: Required for bot functionality
    echo - OPENAI_API_KEY: Required for AI features
    echo.
    
    :: Check if critical configs are missing
    findstr /C:"# TELEGRAM_BOT_TOKEN" .env >nul
    if not errorlevel 1 (
        echo WARNING: TELEGRAM_BOT_TOKEN is missing!
        echo Please get your token from https://t.me/BotFather
        echo and add it to the .env file.
    )
    
    findstr /C:"# OPENAI_API_KEY" .env >nul
    if not errorlevel 1 (
        echo WARNING: OPENAI_API_KEY is missing!
        echo Please get your API key from https://platform.openai.com/api-keys
        echo and add it to the .env file.
        echo.
        echo After adding missing configurations, run:
        echo docker-compose restart
    )
) else (
    echo WARNING: .env file was not created!
    echo Manual configuration may be required.
)

echo.
echo Press any key to exit...
pause >nul