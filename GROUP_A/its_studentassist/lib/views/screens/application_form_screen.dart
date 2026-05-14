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

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/application.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../viewmodels/reference_data_viewmodel.dart';
import '../widgets/app_background.dart';
import '../widgets/app_card.dart';
import '../widgets/app_reveal.dart';

class ApplicationFormScreen extends StatefulWidget {
  const ApplicationFormScreen({super.key});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _motivationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _availabilityController = TextEditingController();
  String? _selectedModuleId;
  String? _selectedLevelId;
  int _yearOfStudy = 1;
  String? _selectedModuleId2;
  String? _selectedLevelId2;
  bool _isEligible = false;
  Uint8List? _supportingDocBytes;
  String? _supportingDocName;
  Application? _editingApplication;
  bool _loadedExisting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReferenceDataViewModel>().loadReferenceData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedExisting) {
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Application) {
      _editingApplication = args;
      _selectedModuleId = args.moduleId;
      _selectedLevelId = args.levelId;
      _yearOfStudy = args.yearOfStudy;
      _selectedModuleId2 = args.moduleId2;
      _selectedLevelId2 = args.levelId2;
      _isEligible = args.isEligible;
      _motivationController.text = args.motivation;
      _experienceController.text = args.experience ?? '';
      _availabilityController.text = args.availability ?? '';
    }

    _loadedExisting = true;
  }

  @override
  void dispose() {
    _motivationController.dispose();
    _experienceController.dispose();
    _availabilityController.dispose();
    super.dispose();
  }

  Future<void> _pickSupportingDocument() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.first;
    if (file.bytes == null) {
      return;
    }

    setState(() {
      _supportingDocBytes = file.bytes;
      _supportingDocName = file.name;
    });
  }

  Future<void> _submit() async {
    final viewModel = context.read<ApplicationViewModel>();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!_isEligible) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Confirm eligibility to continue.')),
      );
      return;
    }

    final hasExistingDoc =
        _editingApplication?.supportingDocPath.isNotEmpty ?? false;
    if (_supportingDocBytes == null && !hasExistingDoc) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload a supporting document.')),
      );
      return;
    }

    if (_supportingDocBytes != null &&
        (_supportingDocName == null || _supportingDocName!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid document selection.')),
      );
      return;
    }

    final success = _editingApplication == null
        ? await viewModel.submitApplication(
            moduleId: _selectedModuleId!,
            levelId: _selectedLevelId!,
            yearOfStudy: _yearOfStudy,
            motivation: _motivationController.text.trim(),
            experience: _experienceController.text.trim(),
            availability: _availabilityController.text.trim(),
            moduleId2: _selectedModuleId2,
            levelId2: _selectedLevelId2,
            isEligible: _isEligible,
            supportingDocBytes: _supportingDocBytes!,
            supportingDocName: _supportingDocName!,
          )
        : await viewModel.updateApplication(
            applicationId: _editingApplication!.id,
            moduleId: _selectedModuleId!,
            levelId: _selectedLevelId!,
            yearOfStudy: _yearOfStudy,
            motivation: _motivationController.text.trim(),
            experience: _experienceController.text.trim(),
            availability: _availabilityController.text.trim(),
            moduleId2: _selectedModuleId2,
            levelId2: _selectedLevelId2,
            isEligible: _isEligible,
            supportingDocBytes: _supportingDocBytes,
            supportingDocName: _supportingDocName,
          );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Application submitted.')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage ?? 'Submit failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ApplicationViewModel>();
    final referenceViewModel = context.watch<ReferenceDataViewModel>();
    final isEditing = _editingApplication != null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Application' : 'Application Form'),
      ),
      body: AppBackground(
        child: referenceViewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    if (referenceViewModel.errorMessage != null)
                      AppReveal(
                        child: AppCard(
                          child: Text(
                            referenceViewModel.errorMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                    if (referenceViewModel.errorMessage != null)
                      const SizedBox(height: 12),
                    AppReveal(
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Module Selection',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedModuleId,
                              decoration: const InputDecoration(
                                labelText: 'Module',
                              ),
                              items: referenceViewModel.modules
                                  .map(
                                    (module) => DropdownMenuItem(
                                      value: module.id,
                                      child: Text(
                                        '${module.code} - ${module.name}',
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: referenceViewModel.modules.isEmpty
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _selectedModuleId = value;
                                      });
                                    },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Select a module.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              initialValue: _yearOfStudy,
                              decoration: const InputDecoration(
                                labelText: 'Year of Study',
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text('Year 1'),
                                ),
                                DropdownMenuItem(
                                  value: 2,
                                  child: Text('Year 2'),
                                ),
                                DropdownMenuItem(
                                  value: 3,
                                  child: Text('Year 3'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() {
                                  _yearOfStudy = value;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedLevelId,
                              decoration: const InputDecoration(
                                labelText: 'Level',
                              ),
                              items: referenceViewModel.levels
                                  .map(
                                    (level) => DropdownMenuItem(
                                      value: level.id,
                                      child: Text(level.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: referenceViewModel.levels.isEmpty
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _selectedLevelId = value;
                                      });
                                    },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Select a level.';
                                }
                                return null;
                              },
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
                              'Second Module (Optional)',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedModuleId2,
                              decoration: const InputDecoration(
                                labelText: 'Second Module',
                              ),
                              items: referenceViewModel.modules
                                  .map(
                                    (module) => DropdownMenuItem(
                                      value: module.id,
                                      child: Text(
                                        '${module.code} - ${module.name}',
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: referenceViewModel.modules.isEmpty
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _selectedModuleId2 = value;
                                        if (value == null) {
                                          _selectedLevelId2 = null;
                                        }
                                      });
                                    },
                              validator: (value) {
                                if (value != null &&
                                    value == _selectedModuleId) {
                                  return 'Choose a different second module.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedLevelId2,
                              decoration: const InputDecoration(
                                labelText: 'Second Level',
                              ),
                              items: referenceViewModel.levels
                                  .map(
                                    (level) => DropdownMenuItem(
                                      value: level.id,
                                      child: Text(level.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: referenceViewModel.levels.isEmpty
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _selectedLevelId2 = value;
                                      });
                                    },
                              validator: (value) {
                                if (_selectedModuleId2 != null &&
                                    (value == null || value.isEmpty)) {
                                  return 'Select a level for the second module.';
                                }
                                if (_selectedModuleId2 == null &&
                                    value != null) {
                                  return 'Select a second module first.';
                                }
                                return null;
                              },
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
                              'Motivation & Availability',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _motivationController,
                              decoration: const InputDecoration(
                                labelText: 'Motivation',
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Motivation is required.';
                                }
                                if (value.trim().length < 10) {
                                  return 'Motivation must be at least 10 characters.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _experienceController,
                              decoration: const InputDecoration(
                                labelText: 'Experience',
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _availabilityController,
                              decoration: const InputDecoration(
                                labelText: 'Availability',
                              ),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Eligibility & Documents',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CheckboxListTile(
                              value: _isEligible,
                              onChanged: (value) {
                                setState(() {
                                  _isEligible = value ?? false;
                                });
                              },
                              title: const Text(
                                'I confirm I meet the minimum requirements',
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                            const SizedBox(height: 4),
                            FilledButton.tonal(
                              onPressed: _pickSupportingDocument,
                              child: const Text('Upload Supporting Document'),
                            ),
                            if (_supportingDocName != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text('Selected: $_supportingDocName'),
                              )
                            else if (_editingApplication
                                    ?.supportingDocPath
                                    .isNotEmpty ??
                                false)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text('Using existing document.'),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppReveal(
                      delay: const Duration(milliseconds: 300),
                      child: FilledButton(
                        onPressed: viewModel.isLoading ? null : _submit,
                        child: viewModel.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isEditing
                                    ? 'Update Application'
                                    : 'Submit Application',
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
