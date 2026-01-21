import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'core/providers/auth_provider.dart';
import 'core/services/vault_provider.dart';

import 'core/services/autofill/desktop_autofill_service.dart';
import 'core/services/autofill/autofill_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Desktop Services
  await windowManager.ensureInitialized();
  // hotKeyManager doesn't need ensureInitialized in this version
  await DesktopAutofillService().initialize();

  runApp(const WhisperrKeepApp());
}

class WhisperrKeepApp extends StatefulWidget {
  const WhisperrKeepApp({super.key});

  @override
  State<WhisperrKeepApp> createState() => _WhisperrKeepAppState();
}

class _WhisperrKeepAppState extends State<WhisperrKeepApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      VaultProvider().lock();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VaultProvider()),
        ChangeNotifierProvider(create: (_) => AutofillManager()),
      ],
      child: MaterialApp(
        title: 'WhisperrKeep',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
