import os
from scripts.utils import logger

# Template structure for a premium glassmorphic sales page
HTML_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title} | Client Radar OS Portfolio</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;800&family=Plus+Jakarta+Sans:wght@400;500;700&display=swap" rel="stylesheet">
    <style>
        :root {{
            --bg-color: #060913;
            --surface-color: rgba(22, 28, 45, 0.4);
            --border-color: rgba(255, 255, 255, 0.07);
            --primary-accent: linear-gradient(135deg, #4F46E5 0%, #7C3AED 50%, #EC4899 100%);
            --glow-color: rgba(124, 58, 237, 0.15);
            --text-primary: #F8FAFC;
            --text-secondary: #94A3B8;
            --success-color: #10B981;
        }}

        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}

        body {{
            background-color: var(--bg-color);
            color: var(--text-primary);
            font-family: 'Plus Jakarta Sans', sans-serif;
            line-height: 1.6;
            overflow-x: hidden;
        }}

        /* Subtle glowing background decorations */
        body::before {{
            content: '';
            position: absolute;
            top: -20%;
            left: -10%;
            width: 600px;
            height: 600px;
            background: radial-gradient(circle, rgba(79, 70, 229, 0.12) 0%, rgba(0,0,0,0) 70%);
            z-index: -1;
            filter: blur(80px);
        }}

        body::after {{
            content: '';
            position: absolute;
            bottom: -10%;
            right: -10%;
            width: 500px;
            height: 500px;
            background: radial-gradient(circle, rgba(236, 72, 153, 0.08) 0%, rgba(0,0,0,0) 70%);
            z-index: -1;
            filter: blur(80px);
        }}

        .container {{
            max-width: 1100px;
            margin: 0 auto;
            padding: 40px 20px;
        }}

        header {{
            text-align: center;
            padding: 60px 0 40px 0;
        }}

        .badge {{
            display: inline-block;
            padding: 6px 16px;
            font-size: 0.85rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
            border-radius: 50px;
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.1);
            color: #A78BFA;
            margin-bottom: 20px;
        }}

        h1 {{
            font-family: 'Outfit', sans-serif;
            font-size: 3rem;
            font-weight: 800;
            letter-spacing: -1px;
            background: var(--primary-accent);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 20px;
        }}

        .lead-text {{
            font-size: 1.2rem;
            color: var(--text-secondary);
            max-width: 700px;
            margin: 0 auto;
            font-weight: 300;
        }}

        .grid-layout {{
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 30px;
            margin-top: 50px;
        }}

        @media (max-width: 768px) {{
            .grid-layout {{
                grid-template-columns: 1fr;
            }}
            h1 {{
                font-size: 2.2rem;
            }}
        }}

        .glass-card {{
            background: var(--surface-color);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            padding: 35px;
            box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.3);
            margin-bottom: 30px;
            transition: transform 0.3s ease, border-color 0.3s ease;
        }}

        .glass-card:hover {{
            border-color: rgba(124, 58, 237, 0.3);
        }}

        h2 {{
            font-family: 'Outfit', sans-serif;
            font-size: 1.6rem;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }}

        h2::before {{
            content: '';
            display: inline-block;
            width: 4px;
            height: 24px;
            background: var(--primary-accent);
            border-radius: 2px;
        }}

        ul {{
            list-style: none;
        }}

        .check-list li {{
            margin-bottom: 12px;
            display: flex;
            align-items: flex-start;
            gap: 12px;
        }}

        .check-list li::before {{
            content: '✓';
            color: var(--success-color);
            font-weight: bold;
            font-size: 1.1rem;
        }}

        .step-list li {{
            position: relative;
            padding-left: 35px;
            margin-bottom: 20px;
        }}

        .step-list li::before {{
            content: attr(data-step);
            position: absolute;
            left: 0;
            top: 2px;
            width: 22px;
            height: 22px;
            background: var(--primary-accent);
            font-size: 0.8rem;
            font-weight: bold;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }}

        .faq-item {{
            margin-bottom: 20px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            padding-bottom: 15px;
        }}

        .faq-item:last-child {{
            border-bottom: none;
        }}

        .faq-q {{
            font-weight: 600;
            margin-bottom: 8px;
            color: #F8FAFC;
        }}

        .faq-a {{
            color: var(--text-secondary);
            font-size: 0.95rem;
        }}

        .sidebar-widget {{
            position: sticky;
            top: 40px;
        }}

        .cta-btn {{
            display: block;
            width: 100%;
            text-align: center;
            background: var(--primary-accent);
            color: #FFFFFF;
            font-weight: 700;
            font-size: 1.1rem;
            text-decoration: none;
            padding: 16px 20px;
            border-radius: 12px;
            border: none;
            box-shadow: 0 4px 15px var(--glow-color);
            transition: all 0.3s ease;
            cursor: pointer;
            margin-top: 20px;
        }}

        .cta-btn:hover {{
            transform: translateY(-2px);
            box-shadow: 0 6px 22px rgba(124, 58, 237, 0.4);
        }}

        .price-tag {{
            font-size: 2.2rem;
            font-family: 'Outfit', sans-serif;
            font-weight: 800;
            margin: 15px 0;
            color: #FFFFFF;
        }}

        footer {{
            text-align: center;
            margin-top: 80px;
            padding-top: 40px;
            border-top: 1px solid rgba(255, 255, 255, 0.05);
            color: var(--text-secondary);
            font-size: 0.85rem;
        }}

        .badge-pill {{
            display: inline-block;
            padding: 4px 10px;
            font-size: 0.8rem;
            background: rgba(124, 58, 237, 0.15);
            color: #C084FC;
            border-radius: 6px;
            margin-right: 5px;
            margin-bottom: 5px;
        }}
    </style>
