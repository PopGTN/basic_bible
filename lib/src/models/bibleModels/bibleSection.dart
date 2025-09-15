enum BibleSectionType {
  heading,
  majorHeading,
  subheading,
  parallelReference,
  other,
}

class BibleSection {
  final String title;
  final int startVerse;
  final int endVerse;
  final BibleSectionType type;

  BibleSection({
    required this.title,
    required this.startVerse,
    required this.endVerse,
    this.type = BibleSectionType.heading,
  });
}

