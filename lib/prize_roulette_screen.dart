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
  final Duration spinDuration = const Duration(seconds: 5);

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
  void _spinRoulette() {
    final randomIndex =
        Random().nextInt(numberOfPrizes); // Gera um índice aleatório
    _controller.rollTo(randomIndex, duration: spinDuration); // Gira a roleta

    Future.delayed(spinDuration, () {
      final prize = prizeList[randomIndex]; // Obtém o prêmio sorteado
      _showPrizeAlert(prize); // Mostra o alerta com o prêmio sorteado
      _updateRouletteColors(); // Atualiza as cores da roleta após o giro
    });
  }

  // Função para atualizar a roleta com novas cores
  void _updateRouletteColors() {
    setState(() {
      _buildRoulette(); // Reconstrói a roleta com novas cores
    });
  }

  // Função para exibir um alerta com o prêmio sorteado
  void _showPrizeAlert(String prize) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Prêmio Sorteado!'),
          content: Text('Você ganhou: $prize'),
          actions: <Widget>[
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
      ),
      body: prizeList.isEmpty
          ? const Center(
              child: CircularProgressIndicator(), // Indicador de carregamento
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    'Roleta de Prêmios',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                    height: 20), // Espaçamento entre o título e a roleta
                SizedBox(
                  height: 330, // Altura da roleta
                  width: 330, // Largura da roleta
                  child: Roulette(
                    controller: _controller, // Controla a roleta
                    style: const RouletteStyle(
                      dividerThickness: 4.0,
                      textStyle: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(
                    height: 20), // Espaçamento entre a roleta e o botão
                ElevatedButton(
                  onPressed: _spinRoulette,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 21, 30, 155),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Girar Roleta',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
