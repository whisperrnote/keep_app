import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/colors.dart';
import '../widgets/glass_card.dart';
import '../core/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    await context.read<AuthProvider>().login(
      _emailController.text,
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBg,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.3),
                  radius: 1.5,
                  colors: [Color(0x1A00F5FF), AppColors.voidBg],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // IDMS Header
                      Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.surface2,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.electric.withOpacity(0.1),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              LucideIcons.fingerprint,
                              size: 40,
                              color: AppColors.electric,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .scale(begin: const Offset(0.8, 0.8)),

                      const SizedBox(height: 32),

                      Text(
                        'WHISPERR IDMS',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w900,
                          color: AppColors.titanium,
                        ),
                      ).animate().fadeIn(duration: 800.ms, delay: 200.ms),

                      const SizedBox(height: 8),

                      Text(
                        'Keep Vault Authentication',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.gunmetal,
                          fontWeight: FontWeight.w500,
                        ),
                      ).animate().fadeIn(duration: 800.ms, delay: 300.ms),

                      const SizedBox(height: 48),

                      GlassCard(
                            opacity: 0.4,
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInput(
                                  'IDENTIFIER',
                                  _emailController,
                                  false,
                                  LucideIcons.mail,
                                ),
                                const SizedBox(height: 24),
                                _buildInput(
                                  'KEY',
                                  _passwordController,
                                  true,
                                  LucideIcons.lock,
                                ),

                                const SizedBox(height: 40),

                                SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleLogin,
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: AppColors.voidBg,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text('AUTHORIZE'),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 800.ms, delay: 400.ms)
                          .slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(
                            LucideIcons.shieldCheck,
                            'PASSKEY',
                          ),
                          const SizedBox(width: 16),
                          _buildSocialButton(LucideIcons.key, 'MASTERPASS'),
                        ],
                      ).animate().fadeIn(duration: 800.ms, delay: 600.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller,
    bool isObscure,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            color: AppColors.gunmetal,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.voidBg.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: TextField(
            controller: controller,
            obscureText: isObscure,
            style: GoogleFonts.inter(color: AppColors.titanium),
            cursorColor: AppColors.electric,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(icon, size: 18, color: AppColors.gunmetal),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.electric),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.titanium,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
