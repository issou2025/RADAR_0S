import requests
from scripts.utils import logger, get_env_var, get_current_date

def search_google(keywords, intents, negatives):
    api_key = get_env_var("GOOGLE_API_KEY")
    cse_id = get_env_var("GOOGLE_CSE_ID")
    
    if not api_key or not cse_id:
        logger.warning("Google Custom Search API Key or CX ID is missing. Skipping Google Search.")
        return []
        
    leads = []
    
    # We combine keywords and some commercial intent words to make targeted queries
    # To avoid API rate limit depletion, we run queries on primary terms
    primary_queries = [
        "Revit freelancer",
        "BIM modeler needed",
        "PDF to Revit",
        "DWG to Revit",
        "plans de maison freelance",
        "dessinateur bâtiment freelance",
        "need Flutter developer",
        "looking for Python automation"
    ]
    
    for q in primary_queries:
        query = f'"{q}"'
        url = "https://www.googleapis.com/customsearch/v1"
        params = {
            "key": api_key,
            "cx": cse_id,
            "q": query,
            "dateRestrict": "d7", # Last 7 days
            "num": 10
        }
        
        try:
            logger.info(f"Querying Google CSE for: {query}")
            response = requests.get(url, params=params, timeout=15)
            if response.status_code == 200:
                data = response.json()
                items = data.get("items", [])
                for item in items:
                    lead = {
                        "title": item.get("title", ""),
                        "description": item.get("snippet", ""),
                        "source": "Google Search",
                        "source_type": "search_api",
                        "url": item.get("link", ""),
                        "published_date": get_current_date(), # Restrict d7 implies recent
                        "language": "en" if "revit" in q.lower() or "flutter" in q.lower() else "fr"
                    }
                    leads.append(lead)
            else:
                logger.error(f"Google CSE returned error code {response.status_code}: {response.text}")
        except Exception as e:
            logger.error(f"Failed to query Google CSE for {query}: {e}")
            
    return leads
