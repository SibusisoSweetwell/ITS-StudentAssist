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
import '../../core/theme/app_colors.dart';
import '../../models/admin_application.dart';
import '../../viewmodels/admin_review_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../widgets/app_background.dart';
import '../widgets/app_card.dart';
import '../widgets/app_reveal.dart';

class AdminReviewListScreen extends StatefulWidget {
  const AdminReviewListScreen({super.key});

  @override
  State<AdminReviewListScreen> createState() => _AdminReviewListScreenState();
}

class _AdminReviewListScreenState extends State<AdminReviewListScreen> {
  bool _isCheckingAccess = true;
  String _statusFilter = 'all';
  String _searchQuery = '';
  String _sortOption = 'newest';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureAdminAccess();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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
    context.read<AdminReviewViewModel>().fetchApplications();
  }

  bool _matchesSearch(AdminApplication application, String query) {
    if (query.isEmpty) {
      return true;
    }

    final haystack = [
      application.studentName,
      application.studentNumber,
      application.studentEmail,
      application.moduleCode,
      application.moduleName,
      application.levelName,
      application.status,
    ].whereType<String>().join(' ').toLowerCase();

    return haystack.contains(query);
  }

  int _statusRank(String status) {
    switch (status) {
      case 'submitted':
        return 0;
      case 'approved':
        return 1;
      case 'rejected':
        return 2;
      default:
        return 3;
    }
  }

  String _escapeCsv(String value) {
    final needsQuotes =
        value.contains(',') || value.contains('"') || value.contains('\n');
    if (!needsQuotes) {
      return value;
    }
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  String _buildCsv(List<AdminApplication> applications) {
    final header = 'Student Name,Student Number,Email,Module,Level,Status';
    final lines = applications.map((application) {
      final studentName = application.studentName ?? '';
      final studentNumber = application.studentNumber ?? '';
      final studentEmail = application.studentEmail ?? '';
      final moduleLabel = application.moduleCode != null
          ? '${application.moduleCode} - ${application.moduleName ?? ''}'
          : application.moduleId;
      final levelLabel = application.levelName ?? application.levelId;
      final fields = [
        studentName,
        studentNumber,
        studentEmail,
        moduleLabel,
        levelLabel,
        application.status,
      ].map(_escapeCsv).join(',');
      return fields;
    }).toList();

    return ([header, ...lines]).join('\n');
  }

  Future<void> _exportCsv(List<AdminApplication> applications) async {
    if (applications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No applications to export.')),
      );
      return;
    }

    final csv = _buildCsv(applications);
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Export CSV'),
          content: SingleChildScrollView(child: SelectableText(csv)),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: csv));
                Navigator.pop(context);
              },
              child: const Text('Copy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminReviewViewModel>();
    final theme = Theme.of(context);
    final filterLabels = {
      'all': 'All',
      'submitted': 'Submitted',
      'approved': 'Approved',
      'rejected': 'Rejected',
    };
    final sortLabels = {
      'newest': 'Newest',
      'oldest': 'Oldest',
      'status': 'Status',
    };
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    final pendingCount = viewModel.applications
        .where((item) => item.status == 'submitted')
        .length;
    final filteredApplications = viewModel.applications.where((item) {
      if (_statusFilter != 'all' && item.status != _statusFilter) {
        return false;
      }
      return _matchesSearch(item, normalizedQuery);
    }).toList();

    List<AdminApplication> sortedApplications = List<AdminApplication>.from(
      filteredApplications,
    );
    if (_sortOption == 'oldest') {
      sortedApplications = sortedApplications.reversed.toList();
    } else if (_sortOption == 'status') {
      sortedApplications.sort(
        (a, b) => _statusRank(a.status).compareTo(_statusRank(b.status)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Review'),
        actions: [
          IconButton(
            onPressed: () => _exportCsv(sortedApplications),
            icon: const Icon(Icons.download),
            tooltip: 'Export CSV',
          ),
          if (!_isCheckingAccess && !viewModel.isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _CountBadge(label: 'Pending', count: pendingCount),
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
                      : Column(
                          children: [
                            AppReveal(
                              child: AppCard(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Search student, email, module',
                                    prefixIcon: const Icon(Icons.search),
                                    suffixIcon: _searchQuery.isEmpty
                                        ? null
                                        : IconButton(
                                            onPressed: () {
                                              _searchController.clear();
                                              setState(() {
                                                _searchQuery = '';
                                              });
                                            },
                                            icon: const Icon(Icons.clear),
                                          ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            AppReveal(
                              delay: const Duration(milliseconds: 120),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: filterLabels.entries.map((entry) {
                                  final isSelected = _statusFilter == entry.key;
                                  return ChoiceChip(
                                    label: Text(entry.value),
                                    selected: isSelected,
                                    onSelected: (_) {
                                      setState(() {
                                        _statusFilter = entry.key;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            AppReveal(
                              delay: const Duration(milliseconds: 160),
                              child: Row(
                                children: [
                                  Text(
                                    'Sort',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.slate,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  DropdownButton<String>(
                                    value: _sortOption,
                                    items: sortLabels.entries
                                        .map(
                                          (entry) => DropdownMenuItem(
                                            value: entry.key,
                                            child: Text(entry.value),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      if (value == null) {
                                        return;
                                      }
                                      setState(() {
                                        _sortOption = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: sortedApplications.isEmpty
                                  ? const Center(
                                      child: Text('No applications found.'),
                                    )
                                  : ListView.builder(
                                      itemCount: sortedApplications.length,
                                      itemBuilder: (context, index) {
                                        final application =
                                            sortedApplications[index];
                                        final studentLabel =
                                            application.studentName ??
                                                application.userId;
                                        final moduleLabel = application.moduleCode !=
                                                null
                                            ? '${application.moduleCode} - ${application.moduleName ?? ''}'
                                            : application.moduleId;
                                        final levelLabel = application.levelName ??
                                            application.levelId;

                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: AppReveal(
                                            delay: Duration(
                                              milliseconds: 200 + index * 40,
                                            ),
                                            child: AppCard(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  AppRoutes.adminReviewDetail,
                                                  arguments: application,
                                                );
                                              },
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    studentLabel,
                                                    style: theme
                                                        .textTheme.titleMedium
                                                        ?.copyWith(
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    '$moduleLabel | $levelLabel | Status: ${application.status}',
                                                    style: theme.textTheme.bodyMedium
                                                        ?.copyWith(
                                                      color: AppColors.slate,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
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
