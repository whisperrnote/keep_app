import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:otp/otp.dart';
import 'package:base32/base32.dart';
import '../core/theme/colors.dart';
import '../widgets/glass_card.dart';
import '../core/services/vault_service.dart';
import '../core/models/totp_model.dart';
import '../core/providers/auth_provider.dart';
import 'package:flutter/services.dart';

class TotpScreen extends StatefulWidget {
  const TotpScreen({super.key});

  @override
  State<TotpScreen> createState() => _TotpScreenState();
}

class _TotpScreenState extends State<TotpScreen> {
  final VaultService _vaultService = VaultService();
  List<TotpItem> _totpSecrets = [];
  bool _isLoading = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchTotp();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchTotp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      try {
        final items = await _vaultService.listTotpSecrets(authProvider.user!.$id);
        if (mounted) {
          setState(() {
            _totpSecrets = items;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.electric))
                  : _totpSecrets.isEmpty
                      ? _buildEmptyState()
                      : _buildTotpGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTP CODES',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              Text(
                'Two-factor authentication',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gunmetal,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(LucideIcons.plus, color: AppColors.electric),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.shieldCheck, size: 64, color: AppColors.carbon),
          const SizedBox(height: 16),
          Text(
            'No codes found',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first 2FA secret key.',
            style: GoogleFonts.inter(color: AppColors.gunmetal),
          ),
        ],
      ),
    );
  }

  Widget _buildTotpGrid() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _totpSecrets.length,
      itemBuilder: (context, index) {
        return _TotpCard(totp: _totpSecrets[index]);
      },
    );
  }
}

class _TotpCard extends StatelessWidget {
  final TotpItem totp;
  const _TotpCard({required this.totp});

  String _generateCode() {
    if (totp.secretKey == '[LOCKED]' || totp.secretKey.isEmpty) return 'LOCKED';
    try {
      return OTP.generateTOTPCodeString(
        totp.secretKey,
        DateTime.now().millisecondsSinceEpoch,
        interval: totp.period,
        length: totp.digits,
        algorithm: _getAlgorithm(totp.algorithm),
        isAutollocation: true,
      );
    } catch (e) {
      return 'ERROR';
    }
  }

  Algorithm _getAlgorithm(String alg) {
    switch (alg.toUpperCase()) {
      case 'SHA256': return Algorithm.SHA256;
      case 'SHA512': return Algorithm.SHA512;
      default: return Algorithm.SHA1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = _generateCode();
    final timeRemaining = totp.period - (DateTime.now().second % totp.period);
    final progress = timeRemaining / totp.period;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        opacity: 0.3,
        padding: const EdgeInsets.all(24),
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        totp.issuer ?? 'Unknown',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        totp.accountName ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.gunmetal,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.edit2, size: 16, color: AppColors.gunmetal),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.redAccent),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied to clipboard')),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        '${code.substring(0, code.length ~/ 2)} ${code.substring(code.length ~/ 2)}',
                        style: GoogleFonts.spaceMono(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.electric,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(LucideIcons.copy, size: 16, color: AppColors.electric),
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        timeRemaining <= 5 ? Colors.redAccent : AppColors.electric,
                      ),
                    ),
                    Text(
                      '${timeRemaining}s',
                      style: GoogleFonts.spaceMono(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: timeRemaining <= 5 ? Colors.redAccent : AppColors.gunmetal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
