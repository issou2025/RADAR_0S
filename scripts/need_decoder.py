import re
from scripts.utils import logger

# Service Type Enums
PDF_TO_REVIT = "PDF_TO_REVIT"
DWG_TO_REVIT = "DWG_TO_REVIT"
HOUSE_PLAN_DESIGN = "HOUSE_PLAN_DESIGN"
BIM_MODELING = "BIM_MODELING"
STRUCTURAL_DRAWINGS = "STRUCTURAL_DRAWINGS"
SCAN_TO_BIM = "SCAN_TO_BIM"
PERMIT_DRAWINGS = "PERMIT_DRAWINGS"
AUTOCAD_DRAFTING = "AUTOCAD_DRAFTING"
QUANTITY_TAKEOFF = "QUANTITY_TAKEOFF"
BOQ_ESTIMATE = "BOQ_ESTIMATE"
FLUTTER_APP = "FLUTTER_APP"
PYTHON_AUTOMATION = "PYTHON_AUTOMATION"
EXCEL_AUTOMATION = "EXCEL_AUTOMATION"
STATIC_WEBSITE = "STATIC_WEBSITE"
UNKNOWN = "UNKNOWN"

def decode_need(lead):
    title = lead.get("title", "").lower()
    description = lead.get("description", "").lower()
    combined = title + " " + description
    
    # 1. DETECT SERVICE TYPE
    service_type = UNKNOWN
    offer_page = "/offers/static-website.html"
    
    if "pdf" in combined and "revit" in combined:
        service_type = PDF_TO_REVIT
        offer_page = "/offers/pdf-to-revit.html"
    elif "dwg" in combined and "revit" in combined:
        service_type = DWG_TO_REVIT
        offer_page = "/offers/dwg-to-revit.html"
    elif "scan to bim" in combined or "point cloud" in combined or "nuage de point" in combined:
        service_type = SCAN_TO_BIM
        offer_page = "/offers/scan-to-bim.html"
    elif "structural" in combined or "structure" in combined or "béton armé" in combined or "ferraillage" in combined:
        service_type = STRUCTURAL_DRAWINGS
        offer_page = "/offers/structural-drawings.html"
    elif "permit" in combined or "permis de construire" in combined or "permis de construire" in combined:
        service_type = PERMIT_DRAWINGS
        offer_page = "/offers/permit-drawings.html"
    elif "house plan" in combined or "floor plan" in combined or "plan de maison" in combined or "plan maison" in combined or "plan architectural" in combined:
        service_type = HOUSE_PLAN_DESIGN
        offer_page = "/offers/house-plan-design.html"
    elif "revit" in combined or "bim" in combined:
        service_type = BIM_MODELING
        offer_page = "/offers/bim-modeling.html"
    elif "autocad" in combined or "dwg" in combined or "drafting" in combined or "dessinateur" in combined:
        service_type = AUTOCAD_DRAFTING
        offer_page = "/offers/autocad-drafting.html"
    elif "takeoff" in combined or "métré" in combined or "estimat" in combined or "devis" in combined:
        service_type = QUANTITY_TAKEOFF
        offer_page = "/offers/quantity-takeoff.html"
    elif "flutter" in combined or "dart" in combined:
        service_type = FLUTTER_APP
        offer_page = "/offers/static-website.html"
    elif "python" in combined and "automation" in combined:
        service_type = PYTHON_AUTOMATION
        offer_page = "/offers/static-website.html"
    elif "excel" in combined and "automation" in combined:
        service_type = EXCEL_AUTOMATION
        offer_page = "/offers/static-website.html"
    elif "website" in combined or "site web" in combined or "html" in combined:
        service_type = STATIC_WEBSITE
        offer_page = "/offers/static-website.html"

    # 2. EXTRACT BUDGET
    budget_detected = "not specified"
    budget_match = re.search(r'(?:budget|price|tarif|coût)\s*(?:of|is|around|de|est|:)?\s*([\$€£]?\s*\d+(?:\s*-\s*\d+)?\s*[\$€£]?\s*(?:usd|eur|gbp)?)', combined)
    if budget_match:
        budget_detected = budget_match.group(1).strip()
    elif "cheap" in combined or "low budget" in combined or "pas cher" in combined:
        budget_detected = "cheap / low budget"
    elif "hourly" in combined or "taux horaire" in combined:
        budget_detected = "hourly rate"
        
    # 3. ASSIGN SUGGESTED PRICE & QUESTIONS TO ASK
    recommended_price = "Contact for quote"
    questions = []
    
    if service_type == PDF_TO_REVIT:
        recommended_price = "350 - 900 USD"
        questions = [
            "How many levels/floors does the building have?",
            "Are the PDF plans fully dimensioned, or do we have a graphic scale?",
            "Do you require elevations and sections, or floor plans only?",
            "Do you require a specific Revit version (e.g. Revit 2023, 2024)?",
            "What is your target deadline for the initial draft?"
        ]
    elif service_type == DWG_TO_REVIT:
        recommended_price = "250 - 700 USD"
        questions = [
            "Are the DWG drawings clean and purged of extra blocks?",
            "Do you have elevations/sections in DWG, or only floor plans?",
            "Do you require modeling of interior partition walls or structural shell only?",
            "Which Revit version should be used for deliverables?",
            "Is there a specific template or shared coordinates file to follow?"
        ]
    elif service_type == SCAN_TO_BIM:
        recommended_price = "1200 - 3000 USD"
        questions = [
            "What format is the point cloud file (e.g. RCP, RCS, E57)?",
            "What is the total area of the scanned space (in sq ft or m²)?",
            "What level of detail (LOD) is expected (e.g. LOD 200, LOD 300)?",
            "Do you need MEP systems (pipes, ducts) modeled, or architectural/structural only?",
            "How will the point cloud file be shared (e.g. Google Drive, Autodesk Docs)?"
        ]
    elif service_type == STRUCTURAL_DRAWINGS:
        recommended_price = "800 - 2000 EUR"
        questions = [
            "Avez-vous déjà réalisé l'étude de sol géotechnique pour les fondations ?",
            "Quelles sont les charges d'exploitation particulières (machines, toiture végétalisée) ?",
            "Fournissez-vous les plans d'architecte définitifs au format DWG ?",
            "Quels sont les détails d'exécution attendus (nomenclatures d'acier, détails de ferraillage) ?",
            "Quel est votre calendrier souhaité pour la validation des plans ?"
        ]
    elif service_type == HOUSE_PLAN_DESIGN:
        recommended_price = "500 - 1500 USD"
        questions = [
            "What is the total size of the site and the expected footprint of the house?",
            "How many bedrooms and bathrooms do you need?",
            "Do you have local zoning rules or building height restrictions?",
            "Do you have sketch files or reference images showing the architectural style you like?",
            "Is this plan for permitting, or builder pricing only?"
        ]
    elif service_type == FLUTTER_APP:
        recommended_price = "1500 - 4000 USD"
        questions = [
            "Do you have UI designs ready (Figma, Adobe XD) or should we design the screens?",
            "Which backend service will the app connect to (REST API, Firebase)?",
            "Do you require integration with app stores (App Store, Play Store)?",
            "What state management solution do you prefer (Bloc, Riverpod, Provider)?",
            "What is your target launch date?"
        ]
    elif service_type in [PYTHON_AUTOMATION, EXCEL_AUTOMATION]:
        recommended_price = "200 - 600 USD"
        questions = [
            "What is the input data format (Excel sheets, CSV, website, database)?",
            "What are the step-by-step logic rules for processing the data?",
            "Where should the output be saved (merged sheet, email, database)?",
            "Does this script need to run on a schedule (cron, Windows Scheduler) or manually?",
            "Can you share sample data files for testing?"
        ]
    elif service_type == STATIC_WEBSITE:
        recommended_price = "400 - 1000 USD"
        questions = [
            "Do you have copywriting and images ready, or should they be generated?",
            "Do you need any contact forms, interactive maps, or animations?",
            "What static hosting service do you prefer (GitHub Pages, Netlify, Vercel)?",
            "Do you have a custom domain name registered?",
            "What is the target schedule for publishing?"
        ]
    else:
        recommended_price = "300 - 800 USD"
        questions = [
            "Could you describe the project scope and deliverables in detail?",
            "Do you have any existing drawings or reference documents?",
            "What is your target budget range?",
            "What is your expected timeline?",
            "Which tools/software do you prefer for this project?"
        ]
        
    lead["service_type"] = service_type
    lead["offer_page"] = offer_page
    lead["budget_detected"] = budget_detected
    lead["recommended_price"] = recommended_price
    lead["questions_to_ask"] = questions
    
    return lead
