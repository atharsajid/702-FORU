import 'package:flutter/material.dart';

import '../../features/about/presentation/screens/about_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/how_it_works_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_provider_screen.dart';
import '../../features/auth/presentation/screens/signup_role_screen.dart';
import '../../features/auth/presentation/screens/signup_user_screen.dart';
import '../../features/catalog/domain/entities/category.dart';
import '../../features/catalog/presentation/screens/all_categories_screen.dart';
import '../../features/catalog/presentation/screens/business_screen.dart';
import '../../features/catalog/presentation/screens/category_screen.dart';
import '../../features/catalog/presentation/screens/write_review_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/offers/presentation/screens/offers_screen.dart';
import '../../features/offers/presentation/screens/spotlight_info_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/favorites_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/provider/presentation/screens/business_editor_screen.dart';
import '../../features/provider/presentation/screens/provider_coupons_screen.dart';
import '../../features/provider/presentation/screens/provider_dashboard_screen.dart';
import '../../features/shell/presentation/screens/main_shell.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../utils/responsive.dart';
import 'app_routes.dart';

/// Single place that knows how to build every screen.
///
/// Using [Navigator.onGenerateRoute] (rather than a routing package) keeps the
/// app dependency-free while still centralising navigation and argument
/// handling.
class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _page(const SplashScreen(), settings);

      case AppRoutes.main:
        return _page(const MainShell(), settings);

      case AppRoutes.about:
        return _page(const AboutScreen(), settings);

      // ── Auth ───────────────────────────────────────────────────────────
      case AppRoutes.login:
        return _page(const LoginScreen(), settings);
      case AppRoutes.forgotPassword:
        return _page(const ForgotPasswordScreen(), settings);
      case AppRoutes.signUpRole:
        return _page(const SignUpRoleScreen(), settings);
      case AppRoutes.signUpUser:
        return _page(const SignUpUserScreen(), settings);
      case AppRoutes.signUpProvider:
        return _page(const SignUpProviderScreen(), settings);
      case AppRoutes.howItWorks:
        return _page(const HowItWorksScreen(), settings);

      // ── Content ────────────────────────────────────────────────────────
      case AppRoutes.notifications:
        return _page(const NotificationsScreen(), settings);
      case AppRoutes.offers:
        return _page(const OffersScreen(), settings);
      case AppRoutes.spotlightInfo:
        return _page(const SpotlightInfoScreen(), settings);
      case AppRoutes.allCategories:
        return _page(const AllCategoriesScreen(), settings);

      case AppRoutes.category:
        final category = _arg<Category>(settings);
        if (category == null) return _missingArgument(settings);
        return _page(CategoryScreen(category: category), settings);

      case AppRoutes.business:
        final businessId = _arg<String>(settings);
        if (businessId == null) return _missingArgument(settings);
        return _page(BusinessScreen(businessId: businessId), settings);

      case AppRoutes.writeReview:
        final businessId = _arg<String>(settings);
        if (businessId == null) return _missingArgument(settings);
        return _page(WriteReviewScreen(businessId: businessId), settings);

      // ── Account ────────────────────────────────────────────────────────
      case AppRoutes.favorites:
        return _page(const FavoritesScreen(), settings);
      case AppRoutes.settings:
        return _page(const SettingsScreen(), settings);
      case AppRoutes.editProfile:
        return _page(const EditProfileScreen(), settings);

      // ── Provider ───────────────────────────────────────────────────────
      case AppRoutes.providerDashboard:
        return _page(const ProviderDashboardScreen(), settings);
      case AppRoutes.businessEditor:
        return _page(const BusinessEditorScreen(), settings);
      case AppRoutes.providerCoupons:
        return _page(const ProviderCouponsScreen(), settings);

      default:
        return _page(const _UnknownRouteScreen(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _page(Widget child, RouteSettings settings) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => child,
      settings: settings,
    );
  }

  /// Safe argument extraction – never throws on a bad or missing argument.
  static T? _arg<T>(RouteSettings settings) {
    final arguments = settings.arguments;
    return arguments is T ? arguments : null;
  }

  static Route<dynamic> _missingArgument(RouteSettings settings) => _page(
        const _MissingArgumentScreen(),
        settings,
      );
}

/// Shown when a route name does not exist (should never happen in practice).
class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Not found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Text(
            'We could not find that page.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ),
    );
  }
}

/// Shown when a route is opened without its required argument.
class _MissingArgumentScreen extends StatelessWidget {
  const _MissingArgumentScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Something went wrong')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(context.pagePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'This page needs more information to open.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
