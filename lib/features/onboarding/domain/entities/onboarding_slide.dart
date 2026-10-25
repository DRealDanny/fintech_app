/// Pure Dart Domain Entity representing a single onboarding slide.
/// Strictly follows AGENTS.md rule: Zero Flutter imports in Domain layer.
class OnboardingSlide {
  final String id;
  final String category;
  final String title;
  final String highlightText;
  final String description;
  final String badgeText;

  const OnboardingSlide({
    required this.id,
    required this.category,
    required this.title,
    required this.highlightText,
    required this.description,
    required this.badgeText,
  });
}
