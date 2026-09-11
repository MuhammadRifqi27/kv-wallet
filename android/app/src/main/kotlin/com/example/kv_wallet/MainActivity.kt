package com.example.kv_wallet

import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity instead of FlutterActivity — required by
// local_auth's biometric prompt (BiometricPrompt needs a FragmentActivity),
// see lib/core/auth/biometric_service.dart.
class MainActivity : FlutterFragmentActivity()
