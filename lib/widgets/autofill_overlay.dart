import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/autofill/autofill_manager.dart';
import '../widgets/glass_card.dart';

class AutofillOverlay extends StatelessWidget {
  const AutofillOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AutofillManager>(
      builder: (context, manager, _) {
        if (!manager.isActive) return const SizedBox.shrink();

        return Positioned.fill(
          child: Stack(
            children: [
              GestureDetector(
                onTap: manager.closeOverlay,
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
              Center(
                child: GlassCard(
                  borderRadius: BorderRadius.circular(32),
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: 640,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Search vault...',
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                          onChanged: manager.updateQuery,
                        ),
                        const SizedBox(height: 16),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 320),
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              for (final credential in manager.filteredCredentials)
                                ListTile(
                                  tileColor: Colors.white10,
                                  leading: const Icon(Icons.vpn_key, color: Colors.cyanAccent),
                                  title: Text(credential.title, style: const TextStyle(color: Colors.white)),
                                  subtitle: Text(credential.username, style: const TextStyle(color: Colors.grey)),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.keyboard_return, color: Colors.cyanAccent),
                                    onPressed: () => manager.autofillCredential(credential),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
