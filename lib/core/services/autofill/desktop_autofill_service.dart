import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'package:system_tray/system_tray.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:flutter/services.dart';

class DesktopAutofillService {
  static final DesktopAutofillService _instance =
      DesktopAutofillService._internal();
  factory DesktopAutofillService() => _instance;
  DesktopAutofillService._internal();

  final SystemTray _systemTray = SystemTray();
  final AppWindow _appWindow = AppWindow();
  final Menu _menu = Menu();

  Future<void> initialize() async {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      await _initTray();
      await _initHotkeys();
    }
  }

  Future<void> _initTray() async {
    String iconPath = Platform.isWindows
        ? 'assets/app_icon.ico'
        : 'assets/app_icon.png';

    try {
      await _systemTray.initSystemTray(
        title: "WhisperrKeep",
        iconPath: iconPath,
      );

      await _menu.buildFrom([
        MenuItemLabel(
          label: 'Show Vault',
          onClicked: (menuItem) => _appWindow.show(),
        ),
        MenuItemLabel(
          label: 'Lock Vault',
          onClicked: (menuItem) => _lockVault(),
        ),
        MenuSeparator(),
        MenuItemLabel(label: 'Exit', onClicked: (menuItem) => exit(0)),
      ]);

      await _systemTray.setContextMenu(_menu);
    } catch (e) {
      debugPrint("System tray init failed: $e");
    }
  }

  Future<void> _initHotkeys() async {
    await hotKeyManager.unregisterAll();

    // Quick Autofill Hotkey (Alt + Shift + A)
    HotKey autofillHotkey = HotKey(
      KeyCode.keyA,
      modifiers: [HotKeyModifier.alt, HotKeyModifier.shift],
      scope: HotKeyScope.system,
    );

    await hotKeyManager.register(
      autofillHotkey,
      keyDownHandler: (hotKey) {
        _invokeOverlay();
      },
    );
  }

  void _invokeOverlay() async {
    await windowManager.setAlwaysOnTop(true);
    await windowManager.show();
    await windowManager.focus();
  }

  void _lockVault() {
    // Global VaultProvider lock logic
  }

  Future<void> performAutofill(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
    await windowManager.hide();
  }
}
