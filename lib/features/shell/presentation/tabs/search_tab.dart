import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../catalog/presentation/widgets/business_search_view.dart';

/// Bottom-nav search destination – thin wrapper around [BusinessSearchView].
class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(bottom: false, child: BusinessSearchView()),
    );
  }
}
