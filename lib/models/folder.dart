class Folder {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<String> traceIds;

  const Folder({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.traceIds,
  });

  Folder withAdded(String traceId) {
    if (traceIds.contains(traceId)) {
      return Folder(
        id: id,
        name: name,
        createdAt: createdAt,
        traceIds: [...traceIds],
      );
    }
    return Folder(
      id: id,
      name: name,
      createdAt: createdAt,
      traceIds: [...traceIds, traceId],
    );
  }

  Folder withRemoved(String traceId) {
    return Folder(
      id: id,
      name: name,
      createdAt: createdAt,
      traceIds: traceIds.where((t) => t != traceId).toList(),
    );
  }

  Folder renamed(String newName) =>
      Folder(id: id, name: newName, createdAt: createdAt, traceIds: traceIds);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'traceIds': traceIds,
  };

  factory Folder.fromJson(Map<String, dynamic> json) => Folder(
    id: json['id'] as String,
    name: json['name'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    traceIds: List<String>.from(json['traceIds'] ?? const []),
  );
}
