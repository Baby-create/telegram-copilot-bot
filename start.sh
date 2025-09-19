#!/bin/bash
# Telegram Copilot Bot - One-Click Local Deployment Script for Linux/macOS
# This script provides simplified local deployment without Docker requirements

set -e  # Exit on any error

echo ""
echo "=========================================================="
echo "    Telegram Copilot Bot - One-Click Local Start"
echo "=========================================================="
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

echo "Starting one-click local deployment..."
echo ""

# Check Python installation
echo "[1/4] Checking Python environment..."
if command_exists python3; then
    PYTHON_CMD="python3"
    PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    print_status "Python 3 is installed (version: $PYTHON_VERSION)"
elif command_exists python; then
    # Check if it's Python 3
    PYTHON_VERSION=$(python --version 2>&1)
    if [[ $PYTHON_VERSION == *"Python 3"* ]]; then
        PYTHON_CMD="python"
        print_status "Python 3 is installed (version: $PYTHON_VERSION)"
    else
        print_error "Python 3 is required but Python 2 found!"
        echo "Please install Python 3.8+ and try again."
        echo "Visit: https://www.python.org/downloads/"
        exit 1
    fi
else
    print_error "Python is not installed!"
    echo ""
    echo "Please install Python 3.8+ first:"
    echo "  - macOS: brew install python3 or download from https://www.python.org/"
    echo "  - Ubuntu/Debian: sudo apt update && sudo apt install python3 python3-pip"
    echo "  - CentOS/RHEL: sudo yum install python3 python3-pip"
    echo ""
    exit 1
fi

# Check pip installation
echo "[2/4] Checking pip installation..."
if command_exists pip3; then
    PIP_CMD="pip3"
    print_status "pip3 is available"
elif command_exists pip; then
    PIP_CMD="pip"
    print_status "pip is available"
else
    print_error "pip is not installed!"
    echo "Please install pip and try again."
    echo "Try: $PYTHON_CMD -m ensurepip --upgrade"
    exit 1
fi

# Install dependencies
echo "[3/4] Installing Python dependencies..."
if [ ! -f "requirements.txt" ]; then
    print_error "requirements.txt not found!"
    echo "Make sure you're running this script from the project root directory."
    exit 1
fi

echo "Installing dependencies with: $PIP_CMD install -r requirements.txt"
$PIP_CMD install --user -r requirements.txt || {
    print_error "Failed to install dependencies!"
    echo ""
    echo "Possible solutions:"
    echo "1. Try: $PYTHON_CMD -m pip install --user -r requirements.txt"
    echo "2. Check internet connection"
    echo "3. Update pip: $PIP_CMD install --upgrade pip"
    echo ""
    exit 1
}
print_status "Dependencies installed successfully"

# Configure environment
echo "[4/4] Setting up configuration..."
if [ ! -f ".env" ]; then
    echo "Running configuration detection..."
    $PYTHON_CMD detect_config.py || {
        print_warning "Automatic configuration failed. Creating template .env file..."
        if [ -f ".env.example" ]; then
            cp .env.example .env
        else
            # Create basic .env template
            cat > .env << 'EOF'
# Telegram Bot Configuration
# Get your token from: https://t.me/BotFather
# TELEGRAM_BOT_TOKEN=your_bot_token_here

# OpenAI Configuration (Optional)
# Get your key from: https://platform.openai.com/api-keys  
# OPENAI_API_KEY=your_openai_api_key_here

# Optional: OpenAI Organization ID
# OPENAI_ORG_ID=your_org_id_here
EOF
        fi
    }
fi

# Check configuration status
if grep -q "^TELEGRAM_BOT_TOKEN=" .env 2>/dev/null; then
    print_status "Configuration found - ready to start!"
else
    print_warning "Configuration needed!"
    echo ""
    echo "Before running the bot, please:"
    echo "1. Get your Telegram Bot Token from: https://t.me/BotFather"
    echo "2. Edit the .env file and add your token:"
    echo "   TELEGRAM_BOT_TOKEN=your_actual_token_here"
    echo "3. Optionally add OpenAI API key for AI features"
    echo ""
    echo "Then run this script again to start the bot."
    exit 0
fi

echo ""
echo "=========================================================="
echo "✓ Setup Complete! Starting Telegram Copilot Bot..."
echo "=========================================================="
echo ""

# Start the bot
echo "Starting bot with: $PYTHON_CMD bot.py"
echo "Press Ctrl+C to stop the bot"
echo ""

$PYTHON_CMD bot.py