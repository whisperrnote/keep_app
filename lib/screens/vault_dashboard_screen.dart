import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/colors.dart';
import 'credential_detail_screen.dart';
import '../core/providers/auth_provider.dart';
import '../core/services/vault_service.dart';
import '../core/models/credential_model.dart';
import '../widgets/glass_card.dart';
import 'settings_screen.dart';
import 'password_generator_screen.dart';
import 'create_credential_screen.dart';
import '../core/theme/glass_route.dart';
import 'autofill_overlay.dart';

import '../core/services/vault_provider.dart';
import '../core/services/autofill/autofill_manager.dart';
import 'vault_lock_screen.dart';

class VaultDashboardScreen extends StatefulWidget {
  final bool isDesktop;
  const VaultDashboardScreen({super.key, this.isDesktop = false});

  @override
  State<VaultDashboardScreen> createState() => _VaultDashboardScreenState();
}

class _VaultDashboardScreenState extends State<VaultDashboardScreen> {
  final VaultService _vaultService = VaultService();
  List<Credential> _credentials = [];
  bool _isLoading = true;
  String _selectedFolder = 'All';

  @override
  void initState() {
    super.initState();
    _checkVaultStatus();
  }

  Future<void> _checkVaultStatus() async {
    final vaultProvider = Provider.of<VaultProvider>(context, listen: false);
    await vaultProvider.checkInitialization();
    if (!vaultProvider.isLocked) {
      _fetchCredentials();
    }
  }

  Future<void> _fetchCredentials() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final vaultProvider = Provider.of<VaultProvider>(context, listen: false);

