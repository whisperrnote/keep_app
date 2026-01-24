import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/colors.dart';
import 'logo.dart';
import 'glass_card.dart';

class KeepAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuTap;
  final String userInitials;
  final VoidCallback onEcosystemTap;
  final VoidCallback onAITap;

  const KeepAppBar({
    super.key,
    required this.onMenuTap,
    this.userInitials = 'U',
    required this.onEcosystemTap,
    required this.onAITap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: BorderRadius.zero,
      opacity: 0.8,
      border: const Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(LucideIcons.menu, color: AppColors.titanium, size: 20),
              onPressed: onMenuTap,
            ),
            const SizedBox(width: 8),
            const Logo(size: 28, showText: false),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(LucideIcons.search, size: 16, color: AppColors.gunmetal),
                    const SizedBox(width: 8),
                    Text(
                      'Search vault...',
                      style: GoogleFonts.inter(
                        color: AppColors.gunmetal,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            _HeaderIconButton(
              icon: LucideIcons.sparkles,
              color: AppColors.electric,
              onTap: onAITap,
            ),
            const SizedBox(width: 8),
            _HeaderIconButton(
              icon: LucideIcons.grip,
              color: AppColors.gunmetal,
              onTap: onEcosystemTap,
            ),
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Center(
                child: Text(
                  userInitials,
                  style: GoogleFonts.spaceMono(
                    color: AppColors.electric,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
