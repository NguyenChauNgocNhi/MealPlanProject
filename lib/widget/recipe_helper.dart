import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Trả về icon tương ứng với loại bữa ăn
IconData getMealIcon(String? category) {
  switch (category) {
    case 'breakfast':
      return Icons.free_breakfast;
    case 'lunch':
      return Icons.lunch_dining;
    case 'dinner':
      return Icons.dinner_dining;
    case 'snack':
      return Icons.fastfood;
    default:
      return Icons.restaurant;
  }
}

// Hiển thị ảnh món ăn từ nhiều nguồn khác nhau, đảm bảo không bị crash nếu ảnh lỗi
Widget buildRecipeImage(
  String? path,
  String? category, {
  double width = 56,
  double height = 56,
}) {
  final fallback = Image.asset(
    'assets/images/no_image.jpg',
    width: width,
    height: height,
    fit: BoxFit.cover,
  );

  if (path == null || path.trim().isEmpty) return fallback;

  final trimmed = path.trim();

  // Nếu path bắt đầu bằng assets/
  if (trimmed.startsWith('assets/')) {
    return Image.asset(trimmed, width: width, height: height, fit: BoxFit.cover);
  }

  // Nếu path chỉ là tên file (ví dụ canhmangkho.jpg), tự động thêm prefix assets/images/
  if (!trimmed.contains('://') && !trimmed.startsWith('/')) {
    final assetPath = 'assets/images/$trimmed';
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    );
  }

  // File nội bộ (Mobile)
  if (trimmed.startsWith('/') && !kIsWeb) {
    final file = File(trimmed);
    if (file.existsSync()) {
      return Image.file(file, width: width, height: height, fit: BoxFit.cover);
    }
    return fallback;
  }

  // Base64 (Web)
  if (trimmed.length > 100) {
    try {
      final bytes = base64Decode(trimmed);  // Giải mã bằng base64Decode
      return Image.memory(bytes, width: width, height: height, fit: BoxFit.cover);
    } catch (_) {
      return fallback;
    }
  }

  // URL ảnh
  return Image.network(
    trimmed,
    width: width,
    height: height,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => fallback,
  ); 
}
