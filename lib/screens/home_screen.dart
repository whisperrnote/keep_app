import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../core/theme/colors.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/app_bar.dart';
import '../widgets/sidebar.dart';
import 'vault_dashboard_screen.dart';
import 'totp_screen.dart';
import 'settings_screen.dart';
import 'create_credential_screen.dart';
import '../core/theme/glass_route.dart';
import '../core/providers/auth_provider.dart';
import '../widgets/ecosystem_portal.dart';
import '../widgets/ai_command_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const VaultDashboardScreen(),
    const _PlaceholderScreen(title: 'Payment Cards', icon: LucideIcons.creditCard),
    const TotpScreen(),
    const _PlaceholderScreen(title: 'Trash', icon: LucideIcons.trash2),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userInitials = authProvider.user?.name.substring(0, 1).toUpperCase() ?? 'U';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.voidBg,
      drawer: ResponsiveLayout.isDesktop(context) 
        ? null 
        : Drawer(
            width: 280,
            backgroundColor: AppColors.voidBg,
            child: KeepSidebar(
              selectedIndex: _selectedIndex,
              onTap: (index) {
                setState(() => _selectedIndex = index);
                Navigator.pop(context);
              },
            ),
          ),
      body: ResponsiveLayout(
        mobile: Stack(
          children: [
            Column(
              children: [
                KeepAppBar(
                  onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                  userInitials: userInitials,
                  onEcosystemTap: () => showDialog(
                    context: context,
                    builder: (context) => const EcosystemPortal(),
                  ),
                  onAITap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const AICommandModal(),
                  ),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _screens,
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: KeepBottomNav(
                currentIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
                onAddTap: () => Navigator.push(
                  context,
                  GlassRoute(page: const CreateCredentialScreen()),
                ),
              ),
            ),
          ],
        ),
        desktop: Row(
          children: [
            KeepSidebar(
              selectedIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
            ),
            const VerticalDivider(width: 1, color: AppColors.borderSubtle),
            Expanded(
              child: Column(
                children: [
                  KeepAppBar(
                    onMenuTap: () {},
                    userInitials: userInitials,
                    onEcosystemTap: () => showDialog(
                      context: context,
                      builder: (context) => const EcosystemPortal(),
                    ),
                    onAITap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const AICommandModal(),
                    ),
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: _screens.map((s) {
                        if (s is VaultDashboardScreen) {
                          return const VaultDashboardScreen(isDesktop: true);
                        }
                        return s;
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  const _PlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.gunmetal),
          const SizedBox(height: 16),
          Text(
            '$title Coming Soon',
            style: GoogleFonts.spaceGrotesk(
              color: AppColors.gunmetal,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We are porting this from the web platform...',
            style: GoogleFonts.inter(
              color: AppColors.carbon,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
