import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/business_search_view.dart';

/// Full-screen search, opened from the Home search bar or the Spotlight
/// "Browse" action.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Search')),
      body: BusinessSearchView(autofocus: true),
    );
  }
}
