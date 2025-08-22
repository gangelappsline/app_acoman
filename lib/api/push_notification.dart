class PushNotification {
  PushNotification({
    required this.title,
    required this.body,
    this.dataTitle,
    this.dataBody,
    this.dataImage,
    this.dataRoute,
  });

  final String? title;
  final String? body;
  final String? dataTitle;
  final String? dataBody;
  final String? dataImage;
 final String? dataRoute;
}
