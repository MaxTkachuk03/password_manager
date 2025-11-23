import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String description;
  final Color color;
  final IconData icon;
  final int passwordCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    required this.id,
    required this.name,
    this.description = '',
    required this.color,
    required this.icon,
    this.passwordCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Category copyWith({
    String? id,
    String? name,
    String? description,
    Color? color,
    IconData? icon,
    int? passwordCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      passwordCount: passwordCount ?? this.passwordCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color.value.toString(), // Store as String for TEXT column
      'icon': icon.codePoint.toString(), // Store as String for TEXT column
      'password_count': passwordCount,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    // Handle both old format (ISO8601 strings) and new format (milliseconds)
    DateTime parseDateTime(dynamic value) {
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } else if (value is String) {
        return DateTime.parse(value);
      } else {
        return DateTime.now();
      }
    }

    // Parse color - handle both int and String
    int parseColor(dynamic value) {
      if (value is int) {
        return value;
      } else if (value is String) {
        return int.tryParse(value) ?? Colors.grey.value;
      } else {
        return Colors.grey.value;
      }
    }

    // Parse icon - handle both int and String
    int parseIcon(dynamic value) {
      if (value is int) {
        return value;
      } else if (value is String) {
        return int.tryParse(value) ?? Icons.category.codePoint;
      } else {
        return Icons.category.codePoint;
      }
    }

    // Parse passwordCount - handle both int and String
    int parsePasswordCount(dynamic value) {
      if (value is int) {
        return value;
      } else if (value is String) {
        return int.tryParse(value) ?? 0;
      } else {
        return 0;
      }
    }

    return Category(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      color: Color(parseColor(map['color'])),
      icon: IconData(parseIcon(map['icon']), fontFamily: 'MaterialIcons'),
      passwordCount: parsePasswordCount(map['password_count'] ?? map['passwordCount']),
      createdAt: parseDateTime(map['created_at'] ?? map['createdAt']),
      updatedAt: parseDateTime(map['updated_at'] ?? map['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        color,
        icon,
        passwordCount,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Category(id: $id, name: $name, passwordCount: $passwordCount)';
  }
}

// Predefined categories
class PredefinedCategories {
  static final List<Category> categories = [
    Category(
      id: 'social',
      name: 'Соціальні мережі',
      description: 'Акаунти в соціальних мережах',
      color: Colors.blue,
      icon: Icons.people,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
     Category(
      id: 'work',
      name: 'Робота',
      description: 'Робочі акаунти та сервіси',
      color: Colors.green,
      icon: Icons.work,
      createdAt:  DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'finance',
      name: 'Фінанси',
      description: 'Банківські акаунти та платіжні системи',
      color: Colors.orange,
      icon: Icons.account_balance,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'shopping',
      name: 'Покупки',
      description: 'Інтернет-магазини та торгові платформи',
      color: Colors.purple,
      icon: Icons.shopping_cart,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
     Category(
      id: 'entertainment',
      name: 'Розваги',
      description: 'Стрімінгові сервіси та ігри',
      color: Colors.red,
      icon: Icons.movie,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'health',
      name: 'Здоров\'я',
      description: 'Медичні сервіси та здоров\'я',
      color: Colors.teal,
      icon: Icons.local_hospital,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'email',
      name: 'Email',
      description: 'Електронні поштові скриньки',
      color: Colors.indigo,
      icon: Icons.email,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'other',
      name: 'Інше',
      description: 'Інші категорії',
      color: Colors.grey,
      icon: Icons.category,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  static Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<String> getCategoryNames() {
    return ['All', ...categories.map((category) => category.name)];
  }

  static String getIdByName(String name) {
    if (name == 'All') return 'All';
    
    final category = categories.firstWhere(
      (category) => category.name == name,
      orElse: () => categories.last,
    );
    return category.id;
  }
}