import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class PokeApiService {
  static Future<List<dynamic>?> fetchSpeciesVarieties(String pokemonName) async {
    String queryName = pokemonName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (queryName == 'mrmime') queryName = 'mr-mime';

    try {
      final client = HttpClient();
      final req = await client.getUrl(Uri.parse('https://pokeapi.co/api/v2/pokemon-species/$queryName'));
      final res = await req.close();
      if (res.statusCode == 200) {
        final body = await res.transform(utf8.decoder).join();
        return json.decode(body)['varieties'];
      }
    } catch (e) {
      debugPrint("API Error: $e");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> fetchPokemonData(String formName) async {
    try {
      final client = HttpClient();
      final req = await client.getUrl(Uri.parse('https://pokeapi.co/api/v2/pokemon/$formName'));
      final res = await req.close();
      if (res.statusCode == 200) {
        final body = await res.transform(utf8.decoder).join();
        return json.decode(body);
      }
    } catch (e) {
      debugPrint("API Error: $e");
    }
    return null;
  }
}
