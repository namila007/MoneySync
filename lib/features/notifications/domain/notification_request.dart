final class NotificationId {
  const NotificationId(this.value);
  final int value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

final class NotificationRequest {
  const NotificationRequest({
    required this.id,
    required this.channelId,
    required this.channelName,
    required this.title,
    required this.body,
    this.ongoing = false,
  });

  final NotificationId id;
  final String channelId;
  final String channelName;
  final String title;
  final String body;
  final bool ongoing;
}
