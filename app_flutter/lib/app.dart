import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/settings/github_settings_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/leads/lead_feed_screen.dart';
import 'features/pipeline/pipeline_screen.dart';
import 'features/reply_studio/reply_studio_screen.dart';
import 'features/offer_pages/offer_pages_screen.dart';
import 'features/keyword_lab/keyword_lab_screen.dart';
import 'features/statistics/statistics_screen.dart';
import 'features/settings/settings_screen.dart';

class ClientRadarApp extends StatelessWidget {
  const ClientRadarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Client Radar OS",
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default dark mode as requested
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/github_settings': (context) => const GithubSettingsScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/leads': (context) => const LeadFeedScreen(),
        '/pipeline': (context) => const PipelineScreen(),
        '/reply_studio': (context) => const ReplyStudioScreen(),
        '/offer_pages': (context) => const OfferPagesScreen(),
        '/keyword_lab': (context) => const KeywordLabScreen(),
        '/statistics': (context) => const StatisticsScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
