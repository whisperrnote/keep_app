import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../core/services/autofill/autofill_manager.dart';
import '../core/theme/colors.dart';
import '../widgets/glass_card.dart';

class AutofillOverlay extends StatelessWidget {
  const AutofillOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AutofillManager>(
      builder: (context, manager, _) {
        if (!manager.isActive) return const SizedBox.shrink();

        final isMobile = defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS;

        final content = GlassCard(
          borderRadius: BorderRadius.circular(32),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.search, color: AppColors.electric),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Search vault...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                      onChanged: manager.updateQuery,
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: manager.closeOverlay,
                    icon: const Icon(LucideIcons.x, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (manager.filteredCredentials.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'No matches yet. Try another keyword.',
                    style: const TextStyle(color: Colors.white60),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: isMobile ? 300 : 360,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: manager.filteredCredentials.length,
                    separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                    itemBuilder: (context, index) {
                      final credential = manager.filteredCredentials[index];
                      final isLast = manager.lastAutofilled?.id == credential.id;
                      return ListTile(
                        tileColor: Colors.white10,
                        leading: const Icon(LucideIcons.keyRound, color: AppColors.electric),
                        title: Text(
                          credential.title,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          credential.username,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: Icon(
                          isLast ? LucideIcons.check : LucideIcons.arrowUpRight,
                          color: isLast ? Colors.greenAccent : AppColors.electric,
                        ),
                        onTap: () => manager.autofillCredential(credential),
                      );
                    },
                  ),
                ),
            ],
          ),
        );

        return Positioned.fill(
          child: Stack(
            children: [
              GestureDetector(
                onTap: manager.closeOverlay,
                child: Container(color: Colors.black.withOpacity(0.65)),
              ),
              isMobile
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        child: content,
                      ),
                    )
                  : Center(
                      child: SizedBox(
                        width: 640,
                        child: content,
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
