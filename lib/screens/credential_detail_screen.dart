import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:otp/otp.dart';
import '../core/theme/colors.dart';
import '../widgets/glass_card.dart';
import '../core/services/autofill/desktop_autofill_service.dart';

class CredentialDetailScreen extends StatefulWidget {
  final Map<String, dynamic> credential;

  const CredentialDetailScreen({super.key, required this.credential});

  @override
  State<CredentialDetailScreen> createState() => _CredentialDetailScreenState();
}

class _CredentialDetailScreenState extends State<CredentialDetailScreen> {
  bool _showPassword = false;
  String? _copiedField;
  String _currentOTP = '------';
  double _otpProgress = 0.0;
  Timer? _otpTimer;

  @override
  void initState() {
    super.initState();
    _startOTPTimer();
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    super.dispose();
  }

  void _startOTPTimer() {
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _generateOTP();
    });
    _generateOTP();
  }

  void _generateOTP() {
    final secret = widget.credential['totpSecret'] as String?;
    if (secret == null || secret.isEmpty) {
      setState(() {
        _currentOTP = '------';
      });
      return;
    }

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final otp = OTP.generateTOTPCodeString(
        secret,
        now,
        interval: 30,
        algorithm: Algorithm.SHA1,
        isGoogle: true,
      );

      setState(() {
        _currentOTP = otp;
        _otpProgress = 1.0 - ((now / 1000) % 30) / 30;
      });
    } catch (e) {
      setState(() {
        _currentOTP = 'ERROR';
      });
    }
  }

  String get _password => widget.credential['password'] ?? 'No Password';
  String get _notes => widget.credential['notes'] ?? '';
  String get _name => widget.credential['title'] ?? 'Untitled';
  String get _username => widget.credential['username'] ?? 'No Username';
  String get _url => widget.credential['url'] ?? '';

  Future<void> _handleCopy(String value, String field) async {
    await Clipboard.setData(ClipboardData(text: value));
    setState(() => _copiedField = field);
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiedField = null);
    });
  }

  Future<void> _handleModify() async {
    // Logic to modify credential
  }

  void _handleAutofill() async {
    final desktopService = DesktopAutofillService();
    await desktopService.performAutofill(_password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBg,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.electric.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                GlassCard(
                  borderRadius: BorderRadius.zero,
                  opacity: 0.8,
                  border: const Border(
                    bottom: BorderSide(color: AppColors.borderSubtle),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          LucideIcons.arrowLeft,
                          color: AppColors.gunmetal,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SECURE ACCESS',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.electric,
                          letterSpacing: 2,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          LucideIcons.moreVertical,
                          color: AppColors.gunmetal,
                          size: 20,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlassCard(
                          opacity: 0.4,
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.surface2,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: AppColors.borderSubtle,
                                  ),
                                ),
                                child: Center(
                                  child: widget.credential['icon'] != null
                                      ? Icon(
                                          widget.credential['icon'] as IconData,
                                          color: AppColors.electric,
                                          size: 32,
                                        )
                                      : Text(
                                          _name.isNotEmpty ? _name[0] : '?',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.electric,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _name,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.titanium,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _url.isNotEmpty ? _url : 'Direct Access',
                                      style: GoogleFonts.inter(
                                        color: AppColors.gunmetal,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn().scale(
                          begin: const Offset(0.95, 0.95),
                        ),

                        const SizedBox(height: 32),

                        _buildLabel('IDENTIFIER'),
                        _buildField(value: _username, fieldId: 'username'),

                        const SizedBox(height: 24),

                        _buildLabel('KEYPHRASE'),
                        _buildField(
                          value: _password,
                          fieldId: 'password',
                          isPassword: true,
                        ),

                        const SizedBox(height: 24),

                        _buildLabel('TWO-FACTOR AUTHENTICATION'),
                        _buildTOTPCard(),

                        const SizedBox(height: 24),

                        _buildLabel('ANNOTATIONS'),
                        _buildField(
                          value: _notes.isNotEmpty
                              ? _notes
                              : 'No secure notes provided.',
                          fieldId: 'notes',
                          isMultiline: true,
                        ),

                        const SizedBox(height: 40),

                        _buildMetadataRow('Vault Entry', 'Oct 24, 2024'),
                        const SizedBox(height: 12),
                        _buildMetadataRow('Encryption', 'AES-256-GCM'),
                        const SizedBox(height: 12),
                        _buildMetadataRow('Last Sync', '2 mins ago'),

                        const SizedBox(height: 48),

                        Row(
                          children: [
                            Expanded(
                              child: _buildActionBtn(
                                LucideIcons.zap,
                                'AUTOFILL',
                                _handleAutofill,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildActionBtn(
                                LucideIcons.edit3,
                                'MODIFY',
                                _handleModify,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildActionBtn(
                          LucideIcons.trash2,
                          'PURGE CREDENTIAL',
                          () {},
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: AppColors.gunmetal,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildField({
    required String value,
    required String fieldId,
    bool isPassword = false,
    bool isMultiline = false,
  }) {
    final displayValue = isPassword && !_showPassword
        ? '••••••••••••••••'
        : value;

    return GlassCard(
      opacity: 0.3,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              displayValue,
              style: GoogleFonts.spaceMono(
                fontSize: 14,
                color: isPassword && !_showPassword
                    ? AppColors.gunmetal
                    : AppColors.titanium,
                letterSpacing: isPassword && !_showPassword ? 2 : 0,
              ),
            ),
          ),
          if (isPassword)
            IconButton(
              onPressed: () => setState(() => _showPassword = !_showPassword),
              icon: Icon(
                _showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                size: 18,
                color: AppColors.gunmetal,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _handleCopy(value, fieldId),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _copiedField == fieldId
                    ? AppColors.electric.withOpacity(0.1)
                    : AppColors.surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _copiedField == fieldId
                      ? AppColors.electric
                      : AppColors.borderSubtle,
                ),
              ),
              child: Icon(
                _copiedField == fieldId ? LucideIcons.check : LucideIcons.copy,
                size: 16,
                color: _copiedField == fieldId
                    ? AppColors.electric
                    : AppColors.gunmetal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTOTPCard() {
    return GlassCard(
      opacity: 0.3,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentOTP.contains('-')
                    ? _currentOTP
                    : '${_currentOTP.substring(0, 3)} ${_currentOTP.substring(3)}',
                style: GoogleFonts.spaceMono(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.electric,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'EXPIRES IN ${(_otpProgress * 30).toInt()}S',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.gunmetal,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _handleCopy(_currentOTP, 'otp'),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    value: _otpProgress,
                    strokeWidth: 3,
                    backgroundColor: AppColors.surface2,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.electric,
                    ),
                  ),
                ),
                Icon(
                  _copiedField == 'otp' ? LucideIcons.check : LucideIcons.clock,
                  size: 16,
                  color: AppColors.electric,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDestructive ? const Color(0xFF220505) : AppColors.surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDestructive
                ? const Color(0xFF441111)
                : AppColors.borderSubtle,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isDestructive ? Colors.red : AppColors.titanium,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDestructive ? Colors.red : AppColors.titanium,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Row(
      children: [
        const Icon(
          LucideIcons.shieldCheck,
          size: 14,
          color: AppColors.gunmetal,
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.gunmetal,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.titanium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
