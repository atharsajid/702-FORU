/// Every route name in one place – no string literals scattered in screens.
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String main = '/main';

  // Auth
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String signUpRole = '/signup';
  static const String signUpUser = '/signup/user';
  static const String signUpProvider = '/signup/provider';
  static const String howItWorks = '/how-it-works';

  // Content
  static const String about = '/about';
  static const String notifications = '/notifications';
  static const String offers = '/offers';
  static const String search = '/search';
  static const String allCategories = '/categories';
  static const String category = '/category';
  static const String business = '/business';
  static const String writeReview = '/write-review';
  static const String spotlightInfo = '/spotlight';

  // Account
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String favorites = '/favorites';
  static const String settings = '/settings';

  // Provider
  static const String providerDashboard = '/provider';
  static const String businessEditor = '/provider/business';
  static const String providerCoupons = '/provider/coupons';
}