</head>
<body>
    <div class="container">
        <header>
            <span class="badge">{service_type}</span>
            <h1>{title}</h1>
            <p class="lead-text">{description}</p>
        </header>

        <div class="grid-layout">
            <div class="main-content">
                <div class="glass-card">
                    <h2>Key Deliverables</h2>
                    <ul class="check-list">
                        {deliverables}
                    </ul>
                </div>

                <div class="glass-card">
                    <h2>Working Process</h2>
                    <ul class="step-list">
                        {process}
                    </ul>
                </div>

                <div class="glass-card">
                    <h2>Frequently Asked Questions</h2>
                    {faq}
                </div>
            </div>

            <div class="sidebar">
                <div class="sidebar-widget glass-card">
                    <h2>Get an Estimate</h2>
                    <p style="color: var(--text-secondary); font-size: 0.95rem;">Starting from:</p>
                    <div class="price-tag">{price_tag}</div>
                    <p style="color: var(--text-secondary); font-size: 0.9rem; margin-bottom: 15px;">
                        Final price will be determined based on the size, complexity, and exact timeline of your project.
                    </p>
                    <hr style="border: none; border-top: 1px solid rgba(255, 255, 255, 0.05); margin: 15px 0;">
                    <h2>Required Files</h2>
                    <div style="margin-top: 10px;">
                        {required_files}
                    </div>
                    <a href="mailto:freelance@example.com?subject=Inquiry%20for%20{title}" class="cta-btn">Book a consultation</a>
                </div>
            </div>
        </div>

        <footer>
            <p>© 2026 Client Radar OS Private Workspace. All rights reserved. Content is private and generated for authorized client presentations.</p>
        </footer>
    </div>
