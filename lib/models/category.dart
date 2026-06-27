import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String emoji;
  final Color color;

  CategoryModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    String? emoji,
    Color? color,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
    );
  }
}
