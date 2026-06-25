class AppConstants {
  static const String appName = "Client Radar OS";
  static const String appSlogan = "Find clients before they find freelancers.";

  // Shared Preferences Keys
  static const String keyGithubUsername = "github_username";
  static const String keyGithubRepo = "github_repo";
  static const String keyGithubBranch = "github_branch";
  static const String keyGithubPagesBaseUrl = "github_pages_base_url";
  static const String keyLeadsPath = "leads_json_path";
  static const String keyActionsPath = "user_actions_json_path";
  static const String keyIsFirstRun = "is_first_run";

  // Defaults
  static const String defaultBranch = "main";
  static const String defaultLeadsPath = "data/leads.json";
  static const String defaultActionsPath = "data/user_actions.json";

  // Service Type Labels
  static const Map<String, String> serviceLabels = {
    "PDF_TO_REVIT": "PDF vers Revit",
    "DWG_TO_REVIT": "DWG vers Revit",
    "HOUSE_PLAN_DESIGN": "Plan de maison",
    "BIM_MODELING": "Modélisation BIM",
    "STRUCTURAL_DRAWINGS": "Plans de structure",
    "SCAN_TO_BIM": "Scan-to-BIM",
    "PERMIT_DRAWINGS": "Plans de permis",
    "AUTOCAD_DRAFTING": "Dessin AutoCAD",
    "QUANTITY_TAKEOFF": "Métrés & Quantités",
    "BOQ_ESTIMATE": "Estimation Devis",
    "FLUTTER_APP": "Application Flutter",
    "PYTHON_AUTOMATION": "Script Python",
    "EXCEL_AUTOMATION": "Majeur Excel",
    "STATIC_WEBSITE": "Site Web Statique",
    "UNKNOWN": "Autre service"
  };
}
