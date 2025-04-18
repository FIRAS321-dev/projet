import 'dart:io';

class PlatformConfig {
  static bool get isFirebaseSupported {
    // Firebase est pleinement supporté sur Android, iOS et Web
    if (Platform.isAndroid || Platform.isIOS || identical(0, 0.0)) {
      return true;
    }
    
    // Sur Windows, macOS et Linux, nous pouvons limiter certaines fonctionnalités
    return false;
  }
  
  static bool get isStorageSupported {
    // Le stockage Firebase peut être problématique sur certaines plateformes
    if (Platform.isWindows) {
      return false;
    }
    return isFirebaseSupported;
  }
}

