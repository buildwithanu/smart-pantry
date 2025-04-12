import 'package:uuid/uuid.dart';

class PantryItem {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final String category;
  final DateTime dateAdded;
  final DateTime? expiryDate;
  final String? notes;

  PantryItem({
    String? id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    DateTime? dateAdded,
    this.expiryDate,
    this.notes,
  })  : id = id ?? const Uuid().v4(),
        dateAdded = dateAdded ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'category': category,
      'dateAdded': dateAdded.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'notes': notes,
    };
  }

  factory PantryItem.fromMap(Map<String, dynamic> map) {
    return PantryItem(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'].toDouble(),
      unit: map['unit'],
      category: map['category'],
      dateAdded: DateTime.parse(map['dateAdded']),
      expiryDate: map['expiryDate'] != null ? DateTime.parse(map['expiryDate']) : null,
      notes: map['notes'],
    );
  }
} 