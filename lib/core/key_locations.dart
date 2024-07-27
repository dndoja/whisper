import 'package:bonfire/bonfire.dart' show Vector2;

class Point16 {
  const Point16(this.x, this.y);
  final int x;
  final int y;

  factory Point16.fromMapPos(Vector2 pos) => Point16(pos.x ~/ 16, pos.y ~/ 16);

  Vector2 get mapPosition => Vector2(x * 16.0, y * 16.0);

  @override
  String toString() => '($x, $y)';
}

enum KeyLocation {
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
    Point16(41, 10),
    Point16(44, 11),
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
      point.x >= tl.x && point.x <= br.x && point.y >= tl.y && point.y <= br.y;
}
