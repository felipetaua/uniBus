import 'package:flutter/material.dart';
import 'colors.dart'; 

class AppTextStyles {
  // Tema claro
  static const TextStyle lightTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.lightTextPrimary,
  );

  static const TextStyle lightBody = TextStyle(
    fontSize: 16,
    color: AppColors.lightTextPrimary,
  );

  // Tema escuro
  static const TextStyle darkTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.darkTextPrimary,
  );

  static const TextStyle darkBody = TextStyle(
    fontSize: 16,
    color: AppColors.darkTextPrimary,
  );
}