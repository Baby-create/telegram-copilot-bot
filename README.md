#!/usr/bin/env python3
"""
Telegram Copilot Bot - Main Application
Adds web UI (/app) and enhanced /health endpoint while keeping existing bot features.
"""

import os
import sys
import logging
import asyncio
from pathlib import Path
from typing import Optional

from dotenv import load_dotenv
from aiohttp import web

from telegram import Update
from telegram.ext import (
    Application,
    CommandHandler,
    MessageHandler,
    ContextTypes,
    filters,
)

# OpenAI v1 client (auto-reads OPENAI_API_KEY from env)
try:
    from openai import OpenAI
except Exception:
    OpenAI = None  # OpenAI is optional

# Logging
logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s", level=logging.INFO
)
logger = logging.getLogger("telegram-copilot-bot")


class TelegramCopilotBot:
    def __init__(self):
        self.telegram_token: Optional[str] = None
        self.openai_client = None
        self.app: Optional[Application] = None

    async def initialize(self):
        load_dotenv()

        self.telegram_token = os.getenv("TELEGRAM_BOT_TOKEN")
        if not self.telegram_token:
            logger.error("TELEGRAM_BOT_TOKEN is missing. Please set it in your environment or .env file.")
            sys.exit(1)

        # Initialize OpenAI if available and configured
        if OpenAI and os.getenv("OPENAI_API_KEY"):
            try:
                self.openai_client = OpenAI()
                logger.info("OpenAI client initialized.")
            except Exception as e:
                logger.warning(f"Failed to initialize OpenAI client: {e}")
                self.openai_client = None
        else:
            logger.info("OpenAI not configured; AI responses will be disabled.")

        # Telegram handlers
        self.app = Application.builder().token(self.telegram_token).build()
        self.app.add_handler(CommandHandler("start", self.cmd_start))
        self.app.add_handler(CommandHandler("help", self.cmd_help))
        self.app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, self.on_text))

        # Start web server (health + frontend)
        await self._start_web_server()

    async def cmd_start(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        msg = (
            "🤖 Welcome to Telegram Copilot Bot!\n\n"
            "Commands:\n"
            "/start - Show welcome\n"
            "/help - Show help\n\n"
            "Web UI: visit http://localhost:8080/app after building the frontend.\n"
        )
        await update.message.reply_text(msg)

    async def cmd_help(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        msg = (
            "🔧 Help\n\n"
            "Send any text and I'll reply. If OPENAI_API_KEY is configured, I'll use AI responses.\n"
            "Health check: GET /health\n"
            "Web UI: /app (requires `npm run build` to generate dist/)\n"
        )
        await update.message.reply_text(msg)

    async def on_text(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        user_text = update.message.text or ""
        await context.bot.send_chat_action(chat_id=update.effective_chat.id, action="typing")

        if self.openai_client:
            try:
                resp = self.openai_client.chat.completions.create(
                    model="gpt-3.5-turbo",
                    messages=[
                        {"role": "system", "content": "You are a helpful assistant in a Telegram bot. Be concise."},
                        {"role": "user", "content": user_text},
                    ],
                    max_tokens=300,
                    temperature=0.7,
                )
                reply = (resp.choices[0].message.content or "").strip()
            except Exception as e:
                logger.error(f"OpenAI error: {e}")
                reply = "AI is temporarily unavailable. Please try again later."
        else:
            reply = f"I received: {user_text}\n\nAI is disabled (no OPENAI_API_KEY)."

        await update.message.reply_text(reply)

    async def _start_web_server(self):
        async def health(_request):
            return web.json_response(
                {
                    "status": "healthy",
                    "service": "telegram-copilot-bot",
                    "frontend": "use /app (requires dist/)",
                }
            )

        async def app_page(_request):
            dist_dir = Path(__file__).parent / "dist"
            index_html = dist_dir / "index.html"
            if not index_html.exists():
                html = """
<!doctype html>
<html>
<head><meta charset="utf-8"><title>Telegram Copilot Bot</title></head>
<body>
  <h1>Telegram Copilot Bot</h1>
  <p>Frontend not built yet. Run: <code>npm install && npm run build</code></p>
  <p>Health: <a href="/health">/health</a></p>
</body>
</html>
                """.strip()
                return web.Response(text=html, content_type="text/html")

            return web.FileResponse(index_html)

        app = web.Application()
        app.router.add_get("/health", health)
        app.router.add_get("/", health)
        app.router.add_get("/app", app_page)
        app.router.add_get("/app/", app_page)

        dist_dir = Path(__file__).parent / "dist"
        if dist_dir.exists():
            # Serve static assets (JS/CSS) from dist root
            app.router.add_static("/", dist_dir, name="static")

        runner = web.AppRunner(app)
        await runner.setup()
        site = web.TCPSite(runner, "0.0.0.0", 8080)
        await site.start()
        logger.info("Web server started on :8080 (health at /health, UI at /app)")

    async def run(self):
        logger.info("Starting Telegram bot polling...")
        await self.app.initialize()
        await self.app.start()
        # Note: depending on your python-telegram-bot version, updater may or may not be present.
        # This follows the existing project usage.
        await self.app.updater.start_polling()
        try:
            await asyncio.Event().wait()
        except KeyboardInterrupt:
            logger.info("Shutting down...")
        finally:
            await self.app.updater.stop()
            await self.app.stop()
            await self.app.shutdown()


async def main():
    bot = TelegramCopilotBot()
    await bot.initialize()
    await bot.run()


if __name__ == "__main__":
    asyncio.run(main())