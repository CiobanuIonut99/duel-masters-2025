import 'package:flutter/material.dart';
import 'widgets/duel_card.dart'; // import the custom card
import 'screens/game_screen.dart'; // Import new screen

import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.setLandscape();
  Flame.device.fullScreen();
  Flame.images.prefix = ''; // 👈 VERY IMPORTANT: disables "images/" prefix
  await Flame.device.fullScreen(); // Optional for mobile/web
  await Flame.device.setLandscape(); // Optional for game orientation

  runApp(DuelApp());
}

class DuelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Duel Masters UI',
      theme: ThemeData.dark(),
      home: GameScreen(), // Use the full game screen
    );
  }
}

class CardDemoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Hand")),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              DuelCard(
                frontImage: 'assets/cards/79.jpg',
                cardName: 'Bolshack Dragon',
              ),
              DuelCard(
                frontImage: 'assets/cards/aquasnipertest.jpg',
                cardName: 'Aqua Sniper',
              ),
              // Add more cards here
            ],
          ),
        ),
      ),
    );
  }
}
