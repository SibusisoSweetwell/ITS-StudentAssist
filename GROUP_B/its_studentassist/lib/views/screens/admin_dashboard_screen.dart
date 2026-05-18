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
import '../../viewmodels/admin_review_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../widgets/app_background.dart';
import '../widgets/app_card.dart';
import '../widgets/app_reveal.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isCheckingAccess = true;
  String _recentFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureAdminAccess();
    });
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
    context.read<AdminReviewViewModel>().fetchApplications();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminReviewViewModel>();
    final theme = Theme.of(context);

    final applications = viewModel.applications;
    final total = applications.length;
    final submitted = applications.where((a) => a.status == 'submitted').length;
    final approved = applications.where((a) => a.status == 'approved').length;
    final rejected = applications.where((a) => a.status == 'rejected').length;
    final pendingReview = submitted;

    final filterLabels = {
      'all': 'All',
      'submitted': 'Submitted',
      'approved': 'Approved',
      'rejected': 'Rejected',
    };
    final recent = applications
        .where((item) => _recentFilter == 'all' || item.status == _recentFilter)
        .take(5)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
            icon: const Icon(Icons.person),
          ),
          IconButton(
            onPressed: () => viewModel.fetchApplications(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: AppBackground(
        child: _isCheckingAccess
            ? const Center(child: CircularProgressIndicator())
            : viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.errorMessage != null
                    ? Center(child: Text(viewModel.errorMessage!))
                    : ListView(
                        children: [
                          AppReveal(
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _MetricCard(label: 'Total', value: total),
                                _MetricCard(label: 'Submitted', value: submitted),
                                _MetricCard(label: 'Approved', value: approved),
                                _MetricCard(label: 'Rejected', value: rejected),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppReveal(
                            delay: const Duration(milliseconds: 120),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.adminReviewList,
                                      );
                                    },
                                    child: const Text('Review Applications'),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: -8,
                                  child: _CountBadge(
                                    label: 'Pending',
                                    count: pendingReview,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppReveal(
                            delay: const Duration(milliseconds: 180),
                            child: Text(
                              'Recent Applications',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          AppReveal(
                            delay: const Duration(milliseconds: 200),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: filterLabels.entries.map((entry) {
                                final isSelected = _recentFilter == entry.key;
                                return ChoiceChip(
                                  label: Text(entry.value),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    setState(() {
                                      _recentFilter = entry.key;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (recent.isEmpty)
                            const Text('No applications found.')
                          else
                            ...recent.asMap().entries.map((entry) {
                              final index = entry.key;
                              final application = entry.value;
                              final studentLabel =
                                  application.studentName ?? application.userId;
                              final moduleLabel = application.moduleCode != null
                                  ? '${application.moduleCode} - ${application.moduleName ?? ''}'
                                  : application.moduleId;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: AppReveal(
                                  delay: Duration(milliseconds: 240 + index * 60),
                                  child: AppCard(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.adminReviewDetail,
                                        arguments: application,
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          studentLabel,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '$moduleLabel | Status: ${application.status}',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: AppColors.slate,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final int value;

  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 160,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.slate,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final String label;
  final int count;

  const _CountBadge({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
