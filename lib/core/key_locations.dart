import 'package:bonfire/bonfire.dart' show Vector2;

final spawnOffset = Vector2(-12, -16);

class Point16 {
  const Point16(this.x, this.y);
  final int x;
  final int y;

  factory Point16.fromMapPos(Vector2 pos) => Point16(pos.x ~/ 16, pos.y ~/ 16);

  @override
  bool operator ==(Object other) =>
      other is Point16 && other.x == x && other.y == y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  Vector2 get mapPosition => Vector2(x * 16.0 + 8, y * 16.0 + 8);

  int distanceSquaredTo(Point16 other) {
    final dx = (x - other.x).abs();
    final dy = (y - other.y).abs();
    return dx * dx + dy * dy;
  }

  @override
  String toString() => '($x, $y)';
}

class Paths {
  static const churchToGraveyard = [
    Point16(22, 15),
    Point16(22, 3),
    Point16(17, 3),
  ];

  static const churchToMarket = [
    Point16(22, 15),
    Point16(20, 11),
    Point16(17, 12),
  ];
}

enum KeyLocation {
  appleFarm(
    Point16(57, 1),
    Point16(63, 11),
    Point16(72, 12),
  ),
  alchemistLab(
    Point16(93, 10),
    Point16(93, 10),
    Point16(93, 10),
  ),
  church(
    Point16(25, 10),
    Point16(31, 14),
    Point16(37, 22),
  ),
  crazyJoeFarm(
    Point16(0, 43),
    Point16(13, 50),
    Point16(23, 59),
  ),
  fishermanHut(
    Point16(49, 23),
    Point16(49, 26),
    Point16(53, 26),
  ),
  graveyard(
    Point16(6, 0),
    Point16(17, 3),
    Point16(16, 6),
  ),
  observatory(
    Point16(41, 8),
    Point16(42, 9),
    Point16(44, 11),
  ),
  ritualSite(
    Point16(64, 7),
    Point16(66, 10),
    Point16(69, 12),
  ),
  villageEntrance(
    Point16(30, 26),
    Point16(31, 26),
    Point16(32, 26),
  ),
  villageExitEast(
    Point16(0, 16),
    Point16(0, 16),
    Point16(0, 16),
  ),
  villageExitSouth(
    Point16(31, 59),
    Point16(31, 59),
    Point16(31, 59),
  ),
  villageMainSquare(
    Point16(6, 14),
    Point16(22, 15),
    Point16(37, 22),
  ),
  ;

  const KeyLocation(this.tl, this.ref, this.br);
  final Point16 tl;
  final Point16 br;
  final Point16 ref;

  bool contains(Point16 point) =>
      (point.x == ref.x && point.y == ref.y) ||
      (point.x >= tl.x &&
          point.x <= br.x &&
          point.y >= tl.y &&
          point.y <= br.y);

  List<Point16> get patrol => patrolCheckpoints[this] ?? const [];

  static const List<Point16> massMurderPatrol = [
    Point16(31, 22),
    Point16(25, 22),
    Point16(25, 15),
    Point16(38, 15),
    Point16(38, 10),
    Point16(41, 8),
    Point16(44, 8),
    Point16(44, 11),
    Point16(42, 11),
    Point16(42, 25),
  ];
  static const List<KeyLocation> massMurderLocations = [
    church,
    observatory,
    fishermanHut,
  ];

  static const List<Point16> villageEntrancePath = [
    Point16(31, 44),
    Point16(31, 22),
  ];

  static const Map<KeyLocation, List<Point16>> patrolCheckpoints = {
    KeyLocation.church: [
      Point16(31, 15),
      Point16(27, 15),
      Point16(35, 15),
    ],
    KeyLocation.observatory: [
      Point16(42, 8),
      Point16(41, 11),
      Point16(44, 11),
    ],
    KeyLocation.villageMainSquare: [
      Point16(25, 21),
      Point16(25, 15),
      Point16(12, 14),
      Point16(12, 16),
      Point16(20, 16),
    ],
    KeyLocation.ritualSite: [
      Point16(72, 8),
      Point16(68, 11),
      Point16(64, 8),
    ],
  };
}
