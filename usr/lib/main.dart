import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMW Open World Driving Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(game: BMWDrivingGame()),
    );
  }
}

class BMWDrivingGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
  late Car playerCar;
  late World world;
  late CameraComponent camera;

  @override
  Future<void> onLoad() async {
    // Load world
    world = World();
    add(world);

    // Add player car starting with BMW M5 E39
    playerCar = Car('BMW M5 E39');
    world.add(playerCar);

    // Set up camera to follow the car
    camera = CameraComponent(world: world);
    camera.follow(playerCar);
    add(camera);

    // Add basic world elements (roads, buildings, etc.)
    _addWorldElements();
  }

  void _addWorldElements() {
    // Add road network
    world.add(Road(Vector2(0, 0), Vector2(1000, 0))); // Horizontal road
    world.add(Road(Vector2(0, 0), Vector2(0, 1000))); // Vertical road

    // Add some buildings or obstacles
    world.add(Building(Vector2(200, 200)));
    world.add(Building(Vector2(400, 400)));
  }
}

class Car extends SpriteComponent with KeyboardHandler, HasGameRef<BMWDrivingGame> {
  final String model;
  Vector2 velocity = Vector2.zero();
  double speed = 0.0;
  double maxSpeed = 200.0;
  double acceleration = 50.0;
  double deceleration = 30.0;
  double rotationSpeed = 3.0;

  Car(this.model) : super(size: Vector2(32, 16));

  @override
  Future<void> onLoad() async {
    // Load car sprite (placeholder for now)
    sprite = await gameRef.loadSprite('car_$model.png');
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update position based on velocity
    position += velocity * dt;

    // Apply friction
    velocity *= 0.98;
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Handle keyboard input for driving
    if (keysPressed.contains(LogicalKeyboardKey.keyW) || keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      speed += acceleration * gameRef.dt;
      if (speed > maxSpeed) speed = maxSpeed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyS) || keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      speed -= deceleration * gameRef.dt;
      if (speed < -maxSpeed / 2) speed = -maxSpeed / 2;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyA) || keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      angle -= rotationSpeed * gameRef.dt;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD) || keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      angle += rotationSpeed * gameRef.dt;
    }

    // Update velocity based on angle and speed
    velocity = Vector2(cos(angle), sin(angle)) * speed;

    return true;
  }
}

class Road extends PositionComponent {
  final Vector2 start;
  final Vector2 end;

  Road(this.start, this.end);

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.gray..strokeWidth = 10;
    canvas.drawLine(Offset(start.x, start.y), Offset(end.x, end.y), paint);
  }
}

class Building extends PositionComponent {
  Building(Vector2 position) {
    this.position = position;
    size = Vector2(50, 50);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.brown;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
  }
}