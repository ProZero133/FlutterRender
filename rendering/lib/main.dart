import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(PokeApiAPP());
}

class PokeApiAPP extends StatefulWidget {
  const PokeApiAPP({super.key});

  @override
  PokeApiAPPState createState() => PokeApiAPPState();
}

class PokeApiAPPState extends State<PokeApiAPP> {
  String? _currentPokemonName;
  List<dynamic>? _currentPokemonAbilities;
  String? _currentAbilityName;
  List<String> _searchHistory = [];
  List<String> _favorites = [];
  String? _firstPokemonForComparison;
  String? _secondPokemonForComparison;

  void updatePokemon(String name, List<dynamic> abilities) {
    setState(() {
      _currentPokemonName = name;
      _currentPokemonAbilities = abilities;
      if (!_searchHistory.contains(name)) {
        _searchHistory.add(name);
      }
    });
  }

  void updateAbilityName(String name) {
    setState(() {
      _currentAbilityName = name;
    });
  }

  void toggleFavorite(String pokemonName) {
    setState(() {
      if (_favorites.contains(pokemonName)) {
        _favorites.remove(pokemonName);
      } else {
        _favorites.add(pokemonName);
      }
    });
  }

  void compararPokemon(String pokemonName) {
    setState(() {
      if (_firstPokemonForComparison == null) {
        _firstPokemonForComparison = pokemonName;
      } else if (_secondPokemonForComparison == null) {
        _secondPokemonForComparison = pokemonName;
      } else {
        _firstPokemonForComparison = pokemonName;
        _secondPokemonForComparison = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(
        currentPokemonName: _currentPokemonName,
        currentPokemonAbilities: _currentPokemonAbilities,
        currentAbilityName: _currentAbilityName,
        searchHistory: _searchHistory,
        favorites: _favorites,
        firstPokemonForComparison: _firstPokemonForComparison,
        secondPokemonForComparison: _secondPokemonForComparison,
        onUpdatePokemon: updatePokemon,
        onUpdateAbilityName: updateAbilityName,
        onToggleFavorite: toggleFavorite,
        onSelectPokemonForComparison: compararPokemon,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String? currentPokemonName;
  final List<dynamic>? currentPokemonAbilities;
  final String? currentAbilityName;
  final List<String> searchHistory;
  final List<String> favorites;
  final String? firstPokemonForComparison;
  final String? secondPokemonForComparison;
  final Function(String, List<dynamic>) onUpdatePokemon;
  final Function(String) onUpdateAbilityName;
  final Function(String) onToggleFavorite;
  final Function(String) onSelectPokemonForComparison;

  const HomePage({
    super.key,
    required this.currentPokemonName,
    required this.currentPokemonAbilities,
    required this.currentAbilityName,
    required this.searchHistory,
    required this.favorites,
    required this.firstPokemonForComparison,
    required this.secondPokemonForComparison,
    required this.onUpdatePokemon,
    required this.onUpdateAbilityName,
    required this.onToggleFavorite,
    required this.onSelectPokemonForComparison,
  });

  Future<void> fetchPokemonData(
      String pokemonName, BuildContext context) async {
    try {
      final response = await http
          .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$pokemonName'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        onUpdatePokemon(
          data['name'],
          data['abilities'],
        );
      } else {
        if (context.mounted) {
          _showErrorSnackbar(context, 'No se encontró el Pokémon.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackbar(context, 'Error al obtener los datos del Pokémon.');
      }
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController pokemonSearchController =
        TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokeapi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesPage(
                    favorites: favorites,
                    onToggleFavorite: onToggleFavorite,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.compare),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ComparisonPage(
                    firstPokemon: firstPokemonForComparison,
                    secondPokemon: secondPokemonForComparison,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
              'Buscar Pokémon:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: pokemonSearchController,
                    decoration: const InputDecoration(
                      labelText: 'Ingrese el nombre o ID del Pokémon',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    final input = pokemonSearchController.text.trim();
                    if (input.isEmpty) {
                      _showErrorSnackbar(
                          context, 'Por favor, ingrese un nombre o ID.');
                    } else {
                      fetchPokemonData(input, context);
                    }
                  },
                  child: const Text('Buscar'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (searchHistory.isNotEmpty)
              Column(
                children: [
                  const Text(
                    'Historial de búsquedas:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 10,
                    children: searchHistory.map((pokemon) {
                      return ElevatedButton(
                        onPressed: () => fetchPokemonData(pokemon, context),
                        child: Text(pokemon),
                      );
                    }).toList(),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (favorites.isNotEmpty)
              Column(
                children: [
                  const Text(
                    'Favoritos:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 10,
                    children: favorites.map((pokemon) {
                      return ElevatedButton(
                        onPressed: () => fetchPokemonData(pokemon, context),
                        child: Text(pokemon),
                      );
                    }).toList(),
                  ),
                ],
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
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      onToggleFavorite(currentPokemonName!);
                    },
                    icon: Icon(
                      favorites.contains(currentPokemonName)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: favorites.contains(currentPokemonName)
                          ? Colors.red
                          : null,
                    ),
                    label: Text(
                      favorites.contains(currentPokemonName)
                          ? 'Eliminar de favoritos'
                          : 'Añadir a favoritos',
                    ),
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
  bool _isLoading = true;
  Map<String, dynamic>? _abilityData;

  @override
  void initState() {
    super.initState();
    fetchAbilityData();
  }

  Future<void> fetchAbilityData() async {
    try {
      final response = await http.get(Uri.parse(widget.abilityUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _abilityData = data;
          _isLoading = false;
        });
        widget.onUpdateAbilityName(data[
            'name']); // Actualiza el nombre de la habilidad en el estado principal
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackbar('No se pudo cargar la habilidad.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Error al obtener los datos de la habilidad.');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la habilidad'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _abilityData != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nombre: ${_abilityData!['name']}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Efecto:',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        (_abilityData!['effect_entries'] as List).firstWhere(
                          (entry) => entry['language']['name'] == 'en',
                          orElse: () => {'effect': 'No disponible'},
                        )['effect'],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                )
              : const Center(
                  child: Text('No se encontraron datos de la habilidad.'),
                ),
    );
  }
}

class ManualAbilityPage extends StatefulWidget {
  final Function(String) onUpdateAbilityName;

  const ManualAbilityPage({
    super.key,
    required this.onUpdateAbilityName,
  });

  @override
  ManualAbilityPageState createState() => ManualAbilityPageState();
}

class ManualAbilityPageState extends State<ManualAbilityPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _abilityData;

  Future<void> fetchAbilityData(String idOrName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http
          .get(Uri.parse('https://pokeapi.co/api/v2/ability/$idOrName'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _abilityData = data;
        });
        widget.onUpdateAbilityName(data[
            'name']); // Actualiza el nombre de la habilidad en el estado principal
      } else {
        setState(() {
          _abilityData = null;
        });
        _showErrorSnackbar('No se encontró la habilidad.');
      }
    } catch (e) {
      _showErrorSnackbar('Error al obtener los datos de la habilidad.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar habilidad manualmente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
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
                if (input.isEmpty) {
                  _showErrorSnackbar('Por favor, ingrese un ID o nombre.');
                } else {
                  fetchAbilityData(input);
                }
              },
              child: const Text('Buscar habilidad'),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_abilityData != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nombre: ${_abilityData!['name']}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Efecto:',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    (_abilityData!['effect_entries'] as List).firstWhere(
                      (entry) => entry['language']['name'] == 'en',
                      orElse: () => {'effect': 'No disponible'},
                    )['effect'],
                    style: const TextStyle(fontSize: 16),
                  ),
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

class ComparisonPage extends StatelessWidget {
  final String? firstPokemon;
  final String? secondPokemon;

  const ComparisonPage({
    super.key,
    required this.firstPokemon,
    required this.secondPokemon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparar Pokémon'),
      ),
      body: firstPokemon != null && secondPokemon != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Comparación entre $firstPokemon y $secondPokemon:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Aquí puedes agregar más detalles de comparación
              ],
            )
          : const Center(
              child: Text('Selecciona dos Pokémon para comparar.'),
            ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  final List<String> favorites;
  final Function(String) onToggleFavorite;

  const FavoritesPage({
    super.key,
    required this.favorites,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon Favoritos'),
      ),
      body: favorites.isNotEmpty
          ? ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final pokemon = favorites[index];
                return ListTile(
                  title: Text(pokemon),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      onToggleFavorite(pokemon);
                    },
                  ),
                );
              },
            )
          : const Center(
              child: Text('No hay Pokémon favoritos.'),
            ),
    );
  }
}
