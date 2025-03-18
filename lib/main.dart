import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http/io_client.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 34, 133, 255)),
        ),
        home: MyHomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

// ...

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      case 2:
        page = TravelPage();
      case 3:
        page = CalculatorPage();
      case 4:
        page = CarouselPage();
      case 5:
        page = HangmanPage();
      case 6:
        page = PokemonListPage();
      case 7:
        page = PokemonBattlePage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.travel_explore),
                    label: Text('Travel Page'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.calculate),
                    label: Text('Calculator'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.image),
                    label: Text('Carousel'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.gamepad),
                    label: Text('Hangman'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.list),
                    label: Text('Pokémon List'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.sports_martial_arts),
                    label: Text('Pokémon Battle'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class PokemonBattlePage extends StatefulWidget {
  @override
  _PokemonBattlePageState createState() => _PokemonBattlePageState();
}

class _PokemonBattlePageState extends State<PokemonBattlePage> {
  Map<String, dynamic>? _pokemon1;
  Map<String, dynamic>? _pokemon2;
  String? _winner;

  @override
  void initState() {
    super.initState();
    _fetchPokemonData();
  }

  Future<void> _fetchPokemonData() async {
    try {
      HttpClient httpClient = HttpClient();
      IOClient ioClient = IOClient(httpClient);

      final response =
          await ioClient.get(Uri.parse('https://api.pokemontcg.io/v2/cards'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> pokemonList = data['data'];
        final random = Random();
        setState(() {
          _pokemon1 = pokemonList[random.nextInt(pokemonList.length)];
          _pokemon2 = pokemonList[random.nextInt(pokemonList.length)];
          _determineWinner();
        });
      } else {
        throw Exception(
            'Failed to load Pokémon data: Status ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('⚠️ Error fetching Pokémon data: ${e.runtimeType} - $e');
      print('📌 Stack trace: $stackTrace');
      setState(() {
        _pokemon1 = null;
        _pokemon2 = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching Pokémon data: $e')),
      );
    }
  }

  void _determineWinner() {
    if (_pokemon1 != null && _pokemon2 != null) {
      int hp1 = int.tryParse(_pokemon1!['hp']) ?? 0;
      int hp2 = int.tryParse(_pokemon2!['hp']) ?? 0;

      if (hp1 > hp2) {
        _winner = '${_pokemon1!['name']} wins!';
      } else if (hp2 > hp1) {
        _winner = '${_pokemon2!['name']} wins!';
      } else {
        _winner = 'It\'s a tie!';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokémon Battle'),
      ),
      body: _pokemon1 == null || _pokemon2 == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPokemonCard(_pokemon1!),
                    _buildPokemonCard(_pokemon2!),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  _winner ?? '',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
    );
  }

  Widget _buildPokemonCard(Map<String, dynamic> pokemon) {
    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 550,
            height: 400,
            child: Image.network(
              pokemon['images']['large'],
              fit: BoxFit.contain,
            ),
          ),
          Text(pokemon['name'], style: TextStyle(fontSize: 24)),
          Text('${pokemon['hp']} HP', style: TextStyle(fontSize: 18)),
          Text(pokemon['supertype'], style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

class PokemonListPage extends StatefulWidget {
  @override
  _PokemonListPageState createState() => _PokemonListPageState();
}

class _PokemonListPageState extends State<PokemonListPage> {
  List<dynamic> _pokemonList = [];

  @override
  void initState() {
    super.initState();
    _fetchPokemonData();
  }

  // Future<void> _fetchPokemonData() async {
  //   try {
  //     final response =
  //         await http.get(Uri.parse('https://api.pokemontcg.io/v2/cards'));
  //     if (response.statusCode == 200) {
  //       print('Response Body: ${response.body}');
  //       final data = json.decode(response.body);
  //       setState(() {
  //         _pokemonList = data['data'];
  //       });
  //     } else {
  //       throw Exception(
  //           'Failed to load Pokémon data: Status ${response.statusCode}');
  //     }
  //   } catch (e, stackTrace) {
  //     print('Error fetching Pokémon data: $e');
  //     print('Stack trace: $stackTrace');
  //     setState(() {
  //       _pokemonList = [];
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error fetching Pokémon data: $e')),
  //     );
  //   }
  // }

  Future<void> _fetchPokemonData() async {
    try {
      HttpClient httpClient = HttpClient();
      IOClient ioClient = IOClient(httpClient);

      final response =
          await ioClient.get(Uri.parse('https://api.pokemontcg.io/v2/cards'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _pokemonList = data['data'];
        });
      } else {
        throw Exception(
            'Failed to load Pokémon data: Status ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('⚠️ Error fetching Pokémon data: ${e.runtimeType} - $e');
      print('📌 Stack trace: $stackTrace');
      setState(() {
        _pokemonList = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching Pokémon data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokémon List'),
      ),
      body: _pokemonList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _pokemonList.length,
              itemBuilder: (context, index) {
                final pokemon = _pokemonList[index];
                return ListTile(
                  title: Text(pokemon['name']),
                  subtitle: Text(pokemon['supertype']),
                  leading: Image.network(pokemon['images']['small']),
                );
              },
            ),
    );
  }
}

class HangmanPage extends StatefulWidget {
  @override
  _HangmanPageState createState() => _HangmanPageState();
}

class _HangmanPageState extends State<HangmanPage> {
  final List<String> words = [
    'flutter',
    'hangman',
    'dart',
    'widget',
    'provider',
    'carousel',
    'state',
    'context',
    'scaffold',
    'material',
    'navigator',
    'button',
    'column',
    'row',
    'container',
    'padding',
    'alignment',
    'gesture',
    'animation',
    'theme',
    'icon',
    'text',
    'image',
    'network',
    'asset',
    'list',
    'grid',
    'card',
    'dialog',
    'snackbar',
    'drawer',
    'sheep',
    'horse',
    'dog',
    'cat',
    'tiger',
    'penguin'
  ];
  late String selectedWord;
  late List<String> guessedLetters;
  int wrongGuesses = 0;
  final int maxWrongGuesses = 6;

  final List<String> hangmanStages = [
    '''
     -----
     |   |
         |
         |
         |
         |
    =========''',
    '''
     -----
     |   |
     O   |
         |
         |
         |
    =========''',
    '''
     -----
     |   |
     O   |
     |   |
         |
         |
    =========''',
    '''
     -----
     |   |
     O   |
    /|   |
         |
         |
    =========''',
    '''
     -----
     |   |
     O   |
    /|\\  |
         |
         |
    =========''',
    '''
     -----
     |   |
     O   |
    /|\\  |
    /    |
         |
    =========''',
    '''
     -----
     |   |
     O   |
    /|\\  |
    / \\  |
         |
    ========='''
  ];

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      final random = Random();
      selectedWord = words[random.nextInt(words.length)];
      guessedLetters = [];
      wrongGuesses = 0;
    });
  }

  void _guessLetter(String letter) {
    setState(() {
      if (!selectedWord.contains(letter)) {
        wrongGuesses++;
      }
      guessedLetters.add(letter);
    });
  }

  @override
  Widget build(BuildContext context) {
    String displayWord = selectedWord.split('').map((letter) {
      return guessedLetters.contains(letter) ? letter : '_';
    }).join(' ');

    bool isGameOver = wrongGuesses >= maxWrongGuesses;
    bool isGameWon = !displayWord.contains('_');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Hangman Game'),
            Text(
              'Guess the word by selecting letters',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              hangmanStages[wrongGuesses],
              style: TextStyle(fontSize: 18, fontFamily: 'Courier'),
            ),
            SizedBox(height: 20),
            Text(
              displayWord,
              style: TextStyle(fontSize: 32, letterSpacing: 2),
            ),
            SizedBox(height: 20),
            Text('Wrong guesses: $wrongGuesses'),
            Text('Guesses left: ${maxWrongGuesses - wrongGuesses}'),
            SizedBox(height: 20),
            if (isGameOver)
              Text(
                'Game Over! The word was "$selectedWord".',
                style: TextStyle(fontSize: 24, color: Colors.red),
              ),
            if (isGameWon)
              Text(
                'Congratulations! You guessed the word!',
                style: TextStyle(fontSize: 24, color: Colors.green),
              ),
            SizedBox(height: 20),
            if (isGameOver || isGameWon)
              ElevatedButton(
                onPressed: _startNewGame,
                child: Text('Restart'),
              ),
            if (!isGameOver && !isGameWon)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: 'abcdefghijklmnopqrstuvwxyz'.split('').map((letter) {
                  return ElevatedButton(
                    onPressed: guessedLetters.contains(letter)
                        ? null
                        : () => _guessLetter(letter),
                    child: Text(letter),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _output = "0";
  String _input = "";
  String _operator = "";
  double _num1 = 0;
  double _num2 = 0;

  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        _output = "0";
        _input = "";
        _operator = "";
        _num1 = 0;
        _num2 = 0;
      } else if (buttonText == "+" ||
          buttonText == "-" ||
          buttonText == "*" ||
          buttonText == "/") {
        if (_input.isNotEmpty) {
          _num1 = double.parse(_input);
          _operator = buttonText;
          _input = "";
        }
      } else if (buttonText == "=") {
        if (_input.isNotEmpty) {
          _num2 = double.parse(_input);
          if (_operator == "+") {
            _output = (_num1 + _num2).toString();
          } else if (_operator == "-") {
            _output = (_num1 - _num2).toString();
          } else if (_operator == "*") {
            _output = (_num1 * _num2).toString();
          } else if (_operator == "/") {
            _output = (_num1 / _num2).toString();
          }
          _input = _output;
          _operator = "";
        }
      } else {
        _input += buttonText;
        _output = _input;
      }
    });
  }

  Widget _buildButton(String buttonText) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () => _buttonPressed(buttonText),
        child: Text(
          buttonText,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          child: Text(
            _output,
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Divider(),
        ),
        Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                _buildButton("7"),
                _buildButton("8"),
                _buildButton("9"),
                _buildButton("/"),
              ],
            ),
            Row(
              children: <Widget>[
                _buildButton("4"),
                _buildButton("5"),
                _buildButton("6"),
                _buildButton("*"),
              ],
            ),
            Row(
              children: <Widget>[
                _buildButton("1"),
                _buildButton("2"),
                _buildButton("3"),
                _buildButton("-"),
              ],
            ),
            Row(
              children: <Widget>[
                _buildButton("."),
                _buildButton("0"),
                _buildButton("00"),
                _buildButton("+"),
              ],
            ),
            Row(
              children: <Widget>[
                _buildButton("C"),
                _buildButton("="),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class CarouselPage extends StatefulWidget {
  @override
  _CarouselPageState createState() => _CarouselPageState();
}

class _CarouselPageState extends State<CarouselPage> {
  final List<String> imgList = [
    'assets/shib-1.jpg',
    'assets/shib-2.jpg',
    'assets/shib-3.jpg',
    'assets/shib-4.jpg',
  ];

  bool _isAutoPlay = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shibas of the World'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 400.0,
                  autoPlay: _isAutoPlay,
                  autoPlayInterval: Duration(seconds: 3),
                  enlargeCenterPage: true,
                ),
                items: imgList
                    .map((item) => Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.amber, width: 4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.asset(item,
                                fit: BoxFit.cover, width: 1000),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isAutoPlay = !_isAutoPlay;
                });
              },
              child: Text(_isAutoPlay ? 'Pause' : 'Resume'),
            ),
          ),
        ],
      ),
    );
  }
}

class TravelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        "Travel Page",
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      SizedBox(
        height: 20,
      ),
      Image.asset(
        'assets/boracay.jpg', // Path to your local image
        height: 400,
      ),
      Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
            "Welcome, adventurers and relaxation seekers! Get ready to embark on a journey to one of the most idyllic destinations in the world – Boracay Island in the Philippines. Renowned for its powdery white-sand beaches, crystal-clear azure waters, and vibrant nightlife, Boracay Island offers the perfect backdrop for an unforgettable weekend getaway."),
      )
    ]));
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ...

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  // ...

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),

        // ↓ Make the following change.
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet'),
      );
    }

    return ListView(children: [
      Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'You have ${appState.favorites.length} saved words ❤️ ',
        ),
      ),
      for (var pair in appState.favorites)
        ListTile(
          leading: Icon(Icons.favorite),
          title: Text(pair.asLowerCase),
        ),
    ]);
  }
}
