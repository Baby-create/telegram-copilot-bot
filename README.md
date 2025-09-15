# Telegram Copilot Bot

🤖 A fully automated Telegram bot with AI-powered responses and complete deployment automation.

## Features

- 🚀 **One-Click Deployment**: Double-click `deploy_bot.bat` to automatically deploy
- 🔍 **Auto Configuration**: Automatically detects and populates required API keys
- 🐳 **Docker Support**: Complete containerization with Docker and docker-compose
- 🤖 **AI Integration**: OpenAI GPT-powered chat responses
- 🔧 **Zero Manual Setup**: No manual configuration required

## Quick Start (Windows)

1. **Download or clone this repository**
2. **Double-click `deploy_bot.bat`** - That's it! 

The script will automatically:
- Check Docker installation
- Detect and configure API keys
- Build and start the bot
- Show configuration status

## Requirements

- Docker Desktop installed and running
- Python 3.11+ (for configuration detection)
- Telegram Bot Token (get from [@BotFather](https://t.me/BotFather))
- OpenAI API Key (get from [OpenAI Platform](https://platform.openai.com/api-keys))

## Manual Setup (Advanced Users)

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Configure Environment
```bash
# Run automatic configuration detection
python detect_config.py

# Or manually create .env file
cp .env.example .env
# Edit .env with your keys
```

### 3. Run with Docker
```bash
# Build and start
docker-compose up --build -d

# View logs
docker-compose logs telegram-copilot-bot

# Stop
docker-compose down
```

### 4. Run Locally (Development)
```bash
python bot.py
```

## Configuration

The bot automatically searches for configuration in:
- Environment variables
- Project files (.env, config files)
- User configuration directories
- Git history (safely)

### Required Configuration
- `TELEGRAM_BOT_TOKEN`: Your Telegram bot token from @BotFather
- `OPENAI_API_KEY`: Your OpenAI API key (optional, enables AI features)

### Optional Configuration
- `OPENAI_ORG_ID`: OpenAI organization ID (for organization accounts)

## Bot Commands

- `/start` - Welcome message and introduction
- `/help` - Show available commands
- **Text messages** - AI-powered responses using OpenAI

## File Structure

```
telegram-copilot-bot/
├── bot.py                 # Main bot application
├── config_detector.py     # Automatic configuration detection
├── detect_config.py       # Standalone config detection script
├── requirements.txt       # Python dependencies
├── Dockerfile            # Docker container configuration
├── docker-compose.yml    # Docker orchestration
├── deploy_bot.bat        # Windows one-click deployment
├── .gitignore           # Git ignore rules
└── README.md            # This file
```

## Deployment Options

### Option 1: One-Click Deployment (Recommended)
- Double-click `deploy_bot.bat` on Windows
- Everything is automated

### Option 2: Docker Compose
```bash
docker-compose up --build -d
```

### Option 3: Docker Manual
```bash
docker build -t telegram-copilot-bot .
docker run -d --env-file .env telegram-copilot-bot
```

### Option 4: Python Direct
```bash
python bot.py
```

## Troubleshooting

### Bot Not Starting
1. Check if Docker is running
2. Verify .env file has correct tokens
3. Check logs: `docker-compose logs telegram-copilot-bot`

### Configuration Issues
1. Run: `python detect_config.py`
2. Check generated .env file
3. Manually add missing configurations

### Docker Issues
1. Ensure Docker Desktop is installed and running
2. Check available disk space
3. Try: `docker-compose down && docker-compose up --build -d`

## Security

- API keys are automatically detected but never logged
- .env files are excluded from git commits
- Bot runs in isolated Docker container
- Uses non-root user in container

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `deploy_bot.bat`
5. Submit a pull request

## License

This project is open source and available under the MIT License.

## Support

If you encounter issues:
1. Check the troubleshooting section
2. Review Docker and bot logs
3. Ensure all requirements are met
4. Open an issue on GitHub

---

🎉 **Enjoy your fully automated Telegram Copilot Bot!**