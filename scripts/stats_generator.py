import os
from collections import Counter
from scripts.utils import logger, save_json, get_current_date

def generate_stats(leads, stats_filepath="data/stats.json", report_dir="reports/weekly"):
    if not leads:
        logger.warning("No leads found to compile statistics.")
        return {}
        
    total_leads = len(leads)
    
    # 1. COUNTER DICTS
    status_counts = Counter([l.get("status", "new") for l in leads])
    source_counts = Counter([l.get("source", "unknown") for l in leads])
    service_counts = Counter([l.get("service_type", "UNKNOWN") for l in leads])
    
    # Keywords count
    all_keywords = []
    for l in leads:
        all_keywords.extend(l.get("keywords_detected", []))
    keyword_counts = Counter(all_keywords)
    
    # Scores
    scores = [l.get("score", 0) for l in leads]
    avg_score = sum(scores) / len(scores) if scores else 0.0
    
    risks = [l.get("risk_score", 0) for l in leads]
    avg_risk = sum(risks) / len(risks) if risks else 0.0
    
    qualified_leads = sum(1 for l in leads if l.get("score", 0) >= 75)
    very_hot_leads = sum(1 for l in leads if l.get("score", 0) >= 90)
    
    # Statuses
    contacted = status_counts.get("contacted", 0) + status_counts.get("replied", 0) + status_counts.get("won", 0) + status_counts.get("lost", 0)
    won = status_counts.get("won", 0)
    lost = status_counts.get("lost", 0)
    ignored = status_counts.get("ignored", 0)
    
    conversion_rate = (won / contacted * 100) if contacted > 0 else 0.0
    
    # Best indicators
    best_sources = [item[0] for item in source_counts.most_common(3)]
    best_keywords = [item[0] for item in keyword_counts.most_common(5)]
    best_service_types = [item[0] for item in service_counts.most_common(3)]
    
    # 2. COMPILE REPORT TEXT
    best_src_str = best_sources[0] if best_sources else "N/A"
    best_kw_str = best_keywords[0] if best_keywords else "N/A"
    best_svc_str = best_service_types[0] if best_service_types else "N/A"
    
    rec_text = "Focalisez-vous sur "
    if best_svc_str != "N/A":
        rec_text += f"le service {best_svc_str.replace('_', ' ')} "
    if best_kw_str != "N/A":
        rec_text += f"avec le mot-clé '{best_kw_str}' "
    rec_text += "pour maximiser vos conversions cette semaine."
    
    report_summary = f"""Rapport généré le {get_current_date()}.
Opportunités totales : {total_leads}
Pistes qualifiées : {qualified_leads} (Score >= 75)
Très chaudes : {very_hot_leads} (Score >= 90)
Contactées : {contacted}
Projets Gagnés : {won}
Taux de conversion : {conversion_rate:.1f}%

Meilleure source : {best_src_str}
Meilleur service : {best_svc_str}
Recommandation : {rec_text}"""

    # 3. SAVE TO STATS JSON
    stats_data = {
        "total_leads": total_leads,
        "qualified_leads": qualified_leads,
        "very_hot_leads": very_hot_leads,
        "contacted": contacted,
        "won": won,
        "lost": lost,
        "ignored": ignored,
        "best_sources": best_sources,
        "best_keywords": best_keywords,
        "best_service_types": best_service_types,
        "conversion_rate": round(conversion_rate, 2),
        "average_score": round(avg_score, 2),
        "average_risk": round(avg_risk, 2),
        "weekly_report_summary": report_summary
    }
    
    save_json(stats_filepath, stats_data)
    
    # 4. SAVE WEEKLY MARKDOWN REPORT
    os.makedirs(report_dir, exist_ok=True)
    report_filename = f"weekly_report_{get_current_date()}.md"
    report_path = os.path.join(report_dir, report_filename)
    
    md_report = f"""# Rapport Client Radar OS - Semaine du {get_current_date()}

## Résumé Commercial
- **Total Opportunités trouvées :** {total_leads}
- **Pistes Qualifiées (Score >= 75) :** {qualified_leads}
- **Pistes Très Chaudes (Score >= 90) :** {very_hot_leads}
- **Clients Contactés :** {contacted}
- **Contrats Gagnés :** {won}
- **Taux de Conversion Actuel :** {conversion_rate:.2f}%

## Analyse des Sources
- **Sources Principales :** {", ".join([f"{k} ({v})" for k, v in source_counts.items()])}
- **Meilleure Source :** **{best_src_str}**

## Analyse de l'Intérêt Client
- **Services Demandés :** {", ".join([f"{k} ({v})" for k, v in service_counts.items()])}
- **Meilleur Service :** **{best_svc_str}**
- **Mots-clés Détectés :** {", ".join(best_keywords)}

## Recommandations Stratégiques
> {rec_text}

---
*Client Radar OS - Automatisation de Détection Commerciale*
"""
    try:
        with open(report_path, "w", encoding="utf-8") as f:
            f.write(md_report)
        logger.info(f"Generated weekly markdown report: {report_path}")
    except Exception as e:
        logger.error(f"Failed to generate weekly markdown report: {e}")
        
    return stats_data
