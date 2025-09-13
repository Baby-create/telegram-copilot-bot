# Telegram Copilot Bot - Installation Guide

## Quick Installation (Recommended)

### Windows Users
1. Download or clone this repository
2. **Double-click `deploy_bot.bat`**
3. Follow the prompts and add your API keys when requested

### Linux/Mac Users
1. Download or clone this repository
2. **Run `./deploy_bot.sh`**
3. Follow the prompts and add your API keys when requested

## Prerequisites

### Required
- **Python 3.8+** installed and accessible from command line
- **Telegram Bot Token** - Get from [@BotFather](https://t.me/BotFather)

### Optional but Recommended
- **Docker** and Docker Compose for containerized deployment
- **OpenAI API Key** - Get from [OpenAI Platform](https://platform.openai.com/api-keys) for AI features
- **Git** for easy updates

## Step-by-Step Manual Installation

### 1. Get Your API Keys

#### Telegram Bot Token
1. Open Telegram and search for [@BotFather](https://t.me/BotFather)
2. Send `/newbot` command
3. Follow the instructions to create your bot
4. Copy the bot token (format: `1234567890:ABCDEFGHIJKLMNOPQRSTUVWXYZ`)

#### OpenAI API Key (Optional)
1. Go to [OpenAI Platform](https://platform.openai.com/api-keys)
2. Create an account or log in
3. Click "Create new secret key"
4. Copy the API key (format: `sk-...`)

### 2. Download the Bot
```bash
# Option 1: Git clone
git clone https://github.com/Baby-create/telegram-copilot-bot.git
cd telegram-copilot-bot

# Option 2: Download ZIP
# Download from GitHub and extract
```

### 3. Install Dependencies
```bash
# Install Python dependencies
pip install -r requirements.txt

# Or with pip3 on some systems
pip3 install -r requirements.txt
```

### 4. Configure the Bot
```bash
# Run automatic configuration detection
python detect_config.py

# Or manually create .env file
cp .env.example .env
# Edit .env with your favorite text editor
```

### 5. Add Your API Keys
Edit the `.env` file and add your keys:
```env
TELEGRAM_BOT_TOKEN=your_actual_bot_token_here
OPENAI_API_KEY=your_actual_openai_key_here
```

### 6. Run the Bot

#### Option A: Direct Python (Simple)
```bash
python bot.py
```

#### Option B: Docker (Recommended for production)
```bash
# Build and run with Docker Compose
docker-compose up --build -d

# View logs
docker-compose logs telegram-copilot-bot

# Stop
docker-compose down
```

#### Option C: Use Deployment Scripts
```bash
# Windows
deploy_bot.bat

# Linux/Mac
./deploy_bot.sh
```

## Configuration Options

### Environment Variables
Create a `.env` file with these variables:

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `TELEGRAM_BOT_TOKEN` | Yes | Your Telegram bot token | `1234567890:ABC...` |
| `OPENAI_API_KEY` | No | OpenAI API key for AI features | `sk-...` |
| `OPENAI_ORG_ID` | No | OpenAI organization ID | `org-...` |

### Automatic Detection
The bot automatically searches for configuration in:
- Environment variables
- `.env` files in project directory
- User configuration directories
- Git history (safely)

## Troubleshooting

### Common Issues

#### "No module named 'telegram'"
```bash
# Install dependencies
pip install -r requirements.txt
```

#### "TELEGRAM_BOT_TOKEN not found"
1. Check your `.env` file exists
2. Verify the token format is correct
3. Remove any quotes around the token

#### Bot doesn't respond
1. Check if the bot is running: `python bot.py`
2. Verify your bot token is correct
3. Make sure you've started the bot in Telegram with `/start`

#### Docker issues
1. Ensure Docker is installed and running
2. Try rebuilding: `docker-compose down && docker-compose up --build`
3. Check logs: `docker-compose logs telegram-copilot-bot`

### Health Checks
The bot includes a health check endpoint at `http://localhost:8080/health`

### Logs
- **Direct Python**: Logs appear in console
- **Docker**: Use `docker-compose logs telegram-copilot-bot`
- **Background mode**: Check `bot.log` file

## Directory Structure

After installation, your directory should look like:
```
telegram-copilot-bot/
├── bot.py                 # Main bot application
├── config_detector.py     # Configuration detection
├── detect_config.py       # Standalone config script
├── requirements.txt       # Python dependencies
├── .env                   # Your configuration (created)
├── .env.example          # Configuration template
├── Dockerfile            # Docker configuration
├── docker-compose.yml    # Docker orchestration
├── deploy_bot.bat        # Windows deployment
├── deploy_bot.sh         # Linux/Mac deployment
├── INSTALL.md            # This file
└── README.md             # Project documentation
```

## Security Notes

- Never commit your `.env` file to version control
- Keep your API keys private
- The bot runs in an isolated Docker container when using Docker
- API keys are never logged or transmitted

## Support

1. Check this installation guide
2. Review the main [README.md](README.md)
3. Check the troubleshooting section above
4. Open an issue on GitHub if problems persist

## Next Steps

1. Send `/start` to your bot in Telegram
2. Try sending a message to test AI responses
3. Customize the bot code as needed
4. Set up monitoring and backups for production use

Happy botting! 🤖