class SessionGoal {
  final String id;
  final String templateId;
  final String title;
  final String subtitle;
  final int target;
  final int progress;
  final int rewardXp;
  final bool completed;
  final bool rewarded;
  final String dateKey;
  final Map<String, dynamic> metadata;

  const SessionGoal({
    required this.id,
    required this.templateId,
    required this.title,
    required this.subtitle,
    required this.target,
    required this.progress,
    required this.rewardXp,
    required this.completed,
    required this.rewarded,
    required this.dateKey,
    required this.metadata,
  });

  SessionGoal copyWith({
    String? id,
    String? templateId,
    String? title,
    String? subtitle,
    int? target,
    int? progress,
    int? rewardXp,
    bool? completed,
    bool? rewarded,
    String? dateKey,
    Map<String, dynamic>? metadata,
  }) {
    return SessionGoal(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      rewardXp: rewardXp ?? this.rewardXp,
      completed: completed ?? this.completed,
      rewarded: rewarded ?? this.rewarded,
      dateKey: dateKey ?? this.dateKey,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'templateId': templateId,
      'title': title,
      'subtitle': subtitle,
      'target': target,
      'progress': progress,
      'rewardXp': rewardXp,
      'completed': completed,
      'rewarded': rewarded,
      'dateKey': dateKey,
      'metadata': metadata,
    };
  }

  factory SessionGoal.fromJson(Map<String, dynamic> json) {
    return SessionGoal(
      id: json['id'] as String,
      templateId: json['templateId'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      target: json['target'] as int,
      progress: json['progress'] as int,
      rewardXp: json['rewardXp'] as int,
      completed: json['completed'] as bool,
      rewarded: json['rewarded'] as bool,
      dateKey: json['dateKey'] as String,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}