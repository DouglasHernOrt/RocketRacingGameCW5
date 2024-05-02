import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'game_over_screen.dart';
import 'dart:async' as async;
import 'dart:math';
import 'dart:ui' as ui;

class RocketRacingGame extends FlameGame {
  late BuildContext context;
  late PlayerRocket playerRocket;
  late async.Timer _obstacleTimer;
  final List<Obstacle> _obstacles = [];
  bool _gameOver = false;
  int _score = 0;
  bool _showCountdown = true;
  late int _countdown;
  static const double maxSpeed = 500;
  static const double initialSpeed = 200;
  static const double speedIncrement = 20;
  double currentSpeed = initialSpeed;
  static const int obstacleIntervalScore = 20;
  static const double initialObstacleInterval = 2.0;
  static const double minObstacleInterval = 0.5;
  double obstacleInterval = initialObstacleInterval;
  late String selectedRocketImage;

  late SpriteComponent background;

  RocketRacingGame(
      this.context, int initialCountdown, int selectedRocketIndex) {
    _countdown = initialCountdown;
    selectedRocketImage = 'rocket$selectedRocketIndex.png';
    initialize();
  }

  Future<void> initialize() async {
    await _loadImages();
    _obstacleTimer = async.Timer(Duration.zero, () {});

    _countdown = 3;
    _startCountdownTimer();
    _startObstacleTimer();

    // Load background image
    background =
        SpriteComponent.fromImage(Flame.images.fromCache('background.png'));
    background.x = 0;
    background.y = 0;
    background.width = size.x;
    background.height = size.y;
    add(background);

    final rocketImage = Flame.images.fromCache(selectedRocketImage);

    // Initialize the playerRocket off-screen
    playerRocket = PlayerRocket(rocketImage);
    playerRocket.x = size.x / 2 - playerRocket.width / 2;
    playerRocket.y = size.y;
    add(playerRocket);

    // Animate the rocket to its starting position after the countdown
    async.Timer(const Duration(seconds: 3), () {
      _showCountdown = false;
      final targetY = size.y * 0.75;
      const animationDuration = Duration(seconds: 1);
      const curve = Curves.easeOut;
      FlameAudio.play('launch.mp3');
      async.Timer.periodic(const Duration(milliseconds: 16), (timer) {
        final progress = (timer.tick / (animationDuration.inMilliseconds / 16))
            .clamp(0.0, 1.0);
        playerRocket.y =
            ui.lerpDouble(size.y, targetY, curve.transform(progress))!;
        if (progress >= 1.0) {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _loadImages() async {
    await Flame.images
        .loadAll([selectedRocketImage, 'obstacle.png', 'background.png']);
  }

  bool get isGameOver => _gameOver;

  @override
  void update(double dt) {
    super.update(dt);
    if (!_gameOver) {
      _updateObstacles(dt);
      _checkCollision();
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (!_gameOver) {
      playerRocket.x += details.delta.dx;

      if (playerRocket.x < 0) {
        playerRocket.x = 0;
      } else if (playerRocket.x + playerRocket.width > size.x) {
        playerRocket.x = size.x - playerRocket.width;
      }
    }
  }

  void _startCountdownTimer() {
    async.Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        _countdown--;
      } else {
        _showCountdown = false;
        timer.cancel();
      }
    });
  }

  void _startObstacleTimer() {
    _obstacleTimer.cancel();

    async.Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        final random = Random();
        final obstacleX = random.nextDouble() * size.x;
        const obstacleY = -50.0;
        if (obstacleX >= 0 && obstacleX <= size.x) {
          // Check if x-coordinate is within the screen bounds
          final obstacle = Obstacle(obstacleX, obstacleY,
              speed: currentSpeed,
              image: Flame.images.fromCache('obstacle.png'));
          _obstacles.add(obstacle);
          add(obstacle);
        }
      }
    });
  }

  void _updateObstacles(double dt) {
    final obstaclesToRemove = <Obstacle>[];

    for (final obstacle in _obstacles) {
      obstacle.y += obstacle.speed * dt;
      if (obstacle.y > size.y + 50) {
        obstaclesToRemove.add(obstacle);
        _incrementScore();
        _updateSpeed();
      }
    }

    for (final obstacle in obstaclesToRemove) {
      _obstacles.remove(obstacle);
      remove(obstacle);
    }
  }

  void _checkCollision() {
    for (final obstacle in _obstacles) {
      final circleCenter = Offset(playerRocket.x + playerRocket.width / 2,
          playerRocket.y + playerRocket.height / 2);

      final rocketRect = Rect.fromLTWH(
        playerRocket.x + playerRocket.width * 0.15,
        playerRocket.y + playerRocket.height * 0.15,
        playerRocket.width * 0.7,
        playerRocket.height * 0.7,
      );

      final obstacleRect = Rect.fromLTWH(
        obstacle.x,
        obstacle.y,
        obstacle.width,
        obstacle.height,
      );

      if (obstacleRect.contains(circleCenter) ||
          obstacleRect.overlaps(rocketRect)) {
        _endGame();
        FlameAudio.play('explosion.wav');
        return;
      }
    }
  }

  void _endGame() {
    _gameOver = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => GameOverScreen(score: _score)),
    );
  }

  void _incrementScore() {
    _score++;
    if (_score % obstacleIntervalScore == 0) {
      if (obstacleInterval > minObstacleInterval) {
        obstacleInterval -= 0.1;
      }
      if (_score % 5 == 0) {
        FlameAudio.play('score.wav');
      }
    }
  }

  void _updateSpeed() {
    final newSpeed = initialSpeed + (_score ~/ 5) * speedIncrement;
    currentSpeed = newSpeed.clamp(initialSpeed, maxSpeed);

    for (final obstacle in _obstacles) {
      obstacle.speed = currentSpeed;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (_showCountdown) {
      final textSpan = TextSpan(
        text: _countdown.toString(),
        style: const TextStyle(fontSize: 48.0, color: Colors.white),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size.x / 2 - textPainter.width / 2,
            size.y / 2 - textPainter.height / 2),
      );
    }

    final scoreTextSpan = TextSpan(
      text: 'Score: $_score',
      style: const TextStyle(fontSize: 24.0, color: Colors.white),
    );
    final scoreTextPainter = TextPainter(
      text: scoreTextSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    scoreTextPainter.layout();
    scoreTextPainter.paint(
        canvas, Offset(size.x - scoreTextPainter.width - 20, 20));
  }
}

class PlayerRocket extends SpriteComponent {
  PlayerRocket(ui.Image image) : super.fromImage(image) {
    width = 50;
    height = 80;
  }

  void onPanUpdate(DragUpdateDetails details) {
    x += details.delta.dx;
  }
}

class Obstacle extends SpriteComponent {
  double speed;

  Obstacle(double x, double y, {required this.speed, required ui.Image image})
      : super.fromImage(image) {
    this.x = x;
    this.y = y;
    width = 50;
    height = 50;
  }
}
