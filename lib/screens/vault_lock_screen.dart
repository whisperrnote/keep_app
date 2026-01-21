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
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  String? _error;

  void _handleAction() async {
    final vaultProvider = Provider.of<VaultProvider>(context, listen: false);

    if (!vaultProvider.isInitialized) {
      _handleSetup();
    } else {
      _handleUnlock();
    }
  }

  void _handleSetup() async {
    if (_passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      setState(() => _error = 'Please fill in both password fields');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final vaultProvider = Provider.of<VaultProvider>(context, listen: false);
      await vaultProvider.setupMasterPassword(_passwordController.text);

      // Clear fields
      _passwordController.clear();
      _confirmPasswordController.clear();

      widget.onUnlocked();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to setup vault: $e';
      });
    }
  }

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
      _passwordController.clear();
      widget.onUnlocked();
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Invalid master password. Data decryption failed.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vaultProvider = Provider.of<VaultProvider>(context);
    final isSetup = !vaultProvider.isInitialized;

    return Scaffold(
      backgroundColor: AppColors.voidBg,
      body: Center(
        child: SingleChildScrollView(
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
                child: Icon(
                  isSetup ? LucideIcons.shieldAlert : LucideIcons.lock,
                  size: 32,
                  color: AppColors.electric,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isSetup ? 'INITIALIZE VAULT' : 'VAULT LOCKED',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.titanium,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isSetup
                    ? 'Set a master password to protect your credentials. This cannot be recovered.'
                    : 'Enter master password to decrypt your credentials',
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
                    hintText: isSetup
                        ? 'New Master Password'
                        : 'Master Password',
                    hintStyle: GoogleFonts.inter(color: AppColors.gunmetal),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (isSetup) ...[
                const SizedBox(height: 16),
                GlassCard(
                  opacity: 0.3,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    style: GoogleFonts.inter(color: AppColors.titanium),
                    decoration: InputDecoration(
                      hintText: 'Confirm Master Password',
                      hintStyle: GoogleFonts.inter(color: AppColors.gunmetal),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
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
                  onPressed: _isLoading ? null : _handleAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electric,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.voidBg)
                      : Text(
                          isSetup ? 'SECURE VAULT' : 'UNLOCK VAULT',
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.bold,
                            color: AppColors.voidBg,
                          ),
                        ),
                ),
              ),
              if (!isSetup) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _isLoading ? null : _handleBiometricUnlock,
                  icon: const Icon(
                    LucideIcons.fingerprint,
                    color: AppColors.electric,
                  ),
                  label: Text(
                    'Use Biometrics',
                    style: GoogleFonts.inter(
                      color: AppColors.titanium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleBiometricUnlock() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final vaultProvider = Provider.of<VaultProvider>(context, listen: false);
    final success = await vaultProvider.unlockWithBiometrics();

    if (success) {
      widget.onUnlocked();
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Biometric authentication failed or not setup.';
      });
    }
  }
}
