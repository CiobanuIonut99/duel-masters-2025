import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/card_model.dart';

class GameDataService {
  static Future<Map<String, List<CardModel>>> fetchInitialGameData() async {
    final response = await http.get(
      Uri.parse('https://8015-213-170-209-87.ngrok-free.app/api/games'),
      // Uri.parse('http://8015-213-170-209-87.ngrok-free.app/api/games'),
    );

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('deck') &&
            data.containsKey('shields') &&
            data.containsKey('hand')) {
          final fetchedDeck = CardModel.fromList(data['deck']);
          final fetchedShields = CardModel.fromList(data['shields']);
          final fetchedHand = CardModel.fromList(data['hand']);

          return {
            'deck': fetchedDeck,
            'shields': fetchedShields,
            'hand': fetchedHand,
          };
        } else {
          throw Exception("Missing expected keys in response");
        }
      } catch (e) {
        throw Exception("Failed to decode response: $e");
      }
    } else {
      throw Exception("Failed to load game data. Status code: ${response.statusCode}");
    }
  }
}
