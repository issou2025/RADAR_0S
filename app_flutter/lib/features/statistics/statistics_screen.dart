import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/stats_model.dart';
import '../../data/repositories/lead_repository.dart';
import '../../data/repositories/sync_repository.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _leadRepo = LeadRepository();
  final _syncRepo = SyncRepository();

  StatsModel _stats = StatsModel.empty();
  bool _isLoading = false;

  int _totalLeads = 0;
  Map<String, int> _leadsBySource = {};
  Map<String, int> _leadsByService = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    
    final stats = await _syncRepo.getStats();
    final leads = await _leadRepo.getAllLeads();

    // Compute charts data locally
    final Map<String, int> sourceCounts = {};
    final Map<String, int> serviceCounts = {};
    for (var l in leads) {
      sourceCounts[l.source] = (sourceCounts[l.source] ?? 0) + 1;
      serviceCounts[l.serviceType] = (serviceCounts[l.serviceType] ?? 0) + 1;
    }

    setState(() {
      _stats = stats;
      _totalLeads = leads.length;
      _leadsBySource = sourceCounts;
      _leadsByService = serviceCounts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistiques Commerciales"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary Report Card
                _buildSummaryReportCard(),
                const SizedBox(height: 24),

                // Funnel / Conversion Metrics
                const Text(
                  "Tunnel de Conversion",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                ),
                const SizedBox(height: 12),
                _buildConversionMetrics(),
                const SizedBox(height: 24),

                // Distribution by Source
                const Text(
                  "Opportunités par Source",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                ),
                const SizedBox(height: 12),
                _buildSourceDistribution(),
                const SizedBox(height: 24),

                // Distribution by Service
                const Text(
                  "Opportunités par Service",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                ),
                const SizedBox(height: 12),
                _buildServiceDistribution(),
                const SizedBox(height: 40),
              ],
            ),
    );
  }

  Widget _buildSummaryReportCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E2640)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description_outlined, color: AppTheme.primaryColor),
              SizedBox(width: 10),
              Text(
                "Rapport hebdomadaire du radar",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _stats.weeklyReportSummary.isNotEmpty 
                ? _stats.weeklyReportSummary 
                : "Lancez une synchronisation avec GitHub pour récupérer le dernier rapport rédigé par le script d'automatisation.",
            style: const TextStyle(color: AppTheme.textSecondary, height: 1.4, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildConversionMetrics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E2640)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFittedStat("Opportunités", "$_totalLeads", AppTheme.info),
              _buildFittedStat("Qualifiées", "${_stats.qualifiedLeads}", AppTheme.warning),
              _buildFittedStat("Contactées", "${_stats.contacted}", AppTheme.primaryColor),
              _buildFittedStat("Gagnées", "${_stats.won}", AppTheme.success),
            ],
          ),
          const SizedBox(height: 20),
          // Progress ratio visual representation
          Row(
            children: [
              const Text("Taux de conversion : ", style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              const Spacer(),
              Text(
                "${_stats.conversionRate.toStringAsFixed(1)} %",
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.success, fontSize: 16),
              )
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _stats.conversionRate > 0 ? _stats.conversionRate / 100 : 0,
              backgroundColor: const Color(0xFF1E2640),
              color: AppTheme.success,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFittedStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted), textAlign: Center),
        ],
      ),
    );
  }

  Widget _buildSourceDistribution() {
    if (_leadsBySource.isEmpty) {
      return const Center(child: Text("Aucune opportunité triée par source."));
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E2640)),
      ),
      child: Column(
        children: _leadsBySource.entries.map((entry) {
          final ratio = _totalLeads > 0 ? entry.value / _totalLeads : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: const TextStyle(fontSize: 13)),
                    Text("${entry.value} (${(ratio * 100).toStringAsFixed(0)}%)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: const Color(0xFF1E2640),
                    color: AppTheme.primaryColor,
                    minHeight: 6,
                  ),
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildServiceDistribution() {
    if (_leadsByService.isEmpty) {
      return const Center(child: Text("Aucune opportunité classée par service."));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E2640)),
      ),
      child: Column(
        children: _leadsByService.entries.map((entry) {
          final ratio = _totalLeads > 0 ? entry.value / _totalLeads : 0.0;
          final serviceLabel = AppConstants.serviceLabels[entry.key] ?? entry.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(serviceLabel, style: const TextStyle(fontSize: 13)),
                    Text("${entry.value} (${(ratio * 100).toStringAsFixed(0)}%)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: const Color(0xFF1E2640),
                    color: AppTheme.secondaryColor,
                    minHeight: 6,
                  ),
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
