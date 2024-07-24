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
  crazyJoeFarm(
    Point16(13, 50),
    Point16(0, 43),
    Point16(23, 59),
  ),
  alchemistLab(
    Point16(0, 0),
    Point16(0, 0),
    Point16(0, 0),
  ),
  ;

  const KeyLocation(this.ref, this.tl, this.br);
  final Point16 tl;
  final Point16 br;
  final Point16 ref;

  bool contains(Point16 point) =>
      point.x >= tl.x && point.x <= br.x && point.y >= tl.y && point.y <= br.y;
}
