/// Spacing scale (4px grid). The only allowed source of paddings/gaps in UI
/// code.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
}

/// Corner radii from the design: [s] for chips/slot cells/tags, [m] for
/// cards, sheets, inputs and buttons.
abstract final class AppRadius {
  static const double s = 8;
  static const double m = 16;
}
