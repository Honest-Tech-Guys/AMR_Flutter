// lib/shared/models/equipment_model.dart
class Equipment {
  final int id;
  final String name;
  final String? icon;
  final String? serialNumber;
  final String? description;

  Equipment({
    required this.id,
    required this.name,
    this.serialNumber,
    this.icon,
    this.description,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'] as int,
      name: json['name'] as String,
      serialNumber: json['serial_number'] as String?,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
    );
  }
}
