import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_color.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/gpa_calculator.dart';
import '../core/utils/student_type.dart';
import '../models/subject_model.dart';
import '../providers/grade_provider.dart';
import '../widgets/grade_dropdown.dart';

class AddSubjectScreen extends StatefulWidget {
  const AddSubjectScreen({super.key});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen>
    with SingleTickerProviderStateMixin {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _marksCtrl  = TextEditingController();
  final _maxCtrl    = TextEditingController();

  String _selectedGrade   = 'A';
  int    _selectedCredits = 3;

  late AnimationController _animController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _slideAnim = Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _fadeAnim = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    _marksCtrl.addListener(_updateGradeFromMarks);
    _maxCtrl.addListener(_updateGradeFromMarks);
  }

  void _updateGradeFromMarks() {
    final scored = double.tryParse(_marksCtrl.text);
    final max    = double.tryParse(_maxCtrl.text);
    if (scored != null && max != null && max > 0) {
      final pct   = (scored / max) * 100;
      final grade = GpaCalculator.percentageToGrade(pct);
      setState(() => _selectedGrade = grade);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameCtrl.dispose();
    _marksCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  void _submit(bool usesGpa) {
    if (!_formKey.currentState!.validate()) return;

    final subject = SubjectModel(
      id:          DateTime.now().millisecondsSinceEpoch.toString(),
      name:        _nameCtrl.text.trim(),
      grade:       _selectedGrade,
      credits:     _selectedCredits,
      marksScored: usesGpa ? null : double.tryParse(_marksCtrl.text),
      maxMarks:    usesGpa ? null : double.tryParse(_maxCtrl.text),
    );

    context.read<GradeProvider>().addSubject(subject);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GradeProvider>();
    final usesGpa  = provider.usesGpa;

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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentGlow,
                borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                border: Border.all(color: AppColors.accent.withOpacity(0.4)),
              ),
              child: Text(provider.studentType?.label ?? '',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.accent, fontSize: 10)),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.paddingLG),
              children: [
                _buildLabel('SUBJECT NAME'),
                const SizedBox(height: AppConstants.paddingSM),
                _buildNameField(provider),
                const SizedBox(height: AppConstants.paddingLG),
                if (usesGpa) ...[
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
                ] else ...[
                  _buildLabel('MARKS SCORED'),
                  const SizedBox(height: AppConstants.paddingSM),
                  _buildMarksRow(),
                  const SizedBox(height: AppConstants.paddingLG),
                  _buildAutoGradePreview(),
                ],
                const SizedBox(height: AppConstants.paddingXL),
                _buildSubmitButton(usesGpa),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text, style: AppTextStyles.label);

  Widget _buildNameField(GradeProvider provider) {
    final templates = provider.studentType?.usesPercentage == true
        ? (provider.studentType?.name == 'seniorSecondary'
        ? AppConstants.subjectTemplatesSecondary
        : AppConstants.subjectTemplatesHigher)
        : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _styledField(
          controller: _nameCtrl,
          hint: 'e.g. Mathematics',
          validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Enter a subject name' : null,
        ),
        if (templates.isNotEmpty) ...[
          const SizedBox(height: AppConstants.paddingSM),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: templates.map((t) => GestureDetector(
              onTap: () => _nameCtrl.text = t,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius:
                  BorderRadius.circular(AppConstants.radiusSM),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(t, style: AppTextStyles.caption),
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildMarksRow() {
    return Row(
      children: [
        Expanded(
          child: _styledField(
            controller: _marksCtrl,
            hint: 'Scored',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter marks';
              if (double.tryParse(v) == null) return 'Invalid';
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('/',
              style: AppTextStyles.title
                  .copyWith(color: AppColors.textSecondary)),
        ),
        Expanded(
          child: _styledField(
            controller: _maxCtrl,
            hint: 'Max',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter max';
              if (double.tryParse(v) == null) return 'Invalid';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAutoGradePreview() {
    final scored = double.tryParse(_marksCtrl.text);
    final max    = double.tryParse(_maxCtrl.text);
    if (scored == null || max == null || max == 0) return const SizedBox.shrink();
    final pct   = (scored / max) * 100;
    final color = AppColors.percentageColor(pct);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(AppConstants.paddingMD),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: color, size: 18),
          const SizedBox(width: 8),
          Text('${pct.toStringAsFixed(1)}%  •  Grade $_selectedGrade',
              style: AppTextStyles.body.copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
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
              border: Border.all(
                  color: selected ? AppColors.accent : AppColors.cardBorder),
              boxShadow: selected
                  ? [BoxShadow(color: AppColors.accentGlow, blurRadius: 12)]
                  : [],
            ),
            child: Center(
              child: Text('$credit',
                  style: AppTextStyles.title.copyWith(
                    color: selected
                        ? AppColors.background
                        : AppColors.textSecondary,
                  )),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton(bool usesGpa) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _submit(usesGpa),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.background,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLG)),
          elevation: 0,
          shadowColor: AppColors.accentGlow,
        ),
        child: const Text('Add Subject',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      ),
    );
  }

  Widget _styledField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: AppTextStyles.body,
      cursorColor: AppColors.accent,
      keyboardType: keyboardType,
      inputFormatters: keyboardType != null
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
          : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            borderSide: BorderSide(color: AppColors.cardBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            borderSide:
            const BorderSide(color: AppColors.accent, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            borderSide: BorderSide(color: AppColors.rose)),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMD,
            vertical: AppConstants.paddingMD),
      ),
      validator: validator,
    );
  }
}