import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/lead_model.dart';
import '../../data/repositories/lead_repository.dart';

class LeadDetailScreen extends StatefulWidget {
  final String leadId;
  const LeadDetailScreen({super.key, required this.leadId});

  @override
  State<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends State<LeadDetailScreen> with SingleTickerProviderStateMixin {
  final _leadRepo = LeadRepository();
  
  LeadModel? _lead;
  bool _isLoading = false;
  late TabController _tabController;
  final _notesController = TextEditingController();
  String _githubPagesBaseUrl = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadLead();
  }

  Future<void> _loadLead() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString(AppConstants.keyGithubPagesBaseUrl) ?? "";
    final lead = await _leadRepo.getLeadById(widget.leadId);
    
    setState(() {
      _lead = lead;
      _githubPagesBaseUrl = baseUrl;
      if (lead != null) {
        _notesController.text = lead.notes;
      }
      _isLoading = false;
    });
  }

  Future<void> _changeStatus(String status) async {
    if (_lead == null) return;
    await _leadRepo.updateLeadStatus(_lead!.id, status);
    setState(() {
      _lead = _lead!.copyWith(status: status, updatedAt: DateTime.now().toIso8601String());
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Statut mis à jour : '$status'"),
        backgroundColor: AppTheme.success,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _saveNotes() async {
    if (_lead == null) return;
    await _leadRepo.updateLeadNotes(_lead!.id, _notesController.text);
    setState(() {
      _lead = _lead!.copyWith(notes: _notesController.text, updatedAt: DateTime.now().toIso8601String());
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Notes personnelles enregistrées !"),
        backgroundColor: AppTheme.success,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$label copié dans le presse-papiers !"),
        backgroundColor: AppTheme.primaryColor,
        duration: const Duration(seconds: 1.5),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Impossible d'ouvrir l'URL : $url"),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_lead == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text("Prospect introuvable")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détail du prospect", style: TextStyle(fontFamily: 'Outfit')),
        actions: [
          IconButton(
            icon: Icon(_lead!.status == 'favorite' ? Icons.star : Icons.star_border),
            color: _lead!.status == 'favorite' ? AppTheme.warning : null,
            onPressed: () async {
              final newFav = _lead!.status != 'favorite';
              await _leadRepo.toggleFavorite(_lead!.id, newFav);
              _loadLead();
            },
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: "Lien original",
            onPressed: () => _openUrl(_lead!.url),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header summary info
          _buildLeadHeader(),
          
          // Tab navigation bar
          TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.primaryColor,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textSecondary,
            tabs: const [
              Tab(text: "Analyse"),
              Tab(text: "Réponses"),
              Tab(text: "Proposition"),
              Tab(text: "Notes & Suivi"),
            ],
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAnalysisTab(),
                _buildRepliesTab(),
                _buildProposalTab(),
                _buildNotesTab(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLeadHeader() {
    return Container(
      width: double.infinity,
      color: AppTheme.surfaceColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  AppConstants.serviceLabels[_lead!.serviceType] ?? _lead!.serviceType,
                  style: const TextStyle(fontSize: 12, color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                "Source: ${_lead!.source}",
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _lead!.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    Color tempColor;
    String tempLabel;
    switch (_lead!.clientTemperature) {
      case 'very_hot':
        tempColor = AppTheme.danger;
        tempLabel = "Très Chaud";
        break;
      case 'hot':
        tempColor = AppTheme.warning;
        tempLabel = "Chaud";
        break;
      case 'warm':
        tempColor = AppTheme.success;
        tempLabel = "Tiède";
        break;
      default:
        tempColor = AppTheme.info;
        tempLabel = "Faible";
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row of Main indicators
          Row(
            children: [
              Expanded(
                child: _buildMetricTile("Score d'Intérêt", "${_lead!.score}/100", 
                    _lead!.score >= 80 ? AppTheme.success : AppTheme.warning),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile("Indice de Risque", "${_lead!.riskScore}/100", 
                    _lead!.riskScore >= 50 ? AppTheme.danger : AppTheme.success),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile("Température Client", tempLabel, tempColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile("Tarif Conseillé", _lead!.recommendedPrice, AppTheme.warning),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Decoded details
          const Text("Description du client", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E2640)),
            ),
            child: Text(
              _lead!.description.isNotEmpty ? _lead!.description : "Aucune description fournie.",
              style: const TextStyle(height: 1.4),
            ),
          ),
          const SizedBox(height: 24),

          // Budget Detected
          const Text("Budget détecté", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
          const SizedBox(height: 6),
          Text(
            _lead!.budgetDetected.isNotEmpty && _lead!.budgetDetected != 'not specified' 
              ? _lead!.budgetDetected 
              : "Aucun budget explicite détecté.",
            style: const TextStyle(fontSize: 15, color: Colors.white70),
          ),
          const SizedBox(height: 24),

          // Reasons for score
          const Text("Facteurs de qualification", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
          const SizedBox(height: 8),
          ..._lead!.scoreReasons.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              children: [
                Icon(
                  r.contains('-') ? Icons.remove_circle_outline : Icons.check_circle_outline, 
                  color: r.contains('-') ? AppTheme.danger : AppTheme.success, 
                  size: 18
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(r)),
              ],
            ),
          )),
          const SizedBox(height: 24),

          // Questions to ask
          if (_lead!.questionsToAsk.isNotEmpty) ...[
            const Text("Questions techniques recommandées", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E2640)),
              ),
              child: Column(
                children: [
                  ..._lead!.questionsToAsk.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${entry.key + 1}. ", style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                        Expanded(child: Text(entry.value, style: const TextStyle(height: 1.3))),
                      ],
                    ),
                  )),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        final text = _lead!.questionsToAsk.asMap().entries.map((e) => "${e.key+1}. ${e.value}").join('\n');
                        _copyToClipboard(text, "Questions");
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text("Copier toutes les questions"),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
          ]
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2640)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildRepliesTab() {
    final replies = _lead!.replies;
    if (replies.isEmpty) {
      return const Center(child: Text("Aucun modèle de réponse disponible pour cette langue/service."));
    }

    final isFr = _lead!.language == 'fr';
    final shortText = isFr ? (replies['short_fr'] ?? _lead!.replyShort) : (replies['short_en'] ?? _lead!.replyShort);
    final profText = isFr ? (replies['prof_fr'] ?? _lead!.replyProfessional) : (replies['prof_en'] ?? _lead!.replyProfessional);
    final techText = isFr ? (replies['tech_fr'] ?? "") : (replies['tech_en'] ?? "");
    final offerText = isFr ? (replies['offer_fr'] ?? "") : (replies['offer_en'] ?? "");
    final followUp3 = replies['follow_up_3_days'] ?? "";
    final followUp7 = replies['follow_up_7_days'] ?? "";

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReplySection("Réponse Courte (Conseillé)", shortText),
        _buildReplySection("Réponse Professionnelle", profText),
        if (techText.isNotEmpty) _buildReplySection("Réponse Technique", techText),
        if (offerText.isNotEmpty) _buildReplySection("Réponse avec Page d'Offre", offerText),
        if (followUp3.isNotEmpty) _buildReplySection("Relance (J+3)", followUp3),
        if (followUp7.isNotEmpty) _buildReplySection("Relance Finale (J+7)", followUp7),
        
        // Link to GitHub page
        const SizedBox(height: 12),
        Card(
          color: AppTheme.surfaceColor.withOpacity(0.5),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Page d'Offre Portfolio associée", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  "$_githubPagesBaseUrl${_lead!.offerPage}",
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _copyToClipboard("$_githubPagesBaseUrl${_lead!.offerPage}", "Lien d'offre"),
                        child: const Text("Copier le lien"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _openUrl("$_githubPagesBaseUrl${_lead!.offerPage}"),
                        child: const Text("Ouvrir"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildReplySection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2640)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              IconButton(
                icon: const Icon(Icons.copy, size: 18, color: AppTheme.textSecondary),
                onPressed: () => _copyToClipboard(content, title),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(height: 1.4, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildProposalTab() {
    final hasProposal = _lead!.proposalPath.isNotEmpty;
    // We can show a mock markdown preview block
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Proposition Commerciale (Markdown)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
              if (hasProposal)
                IconButton(
                  icon: const Icon(Icons.copy, color: AppTheme.textSecondary),
                  onPressed: () {
                    final mockText = _generateMockProposalText();
                    _copyToClipboard(mockText, "Proposition");
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E2640)),
            ),
            child: Text(
              _generateMockProposalText(),
              style: const TextStyle(fontFamily: 'Courier', fontSize: 12, height: 1.4),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _generateMockProposalText() {
    final lang = _lead!.language;
    final title = _lead!.title;
    final svc = _lead!.serviceType.replaceAll('_', ' ').toUpperCase();
    
    if (lang == 'fr') {
      return """# Proposition de Projet — $svc

## Compréhension du Projet
Vous recherchez un prestataire pour : $title

## Étendue des Travaux
- Analyse des documents fournis et mise en place des gabarits.
- Modélisation/Développement selon les exigences formulées.
- Validation des livrables techniques.
- Intégration des commentaires et corrections.
- Remise du dossier final (fichiers sources inclus).

## Budget et Délai Indicatifs
- **Tarif indicatif :** ${_lead!.recommendedPrice}
- **Délai de réalisation estimé :** 3 à 7 jours ouvrés.

## Questions complémentaires
${_lead!.questionsToAsk.asMap().entries.map((e) => "${e.key+1}. ${e.value}").join('\n')}
""";
    } else {
      return """# Project Proposal — $svc

## Project Understanding
You need assistance with: $title

## Scope of Work
- Asset analysis and workspace initialization.
- Core modeling / development based on specifications.
- Technical validation and quality checks.
- Clean handover of source files and documentation.

## Estimated Price and Timeline
- **Estimated Price:** ${_lead!.recommendedPrice}
- **Estimated Timeline:** 3 to 7 business days.

## Project Questions
${_lead!.questionsToAsk.asMap().entries.map((e) => "${e.key+1}. ${e.value}").join('\n')}
""";
    }
  }

  Widget _buildNotesTab() {
    final statuses = [
      'new',
      'viewed',
      'favorite',
      'contacted',
      'negotiation',
      'won',
      'lost',
      'ignored',
      'archived'
    ];

    final Map<String, String> statusLabels = {
      'new': 'Nouveau',
      'viewed': 'Vu',
      'favorite': 'Favori ⭐',
      'contacted': 'Contacté',
      'negotiation': 'Négociation',
      'won': 'Gagné 🏆',
      'lost': 'Perdu ❌',
      'ignored': 'Ignoré 🚫',
      'archived': 'Archivé',
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Selector
          const Text("Cycle de vie du client", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: statuses.map((status) {
              final isCurrent = _lead!.status == status;
              return ChoiceChip(
                label: Text(statusLabels[status] ?? status),
                selected: isCurrent,
                selectedColor: status == 'won' 
                  ? AppTheme.success 
                  : (status == 'lost' || status == 'ignored' ? AppTheme.danger : AppTheme.primaryColor),
                onSelected: (selected) {
                  if (selected) {
                    _changeStatus(status);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Personal Notes Editor
          const Text("Notes personnelles", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: "Saisissez vos observations, coordonnées client, rappels de prix convenus...",
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveNotes,
              child: const Text("Enregistrer les notes"),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
