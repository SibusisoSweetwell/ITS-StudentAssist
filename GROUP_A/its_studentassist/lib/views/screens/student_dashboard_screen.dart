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

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/application.dart';
import '../../models/profile.dart';
import '../../services/supabase_service.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../widgets/app_background.dart';
import '../widgets/app_card.dart';
import '../widgets/app_reveal.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  late Future<Profile?> _profileFuture;
  late Future<Application?> _applicationFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = context.read<AuthViewModel>().fetchCurrentUserProfile();
    _applicationFuture = context
        .read<ApplicationViewModel>()
        .fetchCurrentUserApplication();
  }

  Future<void> _signOut(BuildContext context) async {
    await SupabaseService.client.auth.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  Future<void> _openProfile() async {
    await Navigator.pushNamed(context, AppRoutes.profile);
    if (!mounted) {
      return;
    }
    setState(() {
      _profileFuture = context.read<AuthViewModel>().fetchCurrentUserProfile();
    });
  }

  Future<void> _openMyApplication() async {
    await Navigator.pushNamed(context, AppRoutes.myApplicationDetail);
    if (!mounted) {
      return;
    }
    setState(() {
      _applicationFuture = context
          .read<ApplicationViewModel>()
          .fetchCurrentUserApplication();
    });
  }

  Future<void> _openApplicationForm() async {
    await Navigator.pushNamed(context, AppRoutes.applicationForm);
    if (!mounted) {
      return;
    }
    setState(() {
      _applicationFuture = context
          .read<ApplicationViewModel>()
          .fetchCurrentUserApplication();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.danger;
      case 'submitted':
        return AppColors.warning;
      default:
        return AppColors.slate;
    }
  }

  Widget _buildStatusPill(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: AppColors.slate, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: _openMyApplication,
            icon: const Icon(Icons.assignment_outlined),
          ),
          IconButton(onPressed: _openProfile, icon: const Icon(Icons.person)),
          IconButton(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: AppBackground(
        child: FutureBuilder<Profile?>(
          future: _profileFuture,
          builder: (context, snapshot) {
            final profile = snapshot.data;
            final nameLabel = profile?.fullName ?? 'Student';
            final roleLabel = profile?.role ?? 'student';
            final studentNumber = profile?.studentNumber;
            final isAdmin = roleLabel == 'admin';

            return ListView(
              children: [
                if (snapshot.connectionState == ConnectionState.waiting)
                  AppReveal(
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Loading profile...',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          const LinearProgressIndicator(),
                        ],
                      ),
                    ),
                  ),
                AppReveal(
                  delay: const Duration(milliseconds: 60),
                  child: AppCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: theme.colorScheme.primary.withValues(
                            alpha: 0.12,
                          ),
                          child: Text(
                            nameLabel.isNotEmpty
                                ? nameLabel.substring(0, 1).toUpperCase()
                                : 'S',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, $nameLabel',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Role: $roleLabel',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.slate,
                                ),
                              ),
                              if (studentNumber != null &&
                                  studentNumber.isNotEmpty)
                                Text(
                                  'Student Number: $studentNumber',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.slate,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<Application?>(
                  future: _applicationFuture,
                  builder: (context, applicationSnapshot) {
                    if (applicationSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return AppReveal(
                        delay: const Duration(milliseconds: 120),
                        child: const AppCard(child: LinearProgressIndicator()),
                      );
                    }

                    if (applicationSnapshot.hasError) {
                      return AppReveal(
                        delay: const Duration(milliseconds: 120),
                        child: const AppCard(
                          child: Text('Unable to load application status.'),
                        ),
                      );
                    }

                    final application = applicationSnapshot.data;
                    if (application == null) {
                      return AppReveal(
                        delay: const Duration(milliseconds: 120),
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No application yet',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start an application when you are ready.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.slate,
                                ),
                              ),
                              const SizedBox(height: 12),
                              FilledButton.tonal(
                                onPressed: _openApplicationForm,
                                child: const Text('Start Application'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final moduleLabel = application.moduleCode != null
                        ? '${application.moduleCode} - ${application.moduleName ?? ''}'
                        : application.moduleId;
                    final levelLabel =
                        application.levelName ?? application.levelId;

                    return AppReveal(
                      delay: const Duration(milliseconds: 120),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'My Application',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                _buildStatusPill(application.status),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Module: $moduleLabel',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              'Level: $levelLabel',
                              style: theme.textTheme.bodyMedium,
                            ),
                            if (application.adminNotes != null &&
                                application.adminNotes!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Admin Notes: ${application.adminNotes}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.slate,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            FilledButton.tonal(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.myApplicationDetail,
                                  arguments: application,
                                );
                              },
                              child: const Text('View Details'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                AppReveal(
                  delay: const Duration(milliseconds: 180),
                  child: Column(
                    children: [
                      _actionTile(
                        icon: Icons.edit_note,
                        title: 'Start Application',
                        subtitle: 'Submit your application in minutes.',
                        onTap: _openApplicationForm,
                      ),
                      const SizedBox(height: 12),
                      _actionTile(
                        icon: Icons.assignment_outlined,
                        title: 'My Application',
                        subtitle: 'Track status and review details.',
                        onTap: _openMyApplication,
                      ),
                    ],
                  ),
                ),
                if (isAdmin) ...[
                  const SizedBox(height: 16),
                  AppReveal(
                    delay: const Duration(milliseconds: 240),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Mode',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Review applications and manage submissions.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.slate,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.adminDashboard,
                              );
                            },
                            child: const Text('Open Admin Dashboard'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
