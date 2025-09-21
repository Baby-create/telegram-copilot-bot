# Telegram Copilot Bot

🤖 A fully automated Telegram bot with AI-powered responses and complete deployment automation.

## Features

- 🚀 **One-Click Local Deployment**: Simple scripts for instant local setup
- 🔧 **Cross-Platform Support**: Works on Linux, macOS, and Windows
- 🔍 **Auto Configuration**: Automatically detects and populates required API keys
- 🐳 **Docker Support**: Complete containerization with Docker and docker-compose
- 🤖 **AI Integration**: OpenAI GPT-powered chat responses
- 💡 **Zero Manual Setup**: No manual configuration required

## 🚀 One-Click Local Deployment

The easiest way to get started! No Docker required - just Python.

### Linux & macOS
```bash
# Make executable and run
chmod +x start.sh
./start.sh
```

### Windows
```cmd
# Double-click start.bat or run from command line
start.bat
```

### What the scripts do automatically:
- ✅ Check Python 3.8+ installation
- ✅ Install all dependencies via pip
- ✅ Create configuration template
- ✅ Guide you through API key setup
- ✅ Start the bot locally

## 🐳 Docker Deployment (Alternative)

For containerized deployment with Docker:

### Windows
Double-click `deploy_bot.bat` for automated Docker deployment.

### Linux & macOS  
```bash
./deploy_bot.sh
```

## Requirements

### For Local Deployment (Recommended)
- **Python 3.8+** (automatically checked by start scripts)
- **pip** (Python package manager)
- **Telegram Bot Token** (get from [@BotFather](https://t.me/BotFather))
- **OpenAI API Key** (optional, for AI features - get from [OpenAI Platform](https://platform.openai.com/api-keys))

### For Docker Deployment (Alternative)
- Docker Desktop installed and running
- Python 3.11+ (for configuration detection)
- Same API keys as above

## Manual Setup (Advanced Users)

If you prefer manual setup or need to customize the deployment:

### 1. Install Dependencies
```bash
# Using pip
pip install -r requirements.txt

# Or using pip3
pip3 install -r requirements.txt
```

### 2. Configure Environment
```bash
# Run automatic configuration detection
python detect_config.py

# Or manually create .env file
cp .env.example .env
# Edit .env with your keys
```

### 3. Run the Bot

#### Local Python Execution
```bash
python bot.py
```

#### Docker (with docker-compose)
```bash
# Build and start
docker-compose up --build -d

# View logs
docker-compose logs telegram-copilot-bot

# Stop
docker-compose down
```

#### Docker Manual
```bash
docker build -t telegram-copilot-bot .
docker run -d --env-file .env telegram-copilot-bot
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
### Windows — Super One-Click (Recommended)
- Double-click super_start.bat
- Follow prompts to paste your TELEGRAM_BOT_TOKEN and optional OPENAI_API_KEY
- Choose Local (Python) or Docker deployment
- The script installs dependencies or builds containers and starts the bot automatically

Security tip: Never commit your .env or share your bot token publicly. If a token is exposed, regenerate it in @BotFather.

<!-- In File Structure, add: -->
├── super_start.bat       # Windows super one-click launcher (guided .env + Local/Docker)

<!-- In Deployment Options Summary, add: -->
| Tool | OS | Prereqs | Notes |
|---|---|---|---|
| `super_start.bat` | Windows | Python 3.8+ or Docker Desktop | Super one-click guided setup (recommended) |telegram-copilot-bot/
├── bot.py                 # Main bot application
├── config_detector.py     # Automatic configuration detection
├── detect_config.py       # Standalone config detection script
├── requirements.txt       # Python dependencies
├── start.sh              # Linux/macOS one-click local deployment
├── start.bat             # Windows one-click local deployment
├── deploy_bot.sh         # Linux/macOS Docker deployment
├── deploy_bot.bat        # Windows Docker deployment
├── Dockerfile            # Docker container configuration
├── docker-compose.yml    # Docker orchestration
├── .env.example          # Environment configuration template
├── .gitignore           # Git ignore rules
└── README.md            # This file
```

## Deployment Options Summary

| Method | Platform | Requirements | Best For |
|--------|----------|--------------|----------|
| `start.sh` | Linux/macOS | Python 3.8+ | **Local development, beginners** |
| `start.bat` | Windows | Python 3.8+ | **Local development, beginners** |
| `deploy_bot.sh` | Linux/macOS | Docker | Production, isolated environment |
| `deploy_bot.bat` | Windows | Docker | Production, isolated environment |
| Manual | All | Python/Docker | Custom configuration |

## Troubleshooting

### Local Deployment Issues
1. **Python not found**: Install Python 3.8+ from [python.org](https://python.org/downloads/)
2. **Dependencies fail to install**: 
   - Try: `python -m pip install --upgrade pip`
   - Check internet connection
   - Run as administrator (Windows) or with `sudo` (Linux/macOS)
3. **Configuration missing**: Run the start script again, it will guide you through setup

### Docker Deployment Issues  
1. **Docker not running**: Start Docker Desktop
2. **Build failures**: Check available disk space and Docker memory limits
3. **Container won't start**: Check logs with `docker-compose logs telegram-copilot-bot`

### Bot Connection Issues
1. **Invalid bot token**: Verify token from [@BotFather](https://t.me/BotFather)
2. **Bot not responding**: Check `.env` file configuration
3. **API rate limits**: Wait a few minutes and try again

### Configuration Issues
1. Run: `python detect_config.py` to regenerate configuration
2. Check generated `.env` file for missing values
3. Manually edit `.env` with your API keys

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
