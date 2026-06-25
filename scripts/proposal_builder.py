import os
from scripts.utils import logger

def build_proposal(lead, output_dir="proposals"):
    os.makedirs(output_dir, exist_ok=True)
    
    lead_id = lead.get("id", "unknown_lead")
    title = lead.get("title", "Project Proposal")
    description = lead.get("description", "No description provided.")
    service_type = lead.get("service_type", "General Freelance Work")
    recommended_price = lead.get("recommended_price", "TBD")
    questions = lead.get("questions_to_ask", [])
    
    lang = lead.get("language", "en")
    
    filename = f"{lead_id}.md"
    filepath = os.path.join(output_dir, filename)
    
    # 1. COMPOSE CONTENT
    if lang == "fr":
        md_content = f"""# Proposition de Projet — {service_type.replace('_', ' ').title()}

## Compréhension du Projet
Vous recherchez un prestataire pour : 
**{title}**

*Description du besoin :*
{description}

## Étendue des Travaux
- Analyse des documents fournis et mise en place des gabarits.
- Modélisation/Développement selon les exigences formulées.
- Validation des livrables techniques.
- Intégration des commentaires et corrections.
- Remise du dossier final (fichiers sources inclus).

## Éléments requis pour démarrer
1. Fichiers de référence (dessins, codes d'accès, données d'exemple).
2. Spécifications fonctionnelles ou dimensions.
3. Descriptif des délais attendus.

## Budget et Délai Indicatifs
- **Tarif indicatif :** {recommended_price}
- **Délai de réalisation estimé :** 3 à 7 jours ouvrés (à valider après examen complet des pièces).

## Questions complémentaires
Afin d'ajuster notre proposition, pourriez-vous répondre à ces questions ?
"""
        for i, q in enumerate(questions, 1):
            md_content += f"{i}. {q}\n"
            
        md_content += """
## Notes de collaboration
Les livrables finaux ne seront transmis qu'à l'approbation de l'étape finale. Tout travail hors périmètre convenu fera l'objet d'un avenant tarifé.
"""
    else:
        md_content = f"""# Project Proposal — {service_type.replace('_', ' ').title()}

## Project Understanding
You need assistance with: 
**{title}**

*Project description:*
{description}

## Scope of Work
- Asset analysis and workspace initialization.
- Core modeling / development based on specifications.
- Technical validation and quality checks.
- Incorporation of review feedback.
- Clean handover of source files and documentation.

## Required Files & Inputs
1. Complete reference files (drawings, access tokens, test data).
2. Exact dimensional specs or business rules.
3. Schedule/deadline expectations.

## Estimated Price and Timeline
- **Estimated Price:** {recommended_price}
- **Estimated Timeline:** 3 to 7 business days (to be refined after reviewing the final assets).

## Project Questions
To help me refine this estimate, please clarify:
"""
        for i, q in enumerate(questions, 1):
            md_content += f"{i}. {q}\n"
            
        md_content += """
## Agreement Terms
The final source files will be delivered upon approval of the milestones. Substantial revisions outside the agreed scope will require a change order.
"""

    try:
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(md_content)
        logger.info(f"Generated proposal markdown: {filepath}")
        lead["proposal_path"] = f"/proposals/{filename}"
    except Exception as e:
        logger.error(f"Failed to generate proposal markdown for lead {lead_id}: {e}")
        lead["proposal_path"] = ""
        
    return lead
