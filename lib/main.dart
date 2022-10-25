import 'package:database_diagrams/firebase_options.dart';
import 'package:database_diagrams/main/main_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// ...

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: InitWidget(),
      ),
    ),
  );
}

/// App entry point.
class InitWidget extends StatelessWidget {
  /// Default constructor.
  const InitWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainView();
  }
}