    if (authProvider.user != null) {
      setState(() => _isLoading = true);
      try {
        final credentials = await _vaultService.listCredentials(
          authProvider.user!.$id,
        );
        final manager = AutofillManager();
        setState(() {
          _credentials = credentials;
          _isLoading = false;
        });
        manager.updateCredentials(credentials);
      } catch (e) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Credential> get _filteredCredentials {
    if (_selectedFolder == 'All') return _credentials;
    return _credentials
        .where((c) => c.category.toLowerCase() == _selectedFolder.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final vaultProvider = Provider.of<VaultProvider>(context);

    if (vaultProvider.isLocked) {
      return VaultLockScreen(
        onUnlocked: () {
          _fetchCredentials();
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColors.voidBg,
      body: Stack(
        children: [
          // Background Gradient
          Positioned(
            top: -150,
            left: -150,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                GlassCard(
                  borderRadius: BorderRadius.zero,
                  opacity: 0.8,
                  border: const Border(
                    bottom: BorderSide(color: AppColors.borderSubtle),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VAULT',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.electric,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Digital Identity',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.titanium,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (widget.isDesktop) ...[
                            _DesktopHeaderAction(LucideIcons.plus, () async {
                              await Navigator.push(
                                context,
                                GlassRoute(
                                  page: const CreateCredentialScreen(),
                                ),
                              );
                              _fetchCredentials();
                            }, isPrimary: true),
                            const SizedBox(width: 8),
                          ],
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface2,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  GlassRoute(
                                    page: const PasswordGeneratorScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                LucideIcons.shieldAlert,
                                color: AppColors.electric,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                GlassRoute(page: const SettingsScreen()),
                              );
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.electric,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.voidBg,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  authProvider.user?.name
                                          .substring(0, 1)
                                          .toUpperCase() ??
                                      'U',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.voidBg,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchCredentials,
                    color: AppColors.electric,
                    backgroundColor: AppColors.surface,
                    child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 24,
                        ),
                        children: [
                          // Search Bar
                          _buildSearchBar(
                            onAutofillTap: () => AutofillManager().openOverlay(),
                          ),

                          const SizedBox(height: 24),

                          // Folders Filter
                          _buildPasswordHealthCard(),

                          const SizedBox(height: 24),

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFolderChip('All', _selectedFolder == 'All'),
                                _buildFolderChip(
                                  'Finance',
                                  _selectedFolder == 'Finance',
                                ),
                                _buildFolderChip(
                                  'Social',
                                  _selectedFolder == 'Social',
                                ),
                                _buildFolderChip(
                                  'Work',
                                  _selectedFolder == 'Work',
                                ),
                                _buildFolderChip(
                                  'Keys',
                                  _selectedFolder == 'Keys',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          if (_isLoading)
                            const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.electric,
                              ),
                            )
                          else if (_filteredCredentials.isEmpty)
                            Center(
                              child: Column(
                                children: [
                                  const Icon(
                                    LucideIcons.shieldOff,
                                    size: 48,
                                    color: AppColors.gunmetal,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No credentials found.',
                                    style: GoogleFonts.inter(
                                      color: AppColors.gunmetal,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (widget.isDesktop)
                            _buildDesktopCredentialsGrid()
                          else ...[
                            _buildSectionTitle('ALL CREDENTIALS'),
                            const SizedBox(height: 16),
                            ..._filteredCredentials.map(
                              (c) => _buildCredentialItem(credential: c),
                            ),
                          ],
                        ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const AutofillOverlay(),
        ],
      ),
      floatingActionButton: widget.isDesktop ? null : _buildMobileFAB(),
    );
  }

  Widget _buildSearchBar({VoidCallback? onAutofillTap}) {
    return GlassCard(
      opacity: 0.4,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(
            LucideIcons.search,
            color: AppColors.gunmetal,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              style: GoogleFonts.inter(color: AppColors.titanium),
              onChanged: (value) {
                // Implement search logic if needed
              },
              decoration: InputDecoration(
                hintText: 'Search secure vault...',
                hintStyle: GoogleFonts.inter(color: AppColors.gunmetal),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (onAutofillTap != null)
            IconButton(
              onPressed: onAutofillTap,
              icon: const Icon(
                LucideIcons.zap,
                color: AppColors.electric,
                size: 20,
              ),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  Widget _buildPasswordHealthCard() {
    int weakCount = _credentials.where((c) => c.password.length < 12).length;
    int reusedCount = 0;
    Map<String, int> counts = {};
    for (var c in _credentials) {
      counts[c.password] = (counts[c.password] ?? 0) + 1;
    }
    reusedCount = counts.values.where((v) => v > 1).length;

    return GlassCard(
      opacity: 0.3,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'VAULT HEALTH',
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.electric,
                  letterSpacing: 1.5,
                ),
              ),
              const Icon(
                LucideIcons.activity,
                size: 14,
                color: AppColors.electric,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildHealthStat(
                LucideIcons.shieldAlert,
                '$weakCount Weak',
                Colors.orange,
              ),
              const SizedBox(width: 24),
              _buildHealthStat(
                LucideIcons.copy,
                '$reusedCount Reused',
                Colors.redAccent,
              ),
              const SizedBox(width: 24),
              _buildHealthStat(
                LucideIcons.checkCircle2,
                '${_credentials.length} Total',
                AppColors.electric,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStat(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.titanium,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopCredentialsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('ALL VAULTS'),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _filteredCredentials.length,
          itemBuilder: (context, index) {
            return _buildCredentialItem(
              credential: _filteredCredentials[index],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMobileFAB() {
    return FloatingActionButton(
      onPressed: () async {
        await Navigator.push(
          context,
          GlassRoute(page: const CreateCredentialScreen()),
        );
        _fetchCredentials();
      },
      backgroundColor: AppColors.electric,
      child: const Icon(LucideIcons.plus, color: AppColors.voidBg),
    );
  }

  Widget _buildFolderChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedFolder = label),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.surface2 : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.electric.withOpacity(0.3)
                    : AppColors.borderSubtle,
              ),
            ),
            child: Row(
              children: [
                if (label != 'All') ...[
                  Icon(
                    LucideIcons.folder,
                    size: 14,
                    color: isSelected ? AppColors.electric : AppColors.gunmetal,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.titanium : AppColors.gunmetal,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.spaceMono(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.electric,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildCredentialItem({required Credential credential}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            GlassRoute(
              page: CredentialDetailScreen(credential: credential.toJson()),
            ),
          );
          _fetchCredentials();
        },
        child: GlassCard(
          opacity: 0.3,
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: const Icon(
                  LucideIcons.key,
                  color: AppColors.electric,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      credential.title,
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.titanium,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      credential.username,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.gunmetal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: AppColors.gunmetal.withOpacity(0.5),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0),
      ),
    );
  }
}

class _DesktopHeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _DesktopHeaderAction(this.icon, this.onTap, {this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.electric : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isPrimary ? AppColors.electric : AppColors.borderSubtle,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isPrimary ? AppColors.voidBg : AppColors.electric,
        ),
      ),
    );
  }
}
