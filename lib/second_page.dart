import 'package:flutter/material.dart';

class SecondPage extends StatelessWidget {
  const SecondPage({
    Key? key,
  }) : super(key: key);

  static const String routeName = '/secondPage';

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Back', style: TextStyle(color: Colors.white)),
          ),
        ),
        backgroundColor: Colors.blue,
      );
}
