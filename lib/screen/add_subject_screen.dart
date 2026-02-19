import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_color.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_text_styles.dart';
import '../models/subject_model.dart';
import '../providers/grade_provider.dart';
import '../widgets/grade_dropdown.dart';

class AddSubjectScreen extends StatefulWidget {
  const AddSubjectScreen({super.key});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedGrade = 'A';
  int _selectedCredits = 3;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final subject = SubjectModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      grade: _selectedGrade,
      credits: _selectedCredits,
    );

    context.read<GradeProvider>().addSubject(subject);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Add Subject', style: AppTextStyles.title),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLG),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('SUBJECT NAME'),
              const SizedBox(height: AppConstants.paddingSM),
              _buildNameField(),
              const SizedBox(height: AppConstants.paddingLG),
              _buildLabel('LETTER GRADE'),
              const SizedBox(height: AppConstants.paddingSM),
              GradeDropdown(
                value: _selectedGrade,
                onChanged: (v) => setState(() => _selectedGrade = v!),
              ),
              const SizedBox(height: AppConstants.paddingLG),
              _buildLabel('CREDIT HOURS'),
              const SizedBox(height: AppConstants.paddingSM),
              _buildCreditSelector(),
              const Spacer(),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) =>
      Text(text, style: AppTextStyles.label);

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      style: AppTextStyles.body,
      cursorColor: AppColors.accent,
      decoration: InputDecoration(
        hintText: 'e.g. Calculus II',
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMD,
          vertical: AppConstants.paddingMD,
        ),
      ),
      validator: (v) =>
      (v == null || v.trim().isEmpty) ? 'Please enter a subject name' : null,
    );
  }

  Widget _buildCreditSelector() {
    return Row(
      children: AppConstants.creditOptions.map((credit) {
        final selected = _selectedCredits == credit;
        return GestureDetector(
          onTap: () => setState(() => _selectedCredits = credit),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: AppConstants.paddingSM),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: selected ? AppColors.accent : AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            ),
            child: Center(
              child: Text(
                '$credit',
                style: AppTextStyles.title.copyWith(
                  color: selected ? AppColors.background : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.background,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Add Subject',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}