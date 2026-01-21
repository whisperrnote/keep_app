import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/services.dart';
import '../core/theme/colors.dart';
import '../widgets/glass_card.dart';

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() =>
      _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  double _length = 16;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  bool _includeUppercase = true;
  String _generatedPassword = '••••••••••••••••';

  void _generate() {
    // Mock generation for UI
    const chars = 'abcdefghijklmnopqrstuvwxyz';
    const nums = '0123456789';
    const syms = '!@#\$%^&*()';
    const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    String pool = chars;
    if (_includeNumbers) pool += nums;
    if (_includeSymbols) pool += syms;
    if (_includeUppercase) pool += upper;

    setState(() {
      _generatedPassword = List.generate(
        _length.toInt(),
        (index) => pool[index % pool.length],
      ).join();
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header
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
                        'KEY GENERATOR',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.electric,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      // Password Display
                      GlassCard(
                        opacity: 0.4,
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Text(
                              _generatedPassword,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.spaceMono(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _generatedPassword.contains('•')
                                    ? AppColors.gunmetal
                                    : AppColors.electric,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildCircleAction(
                                  LucideIcons.refreshCw,
                                  _generate,
                                ),
                                const SizedBox(width: 24),
                                _buildCircleAction(LucideIcons.copy, () {
                                  Clipboard.setData(
                                    ClipboardData(text: _generatedPassword),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Copied to clipboard'),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      _buildLabel('ENTROPY PARAMETERS'),
                      const SizedBox(height: 16),

                      GlassCard(
                        opacity: 0.3,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Length',
                                  style: GoogleFonts.inter(
                                    color: AppColors.titanium,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${_length.toInt()}',
                                  style: GoogleFonts.spaceMono(
                                    color: AppColors.electric,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Slider(
                              value: _length,
                              min: 8,
                              max: 64,
                              activeColor: AppColors.electric,
                              inactiveColor: AppColors.surface2,
                              onChanged: (val) => setState(() => _length = val),
                            ),
                            const SizedBox(height: 24),
                            _buildToggle(
                              'Include Numbers (0-9)',
                              _includeNumbers,
                              (v) => setState(() => _includeNumbers = v),
                            ),
                            _buildToggle(
                              'Include Symbols (!@#)',
                              _includeSymbols,
                              (v) => setState(() => _includeSymbols = v),
                            ),
                            _buildToggle(
                              'Include Uppercase (A-Z)',
                              _includeUppercase,
                              (v) => setState(() => _includeUppercase = v),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _generate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.electric,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'GENERATE SECURE KEY',
                            style: GoogleFonts.spaceGrotesk(
                              color: AppColors.voidBg,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
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
    return Text(
      text,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: AppColors.gunmetal,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildCircleAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Icon(icon, color: AppColors.titanium, size: 24),
      ),
    );
  }

  Widget _buildToggle(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(color: AppColors.gunmetal, fontSize: 14),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.electric,
            activeTrackColor: AppColors.electricDim,
            inactiveThumbColor: AppColors.gunmetal,
            inactiveTrackColor: AppColors.surface2,
          ),
        ],
      ),
    );
  }
}
