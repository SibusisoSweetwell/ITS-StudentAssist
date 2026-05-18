/*
Group: GROUP_A
Members:
- Sibusiso Sweetwell Masombuka - 223021992
- Sibonelo Nkosikhona Shabalala - 222086498
- Khanyile Simphiwe Chaka - 222028298
- Neo Moeketsi Motseki - 223061469
- Dan Khoza - 223062645
- Bonolo Olifant - 223016901
- Rekopantswe Molefe - 223065272
- Skhumbuzo Kgethe - 222000496
- Lesedi Setuke - 222009442
- Tshego Malope - 222017305
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'services/supabase_service.dart';
import 'viewmodels/admin_review_viewmodel.dart';
import 'viewmodels/application_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/reference_data_viewmodel.dart';
import 'views/screens/access_denied_screen.dart';
import 'views/screens/admin_review_detail_screen.dart';
import 'views/screens/admin_dashboard_screen.dart';
import 'views/screens/admin_review_list_screen.dart';
import 'views/screens/application_form_screen.dart';
import 'views/screens/login_screen.dart';
import 'views/screens/my_application_detail_screen.dart';
import 'views/screens/profile_screen.dart';
import 'views/screens/register_screen.dart';
import 'views/screens/student_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? startupError;
  try {
    await SupabaseService.initialize();
  } catch (error) {
    startupError = error.toString();
  }
  runApp(MyApp(startupError: startupError));
}

class MyApp extends StatelessWidget {
  final String? startupError;

  const MyApp({super.key, this.startupError});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ApplicationViewModel()),
        ChangeNotifierProvider(create: (_) => ReferenceDataViewModel()),
        ChangeNotifierProvider(create: (_) => AdminReviewViewModel()),
      ],
      child: startupError == null
          ? MaterialApp(
              title: 'Student Assistant App',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              routes: {
                AppRoutes.login: (context) => const LoginScreen(),
                AppRoutes.register: (context) => const RegisterScreen(),
                AppRoutes.accessDenied: (context) => const AccessDeniedScreen(),
              },
              onGenerateRoute: (settings) {
                final name = settings.name;
                final user = SupabaseService.client.auth.currentUser;

                // Protect these routes from unauthenticated access
                switch (name) {
                  case AppRoutes.studentDashboard:
                  case AppRoutes.applicationForm:
                  case AppRoutes.myApplicationDetail:
                  case AppRoutes.profile:
                    if (user == null) {
                      return MaterialPageRoute<void>(
                        settings: RouteSettings(
                          name: name,
                          arguments: <String, dynamic>{
                            'message': 'You must be logged in to view this page.',
                            'blockedResource': name ?? 'protected route',
                          },
                        ),
                        builder: (context) => const AccessDeniedScreen(),
                      );
                    }
                    break;
                  case AppRoutes.adminDashboard:
                  case AppRoutes.adminReviewList:
                  case AppRoutes.adminReviewDetail:
                    if (user == null) {
                      return MaterialPageRoute<void>(
                        settings: RouteSettings(
                          name: name,
                          arguments: <String, dynamic>{
                            'message': 'Admin access requires login.',
                            'blockedResource': name ?? 'admin route',
                          },
                        ),
                        builder: (context) => const AccessDeniedScreen(),
                      );
                    }
                    break;
                }

                // Fall back to default behavior for known routes
                if (name == AppRoutes.studentDashboard) {
                  return MaterialPageRoute<void>(
                      settings: settings,
                      builder: (context) => const StudentDashboardScreen());
                }
                if (name == AppRoutes.applicationForm) {
                  return MaterialPageRoute<void>(
                      settings: settings,
                      builder: (context) => const ApplicationFormScreen());
                }
                if (name == AppRoutes.myApplicationDetail) {
                  return MaterialPageRoute<void>(
                      settings: settings,
                      builder: (context) => const MyApplicationDetailScreen());
                }
                if (name == AppRoutes.adminDashboard) {
                  return MaterialPageRoute<void>(
                      settings: settings,
                      builder: (context) => const AdminDashboardScreen());
                }
                if (name == AppRoutes.adminReviewList) {
                  return MaterialPageRoute<void>(
                      settings: settings,
                      builder: (context) => const AdminReviewListScreen());
                }
                if (name == AppRoutes.adminReviewDetail) {
                  return MaterialPageRoute<void>(
                      settings: settings,
                      builder: (context) => const AdminReviewDetailScreen());
                }
                if (name == AppRoutes.profile) {
                  return MaterialPageRoute<void>(
                      settings: settings,
                      builder: (context) => const ProfileScreen());
                }

                // Let onUnknownRoute handle anything else (will show 403)
                return null;
              },
              onUnknownRoute: (settings) {
                final blockedResource = settings.name ?? 'unknown route';
                return MaterialPageRoute<void>(
                  settings: RouteSettings(
                    name: settings.name,
                    arguments: <String, dynamic>{
                      'message':
                          'The page you requested is not available in this application.',
                      'blockedResource': blockedResource,
                    },
                  ),
                  builder: (context) => const AccessDeniedScreen(),
                );
              },
            )
          : MaterialApp(
              title: 'Student Assistant App',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              home: _StartupErrorScreen(message: startupError!),
            ),
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  final String message;

  const _StartupErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuration Required')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App could not start because Supabase settings are missing.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(message),
                const SizedBox(height: 12),
                const Text(
                  'Run with:\n'
                  'flutter run -d chrome --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
