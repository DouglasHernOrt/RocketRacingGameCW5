import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'start_screen.dart';
import 'rocket_racing_game.dart';
import 'package:flame_audio/flame_audio.dart';

//Rocket Racing App by Douglas Hernandez-Ortiz and Luv Dabhi
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setPortrait();

  runApp(const MaterialApp(
    home: GameLoader(),
  ));

  FlameAudio.bgm.initialize();
  FlameAudio.loopLongAudio('gamebgm.wav');
}

class GameLoader extends StatelessWidget {
  const GameLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: Future.delayed(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else {
          return const StartScreen();
        }
      },
    );
  }
}

class GameScreen extends StatefulWidget {
  final int selectedRocketIndex;

  const GameScreen({Key? key, required this.selectedRocketIndex})
      : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late RocketRacingGame _game;

  @override
  void initState() {
    super.initState();
    _game = RocketRacingGame(context, 3, widget.selectedRocketIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onPanUpdate: _game.onPanUpdate,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GameWidget(
                game: _game,
              );
            },
          ),
        ),
      ],
    );
  }
}
