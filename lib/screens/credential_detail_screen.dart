import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/colors.dart';

class CredentialDetailScreen extends StatefulWidget {
  final Map<String, dynamic> credential;

  const CredentialDetailScreen({
    super.key,
    required this.credential,
  });

  @override
  State<CredentialDetailScreen> createState() => _CredentialDetailScreenState();
}

class _CredentialDetailScreenState extends State<CredentialDetailScreen> {
  bool _showPassword = false;
  String? _copiedField;

  Future<void> _handleCopy(String value, String field) async {
    await Clipboard.setData(ClipboardData(text: value));
    setState(() => _copiedField = field);
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiedField = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBg,
      appBar: AppBar(
        backgroundColor: AppColors.voidBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.gunmetal),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Credential Details',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.titanium,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                   Container(
                     width: 64, height: 64,
                     decoration: BoxDecoration(
                       color: AppColors.surface2,
                       borderRadius: BorderRadius.circular(18),
                       border: Border.all(color: AppColors.borderSubtle),
                     ),
                     child: Center(
                       child: widget.credential['icon'] != null 
                        ? Icon(widget.credential['icon'] as IconData, color: AppColors.titanium, size: 32)
                        : Text(
                           (widget.credential['name'] as String)[0],
                           style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.electric),
                         ),
                     ),
                   ),
                   const SizedBox(width: 20),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           widget.credential['name'],
                           style: GoogleFonts.spaceGrotesk(
                             fontSize: 24,
                             fontWeight: FontWeight.bold,
                             color: AppColors.titanium,
                           ),
                         ),
                         const SizedBox(height: 8),
                         GestureDetector(
                           onTap: () {}, // Open Link
                           child: Row(
                             children: [
                               const Icon(LucideIcons.globe, size: 14, color: AppColors.electric),
                               const SizedBox(width: 4),
                               Text(
                                 'accounts.google.com',
                                 style: GoogleFonts.inter(
                                   color: AppColors.electric,
                                   fontWeight: FontWeight.w600,
                                   decoration: TextDecoration.underline,
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
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),

            const SizedBox(height: 32),

            // Username
            _buildField(
              label: 'USERNAME / EMAIL',
              value: widget.credential['username'],
              fieldId: 'username',
            ),

            const SizedBox(height: 24),

            // Password
            _buildField(
              label: 'PASSWORD',
              value: 'SuperSecretP@ssw0rd!',
              fieldId: 'password',
              isPassword: true,
            ),

            const SizedBox(height: 24),

            // Notes
            _buildField(
              label: 'NOTES',
              value: 'Use this for the main developer account.',
              fieldId: 'notes',
              isMultiline: true,
            ),

            const SizedBox(height: 32),
            const Divider(color: AppColors.borderSubtle),
            const SizedBox(height: 32),

            // Metadata
            _buildMetadataRow('Created', 'Oct 24, 2024'),
            const SizedBox(height: 8),
            _buildMetadataRow('Last Updated', 'Yesterday'),

            const SizedBox(height: 48),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.edit3),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.titanium,
                      side: const BorderSide(color: AppColors.borderSubtle),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.trash2),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Color(0xFF331111)),
                      backgroundColor: const Color(0xFF220505),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label, 
    required String value, 
    required String fieldId,
    bool isPassword = false,
    bool isMultiline = false,
  }) {
    final displayValue = isPassword && !_showPassword ? '••••••••••••••••' : value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.gunmetal,
                letterSpacing: 1,
              ),
            ),
            Row(
              children: [
                if (isPassword)
                  GestureDetector(
                    onTap: () => setState(() => _showPassword = !_showPassword),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _showPassword ? LucideIcons.eyeOff : LucideIcons.eye, 
                            size: 12, 
                            color: AppColors.titanium
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _showPassword ? 'Hide' : 'Show',
                            style: GoogleFonts.inter(fontSize: 10, color: AppColors.titanium),
                          ),
                        ],
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () => _handleCopy(value, fieldId),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _copiedField == fieldId 
                        ? const Color(0xFF10B981).withOpacity(0.2) 
                        : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _copiedField == fieldId 
                          ? const Color(0xFF10B981) 
                          : Colors.transparent
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _copiedField == fieldId ? LucideIcons.check : LucideIcons.copy, 
                          size: 12, 
                          color: _copiedField == fieldId ? const Color(0xFF10B981) : AppColors.electric
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _copiedField == fieldId ? 'Copied' : 'Copy',
                          style: GoogleFonts.inter(
                            fontSize: 10, 
                            color: _copiedField == fieldId ? const Color(0xFF10B981) : AppColors.electric,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Text(
            displayValue,
            style: GoogleFonts.spaceMono(
              fontSize: 14,
              color: isPassword && !_showPassword ? AppColors.gunmetal : AppColors.titanium,
              letterSpacing: isPassword && !_showPassword ? 2 : 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Row(
      children: [
         Icon(LucideIcons.calendar, size: 14, color: AppColors.gunmetal),
         const SizedBox(width: 8),
         Text(
           '$label: ',
           style: GoogleFonts.inter(fontSize: 12, color: AppColors.gunmetal),
         ),
         Text(
           value,
           style: GoogleFonts.inter(fontSize: 12, color: AppColors.titanium),
         ),
      ],
    );
  }
}
