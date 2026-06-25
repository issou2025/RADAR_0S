from scripts.utils import logger

def clean_duplicates(leads):
    if not leads:
        return []
        
    logger.info(f"Deduplicating {len(leads)} leads...")
    
    unique_leads = {}
    
    # Sort leads by score descending, so the highest-scoring duplicates are kept first
    sorted_leads = sorted(leads, key=lambda x: x.get("score", 0), reverse=True)
    
    for lead in sorted_leads:
        url = lead.get("url", "").strip()
        title = lead.get("title", "").strip().lower()
        source = lead.get("source", "").strip()
        service_type = lead.get("service_type", "UNKNOWN")
        
        # We can construct a deduplication key
        # If url is provided and unique, we use url. Otherwise, we combine source, service_type, and a simplified title.
        simplified_title = "".join(char for char in title if char.isalnum())
        
        if url and url != "https://example.com" and not url.startswith("https://example.com/job/"):
            dup_key = url
        else:
            dup_key = f"{source}_{service_type}_{simplified_title[:40]}"
            
        if dup_key not in unique_leads:
            unique_leads[dup_key] = lead
        else:
            logger.info(f"Duplicate detected and filtered out: '{lead.get('title')}' (Score: {lead.get('score')}) in favor of existing lead with higher score (Score: {unique_leads[dup_key].get('score')})")
            
    # Convert back to list, preserving some order
    deduplicated = list(unique_leads.values())
    logger.info(f"Reduced leads count from {len(leads)} to {len(deduplicated)}.")
    return deduplicated
