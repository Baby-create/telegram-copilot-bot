#!/usr/bin/env python3
"""
Configuration Detector - Automatically find and populate bot configuration
Searches for Telegram tokens, OpenAI keys, and other required configurations
"""

import os
import re
import json
import logging
from typing import Dict, List, Optional, Tuple
from pathlib import Path

logger = logging.getLogger(__name__)

class ConfigDetector:
    """Detects and populates configuration automatically"""
    
    def __init__(self):
        self.config = {}
        self.search_patterns = {
            'TELEGRAM_BOT_TOKEN': [
                r'(?i)(?:telegram[_\s]*(?:bot[_\s]*)?token[_\s]*[=:]\s*["\']?)([0-9]+:[A-Za-z0-9_-]+)',
                r'(?i)(?:bot[_\s]*token[_\s]*[=:]\s*["\']?)([0-9]+:[A-Za-z0-9_-]+)',
                r'([0-9]{8,10}:[A-Za-z0-9_-]{35})',  # Standard Telegram bot token format
            ],
            'OPENAI_API_KEY': [
                r'(?i)(?:openai[_\s]*(?:api[_\s]*)?key[_\s]*[=:]\s*["\']?)(sk-[A-Za-z0-9]{48})',
                r'(?i)(?:api[_\s]*key[_\s]*[=:]\s*["\']?)(sk-[A-Za-z0-9]{48})',
                r'(sk-[A-Za-z0-9]{48})',  # Standard OpenAI API key format
            ],
            'OPENAI_ORG_ID': [
                r'(?i)(?:openai[_\s]*(?:org[_\s]*)?(?:id|organization)[_\s]*[=:]\s*["\']?)(org-[A-Za-z0-9]{24})',
                r'(org-[A-Za-z0-9]{24})',  # Standard OpenAI org ID format
            ]
        }
        
    async def detect_and_populate_config(self):
        """Main function to detect and populate all configuration"""
        logger.info("Starting configuration detection...")
        
        # Search in various locations
        await self._search_environment_variables()
        await self._search_project_files()
        await self._search_user_files()
        await self._search_git_history()
        
        # Generate .env file
        await self._generate_env_file()
        
        logger.info("Configuration detection completed!")
        
    async def _search_environment_variables(self):
        """Search existing environment variables"""
        logger.info("Searching environment variables...")
        
        for key in self.search_patterns.keys():
            value = os.getenv(key)
            if value and self._validate_key(key, value):
                self.config[key] = value
                logger.info(f"Found {key} in environment variables")
                
    async def _search_project_files(self):
        """Search project files for configuration"""
        logger.info("Searching project files...")
        
        search_files = [
            '.env', '.env.example', '.env.local', '.env.production',
            'config.json', 'config.yaml', 'config.yml',
            'settings.py', 'config.py', 'constants.py',
            'README.md', 'README.txt', 'INSTALL.md',
            'docker-compose.yml', 'docker-compose.yaml'
        ]
        
        project_root = Path.cwd()
        
        for filename in search_files:
            file_path = project_root / filename
            if file_path.exists():
                await self._search_file_content(file_path)
                
    async def _search_user_files(self):
        """Search user's common configuration locations"""
        logger.info("Searching user configuration files...")
        
        user_home = Path.home()
        search_locations = [
            user_home / '.env',
            user_home / '.bashrc',
            user_home / '.zshrc',
            user_home / '.profile',
            user_home / '.config' / 'telegram-bot',
            user_home / '.config' / 'openai',
            user_home / 'Documents' / 'telegram-bot-config.txt',
            user_home / 'Desktop' / 'bot-config.txt',
        ]
        
        for location in search_locations:
            if location.exists():
                await self._search_file_content(location)
                
    async def _search_git_history(self):
        """Search git history for configuration hints"""
        logger.info("Searching git history...")
        
        try:
            import subprocess
            
            # Search git log for potential configuration mentions
            result = subprocess.run(
                ['git', 'log', '--all', '--grep=token', '--grep=key', '--grep=config', '-p'],
                capture_output=True, text=True, timeout=10
            )
            
            if result.returncode == 0:
                await self._search_text_content(result.stdout, "git history")
                
        except Exception as e:
            logger.debug(f"Could not search git history: {e}")
            
    async def _search_file_content(self, file_path: Path):
        """Search content of a specific file"""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                await self._search_text_content(content, str(file_path))
                
        except Exception as e:
            logger.debug(f"Could not read file {file_path}: {e}")
            
    async def _search_text_content(self, content: str, source: str):
        """Search text content for configuration patterns"""
        for key, patterns in self.search_patterns.items():
            if key in self.config:
                continue  # Already found
                
            for pattern in patterns:
                matches = re.findall(pattern, content)
                for match in matches:
                    if self._validate_key(key, match):
                        self.config[key] = match
                        logger.info(f"Found {key} in {source}")
                        break
                        
                if key in self.config:
                    break
                    
    def _validate_key(self, key_type: str, value: str) -> bool:
        """Validate that a found key matches expected format"""
        if not value or len(value) < 10:
            return False
            
        # Check for common placeholder/example values
        placeholder_patterns = [
            'your_', 'example_', 'sample_', 'test_', 'demo_',
            'placeholder', 'replace_with', 'add_your',
            '123456', 'abcdef', 'xyz'
        ]
        
        value_lower = value.lower()
        for pattern in placeholder_patterns:
            if pattern in value_lower:
                return False
            
        if key_type == 'TELEGRAM_BOT_TOKEN':
            # Don't accept obvious example tokens
            if value == '1234567890:ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890':
                return False
            return re.match(r'^[0-9]+:[A-Za-z0-9_-]+$', value) is not None
            
        elif key_type == 'OPENAI_API_KEY':
            # Don't accept example keys
            if 'your-openai-api-key-here' in value or value == 'sk-your-openai-api-key-here':
                return False
            return re.match(r'^sk-[A-Za-z0-9]{48}$', value) is not None
            
        elif key_type == 'OPENAI_ORG_ID':
            # Don't accept example org IDs
            if 'your-organization-id-here' in value or value == 'org-your-organization-id-here':
                return False
            return re.match(r'^org-[A-Za-z0-9]{24}$', value) is not None
            
        return True
        
    async def _generate_env_file(self):
        """Generate .env file with found configuration"""
        env_path = Path('.env')
        
        env_content = [
            "# Telegram Copilot Bot Configuration",
            "# Auto-generated by configuration detector",
            "# " + "="*50,
            ""
        ]
        
        # Add found configurations
        for key, value in self.config.items():
            env_content.append(f"{key}={value}")
            
        # Add missing configurations with placeholders and instructions
        missing_configs = []
        for key in self.search_patterns.keys():
            if key not in self.config:
                missing_configs.append(key)
                
        if missing_configs:
            env_content.extend([
                "",
                "# Missing configurations - Please add manually:",
                "# " + "-"*50
            ])
            
            for key in missing_configs:
                if key == 'TELEGRAM_BOT_TOKEN':
                    env_content.extend([
                        f"# {key}=your_telegram_bot_token_here",
                        "# Get your token from: https://t.me/BotFather",
                        "# Format: 1234567890:ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                    ])
                elif key == 'OPENAI_API_KEY':
                    env_content.extend([
                        f"# {key}=your_openai_api_key_here", 
                        "# Get your key from: https://platform.openai.com/api-keys",
                        "# Format: sk-..."
                    ])
                elif key == 'OPENAI_ORG_ID':
                    env_content.extend([
                        f"# {key}=your_openai_org_id_here",
                        "# Optional - only needed for organization accounts",
                        "# Format: org-..."
                    ])
                    
                env_content.append("")
                
        # Write .env file
        with open(env_path, 'w', encoding='utf-8') as f:
            f.write('\n'.join(env_content))
            
        logger.info(f"Generated .env file with {len(self.config)} configurations")
        
        if missing_configs:
            logger.warning(f"Missing configurations: {', '.join(missing_configs)}")
            logger.warning("Please check .env file and add missing configurations manually")
        else:
            logger.info("All required configurations found automatically!")
            
    def get_config_status(self) -> Dict[str, bool]:
        """Get status of all required configurations"""
        return {key: key in self.config for key in self.search_patterns.keys()}