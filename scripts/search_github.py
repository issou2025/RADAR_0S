import requests
from datetime import datetime, timedelta
from scripts.utils import logger, get_env_var

def search_github(keywords):
    token = get_env_var("GITHUB_TOKEN") or get_env_var("FREELANCER_TOKEN") # Fallback to any token
    headers = {}
    if token:
        headers["Authorization"] = f"token {token}"
    headers["Accept"] = "application/vnd.github.v3+json"
    
    leads = []
    # Search for issues/PRs created in the last 14 days
    date_since = (datetime.now() - timedelta(days=14)).strftime("%Y-%m-%d")
    
    queries = [
        "Revit freelancer",
        "need Revit",
        "Flutter developer needed",
        "looking for Python automation"
    ]
    
    for q in queries:
        query = f"{q} state:open created:>={date_since}"
        url = "https://api.github.com/search/issues"
        params = {
            "q": query,
            "sort": "created",
            "order": "desc",
            "per_page": 15
        }
        
        try:
            logger.info(f"Querying GitHub API for issues: {query}")
            response = requests.get(url, headers=headers, params=params, timeout=15)
            if response.status_code == 200:
                data = response.json()
                items = data.get("items", [])
                for item in items:
                    # Ignore pull requests, focus on issues
                    if "pull_request" in item:
                        continue
                    
                    lead = {
                        "title": item.get("title", ""),
                        "description": item.get("body", "") or "",
                        "source": "GitHub Search",
                        "source_type": "search_api",
                        "url": item.get("html_url", ""),
                        "published_date": item.get("created_at", "")[:10],
                        "language": "en" # GitHub issues are predominantly English
                    }
                    leads.append(lead)
            else:
                logger.error(f"GitHub Search API returned error code {response.status_code}: {response.text}")
        except Exception as e:
            logger.error(f"Failed to query GitHub Search API for {query}: {e}")
            
    return leads
