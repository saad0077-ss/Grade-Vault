import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_color.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/student_type.dart';
import '../providers/grade_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;

  // edit mode
  bool _editing = false;
  final _nameCtrl   = TextEditingController();
  final _schoolCtrl = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _formKey    = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _nameCtrl.dispose();
    _schoolCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _enterEdit(GradeProvider p) {
    _nameCtrl.text   = p.userName;
    _schoolCtrl.text = p.userSchool;
    _phoneCtrl.text  = p.userPhone;
    _emailCtrl.text  = p.userEmail;
    setState(() => _editing = true);
  }

  Future<void> _saveProfile(GradeProvider p) async {
    if (!_formKey.currentState!.validate()) return;
    await p.saveUserProfile(
      name:   _nameCtrl.text.trim(),
      school: _schoolCtrl.text.trim(),
      phone:  _phoneCtrl.text.trim(),
      email:  _emailCtrl.text.trim(),
    );
    setState(() => _editing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Profile saved!'),
        backgroundColor: AppColors.gradeA,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD)),
      ));
    }
  }

  Future<void> _pickImage(GradeProvider p) async {
    final picker = ImagePicker();
    final source = await _showImageSourceSheet();
    if (source == null) return;
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) await p.setUserImagePath(picked.path);
  }

  Future<ImageSource?> _showImageSourceSheet() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXL)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  )),
              const SizedBox(height: AppConstants.paddingMD),
              Text('Choose Photo', style: AppTextStyles.title),
              const SizedBox(height: AppConstants.paddingMD),
              _SheetBtn(Icons.camera_alt_rounded, 'Take a Photo',
                      () => Navigator.pop(context, ImageSource.camera)),
              const SizedBox(height: AppConstants.paddingSM),
              _SheetBtn(Icons.photo_library_rounded, 'Choose from Gallery',
                      () => Navigator.pop(context, ImageSource.gallery)),
              const SizedBox(height: AppConstants.paddingSM),
              _SheetBtn(Icons.close_rounded, 'Cancel',
                      () => Navigator.pop(context), isDestructive: true),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GradeProvider>();
    final type     = provider.studentType;
    final color    = _typeColor(type);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fade,
        child: CustomScrollView(
          slivers: [

            // ── SliverAppBar ──────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              stretch: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
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
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => _editing
                        ? _saveProfile(provider)
                        : _enterEdit(provider),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: _editing
                            ? AppColors.gradeA.withOpacity(0.18)
                            : AppColors.surface.withOpacity(0.85),
                        borderRadius:
                        BorderRadius.circular(AppConstants.radiusMD),
                        border: Border.all(
                            color: _editing
                                ? AppColors.gradeA.withOpacity(0.5)
                                : AppColors.cardBorder),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(
                          _editing
                              ? Icons.check_rounded
                              : Icons.edit_rounded,
                          color: _editing
                              ? AppColors.gradeA
                              : AppColors.textSecondary,
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _editing ? 'Save' : 'Edit',
                          style: AppTextStyles.caption.copyWith(
                            color: _editing
                                ? AppColors.gradeA
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                ],
                background: _buildHeroBackground(provider, color, type),
              ),
            ),

            // ── Body ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsRow(provider),
                      const SizedBox(height: AppConstants.paddingLG),
                      _buildUserDetailsCard(provider),
                      const SizedBox(height: AppConstants.paddingLG),
                      _buildSectionLabel('STUDENT TYPE', Icons.school_rounded),
                      const SizedBox(height: AppConstants.paddingSM),
                      Text(
                        'Select your education level. This affects grading mode.',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: AppConstants.paddingMD),
                      _buildTypeSelector(provider),
                      const SizedBox(height: AppConstants.paddingLG),
                      _buildSectionLabel('GRADING MODE', Icons.tune_rounded),
                      const SizedBox(height: AppConstants.paddingMD),
                      _buildGradingModeCard(provider),
                      const SizedBox(height: AppConstants.paddingXXL),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero background ────────────────────────────────────────────────────────
  Widget _buildHeroBackground(GradeProvider p, Color color, StudentType? type) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.3), AppColors.background],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // decorative circles
        Positioned(top: -50, right: -50,
            child: Container(width: 230, height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.10),
                ))),
        Positioned(top: 30, left: -40,
            child: Container(width: 130, height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.07),
                ))),

        // Avatar + info centred
        Positioned(
          bottom: 28, left: 0, right: 0,
          child: Column(
            children: [
              // Avatar
              GestureDetector(
                onTap: () => _pickImage(p),
                child: Stack(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [color, color.withOpacity(0.5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: color.withOpacity(0.45),
                              blurRadius: 28,
                              spreadRadius: 2),
                        ],
                      ),
                      child: ClipOval(
                        child: p.userImagePath.isNotEmpty
                            ? Image.file(File(p.userImagePath),
                            fit: BoxFit.cover)
                            : Center(
                          child: Text(
                            p.userName.isNotEmpty
                                ? p.userName[0].toUpperCase()
                                : (type?.emoji ?? '🎓'),
                            style: TextStyle(
                              fontSize: p.userName.isNotEmpty ? 38 : 40,
                              fontWeight: FontWeight.w800,
                              color: AppColors.background,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Camera badge
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 2),
                        ),
                        child: Icon(Icons.camera_alt_rounded,
                            color: color, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                p.userName.isNotEmpty ? p.userName : 'Your Name',
                style: AppTextStyles.title.copyWith(
                  color: p.userName.isNotEmpty
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                ),
              ),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (p.userSchool.isNotEmpty) ...[
                  Icon(Icons.location_city_rounded,
                      size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(p.userSchool, style: AppTextStyles.caption),
                  const SizedBox(width: 10),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    p.usesGpa ? '📐 GPA Mode' : '📊 Percentage Mode',
                    style: AppTextStyles.caption
                        .copyWith(color: color, fontWeight: FontWeight.w700),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  // ── Stats row ──────────────────────────────────────────────────────────────
  Widget _buildStatsRow(GradeProvider p) {
    final stats = [
      _Stat(p.usesGpa
          ? p.currentGpa.toStringAsFixed(2)
          : '${p.overallPercentage.toStringAsFixed(1)}%',
          p.usesGpa ? 'GPA' : 'Overall', AppColors.accent),
      _Stat('${p.subjects.length}', 'Subjects', AppColors.teal),
      _Stat('${p.semesters.length}', 'Semesters', AppColors.violet),
      _Stat(p.usesGpa ? '${p.totalCredits}' : '${p.totalScored.toStringAsFixed(0)}',
          p.usesGpa ? 'Credits' : 'Scored', AppColors.mint),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: stats.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: i < stats.length - 1
                    ? const Border(right: BorderSide(color: AppColors.cardBorder))
                    : null,
              ),
              child: Column(children: [
                Text(s.value,
                    style: AppTextStyles.title.copyWith(color: s.color)),
                const SizedBox(height: 3),
                Text(s.label, style: AppTextStyles.caption),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── User details card ──────────────────────────────────────────────────────
  Widget _buildUserDetailsCard(GradeProvider p) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.person_rounded, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text('PERSONAL DETAILS', style: AppTextStyles.label),
          ]),
          const SizedBox(height: AppConstants.paddingMD),
          if (_editing) ...[
            _buildField(Icons.badge_rounded,     'Full Name',   _nameCtrl,
                validator: (v) => v!.trim().isEmpty ? 'Enter your name' : null),
            const SizedBox(height: AppConstants.paddingSM),
            _buildField(Icons.school_rounded,    'Institution', _schoolCtrl),
            const SizedBox(height: AppConstants.paddingSM),
            _buildField(Icons.phone_rounded,     'Phone',       _phoneCtrl,
                keyboardType: TextInputType.phone),
            const SizedBox(height: AppConstants.paddingSM),
            _buildField(Icons.email_rounded,     'Email',       _emailCtrl,
                keyboardType: TextInputType.emailAddress),
          ] else ...[
            _buildInfoRow(Icons.badge_rounded,        'Name',        p.userName.isNotEmpty ? p.userName : '—'),
            _buildInfoRow(Icons.school_rounded,       'Institution', p.userSchool.isNotEmpty ? p.userSchool : '—'),
            _buildInfoRow(Icons.phone_rounded,        'Phone',       p.userPhone.isNotEmpty ? p.userPhone : '—'),
            _buildInfoRow(Icons.email_rounded,        'Email',       p.userEmail.isNotEmpty ? p.userEmail : '—'),
            if (!p.hasProfile)
              Padding(
                padding: const EdgeInsets.only(top: AppConstants.paddingMD),
                child: GestureDetector(
                  onTap: () => _enterEdit(p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.accentGlow,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                      border: Border.all(color: AppColors.accent.withOpacity(0.35)),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.add_rounded, color: AppColors.accent, size: 18),
                      const SizedBox(width: 6),
                      Text('Add your details',
                          style: AppTextStyles.body.copyWith(
                              color: AppColors.accent, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppConstants.radiusSM),
          ),
          child: Icon(icon, color: AppColors.textSecondary, size: 16),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTextStyles.caption),
          Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }

  Widget _buildField(
      IconData icon,
      String hint,
      TextEditingController ctrl, {
        TextInputType? keyboardType,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: ctrl,
      style: AppTextStyles.body,
      keyboardType: keyboardType,
      cursorColor: AppColors.accent,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 18),
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
    );
  }

  // ── Student type selector ──────────────────────────────────────────────────
  Widget _buildSectionLabel(String title, IconData icon) {
    return Row(children: [
      Icon(icon, size: 14, color: AppColors.textSecondary),
      const SizedBox(width: 6),
      Text(title, style: AppTextStyles.label),
    ]);
  }

  Widget _buildTypeSelector(GradeProvider provider) {
    final types = [
      _CardData(StudentType.seniorSecondary,  AppColors.mint,   Icons.menu_book_rounded),
      _CardData(StudentType.higherSecondary,  AppColors.teal,   Icons.auto_stories_rounded),
      _CardData(StudentType.undergraduate,    AppColors.accent, Icons.school_rounded),
      _CardData(StudentType.postgraduate,     AppColors.violet, Icons.local_library_rounded),
    ];

    return Column(
      children: types.map((data) {
        final isSelected = provider.studentType == data.type;
        return GestureDetector(
          onTap: () async {
            await provider.setStudentType(data.type);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Switched to ${data.type.label}',
                    style: AppTextStyles.body.copyWith(color: AppColors.background)),
                backgroundColor: data.color,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD)),
                duration: const Duration(seconds: 2),
              ));
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            margin: const EdgeInsets.only(bottom: AppConstants.paddingSM),
            padding: const EdgeInsets.all(AppConstants.paddingMD),
            decoration: BoxDecoration(
              color: isSelected ? data.color.withOpacity(0.10) : AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              border: Border.all(
                  color: isSelected ? data.color : AppColors.cardBorder,
                  width: isSelected ? 2 : 1),
              boxShadow: isSelected
                  ? [BoxShadow(color: data.color.withOpacity(0.2), blurRadius: 18)]
                  : [],
            ),
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
                child: Icon(data.icon, color: data.color, size: 22),
              ),
              const SizedBox(width: AppConstants.paddingMD),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(data.type.emoji, style: const TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Text(data.type.label,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isSelected ? data.color : AppColors.textPrimary,
                        )),
                  ]),
                  Text(data.type.subtitle, style: AppTextStyles.caption),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: data.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                    ),
                    child: Text(
                      data.type.usesGpa ? '📐 GPA + Credits' : '📊 Marks / %',
                      style: AppTextStyles.caption.copyWith(
                          color: data.color, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                ]),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isSelected
                    ? Icon(Icons.check_circle_rounded,
                    color: data.color, size: 24, key: const ValueKey(true))
                    : Icon(Icons.radio_button_unchecked_rounded,
                    color: AppColors.textHint, size: 24, key: const ValueKey(false)),
              ),
            ]),
          ),
        );
      }).toList(),
    );
  }

  // ── Grading mode card ──────────────────────────────────────────────────────
  Widget _buildGradingModeCard(GradeProvider provider) {
    final usesGpa = provider.usesGpa;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(children: [
        _buildModeRow(Icons.grade_rounded, 'GPA Mode',
            '4.0 scale · Letter grades · Credit hours',
            AppColors.accent, usesGpa, top: true),
        const Divider(color: AppColors.cardBorder, height: 1),
        _buildModeRow(Icons.percent_rounded, 'Percentage Mode',
            'Marks scored · Max marks · Average %',
            AppColors.teal, !usesGpa, top: false),
      ]),
    );
  }

  Widget _buildModeRow(IconData icon, String title, String desc,
      Color color, bool active, {required bool top}) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMD),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.07) : Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft:     Radius.circular(top ? AppConstants.radiusLG : 0),
          topRight:    Radius.circular(top ? AppConstants.radiusLG : 0),
          bottomLeft:  Radius.circular(!top ? AppConstants.radiusLG : 0),
          bottomRight: Radius.circular(!top ? AppConstants.radiusLG : 0),
        ),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.15) : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppConstants.radiusSM),
          ),
          child: Icon(icon, color: active ? color : AppColors.textHint, size: 20),
        ),
        const SizedBox(width: AppConstants.paddingMD),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
                color: active ? color : AppColors.textSecondary,
              )),
          Text(desc, style: AppTextStyles.caption),
        ])),
        if (active)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text('ACTIVE',
                style: AppTextStyles.label.copyWith(color: color, fontSize: 9)),
          ),
      ]),
    );
  }

  Color _typeColor(StudentType? type) {
    switch (type) {
      case StudentType.seniorSecondary:  return AppColors.mint;
      case StudentType.higherSecondary:  return AppColors.teal;
      case StudentType.undergraduate:    return AppColors.accent;
      case StudentType.postgraduate:     return AppColors.violet;
      default:                           return AppColors.accent;
    }
  }
}

class _CardData {
  final StudentType type; final Color color; final IconData icon;
  const _CardData(this.type, this.color, this.icon);
}

class _Stat {
  final String value, label; final Color color;
  const _Stat(this.value, this.label, this.color);
}

class _SheetBtn extends StatelessWidget {
  final IconData icon; final String label;
  final VoidCallback onTap; final bool isDestructive;
  const _SheetBtn(this.icon, this.label, this.onTap, {this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.rose : AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.body.copyWith(color: color)),
        ]),
      ),
    );
  }
}