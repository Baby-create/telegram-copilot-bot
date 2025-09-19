@echo off
:: Telegram Copilot Bot - One-Click Local Deployment Script for Windows
:: Double-click this file to automatically install dependencies and start the bot locally
:: No Docker required - simple Python-based deployment

:: Enable delayed variable expansion for variables in loops and conditionals
setlocal enabledelayedexpansion

echo.
echo ==========================================================
echo    Telegram Copilot Bot - One-Click Local Start
echo ==========================================================
echo.

:: Set script directory as working directory
cd /d "%~dp0"

echo Starting one-click local deployment...
echo.

:: Check Python installation
echo [1/4] Checking Python environment...
python --version >nul 2>&1
if errorlevel 1 (
    :: Try python3 command
    python3 --version >nul 2>&1
    if errorlevel 1 (
        echo ERROR: Python is not installed or not in PATH!
        echo.
        echo Please install Python 3.8+ first:
        echo   1. Download from: https://www.python.org/downloads/
        echo   2. During installation, check "Add Python to PATH"
        echo   3. Restart this script after installation
        echo.
        pause
        exit /b 1
    ) else (
        set PYTHON_CMD=python3
        for /f "tokens=*" %%i in ('python3 --version 2^>^&1') do set PYTHON_VERSION=%%i
        echo ✓ Python 3 is installed: !PYTHON_VERSION!
    )
) else (
    :: Check if it's Python 3
    for /f "tokens=*" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
    echo !PYTHON_VERSION! | findstr /C:"Python 3" >nul
    if errorlevel 1 (
        echo ERROR: Python 3 is required but Python 2 found!
        echo Please install Python 3.8+ from: https://www.python.org/downloads/
        echo.
        pause
        exit /b 1
    ) else (
        set PYTHON_CMD=python
        echo ✓ Python 3 is installed: !PYTHON_VERSION!
    )
)

:: Check pip installation
echo [2/4] Checking pip installation...
!PYTHON_CMD! -m pip --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: pip is not available!
    echo.
    echo Try to fix pip installation:
    echo   !PYTHON_CMD! -m ensurepip --upgrade
    echo.
    pause
    exit /b 1
)
echo ✓ pip is available

:: Install dependencies
echo [3/4] Installing Python dependencies...
if not exist "requirements.txt" (
    echo ERROR: requirements.txt not found!
    echo Make sure you're running this script from the project root directory.
    echo.
    pause
    exit /b 1
)

echo Installing dependencies with: !PYTHON_CMD! -m pip install -r requirements.txt
!PYTHON_CMD! -m pip install --user -r requirements.txt
if errorlevel 1 (
    echo ERROR: Failed to install dependencies!
    echo.
    echo Possible solutions:
    echo 1. Check internet connection
    echo 2. Update pip: !PYTHON_CMD! -m pip install --upgrade pip
    echo 3. Try running as administrator
    echo.
    pause
    exit /b 1
)
echo ✓ Dependencies installed successfully

:: Configure environment
echo [4/4] Setting up configuration...
if not exist ".env" (
    echo Running configuration detection...
    !PYTHON_CMD! detect_config.py
    if errorlevel 1 (
        echo WARNING: Automatic configuration failed. Creating template .env file...
        if exist ".env.example" (
            copy ".env.example" ".env" >nul
        ) else (
            :: Create basic .env template
            (
                echo # Telegram Bot Configuration
                echo # Get your token from: https://t.me/BotFather
                echo # TELEGRAM_BOT_TOKEN=your_bot_token_here
                echo.
                echo # OpenAI Configuration ^(Optional^)
                echo # Get your key from: https://platform.openai.com/api-keys
                echo # OPENAI_API_KEY=your_openai_api_key_here
                echo.
                echo # Optional: OpenAI Organization ID
                echo # OPENAI_ORG_ID=your_org_id_here
            ) > .env
        )
    )
)

:: Check configuration status
findstr /R "^TELEGRAM_BOT_TOKEN=" .env >nul 2>&1
if errorlevel 1 (
    echo WARNING: Configuration needed!
    echo.
    echo Before running the bot, please:
    echo 1. Get your Telegram Bot Token from: https://t.me/BotFather
    echo 2. Edit the .env file and add your token:
    echo    TELEGRAM_BOT_TOKEN=your_actual_token_here
    echo 3. Optionally add OpenAI API key for AI features
    echo.
    echo Then run this script again to start the bot.
    echo.
    echo Press any key to open the .env file for editing...
    pause >nul
    notepad .env
    exit /b 0
) else (
    echo ✓ Configuration found - ready to start!
)

echo.
echo ==========================================================
echo ✓ Setup Complete! Starting Telegram Copilot Bot...
echo ==========================================================
echo.

:: Start the bot
echo Starting bot with: !PYTHON_CMD! bot.py
echo Press Ctrl+C to stop the bot
echo.

!PYTHON_CMD! bot.py

:: Keep window open if there's an error
if errorlevel 1 (
    echo.
    echo Bot stopped with an error. Check the messages above.
    echo.
    pause
)