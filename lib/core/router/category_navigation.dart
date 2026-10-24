import 'package:flutter/material.dart';

import '../../features/catalog/domain/entities/category.dart';
import 'app_routes.dart';

/// Category id that owns the dedicated free-attractions experience.
const String freeThingsCategoryId = 'free-things-to-do';

/// Opens a category, or the dedicated Free Things To Do listing for that
/// category. Keeps every entry point (home grid, all categories, search
/// shortcuts) consistent.
void openCategory(BuildContext context, Category category) {
  if (category.id == freeThingsCategoryId) {
    Navigator.of(context).pushNamed(AppRoutes.freeThings);
    return;
  }
  Navigator.of(context).pushNamed(AppRoutes.category, arguments: category);
}
