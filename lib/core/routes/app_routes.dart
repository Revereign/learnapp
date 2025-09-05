import 'package:flutter/material.dart';
import '../../presentation/pages/splash_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/child/main_menu/main_menu.dart';
import '../../presentation/pages/child/choose_level.dart';
import '../../presentation/pages/admin/admin_dashboard_page.dart';
import '../../presentation/pages/admin/add_sample_data_page.dart';
import '../../presentation/pages/parent/dashboard_page.dart' as parent;
import '../../presentation/pages/child/jadikan_sempurna_game_page.dart';
import '../../presentation/pages/child/leaderboard/leaderboard_level_selection_page.dart';
import '../../presentation/pages/child/leaderboard/leaderboard_page.dart';
import '../../presentation/pages/child/achievements/achievement_main_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String mainMenu = '/main-menu';
  static const String chooseLevel = '/choose-level';
  static const String adminDashboard = '/admin-dashboard';
  static const String addSampleData = '/add-sample-data';
  static const String parentDashboard = '/parent-dashboard';
  static const String jadikanSempurna = '/jadikan-sempurna';
  static const String leaderboard = '/leaderboard';
  static const String achievements = '/achievements';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case mainMenu:
        return MaterialPageRoute(builder: (_) => const MainMenuPage());
      case chooseLevel:
        return MaterialPageRoute(builder: (_) => const ChooseLevelPage(isParentUser: false));
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardPage());
      case addSampleData:
        return MaterialPageRoute(builder: (_) => const AddSampleDataPage());
      case parentDashboard:
        return MaterialPageRoute(builder: (_) => const parent.ParentDashboardPage());
      case jadikanSempurna:
        return MaterialPageRoute(
          builder: (_) => const JadikanSempurnaGamePage(level: 4),
        );
      case leaderboard:
        return MaterialPageRoute(
          builder: (_) => const LeaderboardLevelSelectionPage(),
        );
      case achievements:
        return MaterialPageRoute(
          builder: (_) => const AchievementMainPage(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
} 