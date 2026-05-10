import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/pokedex_colors.dart';
import '../../services/tflite_service.dart';
import '../widgets/pokedex_components.dart';
import 'pokemon_detail_screen.dart';

class PokemonHomePage extends StatefulWidget {
  const PokemonHomePage({super.key});

  @override
  State<PokemonHomePage> createState() => _PokemonHomePageState();
}

class _PokemonHomePageState extends State<PokemonHomePage> {
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoading = false;
  String _result = 'SYSTEM READY';

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      await TfliteService.loadLabels();
    } catch (e) {
      setState(() { _result = 'SYSTEM ERROR:\nLABELS NOT FOUND'; });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? selectedImage = await _picker.pickImage(source: source);
      if (selectedImage != null) {
        setState(() {
          _image = selectedImage;
          _result = 'ANALYZING...';
          _isLoading = true;
        });
        
        await Future.delayed(const Duration(milliseconds: 500));
        await _processImage(selectedImage);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _result = 'ERROR:\nCAMERA/GALLERY FAILED';
      });
    }
  }

  Future<void> _processImage(XFile imageFile) async {
    try {
      final results = await TfliteService.runInference(imageFile.path);
      if (results.isEmpty) return;

      final top1 = results[0];
      final top2 = results.length > 1 ? results[1] : null;

      String name1 = top1['name'];
      double conf1 = top1['confidence'];

      String? name2;
      double conf2 = 0.0;
      if (top2 != null) {
        name2 = top2['name'];
        conf2 = top2['confidence'];
      }

      setState(() { _isLoading = false; _result = 'SCAN COMPLETE'; });

      if (name2 != null && conf2 > 0.10) {
         _showSelectionDialog(name1, conf1, name2, conf2);
      } else {
         _openDetailPage(name1, conf1);
      }
    } catch (e) {
      setState(() {
        _result = 'ANALYSIS ERROR:\nCHECK SYSTEM LOGS';
        _isLoading = false;
      });
    }
  }

  void _openDetailPage(String name, double confidence) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PokemonDetailPage(pokemonName: name, confidence: confidence),
      ),
    );
  }

  Widget _buildCandidateCard(String name, double conf, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PokedexColors.darkGrey, width: 3),
          boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(2, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black87)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: PokedexColors.lcdGreen, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black)),
              child: Text('${(conf * 100).toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Courier')),
            ),
          ],
        ),
      ),
    );
  }

  void _showSelectionDialog(String name1, double conf1, String name2, double conf2) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: PokedexColors.lightGrey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: PokedexColors.border, width: 4)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
                const SizedBox(height: 12),
                const Text('MULTIPLE MATCHES', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                const SizedBox(height: 8),
                const Text(
                  'Sensors detected two possible Pokémon.\nPlease tap a card to view its Pokédex entry:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 24),
                _buildCandidateCard(name1, conf1, () {
                  Navigator.pop(context);
                  _openDetailPage(name1, conf1);
                }),
                _buildCandidateCard(name2, conf2, () {
                  Navigator.pop(context);
                  _openDetailPage(name2, conf2);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PokedexColors.red,
      body: SafeArea(
        child: Column(
          children: [
            // Top Lights
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PokedexLens(),
                  const SizedBox(width: 16),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: const [
                        PokedexSmallLight(color: Colors.redAccent), SizedBox(width: 10),
                        PokedexSmallLight(color: Colors.yellow), SizedBox(width: 10),
                        PokedexSmallLight(color: Colors.green),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.black45, thickness: 2, height: 1),
            const SizedBox(height: 20),

            // Main Screen Container
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PokedexColors.lightGrey,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(48),
                  ),
                  border: Border.all(color: PokedexColors.border, width: 3),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                        const SizedBox(width: 16),
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: PokedexColors.darkGrey,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: _image == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.catching_pokemon, size: 80, color: Colors.white.withOpacity(0.15)),
                                    const SizedBox(height: 16),
                                    Text('AWAITING INPUT', style: TextStyle(color: Colors.white.withOpacity(0.5), letterSpacing: 2, fontWeight: FontWeight.bold)),
                                  ],
                                )
                              : (kIsWeb ? Image.network(_image!.path, fit: BoxFit.cover) : Image.file(File(_image!.path), fit: BoxFit.cover)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 24, height: 24, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, offset: Offset(1, 1))])),
                        const Icon(Icons.menu, color: PokedexColors.border, size: 36),
                      ],
                    )
                  ],
                ),
              ),
            ),
            
            // Result LCD
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: PokedexColors.lcdGreen,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: PokedexColors.darkGrey, width: 4),
                boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 4))],
              ),
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Colors.black87))
                  : Text(
                      _result,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'Courier', fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: 1.2),
                    ),
            ),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0, left: 24, right: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  PokedexButton(title: 'Gallery', color: PokedexColors.yellow, textColor: Colors.black87, onTap: () => _pickImage(ImageSource.gallery)),
                  PokedexButton(title: 'Camera', color: PokedexColors.blue, textColor: Colors.white, onTap: () => _pickImage(ImageSource.camera)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
