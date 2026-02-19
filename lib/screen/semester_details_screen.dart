import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_color.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/gpa_calculator.dart';
import '../models/semester_model.dart';
import '../models/subject_model.dart';
import '../providers/grade_provider.dart';
import '../widgets/grade_dropdown.dart';

class SemesterDetailScreen extends StatefulWidget {
  final SemesterModel semester;

  const SemesterDetailScreen({super.key, required this.semester});

  @override
  State<SemesterDetailScreen> createState() => _SemesterDetailScreenState();
}

class _SemesterDetailScreenState extends State<SemesterDetailScreen>
    with SingleTickerProviderStateMixin {
  late List<SubjectModel> _subjects;
  late AnimationController _ctrl;
  late Animation<double> _fade;

  bool _hasChanges = false;
  late bool _usesGpa;

  @override
  void initState() {
    super.initState();
    _subjects = List.from(widget.semester.subjects);
    _usesGpa  = widget.semester.studentType == 'undergraduate' ||
        widget.semester.studentType == 'postgraduate';

    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double get _gpa => GpaCalculator.calculate(_subjects);
  double get _pct => GpaCalculator.overallPercentage(_subjects);

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLG)),
        title: Text('Unsaved Changes', style: AppTextStyles.title),
        content: Text(
            'You have unsaved changes. Save before leaving?',
            style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Discard',
                style: AppTextStyles.body.copyWith(color: AppColors.rose)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSM)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == true) await _saveChanges();
    return true;
  }

  Future<void> _saveChanges() async {
    await context.read<GradeProvider>().updateSemesterSubjects(
        widget.semester.id, _subjects);
    setState(() => _hasChanges = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Semester updated!'),
        backgroundColor: AppColors.gradeA,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD)),
      ));
    }
  }

  void _removeSubject(int index) {
    setState(() {
      _subjects.removeAt(index);
      _hasChanges = true;
    });
  }

  void _showEditSubjectSheet(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXL)),
      ),
      builder: (_) => _EditSubjectSheet(
        subject: _subjects[index],
        usesGpa: _usesGpa,
        onSave: (updated) {
          setState(() {
            _subjects[index] = updated;
            _hasChanges = true;
          });
        },
      ),
    );
  }

  void _showAddSubjectSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXL)),
      ),
      builder: (_) => _EditSubjectSheet(
        subject: null,
        usesGpa: _usesGpa,
        onSave: (newSubject) {
          setState(() {
            _subjects.add(newSubject);
            _hasChanges = true;
          });
        },
      ),
    );
  }

  void _showRenameDialog() {
    final ctrl = TextEditingController(text: widget.semester.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLG)),
        title: Text('Rename Semester', style: AppTextStyles.title),
        content: TextField(
          controller: ctrl,
          style: AppTextStyles.body,
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            hintText: 'e.g. Fall 2025',
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) {
                await context.read<GradeProvider>()
                    .renameSemester(widget.semester.id, ctrl.text.trim());
              }
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSM)),
            ),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _usesGpa
        ? AppColors.gradeColor(GpaCalculator.percentageToGrade(
        _usesGpa ? _gpa / 4.0 * 100 : _pct))
        : AppColors.percentageColor(_pct);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: FadeTransition(
          opacity: _fade,
          child: CustomScrollView(
            slivers: [

              // ── SliverAppBar ─────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: AppColors.background,
                elevation: 0,
                leading: IconButton(
                  onPressed: () async {
                    if (await _onWillPop()) Navigator.pop(context);
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.85),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.textSecondary, size: 18),
                  ),
                ),
                actions: [
                  // Rename
                  IconButton(
                    onPressed: _showRenameDialog,
                    icon: const Icon(Icons.drive_file_rename_outline_rounded,
                        color: AppColors.textSecondary, size: 20),
                  ),
                  // Save
                  if (_hasChanges)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: _saveChanges,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.gradeA.withOpacity(0.18),
                            borderRadius:
                            BorderRadius.circular(AppConstants.radiusMD),
                            border: Border.all(
                                color: AppColors.gradeA.withOpacity(0.5)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.save_rounded,
                                color: AppColors.gradeA, size: 15),
                            const SizedBox(width: 5),
                            Text('Save',
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.gradeA,
                                    fontWeight: FontWeight.w700)),
                          ]),
                        ),
                      ),
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withOpacity(0.25),
                              AppColors.background,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // decorative blob
                      Positioned(
                        top: -30, right: -30,
                        child: Container(
                          width: 180, height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withOpacity(0.10),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 24, left: 24, right: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Consumer<GradeProvider>(
                              builder: (_, p, __) => Text(
                                p.semesters
                                    .firstWhere((s) => s.id == widget.semester.id,
                                    orElse: () => widget.semester)
                                    .name,
                                style: AppTextStyles.headline,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(children: [
                              _InfoPill(
                                _usesGpa
                                    ? _gpa.toStringAsFixed(2)
                                    : '${_pct.toStringAsFixed(1)}%',
                                _usesGpa ? 'GPA' : 'Avg',
                                color,
                              ),
                              const SizedBox(width: 8),
                              _InfoPill('${_subjects.length}', 'Subjects',
                                  AppColors.teal),
                              if (_usesGpa) ...[
                                const SizedBox(width: 8),
                                _InfoPill(
                                    '${GpaCalculator.totalCredits(_subjects)}',
                                    'Credits', AppColors.violet),
                              ],
                            ]),
                            const SizedBox(height: 6),
                            Text(
                              '${widget.semester.createdAt.day}/${widget.semester.createdAt.month}/${widget.semester.createdAt.year}',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Subject list ──────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.all(AppConstants.paddingLG),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (_, i) {
                      if (i == _subjects.length) return _buildAddButton();
                      final s     = _subjects[i];
                      final sColor = _usesGpa
                          ? AppColors.gradeColor(s.grade)
                          : AppColors.percentageColor(s.percentage ?? 0);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppConstants.paddingSM),
                        child: _buildSubjectTile(i, s, sColor),
                      );
                    },
                    childCount: _subjects.length + 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectTile(int index, SubjectModel s, Color color) {
    return Dismissible(
      key: Key('${s.id}_$index'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusLG)),
            title: Text('Remove Subject', style: AppTextStyles.title),
            content: Text('Remove "${s.name}" from this semester?',
                style: AppTextStyles.body),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel',
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rose,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusSM)),
                ),
                child: const Text('Remove'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => _removeSubject(index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppConstants.paddingLG),
        decoration: BoxDecoration(
          color: AppColors.rose.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.rose),
      ),
      child: GestureDetector(
        onTap: () => _showEditSubjectSheet(index),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingMD),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(children: [
            // Left accent bar
            Container(
              width: 3, height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppConstants.paddingMD),

            // Grade badge
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                border: Border.all(color: color.withOpacity(0.25)),
              ),
              child: Center(
                child: Text(
                  _usesGpa
                      ? s.grade
                      : '${s.percentage?.toStringAsFixed(0) ?? '--'}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.paddingMD),

            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.name,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(
                  _usesGpa
                      ? '${s.credits} credits  •  ${(AppConstants.gradePoints[s.grade] ?? 0).toStringAsFixed(1)} pts'
                      : '${s.marksScored?.toStringAsFixed(0) ?? '--'} / ${s.maxMarks?.toStringAsFixed(0) ?? '--'} marks',
                  style: AppTextStyles.caption,
                ),
              ]),
            ),

            // Edit icon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppConstants.radiusSM),
              ),
              child: const Icon(Icons.edit_rounded,
                  color: AppColors.textSecondary, size: 16),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _showAddSubjectSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.accentGlow,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(
              color: AppColors.accent.withOpacity(0.35),
              style: BorderStyle.solid),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.add_rounded, color: AppColors.accent, size: 20),
          const SizedBox(width: 8),
          Text('Add Subject',
              style: AppTextStyles.body
                  .copyWith(color: AppColors.accent, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

// ── Edit / Add Subject bottom sheet ───────────────────────────────────────────
class _EditSubjectSheet extends StatefulWidget {
  final SubjectModel? subject;
  final bool usesGpa;
  final ValueChanged<SubjectModel> onSave;

  const _EditSubjectSheet({
    required this.subject,
    required this.usesGpa,
    required this.onSave,
  });

  @override
  State<_EditSubjectSheet> createState() => _EditSubjectSheetState();
}

class _EditSubjectSheetState extends State<_EditSubjectSheet> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _marksCtrl  = TextEditingController();
  final _maxCtrl    = TextEditingController();

  String _grade   = 'A';
  int    _credits = 3;

  @override
  void initState() {
    super.initState();
    final s = widget.subject;
    if (s != null) {
      _nameCtrl.text  = s.name;
      _grade          = s.grade;
      _credits        = s.credits;
      _marksCtrl.text = s.marksScored?.toStringAsFixed(0) ?? '';
      _maxCtrl.text   = s.maxMarks?.toStringAsFixed(0) ?? '';
    }
    _marksCtrl.addListener(_autoGrade);
    _maxCtrl.addListener(_autoGrade);
  }

  void _autoGrade() {
    final scored = double.tryParse(_marksCtrl.text);
    final max    = double.tryParse(_maxCtrl.text);
    if (scored != null && max != null && max > 0) {
      final pct = (scored / max) * 100;
      setState(() => _grade = GpaCalculator.percentageToGrade(pct));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _marksCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final subject = SubjectModel(
      id:          widget.subject?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name:        _nameCtrl.text.trim(),
      grade:       _grade,
      credits:     _credits,
      marksScored: widget.usesGpa ? null : double.tryParse(_marksCtrl.text),
      maxMarks:    widget.usesGpa ? null : double.tryParse(_maxCtrl.text),
    );
    widget.onSave(subject);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.subject != null;
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLG),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingMD),
              Text(isEdit ? 'Edit Subject' : 'Add Subject',
                  style: AppTextStyles.title),
              const SizedBox(height: AppConstants.paddingMD),

              // Name field
              Text('SUBJECT NAME', style: AppTextStyles.label),
              const SizedBox(height: AppConstants.paddingSM),
              _field(_nameCtrl, 'e.g. Mathematics',
                  validator: (v) => v!.trim().isEmpty ? 'Enter name' : null),
              const SizedBox(height: AppConstants.paddingMD),

              if (widget.usesGpa) ...[
                // Grade
                Text('LETTER GRADE', style: AppTextStyles.label),
                const SizedBox(height: AppConstants.paddingSM),
                GradeDropdown(
                    value: _grade,
                    onChanged: (v) => setState(() => _grade = v!)),
                const SizedBox(height: AppConstants.paddingMD),

                // Credits
                Text('CREDIT HOURS', style: AppTextStyles.label),
                const SizedBox(height: AppConstants.paddingSM),
                Row(
                  children: AppConstants.creditOptions.map((c) {
                    final sel = _credits == c;
                    return GestureDetector(
                      onTap: () => setState(() => _credits = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: sel ? AppColors.accent : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                          border: Border.all(
                              color: sel ? AppColors.accent : AppColors.cardBorder),
                        ),
                        child: Center(
                          child: Text('$c',
                              style: AppTextStyles.body.copyWith(
                                color: sel ? AppColors.background : AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              )),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ] else ...[
                // Marks fields
                Text('MARKS', style: AppTextStyles.label),
                const SizedBox(height: AppConstants.paddingSM),
                Row(children: [
                  Expanded(
                    child: _field(_marksCtrl, 'Scored',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) =>
                        v!.trim().isEmpty ? 'Enter marks' : null),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('/',
                        style: AppTextStyles.title.copyWith(
                            color: AppColors.textSecondary)),
                  ),
                  Expanded(
                    child: _field(_maxCtrl, 'Max',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) =>
                        v!.trim().isEmpty ? 'Enter max' : null),
                  ),
                ]),
                // Auto grade preview
                if (_marksCtrl.text.isNotEmpty && _maxCtrl.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppConstants.paddingSM),
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.paddingSM),
                      decoration: BoxDecoration(
                        color: AppColors.gradeA.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                      ),
                      child: Row(children: [
                        const Icon(Icons.auto_awesome_rounded,
                            color: AppColors.gradeA, size: 16),
                        const SizedBox(width: 6),
                        Text('Auto grade: $_grade',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.gradeA)),
                      ]),
                    ),
                  ),
              ],

              const SizedBox(height: AppConstants.paddingLG),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusLG)),
                    elevation: 0,
                  ),
                  child: Text(isEdit ? 'Update Subject' : 'Add Subject',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
              const SizedBox(height: AppConstants.paddingMD),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
      TextEditingController ctrl,
      String hint, {
        TextInputType? keyboardType,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: ctrl,
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
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            borderSide: const BorderSide(color: AppColors.cardBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMD, vertical: 14),
      ),
      validator: validator,
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String value, label;
  final Color color;
  const _InfoPill(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text('$value $label',
          style: AppTextStyles.caption
              .copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }
}