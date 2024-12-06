import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokemon TCG',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CardListPage()),
      );
    });

    return Scaffold(
      body: Stack(
        children: [
          // Background image for the splash screen
          const Positioned.fill(
            child: Image(
              image: AssetImage('assets/pok.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pokemon TCG',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 8,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CardListPage extends StatefulWidget {
  const CardListPage({super.key});

  @override
  State<CardListPage> createState() => _CardListPageState();
}

class _CardListPageState extends State<CardListPage> {
  List<dynamic> cards = [];
  List<dynamic> filteredCards = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCards();
    _searchController.addListener(_filterCards);
  }

  Future<void> fetchCards() async {
    const apiUrl = "https://api.pokemontcg.io/v2/cards";
    const apiKey = "96f38d1c-2a50-4d4d-93e8-a148fe694b6c";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'X-Api-Key': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          cards = data['data'];
          filteredCards = cards;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load cards');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to filter cards based on search input
  void _filterCards() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredCards = cards
          .where((card) => card['name'].toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokemon Cards'),
        backgroundColor: Colors.indigo.shade700,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(cards: cards),
                );
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image applied to the whole screen
          const Positioned.fill(
            child: Image(
              image: AssetImage('assets/bck.jpg'), // Background image
              fit: BoxFit.cover,
            ),
          ),
          // Card list
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredCards.length,
                  itemBuilder: (context, index) {
                    final card = filteredCards[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CardDetailPage(card: card),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 8,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  card['images']['small'],
                                  width: 120,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      card['name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 13, 12, 12),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    if (card['supertype'] != null)
                                      Text(
                                        "Type: ${card['supertype']}",
                                        style: const TextStyle(
                                            fontSize: 14, color: Color.fromARGB(255, 19, 16, 16)),
                                      ),
                                    if (card['rarity'] != null)
                                      Text(
                                        "Rarity: ${card['rarity']}",
                                        style: const TextStyle(
                                            fontSize: 14, color: Color.fromARGB(255, 16, 13, 13)),
                                      ),
                                    if (card['set']['name'] != null)
                                      Text(
                                        "Set: ${card['set']['name']}",
                                        style: const TextStyle(
                                            fontSize: 14, color: Color.fromARGB(255, 9, 7, 7)),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

class CardDetailPage extends StatelessWidget {
  final dynamic card;

  const CardDetailPage({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(card['name']),
        backgroundColor: Colors.indigo.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  card['images']['large'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (card['supertype'] != null)
                      Text(
                        "Type: ${card['supertype']}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    if (card['rarity'] != null)
                      Text(
                        "Rarity: ${card['rarity']}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    if (card['set']['name'] != null)
                      Text(
                        "Set: ${card['set']['name']}",
                        style: const TextStyle(fontSize: 18),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final List<dynamic> cards;

  CustomSearchDelegate({required this.cards});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = cards.where((card) {
      return card['name'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final card = results[index];
        return ListTile(
          leading: Image.network(
            card['images']['small'],
            width: 50,
            height: 70,
            fit: BoxFit.cover,
          ),
          title: Text(card['name']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CardDetailPage(card: card),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = cards.where((card) {
      return card['name'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final card = suggestions[index];
        return ListTile(
          leading: Image.network(
            card['images']['small'],
            width: 50,
            height: 70,
            fit: BoxFit.cover,
          ),
          title: Text(card['name']),
          onTap: () {
            query = card['name'];
            showResults(context);
          },
        );
      },
    );
  }
}
