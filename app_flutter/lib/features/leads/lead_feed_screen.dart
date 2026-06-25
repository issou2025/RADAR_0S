import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/lead_model.dart';
import '../../data/repositories/lead_repository.dart';
import '../lead_detail/lead_detail_screen.dart';

class LeadFeedScreen extends StatefulWidget {
  const LeadFeedScreen({super.key});

  @override
  State<LeadFeedScreen> createState() => _LeadFeedScreenState();
}

class _LeadFeedScreenState extends State<LeadFeedScreen> {
  final _leadRepo = LeadRepository();
  
  List<LeadModel> _allLeads = [];
  List<LeadModel> _filteredLeads = [];
  bool _isLoading = false;

  // Filters State
  String _statusFilter = 'all'; // all, new, favorite, ignored, won, contacted
  String _serviceFilter = 'all'; // all, PDF_TO_REVIT, DWG_TO_REVIT, etc.
  String _langFilter = 'all'; // all, fr, en
  bool _onlyHighScores = false; // score >= 80
  bool _onlyVeryHot = false; // temp == very_hot
  bool _onlyLowRisk = false; // risk <= 20
  bool _onlyWithBudget = false; // has budget

  // Sorting State
  String _sortBy = 'score'; // score, date, risk, budget

  @override
  void initState() {
    super.initState();
    _loadLeads();
  }

  Future<void> _loadLeads() async {
    setState(() => _isLoading = true);
    final leads = await _leadRepo.getAllLeads();
    setState(() {
      _allLeads = leads;
      _isLoading = false;
      _applyFiltersAndSort();
    });
  }

  void _applyFiltersAndSort() {
    List<LeadModel> filtered = List.from(_allLeads);

    // 1. Status Filter
    if (_statusFilter != 'all') {
      if (_statusFilter == 'new') {
        filtered = filtered.where((l) => l.status == 'new').toList();
      } else if (_statusFilter == 'favorite') {
        filtered = filtered.where((l) => l.status == 'favorite').toList();
      } else if (_statusFilter == 'ignored') {
        filtered = filtered.where((l) => l.status == 'ignored').toList();
      } else if (_statusFilter == 'won') {
        filtered = filtered.where((l) => l.status == 'won').toList();
      } else if (_statusFilter == 'contacted') {
        filtered = filtered.where((l) => ['contacted', 'replied'].contains(l.status)).toList();
      }
    } else {
      // By default, hide ignored leads in "All" view to keep list clean
      filtered = filtered.where((l) => l.status != 'ignored').toList();
    }

    // 2. Service Filter
    if (_serviceFilter != 'all') {
      filtered = filtered.where((l) => l.serviceType == _serviceFilter).toList();
    }

    // 3. Language Filter
    if (_langFilter != 'all') {
      filtered = filtered.where((l) => l.language == _langFilter).toList();
    }

    // 4. Metric Switches
    if (_onlyHighScores) {
      filtered = filtered.where((l) => l.score >= 80).toList();
    }
    if (_onlyVeryHot) {
      filtered = filtered.where((l) => l.clientTemperature == 'very_hot').toList();
    }
    if (_onlyLowRisk) {
      filtered = filtered.where((l) => l.riskScore <= 20).toList();
    }
    if (_onlyWithBudget) {
      filtered = filtered.where((l) => l.budgetDetected.isNotEmpty && l.budgetDetected != 'not specified').toList();
    }

    // 5. SORTING
    if (_sortBy == 'score') {
      filtered.sort((a, b) => b.score.compareTo(a.score));
    } else if (_sortBy == 'date') {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_sortBy == 'risk') {
      filtered.sort((a, b) => a.riskScore.compareTo(b.riskScore));
    } else if (_sortBy == 'budget') {
      // Very simple sorting for budget
      filtered.sort((a, b) {
        final aHas = a.budgetDetected != 'not specified' && a.budgetDetected.isNotEmpty;
        final bHas = b.budgetDetected != 'not specified' && b.budgetDetected.isNotEmpty;
        if (aHas && !bHas) return -1;
        if (!aHas && bHas) return 1;
        return b.score.compareTo(a.score);
      });
    }

    setState(() {
      _filteredLeads = filtered;
    });
  }

