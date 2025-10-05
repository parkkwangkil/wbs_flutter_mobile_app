class Project {
  final int id;
  final String title;
  final String description;
  final String status;
  final String color;
  final int createdBy;
  final DateTime createdAt;

  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.color,
    required this.createdBy,
    required this.createdAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'active',
      color: json['color'] ?? 'blue',
      createdBy: json['created_by'] ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'color': color,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Project copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    String? color,
    int? createdBy,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      color: color ?? this.color,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Project(id: $id, title: $title, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Project && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
