import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

void main() {
  runApp(MyApp());
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
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = TravelPage();
        break;
      case 3:
        page = CalculatorPage();
        break;
      case 4:
        page = CarouselPage();
        break;
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