  Future<void> _updateLeadStatus(LeadModel lead, String newStatus) async {
    await _leadRepo.updateLeadStatus(lead.id, newStatus);
    _loadLeads();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flux de Prospection"),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top Status Horizontal tabs
                _buildStatusTabBar(),
                
                // Active Filters Indicator summary
                _buildActiveFiltersRow(),

                // Leads list
                Expanded(
                  child: _filteredLeads.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadLeads,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _filteredLeads.length,
                            itemBuilder: (context, index) {
                              final lead = _filteredLeads[index];
                              return _buildLeadCard(lead);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatusTabBar() {
    final Map<String, String> statusTabs = {
      'all': 'Tous',
      'new': 'Nouveaux',
      'favorite': 'Favoris',
      'contacted': 'Contactés',
      'won': 'Gagnés',
      'ignored': 'Ignorés',
    };

    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: statusTabs.entries.map((entry) {
          final isSelected = _statusFilter == entry.key;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _statusFilter = entry.key;
                    _applyFiltersAndSort();
                  });
                }
              },
              selectedColor: AppTheme.primaryColor,
              backgroundColor: AppTheme.surfaceColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveFiltersRow() {
    final hasActiveFilter = _serviceFilter != 'all' || 
                           _langFilter != 'all' || 
                           _onlyHighScores || 
                           _onlyVeryHot || 
                           _onlyLowRisk || 
                           _onlyWithBudget;

    if (!hasActiveFilter) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        alignment: Alignment.centerLeft,
        child: Text(
          "${_filteredLeads.length} opportunités trouvées • Tri par $_sortBy",
          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      height: 36,
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (_serviceFilter != 'all')
                  _buildFilterIndicator("Svc: $_serviceFilter"),
                if (_langFilter != 'all')
                  _buildFilterIndicator("Lang: ${_langFilter.toUpperCase()}"),
                if (_onlyHighScores)
                  _buildFilterIndicator("Score >= 80"),
                if (_onlyVeryHot)
                  _buildFilterIndicator("Très Chaud"),
                if (_onlyLowRisk)
                  _buildFilterIndicator("Risque Faible"),
                if (_onlyWithBudget)
                  _buildFilterIndicator("Avec Budget"),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _serviceFilter = 'all';
                _langFilter = 'all';
                _onlyHighScores = false;
                _onlyVeryHot = false;
                _onlyLowRisk = false;
                _onlyWithBudget = false;
                _applyFiltersAndSort();
              });
            },
            child: const Text("Effacer", style: TextStyle(fontSize: 12, color: AppTheme.primaryColor)),
          )
        ],
      ),
    );
  }

  Widget _buildFilterIndicator(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("📡", style: TextStyle(fontSize: 50)),
          const SizedBox(height: 16),
          const Text(
            "Aucun prospect trouvé",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Modifiez les filtres de recherche ou effectuez une synchronisation.",
            textAlign: Center,
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: _loadLeads,
            child: const Text("Rafraîchir"),
          )
        ],
      ),
    );
  }

  Widget _buildLeadCard(LeadModel lead) {
    // Determine Temperature color
    Color tempColor;
    String tempLabel;
    switch (lead.clientTemperature) {
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

    final isFav = lead.status == 'favorite';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LeadDetailScreen(leadId: lead.id),
            ),
          ).then((_) => _loadLeads());
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Score Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      lead.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Score circle badge
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: lead.score >= 80 ? AppTheme.success.withOpacity(0.15) : AppTheme.surfaceColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: lead.score >= 80 ? AppTheme.success : AppTheme.textMuted,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "${lead.score}",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: lead.score >= 80 ? AppTheme.success : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Description Snippet
              Text(
                lead.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),

              // Badges Row
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  // Service Badge
                  _buildTagBadge(AppConstants.serviceLabels[lead.serviceType] ?? lead.serviceType, AppTheme.primaryColor),
                  // Source
                  _buildTagBadge(lead.source, const Color(0xFF232D4F)),
                  // Temp badge
                  _buildTagBadge(tempLabel, tempColor),
                  // Risk
                  if (lead.riskScore >= 50)
                    _buildTagBadge("Risque élevé", AppTheme.danger),
                  // Budget
                  if (lead.budgetDetected != 'not specified' && lead.budgetDetected.isNotEmpty)
                    _buildTagBadge(lead.budgetDetected, AppTheme.warning),
                ],
              ),
              const SizedBox(height: 14),

              const Divider(color: Color(0xFF1E2640), height: 1),
              const SizedBox(height: 8),

              // Bottom card action row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lead.dateFound,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                  Row(
                    children: [
                      // Ignore Action
                      if (lead.status != 'ignored')
                        IconButton(
                          icon: const Icon(Icons.block, size: 20, color: AppTheme.textMuted),
                          tooltip: 'Ignorer',
                          onPressed: () => _updateLeadStatus(lead, 'ignored'),
                        ),
                      
                      // Favorite action
                      IconButton(
                        icon: Icon(isFav ? Icons.star : Icons.star_border, size: 20),
                        color: isFav ? AppTheme.warning : AppTheme.textMuted,
                        tooltip: 'Favoris',
                        onPressed: () => _leadRepo.toggleFavorite(lead.id, !isFav).then((_) => _loadLeads()),
                      ),
                      
                      // Contacted status changer shortcut
                      if (lead.status == 'new' || lead.status == 'favorite')
                        TextButton.icon(
                          onPressed: () => _updateLeadStatus(lead, 'contacted'),
                          icon: const Icon(Icons.send_outlined, size: 16),
                          label: const Text("Répondre", style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppTheme.surfaceColor,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filtres de recherche",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _serviceFilter = 'all';
                            _langFilter = 'all';
                            _onlyHighScores = false;
                            _onlyVeryHot = false;
                            _onlyLowRisk = false;
                            _onlyWithBudget = false;
                          });
                          _applyFiltersAndSort();
                          Navigator.pop(context);
                        },
                        child: const Text("Réinitialiser"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Service Types Dropdown
                  const Text("Type de Service", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _serviceFilter,
                    dropdownColor: AppTheme.cardColor,
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text("Tous les services")),
                      ...AppConstants.serviceLabels.entries.map((entry) {
                        return DropdownMenuItem(value: entry.key, child: Text(entry.value));
                      }).toList(),
                    ],
                    onChanged: (val) {
                      setModalState(() => _serviceFilter = val ?? 'all');
                      setState(() => _serviceFilter = val ?? 'all');
                      _applyFiltersAndSort();
                    },
                  ),
                  const SizedBox(height: 16),

                  // Language
                  const Text("Langue", style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      _buildChipFilter(setModalState, "Toutes", _langFilter == 'all', () => _langFilter = 'all'),
                      _buildChipFilter(setModalState, "Français", _langFilter == 'fr', () => _langFilter = 'fr'),
                      _buildChipFilter(setModalState, "Anglais", _langFilter == 'en', () => _langFilter = 'en'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Metrics Switches
                  const Text("Critères Qualitatifs", style: TextStyle(fontWeight: FontWeight.bold)),
                  SwitchListTile(
                    title: const Text("Uniquement opportunités majeures (Score >= 80)"),
                    value: _onlyHighScores,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (val) {
                      setModalState(() => _onlyHighScores = val);
                      setState(() => _onlyHighScores = val);
                      _applyFiltersAndSort();
                    },
                  ),
                  SwitchListTile(
                    title: const Text("Uniquement prospects très chauds"),
                    value: _onlyVeryHot,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (val) {
                      setModalState(() => _onlyVeryHot = val);
                      setState(() => _onlyVeryHot = val);
                      _applyFiltersAndSort();
                    },
                  ),
                  SwitchListTile(
                    title: const Text("Risques minimes (Score <= 20)"),
                    value: _onlyLowRisk,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (val) {
                      setModalState(() => _onlyLowRisk = val);
                      setState(() => _onlyLowRisk = val);
                      _applyFiltersAndSort();
                    },
                  ),
                  SwitchListTile(
                    title: const Text("Avec budget identifié"),
                    value: _onlyWithBudget,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (val) {
                      setModalState(() => _onlyWithBudget = val);
                      setState(() => _onlyWithBudget = val);
                      _applyFiltersAndSort();
                    },
                  ),
                  const SizedBox(height: 16),

                  // Sorting
                  const Text("Trier par", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _sortBy,
                    dropdownColor: AppTheme.cardColor,
                    items: const [
                      DropdownMenuItem(value: 'score', child: Text("Intérêt commercial décroissant")),
                      DropdownMenuItem(value: 'date', child: Text("Date d'ajout récente")),
                      DropdownMenuItem(value: 'risk', child: Text("Risque minimal")),
                      DropdownMenuItem(value: 'budget', child: Text("Budget détecté en premier")),
                    ],
                    onChanged: (val) {
                      setModalState(() => _sortBy = val ?? 'score');
                      setState(() => _sortBy = val ?? 'score');
                      _applyFiltersAndSort();
                    },
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Appliquer les Filtres"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChipFilter(StateSetter setModalState, String label, bool isSelected, Function action) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, top: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setModalState(() {
              action();
            });
            setState(() {
              action();
            });
            _applyFiltersAndSort();
          }
        },
        selectedColor: AppTheme.primaryColor,
        backgroundColor: AppTheme.cardColor,
      ),
    );
  }
}
