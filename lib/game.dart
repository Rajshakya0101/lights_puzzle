import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lights_out_three/toggleCountScreen.dart';

enum CellState {
  off,
  red,
  green,
}

class Game extends StatefulWidget {
  const Game({required this.dim});
  final int dim;

  @override
  _GameState createState() => _GameState(dim: dim);
}

class _GameState extends State<Game> {
  _GameState({required this.dim});

  late List<List<CellState>> _states;
  late List<List<CellState>> _initialStates;
  late List<List<int>> _toggleCount =
  List.generate(dim, (_) => List.filled(dim, 0));
  int dim;
  bool _gameOver = false;
  int _numSteps = 0;
  String _timeUsed = '00:00:00';
  DateTime? _startTime;
  DateTime? _stopTime;
  late List<List<CellState>> _prevStatesStack; // Stack to store previous game states

  @override
  void initState() {
    super.initState();
    _states = List.generate(dim, (_) => List.filled(dim, CellState.off));
    _initialStates = List.generate(dim, (_) => List.filled(dim, CellState.off));
    _randomize();
  }

  void resetToggleMatrix(){
    _toggleCount = List.generate(dim, (_) => List.filled(dim, 0));
  }

  void _notYet() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Feature Not Yet Implemented'),
          content: Text('This feature is not yet implemented.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void startTimer() {
    _startTime = DateTime.now();
    Timer.periodic(const Duration(milliseconds: 1), (_) {
      _updateTimeUsed();
    });
  }

  void stopTimer() {
    _stopTime = DateTime.now();
  }

  void resetTimer() {
    _startTime = null;
    _stopTime = null;
  }

  Duration? getElapsedTime() {
    if (_startTime != null) {
      if (_stopTime != null) {
        return _stopTime!.difference(_startTime!);
      } else {
        return DateTime.now().difference(_startTime!);
      }
    }
    return null;
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitMilliseconds = twoDigits(duration.inMilliseconds.remainder(1000) ~/ 10); // Take the first two characters
    return "$twoDigitMinutes:$twoDigitSeconds:$twoDigitMilliseconds";
  }

  void _updateTimeUsed() {
    Duration? elapsedTime = getElapsedTime();
    if (elapsedTime != null) {
      setState(() {
        _timeUsed = formatDuration(elapsedTime);
      });
    } else {
      _timeUsed = '00:00:00';
    }
  }

  String _winFormatTime(int timeUsedInMilliseconds) {
    try {
      int minutes = timeUsedInMilliseconds ~/ 60000;
      int seconds = (timeUsedInMilliseconds % 60000) ~/ 1000;
      int milliseconds = timeUsedInMilliseconds % 1000;

      if (minutes == 0) {
        if (milliseconds == 0) {
          return "$seconds Sec";
        } else {
          return "$seconds Sec and $milliseconds MilliSec";
        }
      } else {
        if (seconds == 0) {
          return "$minutes Min";
        } else if (milliseconds == 0) {
          return "$minutes Min and $seconds Sec";
        } else {
          return "$minutes Min, $seconds Sec, and $milliseconds MilliSec";
        }
      }
    } catch (e) {
      return 'Invalid time format';
    }
  }

  void _randomize() {
    setState(() {
      for (int i = 0; i < _states.length; i++) {
        for (int j = 0; j < _states[i].length; j++) {
          _states[i][j] = CellState.values[0];
        }
      }
      _generateRandomPattern();
      _initialStates = List.from(_states);
      _numSteps = 0;
      _gameOver = false;
      startTimer();
    });
  }

  void _generateRandomPattern() {
    int numLights = Random().nextInt(dim) + (3 * dim);
    List<List<int>> clickCounts = List.generate(dim, (_) => List.filled(dim, 0)); // Track click counts for each cell
    while (numLights > 0) {
      int x = Random().nextInt(dim);
      int y = Random().nextInt(dim);
      if (clickCounts[x][y] < 2) {
        _preToggleCell(x, y); // Toggle the cell
        clickCounts[x][y]++; // Increment the click count for the cell
        numLights--;
      }
    }
  }

