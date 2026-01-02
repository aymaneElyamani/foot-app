class Area {
  const Area({required this.id, required this.name, required this.code});

  final int id;
  final String name;
  final String code;

  factory Area.fromMap(Map<String, dynamic> map) {
    return Area(
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: (map['name'] as String?) ?? '',
      code: (map['code'] as String?) ?? '',
    );
  }
}

class Competition {
  const Competition({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.emblem,
    required this.area,
  });

  final int id;
  final String name;
  final String code;
  final String type;
  final String emblem;
  final Area area;

  factory Competition.fromMap(Map<String, dynamic> map) {
    return Competition(
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: (map['name'] as String?) ?? '',
      code: (map['code'] as String?) ?? '',
      type: (map['type'] as String?) ?? '',
      emblem: (map['emblem'] as String?) ?? '',
      area: Area.fromMap((map['area'] as Map<String, dynamic>?) ?? const {}),
    );
  }
}
