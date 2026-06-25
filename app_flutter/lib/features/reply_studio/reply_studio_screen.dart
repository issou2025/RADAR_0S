import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/local/database_helper.dart';
import '../../data/repositories/sync_repository.dart';

class ReplyStudioScreen extends StatefulWidget {
  const ReplyStudioScreen({super.key});

  @override
  State<ReplyStudioScreen> createState() => _ReplyStudioScreenState();
}

class _ReplyStudioScreenState extends State<ReplyStudioScreen> {
  final _dbHelper = DatabaseHelper.instance;
  final _syncRepo = SyncRepository();

  bool _isLoading = false;
  String _selectedLang = 'fr'; // fr or en
  
  // Controller maps for template fields
  final Map<String, TextEditingController> _controllers = {
    'short': TextEditingController(),
    'professional': TextEditingController(),
    'technical': TextEditingController(),
    'with_offer_page': TextEditingController(),
    'follow_up_3_days': TextEditingController(),
    'follow_up_7_days': TextEditingController(),
    'cautious_risk': TextEditingController(),
  };

  final Map<String, String> _labels = {
    'short': 'Réponse Courte',
    'professional': 'Réponse Professionnelle',
    'technical': 'Réponse Technique / Structurée',
    'with_offer_page': 'Réponse avec Lien d\'Offre',
    'follow_up_3_days': 'Relance Douce (J+3)',
    'follow_up_7_days': 'Relance Finale (J+7)',
    'cautious_risk': 'Réponse Prudente (Risque élevé)',
  };

