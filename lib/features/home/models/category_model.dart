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
      'color': color.value,
      'icon': icon.codePoint,
      'passwordCount': passwordCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      color: Color(map['color']),
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
      passwordCount: map['passwordCount'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
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