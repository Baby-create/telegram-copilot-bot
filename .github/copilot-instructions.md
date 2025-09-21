# Telegram Copilot Bot - Developer Instructions

**ALWAYS FOLLOW THESE INSTRUCTIONS FIRST** and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

This is a Python-based Telegram bot with AI-powered responses using OpenAI. The bot features automated configuration detection and deployment through various methods (direct Python execution, Docker, and automated deployment scripts).

## ⚠️ CRITICAL TIMEOUT REQUIREMENTS ⚠️

**NEVER CANCEL BUILDS OR LONG-RUNNING COMMANDS**

- **pip install**: Use 300+ second timeouts (may fail in sandboxed environments with network issues)
- **Deployment scripts**: Use 300+ second timeouts (complete 7-step process)  
- **Docker builds**: Use 600+ second timeouts (may fail due to SSL certificate issues in some environments)
- **Configuration detection**: Very fast (~0.07 seconds) - use 30+ second timeout

**These timeouts are based on actual measured performance. Commands are designed to complete successfully or fail fast with clear error messages.**

## Working Effectively

### Bootstrap, Build, and Test the Repository

#### Initial Setup (Required - 15 seconds total):
```bash
# 1. Install Python dependencies (takes ~13 seconds - NEVER CANCEL)
# Note: May fail in environments with network/firewall limitations
pip3 install -r requirements.txt

# 2. Generate configuration (takes ~0.07 seconds)  
python3 detect_config.py
```

**NETWORK LIMITATIONS**: In some sandboxed environments, pip may fail with SSL certificate errors or timeouts when accessing PyPI. This is environment-specific, not a code issue. The deployment scripts handle these failures gracefully.

#### Automated Deployment Scripts (Recommended for users):
```bash
# Windows users:
deploy_bot.bat

# Linux/Mac users:
./deploy_bot.sh
```

**NEVER CANCEL**: Deployment scripts may take 2-3 minutes to complete all checks, dependency installation, and configuration. Always use timeout of 300+ seconds.

#### Docker Deployment (Use docker compose, not docker-compose):
```bash
# Note: Docker builds may fail in environments with SSL certificate issues
# Use docker compose (v2 syntax), not docker-compose
docker compose up --build -d

# View logs:
docker compose logs telegram-copilot-bot

# Stop:
docker compose down
```

**CRITICAL**: Docker builds fail in some environments due to SSL certificate issues when accessing PyPI. Document this limitation - it's environment-specific, not a code issue.

#### Direct Python Execution:
```bash
# Start the bot (requires valid .env configuration)
python3 bot.py
```

### Timing Expectations and Timeouts

- **Python dependency installation**: ~13 seconds in normal environments - Set timeout to 120+ seconds minimum
- **Configuration detection**: ~0.07 seconds - Very fast
- **Deployment scripts**: 2-3 minutes for full execution - Set timeout to 300+ seconds  
- **Docker builds**: Variable (may fail due to SSL issues) - Set timeout to 600+ seconds
- **Bot startup**: Immediate if config valid, fails fast if invalid

**NETWORK LIMITATIONS**: In sandboxed environments, pip installations may fail with timeout errors when accessing PyPI. This is normal and environment-specific - document this limitation in instructions.

**NEVER CANCEL** any of these operations. They are designed to complete successfully or fail fast with clear error messages.

## Validation

### Always Test After Changes:
1. **Configuration validation**: Run `python3 detect_config.py` to ensure config detection works
2. **Bot startup validation**: Test with invalid token first to ensure proper error handling:
   ```bash
   echo 'TELEGRAM_BOT_TOKEN=test_token_12345:fake_token' > .env.test
   cp .env.test .env  
   timeout 10 python3 bot.py  # Should fail gracefully with clear error message
   ```
3. **Deployment script validation**: Test both `./deploy_bot.sh` (Linux/Mac) and `deploy_bot.bat` (Windows) 
4. **Docker validation**: Test `docker compose up --build` (expect SSL failures in some environments)

### Manual Validation Scenarios:
Since the bot requires valid Telegram and OpenAI API keys for full functionality, perform these validation scenarios after making changes:

1. **Configuration Detection Test**: 
   - Remove .env file
   - Run `python3 detect_config.py`
   - Verify it creates .env with proper placeholder comments and instructions

2. **Error Handling Test**:
   - Test with invalid bot token format
   - Test with missing configuration  
   - Verify graceful error messages and exit codes
   - Expected: Bot exits with "TELEGRAM_BOT_TOKEN not found!" or "ModuleNotFoundError" if dependencies missing

3. **Deployment Script Test**:
   - Run deployment scripts and verify they complete all 7 steps
   - Check that Docker/Python fallback logic works correctly

## Configuration and Environment

### Required Configuration (.env file):
```
TELEGRAM_BOT_TOKEN=your_bot_token_here  # Get from @BotFather
OPENAI_API_KEY=your_openai_key_here     # Optional - for AI features
OPENAI_ORG_ID=your_org_id_here          # Optional - organization accounts
```

### Environment Requirements:
- **Python 3.8+** (tested with 3.12.3)
- **pip3** for package management
- **Docker** (optional) - Use `docker compose` not `docker-compose`
- **Git** (optional) - for repository updates

### Configuration Detection Behavior:
The `config_detector.py` automatically searches:
- Environment variables
- Project files (.env, config files)  
- User configuration directories
- Git history (safely - no sensitive data exposure)

## Key File Structure and Navigation

### Primary Application Files:
- `bot.py` - Main Telegram bot application
- `config_detector.py` - Automatic configuration detection library
- `detect_config.py` - Standalone configuration script
- `requirements.txt` - Python dependencies (5 packages)

