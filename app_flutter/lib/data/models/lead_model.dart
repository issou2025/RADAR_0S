import 'dart:convert';

class LeadModel {
  final String id;
  final String title;
  final String description;
  final String source;
  final String sourceType;
  final String url;
  final String dateFound;
  final String publishedDate;
  final String language;
  final String country;
  final String serviceType;
  final String clientTemperature;
  final int score;
  final int riskScore;
  final String budgetDetected;
  final String recommendedPrice;
  final String recommendedAction;
  final List<String> keywordsDetected;
  final List<String> scoreReasons;
  final List<String> questionsToAsk;
  final String replyShort;
  final String replyProfessional;
  final String offerPage;
  final String proposalPath;
  final String status;
  final String notes;
  final String createdAt;
  final String updatedAt;
  final Map<String, String> replies;

  LeadModel({
    required this.id,
    required this.title,
    required this.description,
    required this.source,
    required this.sourceType,
    required this.url,
    required this.dateFound,
    required this.publishedDate,
    required this.language,
    required this.country,
    required this.serviceType,
    required this.clientTemperature,
    required this.score,
    required this.riskScore,
    required this.budgetDetected,
    required this.recommendedPrice,
    required this.recommendedAction,
    required this.keywordsDetected,
    required this.scoreReasons,
    required this.questionsToAsk,
    required this.replyShort,
    required this.replyProfessional,
    required this.offerPage,
    required this.proposalPath,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.replies,
  });

  LeadModel copyWith({
    String? status,
    String? notes,
    String? updatedAt,
  }) {
    return LeadModel(
      id: id,
      title: title,
      description: description,
      source: source,
      sourceType: sourceType,
      url: url,
      dateFound: dateFound,
      publishedDate: publishedDate,
      language: language,
      country: country,
      serviceType: serviceType,
      clientTemperature: clientTemperature,
      score: score,
      riskScore: riskScore,
      budgetDetected: budgetDetected,
      recommendedPrice: recommendedPrice,
      recommendedAction: recommendedAction,
      keywordsDetected: keywordsDetected,
      scoreReasons: scoreReasons,
      questionsToAsk: questionsToAsk,
      replyShort: replyShort,
      replyProfessional: replyProfessional,
      offerPage: offerPage,
      proposalPath: proposalPath,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      replies: replies,
    );
  }

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    // Parse helper for dynamic lists
    List<String> parseList(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
      return [];
    }

    // Parse helper for replies map
    Map<String, String> parseReplies(dynamic val) {
      if (val == null) return {};
      if (val is Map) {
        return val.map((key, value) => MapEntry(key.toString(), value.toString()));
      }
      return {};
    }

    return LeadModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      source: json['source'] ?? '',
      sourceType: json['source_type'] ?? '',
      url: json['url'] ?? '',
      dateFound: json['date_found'] ?? '',
      publishedDate: json['published_date'] ?? '',
      language: json['language'] ?? 'en',
      country: json['country'] ?? 'unknown',
      serviceType: json['service_type'] ?? 'UNKNOWN',
      clientTemperature: json['client_temperature'] ?? 'warm',
      score: json['score'] ?? 0,
      riskScore: json['risk_score'] ?? 0,
      budgetDetected: json['budget_detected'] ?? '',
      recommendedPrice: json['recommended_price'] ?? '',
      recommendedAction: json['recommended_action'] ?? '',
      keywordsDetected: parseList(json['keywords_detected']),
      scoreReasons: parseList(json['score_reasons']),
      questionsToAsk: parseList(json['questions_to_ask']),
      replyShort: json['reply_short'] ?? '',
      replyProfessional: json['reply_professional'] ?? '',
      offerPage: json['offer_page'] ?? '',
      proposalPath: json['proposal_path'] ?? '',
      status: json['status'] ?? 'new',
      notes: json['notes'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      replies: parseReplies(json['replies']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'source': source,
      'source_type': sourceType,
      'url': url,
      'date_found': dateFound,
      'published_date': publishedDate,
      'language': language,
      'country': country,
      'service_type': serviceType,
      'client_temperature': clientTemperature,
      'score': score,
      'risk_score': riskScore,
      'budget_detected': budgetDetected,
      'recommended_price': recommendedPrice,
      'recommended_action': recommendedAction,
      'keywords_detected': keywordsDetected,
      'score_reasons': scoreReasons,
      'questions_to_ask': questionsToAsk,
      'reply_short': replyShort,
      'reply_professional': replyProfessional,
      'offer_page': offerPage,
      'proposal_path': proposalPath,
      'status': status,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'replies': replies,
    };
  }

  // --- SQLITE MAPPER METHODS ---
  factory LeadModel.fromDbMap(Map<String, dynamic> map) {
    List<String> parseJsonList(String? jsonStr) {
      if (jsonStr == null || jsonStr.isEmpty) return [];
      try {
        return List<String>.from(jsonDecode(jsonStr));
      } catch (_) {
        return [];
      }
    }

    Map<String, String> parseJsonMap(String? jsonStr) {
      if (jsonStr == null || jsonStr.isEmpty) return {};
      try {
        final decoded = jsonDecode(jsonStr) as Map;
        return decoded.map((key, value) => MapEntry(key.toString(), value.toString()));
      } catch (_) {
        return {};
      }
    }

    return LeadModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      source: map['source'] ?? '',
      sourceType: map['source_type'] ?? '',
      url: map['url'] ?? '',
      dateFound: map['date_found'] ?? '',
      publishedDate: map['published_date'] ?? '',
      language: map['language'] ?? 'en',
      country: map['country'] ?? 'unknown',
      serviceType: map['service_type'] ?? 'UNKNOWN',
      clientTemperature: map['client_temperature'] ?? 'warm',
      score: map['score'] ?? 0,
      riskScore: map['risk_score'] ?? 0,
      budgetDetected: map['budget_detected'] ?? '',
      recommendedPrice: map['recommended_price'] ?? '',
      recommendedAction: map['recommended_action'] ?? '',
      keywordsDetected: parseJsonList(map['keywords_detected']),
      scoreReasons: parseJsonList(map['score_reasons']),
      questionsToAsk: parseJsonList(map['questions_to_ask']),
      replyShort: map['reply_short'] ?? '',
      replyProfessional: map['reply_professional'] ?? '',
      offerPage: map['offer_page'] ?? '',
      proposalPath: map['proposal_path'] ?? '',
      status: map['status'] ?? 'new',
      notes: map['notes'] ?? '',
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
      replies: parseJsonMap(map['replies']),
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'source': source,
      'source_type': sourceType,
      'url': url,
      'date_found': dateFound,
      'published_date': publishedDate,
      'language': language,
      'country': country,
      'service_type': serviceType,
      'client_temperature': clientTemperature,
      'score': score,
      'risk_score': riskScore,
      'budget_detected': budgetDetected,
      'recommended_price': recommendedPrice,
      'recommended_action': recommendedAction,
      'keywords_detected': jsonEncode(keywordsDetected),
      'score_reasons': jsonEncode(scoreReasons),
      'questions_to_ask': jsonEncode(questionsToAsk),
      'reply_short': replyShort,
      'reply_professional': replyProfessional,
      'offer_page': offerPage,
      'proposal_path': proposalPath,
      'status': status,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'replies': jsonEncode(replies),
    };
  }
}
