import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/colors.dart';
import '../widgets/glass_card.dart';
import '../core/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBg,
      body: Stack(
        children: [
          // Background Gradient
          Positioned(
            bottom: -150,
            right: -150,
            child: Container(
              width: 400,
              height: 400,
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
                // Header
                GlassCard(
                  borderRadius: BorderRadius.zero,
                  opacity: 0.8,
                  border: const Border(bottom: BorderSide(color: AppColors.borderSubtle)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.arrowLeft, color: AppColors.gunmetal, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'CONFIGURATION',
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
                      // User Profile
                      _buildProfileCard(),
                      
                      const SizedBox(height: 32),
                      
                      _buildSectionLabel('SYSTEM PREFERENCES'),
                      const SizedBox(height: 12),
                      _buildSettingToggle('AI Assistance', 'Enhanced cognitive synthesis', true),
                      _buildSettingToggle('Tactile Haptics', 'Physical confirmation responses', true),
                      _buildSettingToggle('Biometric Guard', 'Fingerprint/Passkey entry', false),

                      const SizedBox(height: 32),
                      
                      _buildSectionLabel('ATMOSPHERE'),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildAtmosphereChip('VOID', AppColors.voidBg, true),
                            _buildAtmosphereChip('MIDNIGHT', const Color(0xFF001A33), false),
                            _buildAtmosphereChip('NEBULA', const Color(0xFF1A0033), false),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      
                      _buildSectionLabel('ACCOUNT ACTIONS'),
                      const SizedBox(height: 12),
                      _buildActionItem(LucideIcons.shieldCheck, 'Security Audit', () {}),
                      _buildActionItem(LucideIcons.cloud, 'Data Synchronization', () {}),
                      _buildActionItem(LucideIcons.logOut, 'Terminate Session', () {
                        context.read<AuthProvider>().logout();
                        Navigator.pop(context);
                      }, isDestructive: true),

                      const SizedBox(height: 48),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'WHISPERRKEEP v1.0.0',
                              style: GoogleFonts.spaceMono(
                                fontSize: 10,
                                color: AppColors.gunmetal,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Zero-knowledge password vault.',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: AppColors.gunmetal.withOpacity(0.5),
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
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return GlassCard(
      opacity: 0.4,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppColors.electric,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.voidBg, width: 2),
            ),
            child: Center(
              child: Text(
                'U',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.voidBg,
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
                  'Unknown User',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.titanium,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.electricDim,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'PRO ACCOUNT',
                    style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.electric,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.edit2, size: 18, color: AppColors.gunmetal),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: AppColors.gunmetal,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildSettingToggle(String title, String subtitle, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        opacity: 0.3,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.titanium,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.gunmetal,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: (v) {},
              activeColor: AppColors.electric,
              activeTrackColor: AppColors.electricDim,
              inactiveThumbColor: AppColors.gunmetal,
              inactiveTrackColor: AppColors.surface2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAtmosphereChip(String label, Color color, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.electric : AppColors.borderSubtle,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12, height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.titanium : AppColors.gunmetal,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: GlassCard(
          opacity: 0.3,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 18, color: isDestructive ? Colors.red : AppColors.gunmetal),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDestructive ? Colors.red : AppColors.titanium,
                ),
              ),
              const Spacer(),
              Icon(LucideIcons.chevronRight, size: 16, color: AppColors.gunmetal.withOpacity(0.3)),
            ],
          ),
        ),
      ),
    );
  }
}