  Map<String, dynamic> _fullTemplatesData = {};

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() => _isLoading = true);
    
    // We can fetch from remote files cache or settings
    final remoteDataSource = await _dbHelper.database; // Check database helper
    final cachedJson = await _dbHelper.getCachedStats(); // Let's check stats cache or load fallback
    
    // Since we have a template JSON file on remote: data/reply_templates.json, we can load it.
    // As a robust fallback, we initialize with local copy
    _fullTemplatesData = {
      "en": {
        "short": "Hello,\n\nI saw your request and I can help you with this Revit/BIM project. I can prepare a clean model and professional drawings from your PDF, DWG, sketch, or existing files.\n\nPlease send the available files so I can review the scope, timeline, and cost.\n\nBest regards.",
        "professional": "Hello,\n\nI saw your request for a Revit/BIM freelancer. I can help you convert your source files (PDF/DWG/sketches) into a clean, accurate, and professional Revit model.\n\nHere is what I can deliver:\n- Fully parametric Revit (RVT) model\n- Precise floor plans, sections, and elevations\n- Clean 3D orthographic views and perspective rendering\n- Document sheets exported to PDF and DWG formats\n\nCould you please share your project requirements, files, and preferred timeline so I can provide a detailed estimate?\n\nBest regards.",
        "technical": "Hello,\n\nI specialize in BIM implementation and building drafting using Autodesk Revit. I can convert your assets into a Revit model configured with correct family parameters, clean wall joins, and accurate level offsets.\n\nMy workflow uses strict Level of Detail (LOD 100 to LOD 300) standards depending on your design phase.\n\nLet's discuss your coordinates setup.\n\nBest regards.",
        "with_offer_page": "Hello,\n\nI saw your request and I can assist with this project. I have a dedicated offer page detailing my workflow, deliverables, and typical terms:\n\n{offer_url}\n\nHave a look at the workflow, and feel free to send your files.\n\nBest regards.",
        "follow_up_3_days": "Hello,\n\nI wanted to follow up on your request. Have you had a chance to review my previous message or check the offer page?\n\nBest regards.",
        "follow_up_7_days": "Hello,\n\nI'm checking in one last time regarding your request. If you are still looking for help, please share your files. Otherwise, good luck!\n\nBest regards.",
        "cautious_risk": "Hello,\n\nI would be glad to look into this project. Please provide the exact scope of work and budget details so we can formalize a structured agreement before commencing.\n\nBest regards."
      },
      "fr": {
        "short": "Bonjour,\n\nJ'ai vu votre demande et je peux vous aider pour ce projet Revit/BIM. Je peux réaliser un modèle propre et des plans professionnels à partir de vos fichiers PDF, DWG, croquis ou documents existants.\n\nN'hésitez pas à m'envoyer les fichiers afin que je puisse étudier le volume de travail, le délai et le coût.\n\nCordialement.",
        "professional": "Bonjour,\n\nJ'ai pris connaissance de votre demande de prestation. Spécialiste de la conception et modélisation Revit/BIM, je peux vous accompagner pour convertir vos documents (PDF, plans DWG, croquis) en un modèle 3D précis.\n\nVoici les livrables types :\n- Modèle Revit (.RVT) structuré\n- Plans de niveaux, coupes et élévations cotés\n- Vues 3D réalistes et perspectives de présentation\n- Livrables exports PDF et plans DWG d'exécution\n\nPourriez-vous partager vos éléments de base ainsi que vos contraintes de délai ?\n\nCordialement.",
        "technical": "Bonjour,\n\nIngénieur/projeteur spécialisé en modélisation BIM sous Revit, je vous propose mes services pour structurer votre projet de manière professionnelle. Je configure les nomenclatures, assure le nettoyage des jonctions d'angles et veille à la cohérence du modèle.\n\nJe travaille selon les standards LOD requis (de 100 à 300) avec des familles correctement paramétrées.\n\nCordialement.",
        "with_offer_page": "Bonjour,\n\nJe suis très intéressé par votre demande. J'ai préparé une page d'offre dédiée détaillant ma méthode de travail, mes réalisations et mes tarifs indicatifs :\n\n{offer_url}\n\nJe vous invite à la consulter et à m'envoyer vos fichiers.\n\nCordialement.",
        "follow_up_3_days": "Bonjour,\n\nJe me permets de vous relancer concernant votre projet. Avez-vous pu prendre connaissance de mon message précédent et de mon offre ?\n\nCordialement.",
        "follow_up_7_days": "Bonjour,\n\nUn dernier message de suivi pour savoir si votre projet est toujours d'actualité. Si c'est le cas, je serais ravi de vous accompagner. Dans le cas contraire, bonne continuation.\n\nCordialement.",
        "cautious_risk": "Bonjour,\n\nJe serais ravi d'étudier votre demande. Afin de structurer au mieux notre collaboration, pourriez-vous me transmettre le cahier des charges précis ainsi que vos modalités budgétaires ?\n\nCordialement."
      }
    };

    // Load from local database settings if exists (we store templates as a cached stats variable or in SharedPreferences)
    // For now we populate controllers with the default config
    _populateControllers();
    
    setState(() => _isLoading = false);
  }

  void _populateControllers() {
    final langData = _fullTemplatesData[_selectedLang] as Map<String, dynamic>;
    _controllers.forEach((key, controller) {
      controller.text = langData[key] ?? "";
    });
  }

  Future<void> _saveTemplates() async {
    setState(() => _isLoading = true);

    // Update internal structure
    final Map<String, dynamic> langData = {};
    _controllers.forEach((key, controller) {
      langData[key] = controller.text;
    });
    _fullTemplatesData[_selectedLang] = langData;

    // Queue action to save template remote
    // In our serverless setup, we sync files. We insert action.
    await _dbHelper.insertAction("reply_templates", "update_templates", jsonEncode(_fullTemplatesData));

    setState(() => _isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Modèles enregistrés localement ! Ils seront synchronisés au prochain sync."),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Studio de Réponses"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveTemplates,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Lang selection chip row
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Text("Langue de rédaction : ", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      ChoiceChip(
                        label: const Text("Français 🇫🇷"),
                        selected: _selectedLang == 'fr',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedLang = 'fr';
                              _populateControllers();
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text("Anglais 🇬🇧"),
                        selected: _selectedLang == 'en',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedLang = 'en';
                              _populateControllers();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                
                // Form fields list
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: _controllers.entries.map((entry) {
                      final key = entry.key;
                      final controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _labels[key] ?? key,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: controller,
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: "Saisissez le texte du modèle...",
                                helperText: key == 'with_offer_page' 
                                    ? "Utilisez le tag {offer_url} pour insérer automatiquement le lien de la page." 
                                    : null,
                              ),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
