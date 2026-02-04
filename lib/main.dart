import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:magicful_2048/providers/game_provider.dart';
import 'package:magicful_2048/screens/entry_screen.dart';
import 'package:magicful_2048/utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: MaterialApp(
        title: '2048 Magicful',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: GameColors.gridBackground,
          ),
          useMaterial3: true,
        ),
        home: const EntryScreen(),
      ),
    );
  }
}
