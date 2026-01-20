import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/colors.dart';
import '../widgets/responsive_layout.dart';
import 'vault_dashboard_screen.dart';
import 'settings_screen.dart';
import '../core/theme/glass_route.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBg,
      body: ResponsiveLayout(
        mobile: const VaultDashboardScreen(),
        desktop: _DesktopKeep(),
      ),
    );
  }
}

class _DesktopKeep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _DesktopSidebar(),
        const VerticalDivider(width: 1, color: AppColors.borderSubtle),
        const Expanded(child: VaultDashboardScreen(isDesktop: true)),
      ],
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.voidBg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: const Icon(
                    LucideIcons.shieldCheck,
                    color: AppColors.electric,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'WhisperrKeep',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.titanium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _SidebarItem(
            icon: LucideIcons.lock,
            label: 'All Vaults',
            isActive: true,
          ),
          _SidebarItem(icon: LucideIcons.creditCard, label: 'Cards'),
          _SidebarItem(icon: LucideIcons.user, label: 'Identities'),
          _SidebarItem(icon: LucideIcons.trash2, label: 'Trash'),
          const Spacer(),
          _SidebarItem(
            icon: LucideIcons.settings,
            label: 'Settings',
            onTap: () => Navigator.push(
              context,
              GlassRoute(page: const SettingsScreen()),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? AppColors.electric : AppColors.gunmetal,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: isActive ? AppColors.titanium : AppColors.gunmetal,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
