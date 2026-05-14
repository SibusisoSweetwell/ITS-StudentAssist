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
import '../../viewmodels/application_viewmodel.dart';
import '../widgets/app_background.dart';
import '../widgets/app_card.dart';
import '../widgets/app_reveal.dart';

class MyApplicationDetailScreen extends StatefulWidget {
  const MyApplicationDetailScreen({super.key});

  @override
  State<MyApplicationDetailScreen> createState() =>
      _MyApplicationDetailScreenState();
}

class _MyApplicationDetailScreenState extends State<MyApplicationDetailScreen> {
  Future<Application?>? _applicationFuture;
  Application? _application;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_applicationFuture != null || _application != null) {
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Application) {
      _application = args;
    } else {
      _applicationFuture = context
          .read<ApplicationViewModel>()
          .fetchCurrentUserApplication();
    }
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

  Future<void> _editApplication(Application application) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.applicationForm,
      arguments: application,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _applicationFuture = context
          .read<ApplicationViewModel>()
          .fetchCurrentUserApplication();
    });
  }

  Future<void> _deleteApplication(Application application) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete application?'),
          content: const Text(
            'This will permanently delete your application while it is pending.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) {
      return;
    }

    final success = await context
        .read<ApplicationViewModel>()
        .deleteApplication(
          applicationId: application.id,
          supportingDocPath: application.supportingDocPath,
        );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Application deleted.')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Delete failed.')));
    }
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

  Widget _detailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.slate,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildDetails(BuildContext context, Application application) {
    final theme = Theme.of(context);
    final moduleLabel = application.moduleCode != null
        ? '${application.moduleCode} - ${application.moduleName ?? ''}'
        : application.moduleId;
    final levelLabel = application.levelName ?? application.levelId;
    final module2Label = application.module2Code != null
        ? '${application.module2Code} - ${application.module2Name ?? ''}'
        : (application.moduleId2 ?? '');
    final level2Label = application.level2Name ?? application.levelId2;
    final canManage = application.status == 'submitted';

    return ListView(
      children: [
        AppReveal(
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Application Summary',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    _buildStatusPill(application.status),
                  ],
                ),
                const SizedBox(height: 10),
                _detailRow(
                  context,
                  'Year of Study',
                  application.yearOfStudy.toString(),
                ),
                _detailRow(context, 'Module', moduleLabel),
                _detailRow(context, 'Level', levelLabel),
                if (application.moduleId2 != null) ...[
                  _detailRow(context, 'Second Module', module2Label),
                  if (level2Label != null)
                    _detailRow(context, 'Second Level', level2Label),
                ],
                _detailRow(
                  context,
                  'Eligibility',
                  application.isEligible ? 'Confirmed' : 'Not confirmed',
                ),
                _detailRow(
                  context,
                  'Supporting Doc',
                  application.supportingDocPath.isEmpty
                      ? 'Not uploaded'
                      : 'Uploaded',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        AppReveal(
          delay: const Duration(milliseconds: 120),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Motivation',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(application.motivation),
                if (application.experience != null &&
                    application.experience!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Experience',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(application.experience!),
                ],
                if (application.availability != null &&
                    application.availability!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Availability',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(application.availability!),
                ],
                if (application.adminNotes != null &&
                    application.adminNotes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Admin Notes',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(application.adminNotes!),
                ],
              ],
            ),
          ),
        ),
        if (canManage) ...[
          const SizedBox(height: 16),
          AppReveal(
            delay: const Duration(milliseconds: 180),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Manage Application',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => _editApplication(application),
                    child: const Text('Edit Application'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => _deleteApplication(application),
                    child: const Text('Delete Application'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Application')),
      body: AppBackground(
        child: _application != null
            ? _buildDetails(context, _application!)
            : FutureBuilder<Application?>(
                future: _applicationFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Unable to load application details.'),
                    );
                  }

                  final application = snapshot.data;
                  if (application == null) {
                    return Center(
                      child: AppCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('No application submitted yet.'),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: _openApplicationForm,
                              child: const Text('Start Application'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return _buildDetails(context, application);
                },
              ),
      ),
    );
  }
}
