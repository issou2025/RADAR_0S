import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/lead_model.dart';
import '../../data/models/stats_model.dart';
import '../../data/repositories/lead_repository.dart';
import '../../data/repositories/sync_repository.dart';
import '../lead_detail/lead_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _leadRepo = LeadRepository();
  final _syncRepo = SyncRepository();

  bool _isSyncing = false;
  List<LeadModel> _leads = [];
  StatsModel _stats = StatsModel.empty();
  LeadModel? _bestOpportunity;

  int _newLeadsCount = 0;
  int _scoreAbove80Count = 0;
  int _veryHotCount = 0;
  int _urgentCount = 0;
  int _budgetCount = 0;
  int _contactedCount = 0;
  int _wonCount = 0;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    final leads = await _leadRepo.getAllLeads();
    final stats = await _syncRepo.getStats();
    
    // Compute quick dashboard filters locally
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final newLeads = leads.where((l) => l.status == 'new').toList();
    final score80 = leads.where((l) => l.score >= 80).toList();
    final veryHot = leads.where((l) => l.clientTemperature == 'very_hot').toList();
    
    final urgent = leads.where((l) {
      final desc = l.description.toLowerCase();
      final title = l.title.toLowerCase();
      return desc.contains('urgent') || desc.contains('asap') || title.contains('urgent');
    }).toList();
    
    final budget = leads.where((l) => l.budgetDetected.isNotEmpty && l.budgetDetected != 'not specified').toList();
    final contacted = leads.where((l) => ['contacted', 'replied', 'negotiation'].contains(l.status)).toList();
    final won = leads.where((l) => l.status == 'won').toList();

    // Find best opportunity today (highest score in "new" or "favorite" list)
    final candidateLeads = leads.where((l) => ['new', 'favorite'].contains(l.status)).toList();
    final bestOpp = candidateLeads.isNotEmpty ? candidateLeads.first : null;

    setState(() {
      _leads = leads;
      _stats = stats;
      _bestOpportunity = bestOpp;
      _newLeadsCount = newLeads.length;
      _scoreAbove80Count = score80.length;
      _veryHotCount = veryHot.length;
      _urgentCount = urgent.length;
      _budgetCount = budget.length;
      _contactedCount = contacted.length;
      _wonCount = won.length;
    });
  }

  Future<void> _sync() async {
    setState(() => _isSyncing = true);
    final result = await _syncRepo.syncWithGithub();
    setState(() => _isSyncing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? AppTheme.success : AppTheme.danger,
        ),
      );
      _loadLocalData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Radar Dashboard",
          style: TextStyle(fontFamily: 'Outfit', fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                : const Icon(Icons.sync),
            onPressed: _isSyncing ? null : _sync,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings').then((_) => _loadLocalData()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadLocalData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Radar Actif 📡",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isSyncing
                          ? "Synchronisation des opportunités en cours..."
                          : "Détection active : ${_leads.length} opportunités scannées dans la base locale.",
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Métrique Commerciales",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
              ),
              const SizedBox(height: 12),

              // Grid of Stats
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildStatCard("Pistes Neuves", "$_newLeadsCount", Icons.fiber_new, AppTheme.info),
                  _buildStatCard("Score > 80", "$_scoreAbove80Count", Icons.bolt, AppTheme.success),
                  _buildStatCard("Très Chaudes", "$_veryHotCount", Icons.whatshot, AppTheme.danger),
                  _buildStatCard("Avec Budget", "$_budgetCount", Icons.payments_outlined, AppTheme.warning),
                  _buildStatCard("Contactées", "$_contactedCount", Icons.mail_outline, AppTheme.textSecondary),
                  _buildStatCard("Gagnées 🏆", "$_wonCount", Icons.emoji_events_outlined, AppTheme.success),
                ],
              ),
              const SizedBox(height: 24),

              // Best Opportunity Card
              if (_bestOpportunity != null) ...[
                const Text(
                  "Meilleure opportunité disponible",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LeadDetailScreen(leadId: _bestOpportunity!.id),
                      ),
                    ).then((_) => _loadLocalData());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              "🔥",
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _bestOpportunity!.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF232D4F),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _bestOpportunity!.source,
                                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Score: ${_bestOpportunity!.score}",
                                    style: const TextStyle(fontSize: 12, color: AppTheme.success, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Navigation Shortcuts
              const Text(
                "Raccourcis rapides",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
              ),
              const SizedBox(height: 12),

              _buildShortcutRow(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E2640), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          )
        ],
      ),
    );
  }

  Widget _buildShortcutRow(BuildContext context) {
    Widget item(String label, IconData icon, String route) {
      return Expanded(
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, route).then((_) => _loadLocalData()),
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E2640), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 28),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            item("Leads", Icons.view_list, '/leads'),
            const SizedBox(width: 12),
            item("Pipeline", Icons.view_kanban, '/pipeline'),
            const SizedBox(width: 12),
            item("Réponses", Icons.reply_all, '/reply_studio'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            item("Offres", Icons.web, '/offer_pages'),
            const SizedBox(width: 12),
            item("Mots-clés", Icons.science_outlined, '/keyword_lab'),
            const SizedBox(width: 12),
            item("Analyses", Icons.bar_chart, '/statistics'),
          ],
        ),
      ],
    );
  }
}
