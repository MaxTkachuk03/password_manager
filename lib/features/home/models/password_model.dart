import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Password extends Equatable {
  final String id;
  final String title;
  final String username;
  final String password;
  final String website;
  final String notes;
  final String categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final int strength;
  final List<String> tags;

  const Password({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    required this.website,
    this.notes = '',
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.strength = 0,
    this.tags = const [],
  });

  Password copyWith({
    String? id,
    String? title,
    String? username,
    String? password,
    String? website,
    String? notes,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    int? strength,
    List<String>? tags,
  }) {
    return Password(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      website: website ?? this.website,
      notes: notes ?? this.notes,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      strength: strength ?? this.strength,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
      'website': website,
      'notes': notes,
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite ? 1 : 0,
      'strength': strength,
      'tags': tags.join(','),
    };
  }

  factory Password.fromMap(Map<String, dynamic> map) {
    return Password(
      id: map['id'],
      title: map['title'],
      username: map['username'],
      password: map['password'],
      website: map['website'],
      notes: map['notes'] ?? '',
      categoryId: map['categoryId'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isFavorite: (map['isFavorite'] ?? 0) == 1,
      strength: map['strength'] ?? 0,
      tags: (map['tags'] as String? ?? '').split(',').where((tag) => tag.isNotEmpty).toList(),
    );
  }

  static int calculateStrength(String password) {
    int score = 0;
    
    // Length check
    if (password.length >= 8) score += 1;
    if (password.length >= 12) score += 1;
    if (password.length >= 16) score += 1;
    
    // Character variety
    if (password.contains(RegExp(r'[a-z]'))) score += 1;
    if (password.contains(RegExp(r'[A-Z]'))) score += 1;
    if (password.contains(RegExp(r'[0-9]'))) score += 1;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 1;
    
    return score.clamp(0, 5);
  }

  String get strengthText {
    switch (strength) {
      case 0:
      case 1:
        return 'Дуже слабкий';
      case 2:
        return 'Слабкий';
      case 3:
        return 'Середній';
      case 4:
        return 'Сильний';
      case 5:
        return 'Дуже сильний';
      default:
        return 'Невідомо';
    }
  }

  Color get strengthColor {
    switch (strength) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        username,
        password,
        website,
        notes,
        categoryId,
        createdAt,
        updatedAt,
        isFavorite,
        strength,
        tags,
      ];

  @override
  String toString() {
    return 'Password(id: $id, title: $title, username: $username, website: $website)';
  }
}

