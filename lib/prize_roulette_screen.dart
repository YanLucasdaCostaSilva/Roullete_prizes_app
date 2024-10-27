import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:roulette/roulette.dart'; // Importação do Material Design para interface

class PrizeRouletteScreen extends StatefulWidget {
  const PrizeRouletteScreen({super.key});

  @override
  PrizeRouletteScreenState createState() => PrizeRouletteScreenState();
}

class PrizeRouletteScreenState extends State<PrizeRouletteScreen>
    with SingleTickerProviderStateMixin {
  int numberOfPrizes = 8;
  List<String> prizeList =
      []; // Lista para armazenar os prêmios buscados do Firestore
  late RouletteController _controller;
  final Duration spinDuration = const Duration(seconds: 8);

  @override
  void initState() {
    super.initState();
    _fetchPrizes(); // Busca prêmios no Firebase ao iniciar o app
  }

  // Função para buscar os prêmios da coleção "prizes" do Firestore
  void _fetchPrizes() async {
    try {
      final prizeSnapshot =
          await FirebaseFirestore.instance.collection('prizes').get();
      setState(() {
        prizeList = prizeSnapshot.docs
            .map((doc) => doc.data())
            .first
            .values
            .map((e) => e.toString())
            .toList();
        numberOfPrizes = prizeList.length;
        _buildRoulette(); // Constroi a roleta após buscar os prêmios
      });
    } catch (e) {
      print('Erro ao buscar prêmios: $e');
    }
  }

  // Função para gerar cores aleatórias
  Color _getRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  // Função para construir a roleta com cores e prêmios
  void _buildRoulette() {
    final group = RouletteGroup.uniform(
      numberOfPrizes,
      colorBuilder: (index) => _getRandomColor(), // Gera cores aleatórias
      textBuilder: (index) =>
          prizeList.isNotEmpty ? prizeList[index] : 'Prêmio ${index + 1}',
    );

    _controller = RouletteController(group: group, vsync: this);
    setState(() {}); // Atualiza a tela
  }

  // Função para girar a roleta
  Future<void> _spinRoulette() async {
    final randomIndex = Random().nextInt(numberOfPrizes);
    _controller.rollTo(randomIndex, duration: spinDuration);

    await Future.delayed(spinDuration, () async {
      final prize = prizeList[randomIndex];
      await _showPrizeAlert(prize);
    });
  }

  // Função para exibir um alerta com o prêmio sorteado
  Future<void> _showPrizeAlert(String prize) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Prêmio Sorteado!'),
          content: Text('Você ganhou: $prize'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Roleta de Prêmios',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
      body: prizeList.isEmpty
          ? const Center(
              child: CircularProgressIndicator(), // Indicador de carregamento
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width / 2.5,
                      child: Roulette(
                        controller: _controller,
                        style: const RouletteStyle(
                          dividerThickness: 4.0,
                          textStyle: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _spinRoulette,
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(
                        MediaQuery.sizeOf(context).width / 2.5,
                        40,
                      ),
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Girar Roleta',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