</body>
</html>
"""

OFFERS_DATA = [
    {
        "filename": "pdf-to-revit.html",
        "service_type": "PDF_TO_REVIT",
        "title": "Professional PDF to Revit Conversion",
        "description": "Convert flat PDF architectural sheets or hand-drawn schematics into fully coordinate-aligned, clean BIM models.",
        "deliverables": [
            "Structured Revit RVT Project File (native formats)",
            "Accurate floor plans, roof plans, and sections",
            "Consistent elevations and exterior structural facades",
            "Clear 3D isometric structural or schematic renders",
            "Clean export to standard multi-layer DWG formats"
        ],
        "process": [
            "File Import: Scale and calibrate PDFs inside Revit workspace.",
            "Structural Setout: Model basic grids, datums, and structural levels.",
            "Architectural Modeling: Create basic structural walls, openings, and slabs.",
            "Detail Injection: Place fixtures, doors, windows, and tags.",
            "Quality Audit: Check coordinate systems and export sheets."
        ],
        "faq": [
            ("Are structural calculations included?", "No. This service comprises architectural drafting and BIM modeling. Calculations remain the builder's responsibility."),
            ("Can you model complex decorative details?", "Yes. However, highly complex decorative trim or sculptures may be simplified to preserve model performance unless custom families are ordered.")
        ],
        "price_tag": "$350 - $900",
        "required_files": ["Scaled PDF plans", "Level-to-level heights", "Basic architectural style preferences"]
    },
    {
        "filename": "dwg-to-revit.html",
        "service_type": "DWG_TO_REVIT",
        "title": "DWG to Revit BIM Modeling",
        "description": "Transform multi-layer CAD line work into structured, intelligent BIM files ready for scheduling, quantities, and clash tests.",
        "deliverables": [
            "Native Revit (RVT) file organized by standard categories",
            "Revit Sheet setups aligned with CAD templates",
            "Standard walls, floors, ceilings, and architectural components",
            "3D renders of internal layouts"
        ],
        "process": [
            "CAD Cleanup: Strip annotations, purge blocks, and inspect units.",
            "Link CAD: Link DWG file into Revit using shared origins.",
            "Auto-Drafting & Modeling: Model load-bearing columns, perimeter walls, and structural elements.",
            "Schedule configuration: Map room parameters and basic attributes."
        ],
        "faq": [
            ("What Revit versions do you support?", "I support all versions from Revit 2021 up to 2025. Please specify your preference on startup.")
        ],
        "price_tag": "$250 - $700",
        "required_files": ["AutoCAD DWG files", "Layer standards manual (if any)", "Revit template file (optional)"]
    },
    {
        "filename": "house-plan-design.html",
        "service_type": "HOUSE_PLAN_DESIGN",
        "title": "Residential House Plan & Design",
        "description": "Bespoke architectural layout creation for custom residential homes, villas, or extensions.",
        "deliverables": [
            "Concept planning layouts and space configurations",
            "Dimensioned site plans and site layouts",
            "Detailed building cross-sections and structural details",
            "Exterior photographic 3D rendering"
        ],
        "process": [
            "Briefing: Align on design aesthetic, room requirements, and building budget.",
            "Space Allocation: Draft schematic options for review.",
            "Development: Model chosen schematic in Revit.",
            "Documentation: Produce permit sheets, layout specs, and renders."
        ],
        "faq": [
            ("Do you handle local zoning codes?", "I model to standard construction codes. Local bylaws, land surveys, and site constraints must be provided by the client.")
        ],
        "price_tag": "$500 - $1500",
        "required_files": ["Site coordinates / Land survey", "Zoning requirements", "Design references / Sketches"]
    },
    {
        "filename": "bim-modeling.html",
        "service_type": "BIM_MODELING",
        "title": "High-Fidelity Revit BIM Modeling",
        "description": "General purpose, high-detail parametric building modeling for architectural and structural coordination.",
        "deliverables": [
            "LOD 200 - LOD 300 Revit RVT database",
            "Exported IFC models for open-BIM compatibility",
            "Quantity scheduling reports"
        ],
        "process": [
            "Kickoff: Establish LOD criteria, naming conventions, and coordinate setups.",
            "Component modeling: Model columns, structural members, walls, doors, windows.",
            "Integration: Model secondary walls, ceilings, and basic structural connections.",
            "Audit: Check for structural interferences or orphan lines."
        ],
        "faq": [
            ("Do you model HVAC/Electrical systems?", "I model core architectural and structural structures. MEP systems are excluded unless specified.")
        ],
        "price_tag": "$400 - $1200",
        "required_files": ["Existing layout drawings", "LOD standards booklet", "Project parameter rules"]
    },
    {
        "filename": "structural-drawings.html",
        "service_type": "STRUCTURAL_DRAWINGS",
        "title": "Concrete & Structural Execution Drawings",
        "description": "Detailed reinforcement drawings, structural layout profiles, and column/beam scheduling.",
        "deliverables": [
            "Formwork layouts and foundation excavation profiles",
            "Rebar detailing maps for slabs, beams, columns",
            "Steel reinforcement bar schedules (Bending schedules)",
            "High resolution PDF plans and DWG exports"
        ],
        "process": [
            "Calculation analysis: Review structural loads and sizing results.",
            "Foundation details: Detail structural pad footings, ground slabs, and tie-beams.",
            "Slab Reinforcement: Map upper reinforcement sheets, shear links, and spacing.",
            "Audit: Check bar congestion and confirm cover rules."
        ],
        "faq": [
            ("Do you sign/seal the drawings?", "No. Calculations and layouts must be validated and signed by a licensed professional engineer in your jurisdiction.")
        ],
        "price_tag": "$800 - $2000",
        "required_files": ["Geotechnical report", "Architectural base layouts", "Structural calculations workbook"]
    },
    {
        "filename": "scan-to-bim.html",
        "service_type": "SCAN_TO_BIM",
        "title": "Scan-to-BIM Point Cloud Modeling",
        "description": "Convert laser scanner coordinates (point clouds) into clean, parametric building elements in Revit.",
        "deliverables": [
            "Revit RVT file modeled directly onto cloud vertices",
            "LOD 300 structural frame alignment",
            "Deviation analysis report (if requested)"
        ],
        "process": [
            "Cloud Calibration: Setup survey markers and coordinates.",
            "Structural Alignment: Match floor levels and structural spans.",
            "Envelope Modeling: Draw exterior facades, columns, structural slabs.",
            "Partitioning: Trace interior layouts and false ceiling limits."
        ],
        "faq": [
            ("What cloud formats are supported?", "RCP and E57 are preferred for best quality and imports.")
        ],
        "price_tag": "$1200 - $3000",
        "required_files": ["Laser scan data (RCP/E57)", "Site photographs", "Survey coordinate coordinates"]
    },
    {
        "filename": "permit-drawings.html",
        "service_type": "PERMIT_DRAWINGS",
        "title": "Municipal Permit Drafting Packages",
        "description": "Draft complete architectural and location drawings matching municipal council requirements for residential construction permits.",
        "deliverables": [
            "Site and plot boundary plan sheets",
            "Exterior elevations and building elevation profiles",
            "Internal cross sections showing heights",
            "Window/door schedule sheets"
        ],
        "process": [
            "Check requirements: Review local city zoning and plan rules.",
            "Site placement: Orient the building within coordinates.",
            "Layout definition: Complete layouts with boundary clearances.",
            "Publishing: Arrange sheets into standard size blocks."
        ],
        "faq": [
            ("Do you guarantee permit approval?", "No. I draft the package to comply with standard requirements. However, adjustments requested by municipal authorities are included in the price.")
        ],
        "price_tag": "$600 - $1200",
        "required_files": ["Survey plan", "Council rules checklist", "House design sketch"]
    },
    {
        "filename": "autocad-drafting.html",
        "service_type": "AUTOCAD_DRAFTING",
        "title": "General AutoCAD Drafting Services",
        "description": "Fast, high-accuracy 2D drafting services in AutoCAD. Clean layers, blocks, and sheet styling.",
        "deliverables": [
            "Purged DWG source files with standard layers",
            "Scale-ready layout page blocks",
            "PDF sheet bundles"
        ],
        "process": [
            "Analysis: Review source markup sketches.",
            "Drafting: Draw layouts using strict layer and dimension standards.",
            "Layout: Arrange paper space viewport blocks.",
            "Handover: Final checks and source file purging."
        ],
        "faq": [
            ("Can you work with older AutoCAD versions?", "Yes. DWG files can be saved down to AutoCAD 2013 format if required.")
        ],
        "price_tag": "$150 - $400",
        "required_files": ["Hand markups or PDF sketches", "Title block standard (optional)", "Layer guidelines"]
    },
    {
        "filename": "quantity-takeoff.html",
        "service_type": "QUANTITY_TAKEOFF",
        "title": "Construction Quantity Takeoff & Estimating",
        "description": "Extract raw materials quantities (concrete volume, brick counts, drywall area) directly from plans or BIM databases.",
        "deliverables": [
            "Categorized Excel spreadsheet with itemized formulas",
            "Summary Sheet grouping totals by construction division",
            "Highlighted plan markup sheets showing counted elements"
        ],
        "process": [
            "Plan mapping: Align architectural levels and scales.",
            "Itemized takeoff: Quantify concrete, wood, steel, partitions.",
            "Pricing audit: Apply historical material averages if required.",
            "Handover: Deliver workbook."
        ],
        "faq": [
            ("Do you purchase materials?", "No. This is a quantative reporting service. Material purchase remains the contractor's task.")
        ],
        "price_tag": "$200 - $600",
        "required_files": ["Architectural drawings", "Structural notes", "Specification booklet"]
    },
    {
        "filename": "static-website.html",
        "service_type": "STATIC_WEBSITE",
        "title": "Static Website & Automation Services",
        "description": "Performant static website building and script automation (Python, Flutter, Excel integration) to stream workflows.",
        "deliverables": [
            "TailwindCSS or Vanilla CSS static responsive website",
            "Python script files with setup instructions",
            "Excel VBA / openpyxl integration setups"
        ],
        "process": [
            "Requirements Definition: Frame technical steps and outputs.",
            "Development: Write logic with pandas/openpyxl or compile HTML.",
            "Refinement: Optimize performance and clear bugs.",
            "Handover: Deploy static files or run local execution tests."
        ],
        "faq": [
            ("Do you host the websites?", "I deploy to free static hosting systems like GitHub Pages or Netlify. Custom domains are not included in the fee.")
        ],
        "price_tag": "$300 - $800",
        "required_files": ["Copy / Layout guidelines", "Automation sample sheets", "API access parameters"]
    }
]

def generate_all_offer_pages(output_dir="public/offers"):
    os.makedirs(output_dir, exist_ok=True)
    
    for page in OFFERS_DATA:
        # Deliverables list formatting
        deliv_html = ""
        for d in page["deliverables"]:
            deliv_html += f"<li>{d}</li>\n"
            
        # Process steps formatting
        proc_html = ""
        for i, p in enumerate(page["process"], 1):
            proc_html += f'<li data-step="{i}">{p}</li>\n'
            
        # FAQ layout formatting
        faq_html = ""
        for q, a in page["faq"]:
            faq_html += f"""<div class="faq-item">
                <div class="faq-q">{q}</div>
                <div class="faq-a">{a}</div>
            </div>\n"""
            
        # Required files badges
        req_html = ""
        for r in page["required_files"]:
            req_html += f'<span class="badge-pill">{r}</span>\n'
            
        page_content = HTML_TEMPLATE.format(
            title=page["title"],
            service_type=page["service_type"],
            description=page["description"],
            deliverables=deliv_html,
            process=proc_html,
            faq=faq_html,
            price_tag=page["price_tag"],
            required_files=req_html
        )
        
        filepath = os.path.join(output_dir, page["filename"])
        try:
            with open(filepath, "w", encoding="utf-8") as f:
                f.write(page_content)
            logger.info(f"Generated landing page: {filepath}")
        except Exception as e:
            logger.error(f"Failed to generate {page['filename']}: {e}")
            
    logger.info("All landing pages generated successfully.")
    
if __name__ == "__main__":
    generate_all_offer_pages()
