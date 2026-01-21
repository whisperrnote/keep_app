import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../core/theme/colors.dart';
import '../widgets/glass_card.dart';
import '../core/services/vault_service.dart';
import '../core/providers/auth_provider.dart';

class CreateCredentialScreen extends StatefulWidget {
  const CreateCredentialScreen({super.key});

  @override
  State<CreateCredentialScreen> createState() => _CreateCredentialScreenState();
}

class _CreateCredentialScreenState extends State<CreateCredentialScreen> {
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  final _notesController = TextEditingController();
  final VaultService _vaultService = VaultService();

  String _category = 'Social';
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _handleSave() async {
    if (_titleController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill in required fields (Title, Username, Password)',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      if (authProvider.user != null) {
        await _vaultService.createCredential(
          userId: authProvider.user!.$id,
          title: _titleController.text,
          username: _usernameController.text,
          password: _passwordController.text,
          url: _urlController.text,
          notes: _notesController.text,
          category: _category,
        );
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to secure credential: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildLabel('ENTITY NAME'),
                      _buildTextField(
                        _titleController,
                        'e.g. GitHub, Bank of Orion',
                      ),
                      const SizedBox(height: 24),
                      _buildLabel('IDENTITY / USERNAME'),
                      _buildTextField(_usernameController, 'User identifier'),
                      const SizedBox(height: 24),
                      _buildLabel('ACCESS KEY / PASSWORD'),
                      _buildPasswordField(),
                      const SizedBox(height: 24),
                      _buildLabel('DOMAIN / URL'),
                      _buildTextField(_urlController, 'https://...'),
                      const SizedBox(height: 24),
                      _buildLabel('CATEGORY'),
                      _buildCategoryPicker(),
                      const SizedBox(height: 24),
                      _buildLabel('SECURE NOTES'),
                      _buildTextField(
                        _notesController,
                        'Any additional encrypted info...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 48),
                      _buildSaveButton(),
                      const SizedBox(height: 40),
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

  Widget _buildHeader() {
    return GlassCard(
      borderRadius: BorderRadius.zero,
      opacity: 0.8,
      border: const Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              LucideIcons.arrowLeft,
              color: AppColors.gunmetal,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            'SECURE NEW IDENTITY',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppColors.electric,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: AppColors.gunmetal,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return GlassCard(
      opacity: 0.3,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.inter(color: AppColors.titanium),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            color: AppColors.gunmetal.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return GlassCard(
      opacity: 0.3,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: GoogleFonts.spaceMono(color: AppColors.titanium),
              decoration: InputDecoration(
                hintText: '••••••••••••',
                hintStyle: GoogleFonts.inter(
                  color: AppColors.gunmetal.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
              size: 18,
              color: AppColors.gunmetal,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPicker() {
    final categories = ['Social', 'Finance', 'Work', 'Keys', 'Other'];
    return Wrap(
      spacing: 8,
      children: categories.map((cat) {
        final isSelected = _category == cat;
        return GestureDetector(
          onTap: () => setState(() => _category = cat),
          child: Chip(
            label: Text(cat),
            backgroundColor: isSelected
                ? AppColors.electricDim
                : AppColors.surface2,
            labelStyle: GoogleFonts.inter(
              fontSize: 12,
              color: isSelected ? AppColors.electric : AppColors.gunmetal,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            side: BorderSide(
              color: isSelected ? AppColors.electric : AppColors.borderSubtle,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.electric,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: AppColors.voidBg)
            : Text(
                'VAULT IDENTITY',
                style: GoogleFonts.spaceGrotesk(
                  color: AppColors.voidBg,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }
}
