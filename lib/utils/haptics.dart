import "package:advanced_haptics/advanced_haptics.dart";

enum HapticPrimitives {
  quickRise(.quickRise),
  quickFall(.quickFall),
  thud(.thud),
  spin(.spin);

  final AndroidHapticPrimitive _underlying;

  const HapticPrimitives(this._underlying);

  AndroidPrimitiveEvent get event => .new(_underlying);
}

abstract final class HapticFeedback {
  static final _supportedPrimitives = <HapticPrimitives>{};

  static Future<void> initialize() async {
    for (final primitive in HapticPrimitives.values) {
      final primitives = [primitive._underlying];
      if (await AdvancedHaptics.supportsAndroidPrimitives(primitives))
        _supportedPrimitives.add(primitive);
    }
  }

  static Future<void> play(HapticPrimitives primitive) async {
    if (!_supportedPrimitives.contains(primitive)) return;
    await AdvancedHaptics.playComposition([primitive.event]);
  }
}
