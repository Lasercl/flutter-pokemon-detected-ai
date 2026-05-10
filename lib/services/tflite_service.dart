import 'package:flutter/services.dart';

class TfliteService {
  static const platform = MethodChannel('pokemon.inference');
  static List<String> labels = [];

  static Future<void> loadLabels() async {
    final labelsData = await rootBundle.loadString('assets/labels.txt');
    labels = labelsData.split('\n').where((s) => s.trim().isNotEmpty).toList();
  }

  static Future<List<Map<String, dynamic>>> runInference(String imagePath) async {
    final Map<dynamic, dynamic> response = await platform.invokeMethod('runInference', {
      'imagePath': imagePath,
    });
    
    final List<dynamic> results = response['results'];
    return results.map((e) => {
      'name': labels[e['index'] as int],
      'confidence': (e['confidence'] as num).toDouble(),
    }).toList();
  }
}
