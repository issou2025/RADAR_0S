import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/lead_model.dart';
import '../../data/repositories/lead_repository.dart';

class KeywordLabScreen extends StatefulWidget {
  const KeywordLabScreen({super.key});

  @override
  State<KeywordLabScreen> createState() => _KeywordLabScreenState();
}

class _KeywordLabScreenState extends State<KeywordLabScreen> {
  final _leadRepo = LeadRepository();
  
  List<KeywordMetric> _metrics = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() => _isLoading = true);
    final leads = await _leadRepo.getAllLeads();
    
    // Parse keywords metrics dynamically
    final Map<String, List<LeadModel>> kwLeads = {};
    for (var l in leads) {
      for (var kw in l.keywordsDetected) {
        final key = kw.trim();
        if (key.isEmpty) continue;
        if (!kwLeads.containsKey(key)) {
          kwLeads[key] = [];
        }
        kwLeads[key]!.add(l);
      }
    }

    final List<KeywordMetric> computedMetrics = [];
    kwLeads.forEach((kw, matches) {
      final total = matches.length;
      final qualified = matches.where((l) => l.score >= 75).length;
      final won = matches.where((l) => l.status == 'won').length;
      
      final sumScores = matches.fold(0, (sum, l) => sum + l.score);
      final avgScore = total > 0 ? sumScores / total : 0.0;
      
      // Recommendation rules
      String recommendation;
      Color recColor;
      if (avgScore >= 75 && total >= 2) {
        recommendation = "Garder (Rentable)";
        recColor = AppTheme.success;
      } else if (avgScore < 50) {
        recommendation = "Supprimer (Bruit)";
        recColor = AppTheme.danger;
      } else {
        recommendation = "À affiner";
        recColor = AppTheme.warning;
      }

      computedMetrics.add(
        KeywordMetric(
          keyword: kw,
          leadsFound: total,
          qualifiedLeads: qualified,
          averageScore: avgScore,
          wonCount: won,
          profitability: won * 800, // 800 USD/EUR average job size
          recommendation: recommendation,
          recColor: recColor,
        ),
      );
    });

    // Sort by leads found descending
    computedMetrics.sort((a, b) => b.leadsFound.compareTo(a.leadsFound));

    setState(() {
      _metrics = computedMetrics;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laboratoire de Mots-Clés"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _metrics.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _metrics.length,
                  itemBuilder: (context, index) {
                    final metric = _metrics[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  metric.keyword,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: metric.recColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: metric.recColor.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    metric.recommendation,
                                    style: TextStyle(fontSize: 10, color: metric.recColor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            // Stats columns
                            Row(
                              children: [
                                _buildStatColumn("Prospects", "${metric.leadsFound}"),
                                _buildStatColumn("Qualifiés", "${metric.qualifiedLeads}"),
                                _buildStatColumn("Score Moyen", "${metric.averageScore.toStringAsFixed(1)}"),
                                _buildStatColumn("Gagnés", "${metric.wonCount}"),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: Color(0xFF1E2640), height: 1),
                            const SizedBox(height: 8),

                            // Profitability
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Chiffre d'Affaires estimé",
                                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                ),
                                Text(
                                  "${metric.profitability} € / \$",
                                  style: TextStyle(
                                    fontSize: 13, 
                                    fontWeight: FontWeight.bold, 
                                    color: metric.profitability > 0 ? AppTheme.success : AppTheme.textMuted
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("🔬", style: TextStyle(fontSize: 50)),
            const SizedBox(height: 16),
            const Text(
              "En attente de mots-clés",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Les métriques apparaîtront après avoir importé et qualifié des opportunités contenant vos mots-clés d'intention.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class KeywordMetric {
  final String keyword;
  final int leadsFound;
  final int qualifiedLeads;
  final double averageScore;
  final int wonCount;
  final int profitability;
  final String recommendation;
  final Color recColor;

  KeywordMetric({
    required this.keyword,
    required this.leadsFound,
    required this.qualifiedLeads,
    required this.averageScore,
    required this.wonCount,
    required this.profitability,
    required this.recommendation,
    required this.recColor,
  });
}
