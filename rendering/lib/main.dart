import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = false;
  Map<String, dynamic>? _pokemonData;

  Future<void> _fetchPokemonData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/ditto'));
      if (response.statusCode == 200) {
        setState(() {
          _pokemonData = json.decode(response.body);
        });
      } else {
        setState(() {
          _pokemonData = {'error': 'Failed to fetch data'};
        });
      }
    } catch (e) {
      setState(() {
        _pokemonData = {'error': 'An error occurred'};
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Lifting State Up Example'),
        ),
        body: ConditionalRenderingWidget(
          isLoading: _isLoading,
          pokemonData: _pokemonData,
          fetchPokemonData: _fetchPokemonData,
        ),
      ),
    );
  }
}

class ConditionalRenderingWidget extends StatelessWidget {
  final bool isLoading;
  final Map<String, dynamic>? pokemonData;
  final Future<void> Function() fetchPokemonData;

  const ConditionalRenderingWidget({
    super.key,
    required this.isLoading,
    required this.pokemonData,
    required this.fetchPokemonData,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: fetchPokemonData,
            child: const Text('Fetch Pokémon Data'),
          ),
          const SizedBox(height: 20),
          if (isLoading)
            const CircularProgressIndicator()
          else if (pokemonData != null)
            pokemonData!['error'] != null
                ? Text(
                    pokemonData!['error'],
                    style: const TextStyle(color: Colors.red),
                  )
                : Table(
                    border: TableBorder.all(),
                    children: [
                      TableRow(children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Key', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Value', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ]),
                      TableRow(children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Name'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(pokemonData!['name']),
                        ),
                      ]),
                      TableRow(children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Height'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(pokemonData!['height'].toString()),
                        ),
                      ]),
                      TableRow(children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Weight'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(pokemonData!['weight'].toString()),
                        ),
                      ]),
                    ],
                  )
          else
            const Text('Press the button to fetch Pokémon data'),
        ],
      ),
    );
  }
}

