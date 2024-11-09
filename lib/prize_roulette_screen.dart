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
  // Lista para armazenar os prêmios buscados do Firestore
  List<String> prizeList = [];
  bool isRunned = false;
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
      debugPrint('Erro ao buscar prêmios: $e');
    }
  }

  // Função para construir a roleta com cores e prêmios
  void _buildRoulette() {
    final group = RouletteGroup.uniform(
      numberOfPrizes,
      colorBuilder: (index) => (index % 2 == 0)
          ? const Color(0xff4d236e)
          : const Color(0xFF8C0E7B), // Gera cores aleatórias
      textBuilder: (index) =>
          prizeList.isNotEmpty ? prizeList[index] : 'Prêmio ${index + 1}',
    );

    _controller = RouletteController(group: group, vsync: this);
    setState(() {}); // Atualiza a tela
  }

  // Função para girar a roleta
  Future<void> _spinRoulette() async {
    if (isRunned) return;
    isRunned = true;
    final randomIndex = Random().nextInt(numberOfPrizes);
    _controller.rollTo(randomIndex, duration: spinDuration);

    await Future.delayed(spinDuration, () async {
      final prize = prizeList[randomIndex];
      await _showPrizeAlert(prize);
    });
    isRunned = false;
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
                      width: MediaQuery.sizeOf(context).width / 3,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          InkWell(
                            onTap: _spinRoulette,
                            splashColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Roulette(
                              controller: _controller,
                              style: const RouletteStyle(
                                dividerThickness: 2.0,
                                centerStickSizePercent: 0,
                                textStyle: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const Positioned(
                            top: -45,
                            child: Icon(
                              Icons.arrow_drop_down_sharp,
                              size: 100,
                              color: Colors.white,
                            ),
                          ),
                        ],
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
                      backgroundColor: const Color(0xFF8C0E7B),
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
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
