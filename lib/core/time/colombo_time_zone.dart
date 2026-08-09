const Duration kColomboOffset = Duration(hours: 5, minutes: 30);
final DateTime kColomboOffsetValidFrom = DateTime.utc(2006, 4, 15);

enum DateEvidence {
  messageExplicitDateTime,
  messageDateYearInferred,
  messageDateOnly,
  receivedAtFallback,
  userEdited,
}
