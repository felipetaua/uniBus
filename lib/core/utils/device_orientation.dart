import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

Future<void> setPortraitOrientation() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}