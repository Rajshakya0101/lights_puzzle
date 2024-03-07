// Importing necessary libraries
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lights_out_three/game.dart'; // Assuming 'game.dart' contains game logic

// Main function
void main() => runApp(const MyApp());

// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // Set preferred device orientations
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Return MaterialApp
    return MaterialApp(
      title: 'LightsOut',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const Screen(),
    );
  }
}

// Screen widget
class Screen extends StatefulWidget {
  const Screen({super.key});
  @override
  createState() => _SplashScreenState();
}

// Screen state
class _SplashScreenState extends State<Screen> {
  @override
  Widget build(BuildContext context) {
    // Return SafeArea with MyHomePage
    return const SafeArea(
      child: MyHomePage(title: 'Home'),
    );
  }
}

// Home page widget
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// Home page state
class _MyHomePageState extends State<MyHomePage> {
  // List of level cards
  final List<Widget> _lstLevels = [
    for (int i = 3; i <= 12; i++)
      Card(
        color: Colors.blueGrey,
        elevation: 10.0,
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text(
            i.toString(),
            style: const TextStyle(color: Colors.black, fontSize: 40), // Change text color to black
          ),
        ),
      ),
  ];

  // Currently selected level card
  late Card _currLevel;
  int _currIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Update current level card
    _currLevel = _lstLevels.elementAt(_currIndex) as Card;

    // Return Scaffold with app bar, level cards, and buttons
    return Scaffold(
        appBar: AppBar(title: const Text('Home'),),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Lights Out - Intense',
                style: TextStyle(
                  fontSize: 35, // Adjust the font size as needed
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 25.0,),
              const SizedBox(height: 25.0,),
              // Display current level card with animation
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(seconds: 1),
                  child: _currLevel,
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Navigation button to previous level
                        IconButton(
                          icon: const Icon(Icons.navigate_before, size: 32.0,),
                          onPressed: (){
                            if(_currIndex != 0){
                              setState(() {
                                _currIndex-=1;
                              });
                            }
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Text('Levels', style: TextStyle(fontSize: 20.0),),
                        ),
                        // Navigation button to next level
                        IconButton(
                          icon: const Icon(Icons.navigate_next, size: 32.0,),
                          onPressed: (){
                            if(_currIndex != _lstLevels.length-1){
                              setState(() {
                                _currIndex+=1;
                              });
                            }
                          },
                        )
                      ],
                    ),
                  )
              ),
              // Button to start the game with selected level
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: MaterialButton(
                  color: Colors.redAccent,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Text('Start Game', style: TextStyle(fontSize: 20.0, color: Colors.white),),),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => Game(dim: (_currIndex + 3),) // Passing selected level dimension
                    ));
                  },
                ),
              ),
              // Button to exit the application
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: MaterialButton(
                  color: Colors.blueGrey,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 32.0, right: 32.0),
                    child: Text('Exit', style: TextStyle(fontSize: 20.0, color: Colors.white),),),
                  onPressed: (){
                    exit(0); // Exit application
                  },
                ),
              )
            ],
          ),
        )
    );
  }
}
