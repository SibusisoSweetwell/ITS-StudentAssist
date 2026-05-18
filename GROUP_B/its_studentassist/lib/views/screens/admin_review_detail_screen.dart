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
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../models/admin_application.dart';
import '../../services/supabase_service.dart';
import '../../viewmodels/admin_review_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../widgets/app_background.dart';
import '../widgets/app_card.dart';
import '../widgets/app_reveal.dart';

class AdminReviewDetailScreen extends StatefulWidget {
  const AdminReviewDetailScreen({super.key});

  @override
  State<AdminReviewDetailScreen> createState() =>
      _AdminReviewDetailScreenState();
}

class _AdminReviewDetailScreenState extends State<AdminReviewDetailScreen> {
  final _notesController = TextEditingController();
  bool _notesLoaded = false;
  bool _isCheckingAccess = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureAdminAccess();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _ensureAdminAccess() async {
    final role = await context.read<AuthViewModel>().fetchCurrentUserRole();
    if (!mounted) {
      return;
    }
    if (role != 'admin') {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.accessDenied,
        arguments: 'Admin access required.',
      );
      return;
    }
    setState(() {
      _isCheckingAccess = false;
    });
  }

  Future<void> _updateStatus(
    AdminApplication application,
    String status,
  ) async {
    final viewModel = context.read<AdminReviewViewModel>();
    final success = await viewModel.updateStatus(
      applicationId: application.id,
      status: status,
      adminNotes: _notesController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Updated to $status.')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage ?? 'Update failed.')),
      );
    }
  }

  Future<void> _deleteApplication(AdminApplication application) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete application?'),
          content: const Text('This will permanently delete the application.'),
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

    final viewModel = context.read<AdminReviewViewModel>();
    final success = await viewModel.deleteApplication(
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage ?? 'Delete failed.')),
      );
    }
  }

  Future<void> _copyDocumentLink(AdminApplication application) async {
    if (application.supportingDocPath.isEmpty) {
      return;
    }

    try {
      final url = await SupabaseService.client.storage
          .from('supporting-docs')
          .createSignedUrl(application.supportingDocPath, 600);
      await Clipboard.setData(ClipboardData(text: url));
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Document link copied.')));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to generate link.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAccess) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review Detail')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    final application = args is AdminApplication ? args : null;

    if (application == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review Detail')),
        body: const Center(child: Text('No application selected.')),
      );
    }

    if (!_notesLoaded) {
      _notesController.text = application.adminNotes ?? '';
      _notesLoaded = true;
    }

    final moduleLabel = application.moduleCode != null
        ? '${application.moduleCode} - ${application.moduleName ?? ''}'
        : application.moduleId;
    final levelLabel = application.levelName ?? application.levelId;
    final module2Label = application.module2Code != null
        ? '${application.module2Code} - ${application.module2Name ?? ''}'
        : application.moduleId2;
    final level2Label = application.level2Name ?? application.levelId2;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Review Detail')),
      body: AppBackground(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppReveal(
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Student: ${application.studentName ?? application.userId}',
                      ),
                      if (application.studentNumber != null)
                        Text('Student Number: ${application.studentNumber}'),
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
                        'Application Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Year of Study: ${application.yearOfStudy}'),
                      Text('Module: $moduleLabel'),
                      Text('Level: $levelLabel'),
                      if (application.moduleId2 != null) ...[
                        const SizedBox(height: 8),
                        Text('Second Module: $module2Label'),
                        if (level2Label != null)
                          Text('Second Level: $level2Label'),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Eligibility: ${application.isEligible ? 'Confirmed' : 'Not confirmed'}',
                      ),
                      Text('Status: ${application.status}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              application.supportingDocPath.isEmpty
                                  ? 'Supporting Document: Not uploaded'
                                  : 'Supporting Document: Uploaded',
                            ),
                          ),
                          if (application.supportingDocPath.isNotEmpty)
                            TextButton(
                              onPressed: () => _copyDocumentLink(application),
                              child: const Text('Copy Link'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppReveal(
                delay: const Duration(milliseconds: 180),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student Notes',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (application.motivation != null)
                        Text('Motivation: ${application.motivation}'),
                      if (application.experience != null)
                        Text('Experience: ${application.experience}'),
                      if (application.availability != null)
                        Text('Availability: ${application.availability}'),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Admin Notes',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppReveal(
                delay: const Duration(milliseconds: 240),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Review Actions',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => _updateStatus(application, 'approved'),
                        child: const Text('Approve'),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        onPressed: () => _updateStatus(application, 'rejected'),
                        child: const Text('Reject'),
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
          ),
        ),
      ),
    );
  }
}
