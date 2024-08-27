import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9540179751142457/5743092987';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9540179751142457/7327637397';
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get bannerAdUnitId2 {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9540179751142457/7340181462';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9540179751142457/1604677043';
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get bannerAdUnitId3 {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9540179751142457/7655876239';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9540179751142457/4139303059';
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get bannerAdUnitId4 {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9540179751142457/6620843154';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9540179751142457/3077732709';
    }
    throw UnsupportedError("Unsupported platform");
  }
}
