import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  String? _currentPokemonName;
  List<dynamic>? _currentPokemonAbilities;
  String? _currentAbilityName;

  void updatePokemon(String name, List<dynamic> abilities) {
    setState(() {
      _currentPokemonName = name;
      _currentPokemonAbilities = abilities;
    });
  }

  void updateAbilityName(String name) {
    setState(() {
      _currentAbilityName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(
        currentPokemonName: _currentPokemonName,
        currentPokemonAbilities: _currentPokemonAbilities,
        currentAbilityName: _currentAbilityName,
        onUpdatePokemon: updatePokemon,
        onUpdateAbilityName: updateAbilityName,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String? currentPokemonName;
  final List<dynamic>? currentPokemonAbilities;
  final String? currentAbilityName;
  final Function(String, List<dynamic>) onUpdatePokemon;
  final Function(String) onUpdateAbilityName;

  const HomePage({
    super.key,
    required this.currentPokemonName,
    required this.currentPokemonAbilities,
    required this.currentAbilityName,
    required this.onUpdatePokemon,
    required this.onUpdateAbilityName,
  });

  Future<void> fetchPokemonData(String pokemonName) async {
    try {
      final response = await http
          .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$pokemonName'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        onUpdatePokemon(
          data['name'],
          data['abilities'],
        );
      }
    } catch (e) {
      debugPrint('Error fetching Pokémon data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> pokemonList = [
      'pikachu',
      'bulbasaur',
      'charmander',
      'squirtle',
      'eevee'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokeapi'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (currentAbilityName != null)
              Table(
                border: TableBorder.all(),
                children: [
                  TableRow(children: [
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: const Text(
                        'Habilidad actual',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: Text(currentAbilityName!),
                    ),
                  ]),
                ],
              )
            else
              const Text('No se ha seleccionado ninguna habilidad'),
            const SizedBox(height: 20),
            const Text(
              'Selecciona un Pokémon:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: pokemonList.map((pokemon) {
                return ElevatedButton(
                  onPressed: () => fetchPokemonData(pokemon),
                  child: Text(pokemon),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (currentPokemonName != null)
              Column(
                children: [
                  Text(
                    'Habilidades de $currentPokemonName:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (currentPokemonAbilities != null)
                    Wrap(
                      spacing: 10,
                      children: currentPokemonAbilities!.map((ability) {
                        return ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AbilityPage(
                                  abilityUrl: ability['ability']['url'],
                                  onUpdateAbilityName: onUpdateAbilityName,
                                ),
                              ),
                            );
                          },
                          child: Text(ability['ability']['name']),
                        );
                      }).toList(),
                    ),
                ],
              )
            else
              const Text('No se ha seleccionado ningún Pokémon'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManualAbilityPage(
                      onUpdateAbilityName: onUpdateAbilityName,
                    ),
                  ),
                );
              },
              child: const Text('Ir a la página de habilidades'),
            ),
          ],
        ),
      ),
    );
  }
}

class AbilityPage extends StatefulWidget {
  final String abilityUrl;
  final Function(String) onUpdateAbilityName;

  const AbilityPage({
    super.key,
    required this.abilityUrl,
    required this.onUpdateAbilityName,
  });

  @override
  AbilityPageState createState() => AbilityPageState();
}

class AbilityPageState extends State<AbilityPage> {
  bool _isLoading = false;
  Map<String, dynamic>? _abilityData;

  Future<void> fetchAbilityData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(widget.abilityUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _abilityData = data;
        });
        widget.onUpdateAbilityName(data['name']); // Update the ability name in the parent
      } else {
        setState(() {
          _abilityData = {'error': 'Error al obtener la información'};
        });
      }
    } catch (e) {
      setState(() {
        _abilityData = {'error': 'Error al obtener la información'};
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAbilityData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la habilidad'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _abilityData != null
                ? _abilityData!['error'] != null
                    ? Text(
                        _abilityData!['error'],
                        style: const TextStyle(color: Colors.red),
                      )
                    : Table(
                        border: TableBorder.all(),
                        children: [
                          TableRow(children: [
                            Container(
                              margin: const EdgeInsets.all(8),
                              child: const Text(
                                'Nombre',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(8),
                              child: Text(_abilityData!['name']),
                            ),
                          ]),
                          TableRow(children: [
                            Container(
                              margin: const EdgeInsets.all(8),
                              child: const Text(
                                'Efecto',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(8),
                              child: Text(
                                (_abilityData!['effect_entries'] as List)
                                    .firstWhere(
                                      (entry) =>
                                          entry['language']['name'] == 'en',
                                      orElse: () => {'effect': 'No data'},
                                    )['effect'],
                              ),
                            ),
                          ]),
                        ],
                      )
                : const Text('No se encontraron datos'),
      ),
    );
  }
}

class ManualAbilityPage extends StatefulWidget {
  final Function(String) onUpdateAbilityName;

  const ManualAbilityPage({super.key, required this.onUpdateAbilityName});

  @override
  ManualAbilityPageState createState() => ManualAbilityPageState();
}

class ManualAbilityPageState extends State<ManualAbilityPage> {
  bool _isLoading = false;
  Map<String, dynamic>? _abilityData;
  final TextEditingController _controller = TextEditingController();

  Future<void> fetchAbilityData(String idOrName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('https://pokeapi.co/api/v2/ability/$idOrName'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _abilityData = data;
        });
        widget.onUpdateAbilityName(data['name']); // Update the ability name in the parent
      } else {
        setState(() {
          _abilityData = {'error': 'Error al obtener la información'};
        });
      }
    } catch (e) {
      setState(() {
        _abilityData = {'error': 'Error al obtener la información'};
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar habilidad manualmente'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Ingrese el ID o nombre de la habilidad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final input = _controller.text.trim();
                if (input.isNotEmpty) {
                  fetchAbilityData(input);
                }
              },
              child: const Text('Buscar habilidad'),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_abilityData != null)
              _abilityData!['error'] != null
                  ? Text(
                      _abilityData!['error'],
                      style: const TextStyle(color: Colors.red),
                    )
                  : Table(
                      border: TableBorder.all(),
                      children: [
                        TableRow(children: [
                          Container(
                            margin: const EdgeInsets.all(8),
                            child: const Text(
                              'Nombre',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(8),
                            child: Text(_abilityData!['name']),
                          ),
                        ]),
                        TableRow(children: [
                          Container(
                            margin: const EdgeInsets.all(8),
                            child: const Text(
                              'Efecto',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(8),
                            child: Text(
                              (_abilityData!['effect_entries'] as List)
                                  .firstWhere(
                                    (entry) =>
                                        entry['language']['name'] == 'en',
                                    orElse: () => {'effect': 'No data'},
                                  )['effect'],
                            ),
                          ),
                        ]),
                      ],
                    )
            else
              const Text('Ingrese un ID o nombre para buscar la habilidad'),
          ],
        ),
      ),
    );
  }
}