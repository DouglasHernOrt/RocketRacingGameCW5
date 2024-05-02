import 'package:flutter/material.dart';
import 'main.dart';
import 'package:flame_audio/flame_audio.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  int selectedRocketIndex = 1; // Default selected rocket index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/space2.gif"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Rocket Racer',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 243, 134, 134),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildRocketButton(1),
                  buildRocketButton(2),
                  buildRocketButton(3),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  FlameAudio.play('button_sound.wav');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          GameScreen(selectedRocketIndex: selectedRocketIndex),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    const Color(0xFF800000),
                  ),
                ),
                child: const Text(
                  'Launch',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  FlameAudio.play('button_sound.wav');
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Colors.white.withOpacity(0.8),
                        title: const Text(
                          'Rules:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF800000),
                          ),
                        ),
                        content: const SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '1. Move rocket left and right.\n'
                                '2. Avoid obstacles.\n'
                                '3. Last as long as you can.\n'
                                '4. Obstacles move faster as you endure.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                const Color(0xFF800000),
                              ),
                            ),
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Text(
                    'RULES',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 243, 134, 134),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRocketButton(int index) {
    return GestureDetector(
      onTap: () {
        FlameAudio.play('button_sound.wav');
        setState(() {
          selectedRocketIndex = index;
        });
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: index == selectedRocketIndex
                ? Colors.green
                : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Image.asset('assets/images/rocket$index.png'),
      ),
    );
  }
}
