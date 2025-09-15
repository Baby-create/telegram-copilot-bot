#!/bin/bash
# Telegram Copilot Bot - Linux/Unix Deployment Script
# Run this script to automatically deploy the bot on Linux/Unix systems

set -e  # Exit on any error

echo ""
echo "========================================================"
echo "    Telegram Copilot Bot - Automated Deployment"
echo "========================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Set script directory as working directory
cd "$(dirname "$0")"

# Check Python installation
echo "[1/7] Checking Python installation..."
if command_exists python3; then
    PYTHON_CMD="python3"
    print_status "Python 3 is installed"
elif command_exists python; then
    PYTHON_CMD="python"
    print_status "Python is installed"
else
    print_error "Python is not installed!"
    echo "Please install Python 3.8+ and try again."
    exit 1
fi

# Check pip installation
echo "[2/7] Checking pip installation..."
if command_exists pip3; then
    PIP_CMD="pip3"
    print_status "pip3 is installed"
elif command_exists pip; then
    PIP_CMD="pip"
    print_status "pip is installed"
else
    print_error "pip is not installed!"
    echo "Please install pip and try again."
    exit 1
fi

# Check if Docker is installed (optional)
echo "[3/7] Checking Docker installation..."
if command_exists docker; then
    print_status "Docker is installed"
    DOCKER_AVAILABLE=true
    
    # Check if Docker is running
    if docker info >/dev/null 2>&1; then
        print_status "Docker is running"
        DOCKER_RUNNING=true
    else
        print_warning "Docker is installed but not running"
        DOCKER_RUNNING=false
    fi
else
    print_warning "Docker is not installed. Will use direct Python installation."
    DOCKER_AVAILABLE=false
    DOCKER_RUNNING=false
fi

# Check if Git is installed (optional)
echo "[4/7] Checking Git installation..."
if command_exists git; then
    print_status "Git is installed"
    
    # Update repository if we're in a git repo
    if [ -d ".git" ]; then
        echo "    Updating repository..."
        git pull origin main 2>/dev/null || {
            print_warning "Could not update repository. Continuing with current version."
        }
    fi
else
    print_warning "Git is not installed. Repository updates will be skipped."
fi

# Install Python dependencies
echo "[5/7] Installing Python dependencies..."
if [ ! -f "requirements.txt" ]; then
    print_error "requirements.txt not found!"
    exit 1
fi

$PIP_CMD install --user -r requirements.txt || {
    print_error "Failed to install Python dependencies!"
    echo "Please check your Python/pip installation and try again."
    exit 1
}
print_status "Python dependencies installed"

# Run configuration detection
echo "[6/7] Detecting and configuring bot settings..."
$PYTHON_CMD detect_config.py || {
    print_error "Configuration detection failed!"
    echo "Please check the error messages above and try again."
    exit 1
}
print_status "Configuration completed"

# Choose deployment method
echo "[7/7] Starting Telegram Copilot Bot..."

if [ "$DOCKER_RUNNING" = true ]; then
    echo "Starting with Docker..."
    
    # Stop any existing containers
    docker-compose down 2>/dev/null || true
    
    # Build and start the bot
    docker-compose up --build -d || {
        print_error "Failed to start the bot with Docker!"
        echo "Falling back to direct Python execution..."
        DOCKER_FAILED=true
    }
    
    if [ "$DOCKER_FAILED" != true ]; then
        print_status "Bot started successfully with Docker!"
        echo ""
        echo "Bot is running in Docker container."
        echo ""
        echo "Useful commands:"
        echo "  View logs:         docker-compose logs telegram-copilot-bot"
        echo "  Stop bot:          docker-compose down"
        echo "  Restart bot:       docker-compose restart"
        echo "  Update and restart: ./deploy_bot.sh"
        echo ""
    fi
fi

# Fallback to direct Python execution
if [ "$DOCKER_RUNNING" != true ] || [ "$DOCKER_FAILED" = true ]; then
    echo "Starting with direct Python execution..."
    
    # Check if we have a valid configuration
    if ! grep -q "^TELEGRAM_BOT_TOKEN=" .env 2>/dev/null; then
        print_error "TELEGRAM_BOT_TOKEN not found in .env file!"
        echo "Please add your Telegram bot token to the .env file and try again."
        echo "Get your token from: https://t.me/BotFather"
        exit 1
    fi
    
    # Start bot in background
    nohup $PYTHON_CMD bot.py > bot.log 2>&1 &
    BOT_PID=$!
    
    # Give it a moment to start
    sleep 2
    
    # Check if bot is still running
    if kill -0 $BOT_PID 2>/dev/null; then
        print_status "Bot started successfully (PID: $BOT_PID)"
        echo "Bot is running in the background."
        echo ""
        echo "Useful commands:"
        echo "  View logs:         tail -f bot.log"
        echo "  Stop bot:          kill $BOT_PID"
        echo "  Restart bot:       ./deploy_bot.sh"
        echo ""
        
        # Save PID for later use
        echo $BOT_PID > bot.pid
    else
        print_error "Bot failed to start!"
        echo "Check bot.log for error details:"
        echo "tail bot.log"
        exit 1
    fi
fi

echo "========================================================"
print_status "Telegram Copilot Bot deployed successfully!"
echo "========================================================"
echo ""

# Check configuration status
if [ -f ".env" ]; then
    echo "Configuration file (.env) status:"
    
    if grep -q "^TELEGRAM_BOT_TOKEN=" .env; then
        print_status "TELEGRAM_BOT_TOKEN: Configured"
    else
        print_warning "TELEGRAM_BOT_TOKEN: Missing - Add to .env file"
    fi
    
    if grep -q "^OPENAI_API_KEY=" .env; then
        print_status "OPENAI_API_KEY: Configured"
    else
        print_warning "OPENAI_API_KEY: Missing - AI features disabled"
        echo "         Get your key from: https://platform.openai.com/api-keys"
    fi
    
    echo ""
    echo "To update configuration:"
    echo "1. Edit .env file with your API keys"
    echo "2. Restart the bot: ./deploy_bot.sh"
else
    print_warning ".env file not found! Please run configuration detection manually:"
    echo "$PYTHON_CMD detect_config.py"
fi

echo ""
echo "Bot deployment completed successfully!"