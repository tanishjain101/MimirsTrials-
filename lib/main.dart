import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/course_provider.dart';
import 'providers/achievement_provider.dart';
import 'providers/offline_provider.dart';
import 'providers/lesson_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/trophy_provider.dart';
import 'providers/social_provider.dart';
import 'providers/project_provider.dart';
import 'providers/career_provider.dart';
import 'providers/admin_panel_provider.dart';
import 'providers/mastery_provider.dart';
import 'providers/ai_provider.dart';
import 'providers/quest_provider.dart';
import 'providers/sync_provider.dart';
import 'providers/certificate_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/map/course_map_screen.dart';
import 'screens/achievements/achievements_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/lesson_screen.dart';
import 'screens/analytics/analytics_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/fun_corner.dart';
import 'screens/publish_screen.dart';
import 'screens/trophy_lab_screen.dart';
import 'screens/role_auth_screen.dart';
import 'screens/teacher/teacher_home_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/social/social_hub_screen.dart';
import 'screens/playground/coding_playground_screen.dart';
import 'screens/portfolio/portfolio_screen.dart';
import 'screens/career/career_paths_screen.dart';
import 'screens/ai_tutor/ai_tutor_screen.dart';
import 'screens/ai_tutor/ai_debugger_screen.dart';
import 'screens/ai_tutor/ai_project_builder_screen.dart';
import 'screens/rewards/reward_store_screen.dart';
import 'screens/simulation/simulation_screen.dart';
import 'screens/offline/offline_resources_screen.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}
  // Firebase initialization disabled - uncomment when Firebase is configured
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
        ChangeNotifierProvider(create: (_) => OfflineProvider()),
        ChangeNotifierProvider(create: (_) => LessonProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => TrophyProvider()),
        ChangeNotifierProvider(create: (_) => AIProvider()),
        ChangeNotifierProvider(create: (_) => SocialProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => CareerProvider()),
        ChangeNotifierProvider(create: (_) => MasteryProvider()),
        ChangeNotifierProvider(create: (_) => AdminPanelProvider()),
        ChangeNotifierProvider(create: (_) => QuestProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
        ChangeNotifierProvider(create: (_) => CertificateProvider()),
      ],
      child: MaterialApp(
        title: 'MimirsTrials',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Poppins',
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.surface,
            error: AppColors.error,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.text,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.surfaceAlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            hintStyle: const TextStyle(color: AppColors.textMuted),
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/learn': (context) => const LearnScreen(),
          '/map': (context) => const CourseMapScreen(),
          '/achievements': (context) => const AchievementsScreen(),
          '/leaderboard': (context) => const LeaderboardScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/analytics': (context) => const AnalyticsScreen(),
          '/lesson': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            return LessonScreen(lessonId: args is String ? args : 'html_intro');
          },
          '/quiz': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            return QuizScreen(quizId: args is String ? args : 'html_quiz');
          },
          '/fun-corner': (context) => const FunCorner(),
          '/publish': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            if (args is Map) {
              final tabIndex = args['tabIndex'];
              final lessonCategory = args['lessonCategory'];
              final quizCategory = args['quizCategory'];
              return PublishScreen(
                initialTabIndex: tabIndex is int ? tabIndex : 0,
                initialLessonCategory:
                    lessonCategory is String ? lessonCategory : null,
                initialQuizCategory:
                    quizCategory is String ? quizCategory : null,
              );
            }
            return PublishScreen(initialTabIndex: args is int ? args : 0);
          },
          '/trophy-lab': (context) => const TrophyLabScreen(),
          '/teacher-auth': (context) => const TeacherAuthScreen(),
          '/admin-auth': (context) => const AdminAuthScreen(),
          '/teacher-home': (context) => const TeacherHomeScreen(),
          '/admin-home': (context) => const AdminHomeScreen(),
          '/social': (context) => const SocialHubScreen(),
          '/playground': (context) => const CodingPlaygroundScreen(),
          '/portfolio': (context) => const PortfolioScreen(),
          '/career-paths': (context) => const CareerPathsScreen(),
          '/ai-tutor': (context) => const AITutorScreen(),
          '/ai-debugger': (context) => const AIDebuggerScreen(),
          '/ai-project-builder': (context) => const AIProjectBuilderScreen(),
          '/rewards': (context) => const RewardStoreScreen(),
          '/simulation': (context) => const SimulationScreen(),
          '/offline-resources': (context) => const OfflineResourcesScreen(),
        },
      ),
    );
  }
}
