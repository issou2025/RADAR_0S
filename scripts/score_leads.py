from scripts.utils import logger

def score_lead(lead):
    title = lead.get("title", "").lower()
    description = lead.get("description", "").lower()
    combined = title + " " + description
    
    score = 0
    reasons = []
    
    # 1. POSITIVE SIGNS
    if "revit" in combined:
        score += 25
        reasons.append("Contains Revit (+25)")
    if "bim" in combined:
        score += 20
        reasons.append("Contains BIM (+20)")
    if "pdf to revit" in combined or "pdf vers revit" in combined or "convert pdf" in combined:
        score += 30
        reasons.append("Contains PDF to Revit (+30)")
    if "dwg to revit" in combined or "dwg vers revit" in combined or "convert dwg" in combined:
        score += 30
        reasons.append("Contains DWG to Revit (+30)")
    if "scan to bim" in combined or "point cloud" in combined or "nuage de points" in combined:
        score += 25
        reasons.append("Contains scan to BIM (+25)")
    if "house plan" in combined or "plan de maison" in combined or "plan maison" in combined:
        score += 20
        reasons.append("Contains house plan (+20)")
    if "construction drawing" in combined or "plans de construction" in combined or "plan d'exécution" in combined:
        score += 20
        reasons.append("Contains construction drawings (+20)")
    if "structural" in combined or "structure" in combined or "béton armé" in combined or "coffrage" in combined:
        score += 20
        reasons.append("Contains structural drawings (+20)")
    if "permit drawings" in combined or "permis de construire" in combined:
        score += 20
        reasons.append("Contains permit drawings (+20)")
        
    # Hire intents
    intents = ["freelancer", "hire", "need", "looking for", "cherche", "besoin", "recruter"]
    if any(intent in combined for intent in intents):
        score += 20
        reasons.append("Contains buying intent keywords (+20)")
        
    if any(kw in combined for kw in ["budget", "paid", "remunéré", "payé"]):
        score += 15
        reasons.append("Budget detected (+15)")
        
    if any(kw in combined for kw in ["urgent", "asap", "rapidement"]):
        score += 15
        reasons.append("Urgent request (+15)")
        
    # Recency (we assume searched leads are recent)
    score += 15
    reasons.append("Recent request (+15)")
    
    # Deliverable clear
    if any(kw in combined for kw in ["rvt", "dwg", "pdf", "file", "model", "plan"]):
        score += 10
        reasons.append("Deliverable specified (+10)")
        
    if lead.get("source_type") == "search_api":
        score += 10
        reasons.append("Reliable API source (+10)")
        
    # Language check
    lang = lead.get("language", "en")
    if lang in ["fr", "en"]:
        score += 10
        reasons.append("Language English/French (+10)")
        
    if any(kw in combined for kw in ["deadline", "quote", "proposal", "devis", "tarif"]):
        score += 5
        reasons.append("Contains deadline/quote keyword (+5)")

    # 2. NEGATIVE PENALTIES
    if "tutorial" in combined or "tuto" in combined:
        score -= 40
        reasons.append("Identified as tutorial (-40)")
    if "course" in combined or "formation" in combined or "cours" in combined:
        score -= 50
        reasons.append("Identified as training/course (-50)")
    if "free download" in combined or "téléchargement gratuit" in combined:
        score -= 60
        reasons.append("Identified as free software download (-60)")
    if any(kw in combined for kw in ["crack", "pirat", "torrent", "serial"]):
        score -= 100
        reasons.append("Identified as crack/piracy (-100)")
    if "homework" in combined or "devoir" in combined or "student assignment" in combined:
        score -= 50
        reasons.append("Identified as student homework (-50)")
    if "free work" in combined or "unpaid" in combined or "travail gratuit" in combined or "sans budget" in combined:
        score -= 60
        reasons.append("Asks for free work (-60)")
    if len(combined.strip()) < 50:
        score -= 30
        reasons.append("Description too vague/short (-30)")

    # Cap score between 0 and 100
    score = max(0, min(100, score))
    
    # Temperature
    if score >= 90:
        temp = "very_hot"
    elif score >= 75:
        temp = "hot"
    elif score >= 50:
        temp = "warm"
    elif score >= 25:
        temp = "cold"
    else:
        temp = "bad"
        
    # 3. RISK SCORE CALCULATION
    risk = 0
    if "free work" in combined or "travail gratuit" in combined:
        risk += 30
    if "unpaid test" in combined or "test gratuit" in combined:
        risk += 25
    if "urgent cheap" in combined or "urgent pas cher" in combined:
        risk += 25
    if "no budget" in combined or "sans budget" in combined:
        risk += 20
    if "student assignment" in combined or "devoir" in combined:
        risk += 20
    if "need today" in combined or "pour aujourd'hui" in combined:
        risk += 15
    if "send sample first" in combined or "envoyer échantillon" in combined:
        risk += 15
    if len(description) < 60:
        risk += 20
    if "cheap" in combined or "pas cher" in combined or "low budget" in combined:
        risk += 20
    if "urgent" in combined and ("no budget" in combined or "cheap" in combined):
        risk += 10
        
    risk = min(100, risk)
    
    # Enrich lead dictionary
    lead["score"] = score
    lead["score_reasons"] = reasons
    lead["client_temperature"] = temp
    lead["risk_score"] = risk
    lead["recommended_action"] = "reply_now" if score >= 75 and risk < 50 else ("reply_cautious" if risk >= 50 else "monitor")
    
    return lead
