import 'package:flutter/material.dart';
import '../../core/pokedex_colors.dart';
import '../../services/poke_api_service.dart';
import '../widgets/pokedex_components.dart';

class PokemonDetailPage extends StatefulWidget {
  final String pokemonName;
  final double confidence;

  const PokemonDetailPage({
    super.key,
    required this.pokemonName,
    required this.confidence,
  });

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  Map<String, dynamic>? _pokedexData;
  List<dynamic> _varieties = [];
  String _currentFormName = '';
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    String queryName = widget.pokemonName.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );
    if (queryName == 'mrmime') queryName = 'mr-mime';
    _currentFormName = queryName;

    final varieties = await PokeApiService.fetchSpeciesVarieties(queryName);
    if (varieties != null) {
      _varieties = varieties;
      for (var v in _varieties) {
        if (v['is_default'] == true) {
          _currentFormName = v['pokemon']['name'];
          break;
        }
      }
    }

    await _fetchData(_currentFormName);
  }

  Future<void> _fetchData(String formName) async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });
    final data = await PokeApiService.fetchPokemonData(formName);
    if (data != null) {
      setState(() {
        _pokedexData = data;
        _currentFormName = formName;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: PokedexColors.red,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text(
                'DOWNLOADING POKÉDEX DATA...',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isError || _pokedexData == null) {
      return Scaffold(
        backgroundColor: PokedexColors.red,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'DATA NOT FOUND',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
    }

    final spriteUrl =
        _pokedexData!['sprites']['other']['official-artwork']['front_default'] ??
        _pokedexData!['sprites']['front_default'];
    final height = (_pokedexData!['height'] * 10).toString(); // cm
    final weight = (_pokedexData!['weight'] / 10).toString(); // kg
    final typesList = _pokedexData!['types'] as List;
    final types = typesList
        .map((t) => t['type']['name'])
        .join(' / ')
        .toUpperCase();

    final statsList = _pokedexData!['stats'] as List;
    int hp = 0, atk = 0, def = 0, spAtk = 0, spDef = 0, spd = 0;
    for (var s in statsList) {
      final name = s['stat']['name'];
      final val = s['base_stat'];
      if (name == 'hp') hp = val;
      if (name == 'attack') atk = val;
      if (name == 'defense') def = val;
      if (name == 'special-attack') spAtk = val;
      if (name == 'special-defense') spDef = val;
      if (name == 'speed') spd = val;
    }

    return Scaffold(
      backgroundColor: PokedexColors.red,
      appBar: AppBar(
        backgroundColor: PokedexColors.red,
        foregroundColor: Colors.white,
        title: const Text(
          'DATA ENTRY',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: PokedexColors.lightGrey,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: PokedexColors.darkGrey, width: 4),
              boxShadow: const [
                BoxShadow(color: Colors.black26, offset: Offset(4, 4)),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: const BoxDecoration(
                    color: PokedexColors.darkGrey,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        widget.pokemonName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: PokedexColors.lcdGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'MATCH ${(widget.confidence * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Image
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: PokedexColors.border, width: 3),
                    ),
                    child: spriteUrl != null
                        ? Image.network(spriteUrl, fit: BoxFit.contain)
                        : const Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.grey,
                          ),
                  ),
                ),

                // Types & Info
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PokedexColors.lcdGreen,
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'TYPE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            types,
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'HT / WT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$height cm / $weight kg',
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Form Selector
                if (_varieties.length > 1)
                  Container(
                    height: 36,
                    margin: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 12,
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _varieties.length,
                      itemBuilder: (context, index) {
                        final vName = _varieties[index]['pokemon']['name'];
                        final isSelected = vName == _currentFormName;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              vName.toUpperCase().replaceAll('-', ' '),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            selected: isSelected,
                            showCheckmark: false,
                            selectedColor: PokedexColors.red,
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                            onSelected: (selected) {
                              if (selected && !isSelected) {
                                _fetchData(vName);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),

                // Base Stats
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: PokedexColors.border, width: 3),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BASE STATS',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const Divider(color: Colors.black54, thickness: 2),
                        StatBar(label: 'HP', value: hp, color: Colors.green),
                        StatBar(label: 'ATK', value: atk, color: Colors.red),
                        StatBar(label: 'DEF', value: def, color: Colors.blue),
                        StatBar(
                          label: 'SP.ATK',
                          value: spAtk,
                          color: Colors.purple,
                        ),
                        StatBar(
                          label: 'SP.DEF',
                          value: spDef,
                          color: Colors.indigo,
                        ),
                        StatBar(label: 'SPD', value: spd, color: Colors.orange),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
