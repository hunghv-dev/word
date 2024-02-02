import 'dart:async';

import 'package:base_define/base_define.dart';
import 'package:base_ui/base_ui.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_router.dart';
import 'di.dart';
import 'utils/local_push_notification_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  await LocalPushNotificationHelper.init();
  runApp(DevicePreview(
    enabled: false,
    tools: const [...DevicePreview.defaultTools],
    builder: (context) => BlocProvider(
      create: (_) => ThemeCubit(),
      child: const App(),
    ),
  ));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (_, themeMode) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeDefine.themeData,
          routerConfig: getIt<AppRouter>().config(),
        );
      },
    );
  }
}
