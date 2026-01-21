import 'package:flutter/services.dart';

class AutofillTransport {
  AutofillTransport._();
  static final AutofillTransport instance = AutofillTransport._();

  Future<void> performAutofill(String payload) async {
    if (payload.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: payload));
  }
}
