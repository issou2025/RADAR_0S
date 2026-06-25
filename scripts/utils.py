import os
import json
import logging
from datetime import datetime

def setup_logging():
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S"
    )
    return logging.getLogger("radar")

logger = setup_logging()

def load_json(filepath, default_value=None):
    if not os.path.exists(filepath):
        logger.warning(f"File not found: {filepath}. Returning default.")
        return default_value if default_value is not None else {}
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception as e:
        logger.error(f"Error loading {filepath}: {e}")
        return default_value if default_value is not None else {}

def save_json(filepath, data):
    try:
        os.makedirs(os.path.dirname(os.path.abspath(filepath)), exist_ok=True)
        with open(filepath, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        logger.info(f"Successfully saved to {filepath}")
        return True
    except Exception as e:
        logger.error(f"Error saving {filepath}: {e}")
        return False

def get_env_var(name, default=""):
    return os.environ.get(name, default)

def get_current_date():
    return datetime.now().strftime("%Y-%m-%d")

def get_current_timestamp():
    return datetime.now().isoformat()
