import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/lead_model.dart';
import '../../data/repositories/lead_repository.dart';
import '../lead_detail/lead_detail_screen.dart';

class PipelineScreen extends StatefulWidget {
  const PipelineScreen({super.key});

  @override
  State<PipelineScreen> createState() => _PipelineScreenState();
}

class _PipelineScreenState extends State<PipelineScreen> {
  final _leadRepo = LeadRepository();
  
  List<LeadModel> _allLeads = [];
  bool _isLoading = false;

  final List<String> _columns = [
    'new',
    'viewed',
    'contacted',
    'follow_up_needed',
    'negotiation',
    'won',
    'lost',
    'ignored'
  ];

  final Map<String, String> _columnLabels = {
    'new': 'Nouveau',
    'viewed': 'À répondre',
    'contacted': 'Contacté',
    'follow_up_needed': 'Relance',
    'negotiation': 'Négociation',
    'won': 'Gagné 🏆',
    'lost': 'Perdu ❌',
    'ignored': 'Ignoré',
  };

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
    });
  }

  Future<void> _moveLead(String leadId, String newStatus) async {
    await _leadRepo.updateLeadStatus(leadId, newStatus);
    _loadLeads();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pipeline Kanban"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLeads,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return PageView.builder(
                  itemCount: _columns.length,
                  controller: PageController(viewportFraction: 0.82),
                  itemBuilder: (context, index) {
                    final col = _columns[index];
                    final colLeads = _allLeads.where((l) => l.status == col).toList();
                    return _buildKanbanColumn(col, colLeads);
                  },
                );
              },
            ),
    );
  }

  Widget _buildKanbanColumn(String columnKey, List<LeadModel> leads) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E2640), width: 1.5),
      ),
      child: Column(
        children: [
          // Column Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1E2640), width: 1.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _columnLabels[columnKey] ?? columnKey,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Outfit'),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${leads.length}",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                )
              ],
            ),
          ),

          // Column Leads List
          Expanded(
            child: leads.isEmpty
                ? _buildEmptyColumnState()
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: leads.length,
                    itemBuilder: (context, index) {
                      final lead = leads[index];
                      return _buildKanbanCard(lead);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyColumnState() {
    return const Center(
      child: Text(
        "Vide",
        style: TextStyle(color: AppTheme.textMuted),
      ),
    );
  }

  Widget _buildKanbanCard(LeadModel lead) {
    return Card(
      color: AppTheme.cardColor,
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
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lead.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Score: ${lead.score}",
                    style: TextStyle(
                      fontSize: 11,
                      color: lead.score >= 80 ? AppTheme.success : AppTheme.textSecondary,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    lead.source,
                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              // Move Status Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.swap_horiz, size: 18, color: AppTheme.primaryColor),
                    tooltip: "Déplacer",
                    onSelected: (newStatus) => _moveLead(lead.id, newStatus),
                    itemBuilder: (context) {
                      return _columns.where((c) => c != lead.status).map((col) {
                        return PopupMenuItem<String>(
                          value: col,
                          child: Text(_columnLabels[col] ?? col),
                        );
                      }).toList();
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
