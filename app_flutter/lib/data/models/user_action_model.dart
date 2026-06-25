class UserActionModel {
  final int? id;
  final String leadId;
  final String action;
  final String value;
  final String timestamp;

  UserActionModel({
    this.id,
    required this.leadId,
    required this.action,
    required this.value,
    required this.timestamp,
  });

  factory UserActionModel.fromJson(Map<String, dynamic> json) {
    return UserActionModel(
      id: json['id'],
      leadId: json['lead_id'] ?? '',
      action: json['action'] ?? '',
      value: json['value'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lead_id': leadId,
      'action': action,
      'value': value,
      'timestamp': timestamp,
    };
  }

  factory UserActionModel.fromMap(Map<String, dynamic> map) {
    return UserActionModel(
      id: map['id'],
      leadId: map['lead_id'] ?? '',
      action: map['action'] ?? '',
      value: map['value'] ?? '',
      timestamp: map['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'lead_id': leadId,
      'action': action,
      'value': value,
      'timestamp': timestamp,
    };
    if (id != null) {
      map['id'] = id as String; // standard db field mapping
    }
    return map;
  }
}
