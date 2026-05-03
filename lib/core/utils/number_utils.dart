int clampInt(int value, int min, int max) => value.clamp(min, max).toInt();

double clampDouble(num value, double min, double max) {
  final safe = value.isFinite ? value.toDouble() : min;
  return safe.clamp(min, max).toDouble();
}