  void _showToggleCountScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ToggleCountScreen(toggleCount: _toggleCount),
      ),
    );
  }

  void _reset() {
    setState(() {
      _toggleCount = [];
      _states = List.from(_initialStates);
      resetTimer();
      Navigator.of(context).pop();
    });
  }

  void _preToggleCell(int x, int y) {
    _toggleState(x, y);
    _toggleStateIfValid(x - 1, y);
    _toggleStateIfValid(x + 1, y);
    _toggleStateIfValid(x, y - 1);
    _toggleStateIfValid(x, y + 1);
    _toggleCount[x][y]++;
  }

  void _tappedItems(int x, int y) {
    setState(() {
      _toggleCell(x, y);
      _numSteps++;
      if (_checkFinished()) {
        _gameOver = true;
        stopTimer();
      }
    });
  }


  void _toggleCell(int x, int y) {
    _toggleState(x, y);
    _toggleStateIfValid(x - 1, y);
    _toggleStateIfValid(x + 1, y);
    _toggleStateIfValid(x, y - 1);
    _toggleStateIfValid(x, y + 1);
  }

  void _toggleStateIfValid(int x, int y) {
    if (x >= 0 && x < dim && y >= 0 && y < dim) {
      _toggleState(x, y);
    }
  }

  void _toggleState(int x, int y) {
    if (_states[x][y] == CellState.off) {
      _states[x][y] = CellState.red;
    } else if (_states[x][y] == CellState.red) {
      _states[x][y] = CellState.green;
    } else {
      _states[x][y] = CellState.off;
    }
  }

  bool _checkFinished() {
    for (int i = 0; i < dim; i++) {
      for (int j = 0; j < dim; j++) {
        if (_states[i][j] != CellState.off) {
          return false;
        }
      }
    }
    stopTimer();
    return true;
  }

  Widget _buildGridItems(BuildContext context, int index) {
    int stateLength = _states.length;
    int x = (index / stateLength).floor();
    int y = (index % stateLength);
    Color color;
    switch (_states[x][y]) {
      case CellState.off:
        color = Colors.black;
        break;
      case CellState.red:
        color = Colors.red;
        break;
      case CellState.green:
        color = Colors.lightGreenAccent;
        break;
    }
    return GestureDetector(
      onTap: () {
        _tappedItems(x, y);
      },
      child: GridTile(
        child: Container(
          margin: const EdgeInsets.all(2.0),
          padding: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.white, width: 0.5),
          ),
          child: Container(
            color: color,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game'),
      ),
      body: _gameOver
          ? Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Game Finished',
              style: TextStyle(
                fontSize: 40,
                color: Colors.lightGreenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                'Steps Taken: $_numSteps\nTime Taken: ${_winFormatTime(getElapsedTime()!.inMilliseconds)}',
                style: const TextStyle(fontSize: 15.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: MaterialButton(
                  elevation: 20.0,
                  color: Colors.red,
                  child: const Text(
                    'Play Again?',
                    style: TextStyle(fontSize: 15.0),
                  ),
                  onPressed: () {
                    resetTimer();
                    resetToggleMatrix();
                    _randomize();
                  }),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: MaterialButton(
                elevation: 20.0,
                color: Colors.grey,
                child: const Text(
                  'Exit',
                  style: TextStyle(fontSize: 15.0),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            )
          ],
        ),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: MaterialButton(
                    color: Colors.blueGrey.shade200,
                    onPressed: _notYet,
                    child: const Text('Undo',style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),),

                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 15.0),
                  child: MaterialButton(
                    color: Colors.red.shade300,
                    onPressed: _notYet,
                    child: const Text(
                      'Restart Puzzle',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white54, width: 1.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: dim,
                ),
                itemCount: (dim * dim),
                itemBuilder: _buildGridItems,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: MaterialButton(
                    color: Colors.red,
                    onPressed: _showToggleCountScreen,
                    child: const Text(
                      'Show Solution',style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: MaterialButton(
                    color: const Color(0xFF800000),
                    onPressed: (){
                      resetToggleMatrix();
                      _randomize();
                    },
                    child: const Text('New Puzzle'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: MaterialButton(
                    color: Colors.blueGrey,
                    onPressed: _reset,
                    child: const Text('Change Level',style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              'Number of steps: $_numSteps',
              style: const TextStyle(fontSize: 20.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              'Time Used: $_timeUsed',
              style: const TextStyle(fontSize: 20.0),
            ),
          )
        ],
      ),
    );
  }
}
