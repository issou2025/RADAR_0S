class StatsModel {
  final int totalLeads;
  final int qualifiedLeads;
  final int veryHotLeads;
  final int contacted;
  final int won;
  final int lost;
  final int ignored;
  final List<String> bestSources;
  final List<String> bestKeywords;
  final List<String> bestServiceTypes;
  final double conversionRate;
  final double averageScore;
  final double averageRisk;
  final String weeklyReportSummary;

  StatsModel({
    required this.totalLeads,
    required this.qualifiedLeads,
    required this.veryHotLeads,
    required this.contacted,
    required this.won,
    required this.lost,
    required this.ignored,
    required this.bestSources,
    required this.bestKeywords,
    required this.bestServiceTypes,
    required this.conversionRate,
    required this.averageScore,
    required this.averageRisk,
    required this.weeklyReportSummary,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic val) {
      if (val is List) return val.map((e) => e.toString()).toList();
      return [];
    }

    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return StatsModel(
      totalLeads: json['total_leads'] ?? 0,
      qualifiedLeads: json['qualified_leads'] ?? 0,
      veryHotLeads: json['very_hot_leads'] ?? 0,
      contacted: json['contacted'] ?? 0,
      won: json['won'] ?? 0,
      lost: json['lost'] ?? 0,
      ignored: json['ignored'] ?? 0,
      bestSources: parseList(json['best_sources']),
      bestKeywords: parseList(json['best_keywords']),
      bestServiceTypes: parseList(json['best_service_types']),
      conversionRate: parseDouble(json['conversion_rate']),
      averageScore: parseDouble(json['average_score']),
      averageRisk: parseDouble(json['average_risk']),
      weeklyReportSummary: json['weekly_report_summary'] ?? '',
    );
  }

  factory StatsModel.empty() {
    return StatsModel(
      totalLeads: 0,
      qualifiedLeads: 0,
      veryHotLeads: 0,
      contacted: 0,
      won: 0,
      lost: 0,
      ignored: 0,
      bestSources: [],
      bestKeywords: [],
      bestServiceTypes: [],
      conversionRate: 0.0,
      averageScore: 0.0,
      averageRisk: 0.0,
      weeklyReportSummary: "Aucune donnée disponible. Lancez une synchronisation.",
    );
  }
}
