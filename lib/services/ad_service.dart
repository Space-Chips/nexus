// ignore_for_file: prefer_const_constructors

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:nexus/auth/auth.dart';
import 'package:nexus/pages/ad_page.dart';

class AdPlatformSelection extends StatelessWidget {
  const AdPlatformSelection({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return AuthPage();
    } else {
      return AdPage();
    }
  }
}
