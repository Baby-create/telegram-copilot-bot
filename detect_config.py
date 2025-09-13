#!/usr/bin/env python3
"""
Standalone Configuration Detector Script
Run this script to automatically detect and generate bot configuration
"""

import asyncio
import sys
from config_detector import ConfigDetector

async def main():
    """Main function for standalone config detection"""
    print("🔍 Telegram Copilot Bot - Configuration Detector")
    print("=" * 50)
    
    detector = ConfigDetector()
    
    try:
        await detector.detect_and_populate_config()
        
        # Show results
        config_status = detector.get_config_status()
        
        print("\n📋 Configuration Status:")
        print("-" * 30)
        
        for key, found in config_status.items():
            status = "✓ Found" if found else "✗ Missing"
            print(f"{key}: {status}")
            
        found_count = sum(config_status.values())
        total_count = len(config_status)
        
        print(f"\n📊 Summary: {found_count}/{total_count} configurations found")
        
        if found_count == total_count:
            print("🎉 All configurations found automatically!")
            print("✅ Bot is ready to deploy!")
        else:
            print("⚠️  Some configurations are missing.")
            print("📝 Please check the .env file and add missing configurations.")
            
        print("\n💡 Next steps:")
        print("1. Check the generated .env file")
        print("2. Add any missing configurations")
        print("3. Run deploy_bot.bat to start the bot")
        
        return 0  # Always return 0, let the deployment script handle missing configs
        
    except Exception as e:
        print(f"\n❌ Error during configuration detection: {e}")
        return 1

if __name__ == "__main__":
    exit_code = asyncio.run(main())
    sys.exit(exit_code)