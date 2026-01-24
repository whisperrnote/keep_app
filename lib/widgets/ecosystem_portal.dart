import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/colors.dart';

class EcosystemPortal extends StatelessWidget {
  const EcosystemPortal({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: const Color(0xCC0A0A0A),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 64,
                offset: const Offset(0, 32),
              ),
              BoxShadow(
                color: AppColors.electric.withOpacity(0.05),
                blurRadius: 100,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.zap, color: AppColors.electric, size: 24),
                        const SizedBox(width: 12),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                            children: [
                              const TextSpan(text: 'WHISPERR '),
                              TextSpan(
                                text: 'PORTAL',
                                style: TextStyle(color: Colors.white.withOpacity(0.4)),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(LucideIcons.x, color: Colors.white.withOpacity(0.3), size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: TextField(
                        style: GoogleFonts.inter(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Jump to app or search actions...',
                          hintStyle: GoogleFonts.inter(color: Colors.white.withOpacity(0.3)),
                          icon: Icon(LucideIcons.search, color: Colors.white.withOpacity(0.3), size: 20),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Apps Grid
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AVAILABLE GATEWAYS',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withOpacity(0.3),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _EcosystemAppTile(
                        label: 'Connect',
                        description: 'Real-time communication mesh',
                        icon: LucideIcons.messageSquare,
                        color: Colors.blueAccent,
                      ),
                      _EcosystemAppTile(
                        label: 'Flow',
                        description: 'Visual workflow orchestrator',
                        icon: LucideIcons.gitBranch,
                        color: Colors.purpleAccent,
                      ),
                      _EcosystemAppTile(
                        label: 'Keep',
                        description: 'Secure digital vault',
                        icon: LucideIcons.shield,
                        color: Colors.greenAccent,
                      ),
                      _EcosystemAppTile(
                        label: 'Note',
                        description: 'Second brain memory bank',
                        icon: LucideIcons.fileText,
                        color: AppColors.electric,
                        isActive: true,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.electric.withOpacity(0.03),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                child: Center(
                  child: Text(
                    'WHISPERR ECOSYSTEM v1.0',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.electric.withOpacity(0.4),
                      letterSpacing: 0.5,
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

class _EcosystemAppTile extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final bool isActive;

  const _EcosystemAppTile({
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? color.withOpacity(0.4) : Colors.white.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'ACTIVE',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
