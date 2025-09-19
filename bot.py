#!/usr/bin/env python3
"""
Telegram Copilot Bot - Main Application
Automated deployment with configuration detection
"""

import os
import sys
import logging
import asyncio
from typing import Optional, Dict, Any
from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes
import openai
from dotenv import load_dotenv
from config_detector import ConfigDetector
from aiohttp import web
from pathlib import Path

# Configure logging
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)
logger = logging.getLogger(__name__)

class TelegramCopilotBot:
    """Main Telegram Copilot Bot class"""
    
    def __init__(self):
        self.config_detector = ConfigDetector()
        self.telegram_token = None
        self.openai_api_key = None
        self.openai_client = None
        self.application = None
        self.health_server = None
        
    async def initialize(self):
        """Initialize bot with auto-detected configuration"""
        logger.info("Initializing Telegram Copilot Bot...")
        
        # Auto-detect and populate configuration
        await self.config_detector.detect_and_populate_config()
        
        # Load environment variables
        load_dotenv()
        
        # Get configuration
        self.telegram_token = os.getenv('TELEGRAM_BOT_TOKEN')
        self.openai_api_key = os.getenv('OPENAI_API_KEY')
        
        if not self.telegram_token:
            logger.error("TELEGRAM_BOT_TOKEN not found! Please check configuration.")
            sys.exit(1)
            
        if not self.openai_api_key:
            logger.warning("OPENAI_API_KEY not found! AI features will be disabled.")
            self.openai_client = None
        else:
            self.openai_client = openai.OpenAI(api_key=self.openai_api_key)
            
        # Create application
        self.application = Application.builder().token(self.telegram_token).build()
        
        # Add handlers
        self.application.add_handler(CommandHandler("start", self.start_command))
        self.application.add_handler(CommandHandler("help", self.help_command))
        self.application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, self.handle_message))
        
        logger.info("Bot initialized successfully!")
        
        # Start health check server
        await self._start_health_server()
        
    async def start_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Handle /start command"""
        welcome_message = """
🤖 Welcome to Telegram Copilot Bot!

This bot provides AI-powered assistance with full automation capabilities.

Available commands:
/start - Show this welcome message
/help - Show available commands

Just send me any message and I'll help you with AI-powered responses!
        """
        await update.message.reply_text(welcome_message)
        
    async def help_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Handle /help command"""
        help_message = """
🔧 Available Commands:

/start - Welcome message and introduction
/help - Show this help message

💬 Text Messages:
Send any text message and I'll provide AI-powered responses using OpenAI.

🚀 Features:
- Automated configuration detection
- AI-powered chat responses
- Full deployment automation
- Docker containerization support

This bot is deployed using fully automated scripts - no manual configuration required!
        """
        await update.message.reply_text(help_message)
        
    async def handle_message(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Handle text messages with AI response"""
        user_message = update.message.text
        user_name = update.effective_user.first_name or "User"
        
        logger.info(f"Received message from {user_name}: {user_message}")
        
        # Send typing indicator
        await context.bot.send_chat_action(chat_id=update.effective_chat.id, action="typing")
        
        try:
            if self.openai_client:
                # Generate AI response
                response = await self.generate_ai_response(user_message)
            else:
                response = f"Hello {user_name}! I received your message: '{user_message}'\n\n" \
                          "Note: AI features are currently disabled. Please configure OPENAI_API_KEY for full functionality."
                          
            await update.message.reply_text(response)
            
        except Exception as e:
            logger.error(f"Error handling message: {e}")
            await update.message.reply_text(
                "Sorry, I encountered an error processing your message. Please try again."
            )
            
    async def generate_ai_response(self, message: str) -> str:
        """Generate AI response using OpenAI"""
        try:
            response = self.openai_client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": "You are a helpful AI assistant integrated into a Telegram bot. Provide concise, helpful responses."},
                    {"role": "user", "content": message}
                ],
                max_tokens=500,
                temperature=0.7
            )
            
            return response.choices[0].message.content.strip()
            
        except Exception as e:
            logger.error(f"Error generating AI response: {e}")
            return "I'm sorry, I'm having trouble generating a response right now. Please try again."
            
    async def _start_health_server(self):
        """Start health check HTTP server and serve frontend"""
        async def health_check(request):
            return web.json_response({
                "status": "healthy",
                "bot": "telegram-copilot-bot",
                "timestamp": asyncio.get_event_loop().time(),
                "frontend": "available at /app"
            })
        
        # Serve static files from dist directory
        async def serve_frontend(request):
            """Serve the React frontend"""
            dist_dir = Path(__file__).parent / 'dist'
            index_file = dist_dir / 'index.html'
            
            if not index_file.exists():
                return web.Response(
                    text="""
                    <html>
                    <head><title>Telegram Copilot Bot</title></head>
                    <body>
                        <h1>🤖 Telegram Copilot Bot</h1>
                        <p>Frontend not built yet. Run <code>npm run build</code> to build the React app.</p>
                        <p>Health check: <a href="/health">/health</a></p>
                    </body>
                    </html>
                    """,
                    content_type='text/html'
                )
            
            with open(index_file, 'r', encoding='utf-8') as f:
                content = f.read()
            return web.Response(text=content, content_type='text/html')
            
        app = web.Application()
        app.router.add_get('/health', health_check)
        app.router.add_get('/', health_check)
        app.router.add_get('/app', serve_frontend)
        app.router.add_get('/app/', serve_frontend)
        
        # Serve static assets if dist directory exists
        dist_dir = Path(__file__).parent / 'dist'
        if dist_dir.exists():
            app.router.add_static('/', dist_dir, name='static')
        
        # Start server in background without signal handlers
        try:
            runner = web.AppRunner(app)
            await runner.setup()
            
            site = web.TCPSite(runner, '0.0.0.0', 8080)
            await site.start()
            
            logger.info("Health check server started on port 8080")
            logger.info("Frontend available at http://localhost:8080/app")
        except Exception as e:
            logger.warning(f"Could not start health server: {e}")
            
    async def run(self):
        """Run the bot"""
        logger.info("Starting Telegram Copilot Bot...")
        await self.application.initialize()
        await self.application.start()
        await self.application.updater.start_polling()
        
        # Keep the bot running
        try:
            await asyncio.Event().wait()
        except KeyboardInterrupt:
            logger.info("Shutting down bot...")
        finally:
            await self.application.updater.stop()
            await self.application.stop()
            await self.application.shutdown()

async def main():
    """Main function"""
    bot = TelegramCopilotBot()
    await bot.initialize()
    await bot.run()

if __name__ == "__main__":
    asyncio.run(main())