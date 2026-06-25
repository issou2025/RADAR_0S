import feedparser
from bs4 import BeautifulSoup
from scripts.utils import logger, get_current_date

def clean_html(html_text):
    if not html_text:
        return ""
    try:
        soup = BeautifulSoup(html_text, "html.parser")
        return soup.get_text(separator=" ").strip()
    except Exception:
        return html_text

def search_rss(feed_urls, keywords_dict):
    leads = []
    
    # Flatten keywords for simple check
    all_kw = []
    for k, list_val in keywords_dict.items():
        if k in ["revit_bim_en", "revit_bim_fr", "other_services"]:
            all_kw.extend([w.lower() for w in list_val])
            
    for url in feed_urls:
        try:
            logger.info(f"Parsing RSS Feed: {url}")
            feed = feedparser.parse(url)
            
            # Check for parsing errors
            if feed.bozo:
                logger.warning(f"Possible malformed XML at {url}: {feed.bozo_exception}")
                
            for entry in feed.entries:
                title = entry.get("title", "")
                description = clean_html(entry.get("summary", "") or entry.get("description", ""))
                link = entry.get("link", "")
                published = entry.get("published", "") or entry.get("updated", "") or get_current_date()
                
                # Simple keyword filtering to avoid importing noise
                combined_text = (title + " " + description).lower()
                matches = [kw for kw in all_kw if kw in combined_text]
                
                if matches:
                    lead = {
                        "title": title,
                        "description": description[:1000], # Cap text length
                        "source": "RSS Feeds",
                        "source_type": "rss",
                        "url": link,
                        "published_date": published[:10] if len(published) >= 10 else get_current_date(),
                        "language": "fr" if any(k in combined_text for k in ["cherche", "besoin", "plan"]) else "en"
                    }
                    leads.append(lead)
        except Exception as e:
            logger.error(f"Failed parsing RSS {url}: {e}")
            
    return leads
