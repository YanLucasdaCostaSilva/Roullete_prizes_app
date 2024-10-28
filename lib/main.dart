import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart'; // Importação correta do Firebase Core
import 'prize_roulette_screen.dart';
import 'firebase_options.dart';

// Função principal para inicializar o Firebase e rodar o aplicativo
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roleta de Prêmios',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Chama a tela da roleta
      home: const PrizeRouletteScreen(),
    );
  }
}
