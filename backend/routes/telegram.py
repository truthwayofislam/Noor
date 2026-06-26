from fastapi import APIRouter
from fastapi.responses import JSONResponse
import os

router = APIRouter()

@router.get("/telegram-config")
async def get_telegram_config():
    """
    Return Telegram bot credentials for issue reporting
    """
    bot_token = os.getenv('TELEGRAM_REPORT_BOT', '')
    chat_id = os.getenv('TELEGRAM_CHAT_ID', '')
    
    if not bot_token or not chat_id:
        return JSONResponse(
            status_code=503,
            content={"detail": "Telegram configuration not available"}
        )
    
    return {
        "bot_token": bot_token,
        "chat_id": chat_id
    }