### Deployment Scripts:
- `deploy_bot.sh` - Linux/Mac automated deployment
- `deploy_bot.bat` - Windows automated deployment  
- `start.sh` - Linux/Mac local Python deployment
- `start.bat` - Windows local Python deployment

### Docker Configuration:
- `Dockerfile` - Multi-stage build with security (non-root user)
- `docker-compose.yml` - Container orchestration with health checks
- **Note**: docker-compose.yml uses deprecated `version` field (warning expected)

### Documentation:
- `README.md` - Primary documentation
- `INSTALL.md` - Detailed installation guide
- `DEPLOYMENT_SUMMARY.md` - Automated deployment overview
- `.env.example` - Configuration template

## Common Issues and Solutions

### Network and Environment Limitations:
1. **pip install timeouts**: In sandboxed environments, pip may fail with "Read timed out" errors when accessing PyPI
   - This is environment-specific, not a code issue
   - Deployment scripts handle these failures gracefully
   - Users in normal environments will not experience this issue

### Docker Issues:
1. **SSL Certificate Errors**: Normal in sandboxed environments - use direct Python execution instead
2. **docker-compose not found**: Use `docker compose` (v2 syntax) instead
3. **Permission errors**: Dockerfile uses non-root user for security

### Configuration Issues:
1. **Missing tokens**: Run `python3 detect_config.py` to regenerate .env template
2. **Invalid token format**: Bot validates tokens and provides clear error messages
3. **API rate limits**: Configure appropriate OpenAI organization ID if needed

### Deployment Issues:
1. **Python not found**: Deployment scripts check for python3 and python commands
2. **Dependencies fail**: Usually network/firewall issues - scripts handle gracefully
3. **Git update fails**: Normal in isolated environments - scripts continue without updates

## Bot Commands and Functionality

### Available Bot Commands:
- `/start` - Welcome message and introduction
- `/help` - Show available commands  
- **Text messages** - AI-powered responses (requires OpenAI API key)

### Health Check:
- Bot exposes port 8080 for health checks when running in Docker
- Health check endpoint validates bot is running properly

## Security Notes

- API keys are automatically detected but never logged or exposed
- .env files are in .gitignore to prevent accidental commits
- Docker containers run as non-root user
- Configuration detection safely scans git history without exposing sensitive data

## Development Workflow

1. **Make code changes** to Python files
2. **Test configuration detection**: `python3 detect_config.py`  
3. **Test bot startup** with invalid config to verify error handling
4. **Test deployment scripts** to ensure automation still works
5. **Validate Docker builds** (expect SSL failures in some environments)
6. **Syntax validation**: `python3 -c "import ast; [ast.parse(open(f).read(), f) for f in ['bot.py', 'config_detector.py', 'detect_config.py']]; print('✅ All Python files have valid syntax')"`
7. **No unit tests exist** - validation is primarily functional testing

## Common Tasks

The following are outputs from frequently run commands. Reference them instead of viewing, searching, or running bash commands to save time.

### Repository File Listing
```
ls -la
total 136
drwxr-xr-x 5 runner runner 4096 .
drwxr-xr-x 3 runner runner 4096 ..
-rw-rw-r-- 1 runner runner  822 .env.example
drwxrwxr-x 7 runner runner 4096 .git
drwxrwxr-x 2 runner runner 4096 .github
-rw-rw-r-- 1 runner runner  517 .gitignore
-rw-rw-r-- 1 runner runner 6426 DEPLOYMENT_SUMMARY.md
-rw-rw-r-- 1 runner runner 1338 Dockerfile
-rw-rw-r-- 1 runner runner 5285 INSTALL.md
-rw-rw-r-- 1 runner runner 6207 README.md
-rw-rw-r-- 1 runner runner 7342 bot.py
-rw-rw-r-- 1 runner runner 9982 config_detector.py
-rw-rw-r-- 1 runner runner 1954 demo_deployment.bat
-rwxrwxr-x 1 runner runner 2044 demo_deployment.sh
-rw-rw-r-- 1 runner runner 4099 deploy_bot.bat
-rwxrwxr-x 1 runner runner 6658 deploy_bot.sh
-rw-rw-r-- 1 runner runner 1823 detect_config.py
-rw-rw-r-- 1 runner runner  886 docker-compose.yml
-rw-rw-r-- 1 runner runner   92 requirements.txt
-rw-rw-r-- 1 runner runner 5070 start.bat
-rwxrwxr-x 1 runner runner 4778 start.sh
```

### Python Dependencies (requirements.txt)
```
python-telegram-bot==20.7
openai==1.3.0
python-dotenv==1.0.0
requests==2.31.0
aiohttp==3.9.1
```

### Configuration Template (.env.example)
```
# Telegram Copilot Bot Configuration Example
# Copy this file to .env and fill in your actual values

# Required: Your Telegram Bot Token (get from @BotFather)
# TELEGRAM_BOT_TOKEN=1234567890:ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890

# Required for AI features: Your OpenAI API Key
# OPENAI_API_KEY=sk-your-openai-api-key-here

# Optional: OpenAI Organization ID (only needed for organization accounts)
# OPENAI_ORG_ID=org-your-organization-id-here
```

## Performance and Expectations

- **Fast startup**: Configuration detection and bot initialization in under 1 second
- **Lightweight**: Only 5 Python dependencies
- **Efficient Docker**: Multi-stage build for optimized production images
- **Graceful errors**: All failures provide clear error messages and next steps

Always remember: The bot is designed for easy deployment and clear error messages. If something fails, read the error output - it will tell you exactly what to do next.