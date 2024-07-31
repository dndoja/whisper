import 'package:bonfire/bonfire.dart';

export 'market.dart';
export 'ritual.dart';
export 'shadow_target.dart';

mixin HiddenByDefault on GameComponent {
  @override
  Future<void> onLoad() {
    isVisible = false;
    return super.onLoad();
  }
}
