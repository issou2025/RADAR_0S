import os
import sys
from datetime import datetime

# Add the project root to path to ensure relative imports work in GitHub Actions
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from scripts.utils import logger, load_json, save_json, get_current_date, get_current_timestamp
from scripts.search_google import search_google
from scripts.search_github import search_github
from scripts.search_rss import search_rss
from scripts.search_reddit import search_reddit
from scripts.search_freelancer import search_freelancer
from scripts.score_leads import score_lead
from scripts.need_decoder import decode_need
from scripts.reply_generator import generate_replies
from scripts.proposal_builder import build_proposal
from scripts.duplicate_cleaner import clean_duplicates
from scripts.offer_page_generator import generate_all_offer_pages
from scripts.stats_generator import generate_stats

def main():
    logger.info("Starting Client Radar OS scanning run...")
    
    # 1. LOAD CONFIGURATIONS & DATA
    keywords_path = "data/keywords.json"
    sources_path = "data/sources.json"
    leads_path = "data/leads.json"
    actions_path = "data/user_actions.json"
    templates_path = "data/reply_templates.json"
    
    keywords = load_json(keywords_path, {})
    sources_config = load_json(sources_path, {}).get("sources", [])
    existing_leads = load_json(leads_path, [])
    user_actions = load_json(actions_path, [])
    
    # Load username/repo from settings for GitHub Pages links
    settings_example = load_json("data/settings.example.json", {})
    username = os.environ.get("GITHUB_ACTOR", settings_example.get("github_username", "username"))
    repo = settings_example.get("repository_name", "client-radar-os-private")
    
    # Map existing leads by ID and URL for fast lookup
    leads_by_id = {l["id"]: l for l in existing_leads}
    leads_by_url = {l["url"]: l for l in existing_leads if l.get("url")}
    
    # 2. RECONCILE USER ACTIONS
    if user_actions:
        logger.info(f"Reconciling {len(user_actions)} user actions...")
        for action_item in user_actions:
            lead_id = action_item.get("lead_id")
            action = action_item.get("action")
            value = action_item.get("value")
            
            if lead_id in leads_by_id:
                target_lead = leads_by_id[lead_id]
                if action == "change_status":
                    target_lead["status"] = value
                    target_lead["updated_at"] = get_current_timestamp()
                    logger.info(f"Updated lead {lead_id} status to '{value}'")
                elif action == "update_notes":
                    target_lead["notes"] = value
                    target_lead["updated_at"] = get_current_timestamp()
                    logger.info(f"Updated lead {lead_id} notes")
                elif action == "toggle_favorite":
                    # If user favorited, we can change status or store a flag. 
                    # Let's support both.
                    target_lead["status"] = "favorite" if value else "new"
                    target_lead["updated_at"] = get_current_timestamp()
                    logger.info(f"Toggled favorite for lead {lead_id}")
            else:
                logger.warning(f"User action target lead not found in database: {lead_id}")
                
    # 3. TRIGGER MODULE-SPECIFIC SEARCHES
    new_candidates = []
    
    for src in sources_config:
        if not src.get("enabled", False):
            continue
            
        src_id = src["id"]
        logger.info(f"Activating source scanner: {src['name']}")
        
        if src_id == "google_search":
            results = search_google(keywords, [], []) # Uses internal keywords
            new_candidates.extend(results)
        elif src_id == "github_search":
            results = search_github(keywords)
            new_candidates.extend(results)
        elif src_id == "rss":
            rss_urls = src.get("urls", [])
            results = search_rss(rss_urls, keywords)
            new_candidates.extend(results)
        elif src_id == "reddit":
            results = search_reddit(keywords)
            new_candidates.extend(results)
        elif src_id == "freelancer":
            results = search_freelancer()
            new_candidates.extend(results)

    # 4. QUALIFY, SCORE, DECODE AND BUILD PROPOSALS
    logger.info(f"Found {len(new_candidates)} raw candidate leads. Processing...")
    
    timestamp_suffix = datetime.now().strftime("%Y%m%d_%H%M%S")
    processed_count = 0
    
    for index, cand in enumerate(new_candidates):
        url = cand.get("url")
        
        # Check if we already have this lead
        if url in leads_by_url:
            continue
            
        # Score the lead
        scored_cand = score_lead(cand)
        
        # Filter out bad leads to keep repository size healthy
        if scored_cand["score"] < 40:
            continue
            
        # Assign UUID
        lead_id = f"lead_{timestamp_suffix}_{index:03d}"
        scored_cand["id"] = lead_id
        scored_cand["status"] = "new"
        scored_cand["notes"] = ""
        scored_cand["created_at"] = get_current_timestamp()
        scored_cand["updated_at"] = get_current_timestamp()
        
        # Detect keywords in text for summary
        desc_lower = scored_cand.get("description", "").lower()
        title_lower = scored_cand.get("title", "").lower()
        comb = title_lower + " " + desc_lower
        
        detected_kw = []
        # Check revit categories
        for list_kw in keywords.values():
            for w in list_kw:
                if w.lower() in comb:
                    detected_kw.append(w)
        scored_cand["keywords_detected"] = list(set(detected_kw))[:6]
        
        # Decode specific need
        decoded_cand = decode_need(scored_cand)
        
        # Generate personalized responses
        replied_cand = generate_replies(decoded_cand, templates_path, username, repo)
        
        # Build markdown proposal
        final_cand = build_proposal(replied_cand)
        
        # Add to local maps
        leads_by_url[url] = final_cand
        leads_by_id[lead_id] = final_cand
        processed_count += 1

    # 5. DEDUPLICATE & MERGE
    all_leads = list(leads_by_id.values())
    cleaned_leads = clean_duplicates(all_leads)
    
    # 6. RUN HTML LANDING PAGE COMPILER
    logger.info("Compiling static offer pages...")
    generate_all_offer_pages()
    
    # 7. GENERATE ANALYTICS & WEEKLY REPORT
    logger.info("Compiling project statistics...")
    generate_stats(cleaned_leads)
    
    # 8. SAVE CHANGES BACK TO DATABASE
    save_json(leads_path, cleaned_leads)
    save_json(actions_path, []) # Clear user actions queue
    
    logger.info(f"Client Radar OS run finished. Processed {processed_count} new qualified leads. Database size: {len(cleaned_leads)}")

if __name__ == "__main__":
    main()
