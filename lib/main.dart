import 'package:flutter/material.dart';
import 'package:word/local_notice_service.dart';
import 'package:word/word.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNoticeService().setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Word(),
    );
  }
}