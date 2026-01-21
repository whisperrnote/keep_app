import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../core/theme/colors.dart';
import '../widgets/glass_card.dart';
import '../core/services/vault_provider.dart';

class VaultLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  const VaultLockScreen({super.key, required this.onUnlocked});

  @override
  State<VaultLockScreen> createState() => _VaultLockScreenState();
}

class _VaultLockScreenState extends State<VaultLockScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  void _handleUnlock() async {
    if (_passwordController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    const salt = 'constant_salt_for_prototype';
    final vaultProvider = Provider.of<VaultProvider>(context, listen: false);

    final success = await vaultProvider.unlockWithPassword(
      _passwordController.text,
      salt,
    );

    if (success) {
      widget.onUnlocked();
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Failed to unlock vault. Please check your password.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: const Icon(
                  LucideIcons.lock,
                  size: 32,
                  color: AppColors.electric,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'VAULT LOCKED',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.titanium,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter master password to decrypt your credentials',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: AppColors.gunmetal),
              ),
              const SizedBox(height: 32),
              GlassCard(
                opacity: 0.3,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: GoogleFonts.inter(color: AppColors.titanium),
                  decoration: InputDecoration(
                    hintText: 'Master Password',
                    hintStyle: GoogleFonts.inter(color: AppColors.gunmetal),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleUnlock,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electric,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.voidBg)
                      : Text(
                          'UNLOCK VAULT',
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.bold,
                            color: AppColors.voidBg,
                          ),
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
