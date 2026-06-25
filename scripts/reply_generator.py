from scripts.utils import logger, load_json

def generate_replies(lead, templates_path, username="username", repo="client-radar-os-private"):
    templates = load_json(templates_path, {})
    
    # Standard values
    lang = lead.get("language", "en")
    if lang not in ["fr", "en"]:
        lang = "en"
        
    pages_base_url = f"https://{username}.github.io/{repo}"
    offer_page_path = lead.get("offer_page", "/offers/static-website.html")
    offer_url = f"{pages_base_url}{offer_page_path}"
    
    # 1. READ TEMPLATES
    en_templates = templates.get("en", {})
    fr_templates = templates.get("fr", {})
    
    # 2. FORMAT ENGLISH REPLIES
    reply_en_short = en_templates.get("short", "")
    reply_en_prof = en_templates.get("professional", "")
    reply_en_tech = en_templates.get("technical", "")
    reply_en_offer = en_templates.get("with_offer_page", "").replace("{offer_url}", offer_url)
    
    # 3. FORMAT FRENCH REPLIES
    reply_fr_short = fr_templates.get("short", "")
    reply_fr_prof = fr_templates.get("professional", "")
    reply_fr_tech = fr_templates.get("technical", "")
    reply_fr_offer = fr_templates.get("with_offer_page", "").replace("{offer_url}", offer_url)
    
    # 4. CHOOSE DEFAULTS BASED ON LEAD LANGUAGE
    if lang == "fr":
        lead["reply_short"] = reply_fr_short
        lead["reply_professional"] = reply_fr_prof
    else:
        lead["reply_short"] = reply_en_short
        lead["reply_professional"] = reply_en_prof
        
    # 5. ATTACH ALL VERSIONS FOR THE DETAIL SCREEN / STUDIO
    lead["replies"] = {
        "short_en": reply_en_short,
        "prof_en": reply_en_prof,
        "tech_en": reply_en_tech,
        "offer_en": reply_en_offer,
        "short_fr": reply_fr_short,
        "prof_fr": reply_fr_prof,
        "tech_fr": reply_fr_tech,
        "offer_fr": reply_fr_offer,
        "follow_up_3_days": fr_templates.get("follow_up_3_days", "") if lang == "fr" else en_templates.get("follow_up_3_days", ""),
        "follow_up_7_days": fr_templates.get("follow_up_7_days", "") if lang == "fr" else en_templates.get("follow_up_7_days", ""),
        "cautious_risk": fr_templates.get("cautious_risk", "") if lang == "fr" else en_templates.get("cautious_risk", "")
    }
    
    return lead
