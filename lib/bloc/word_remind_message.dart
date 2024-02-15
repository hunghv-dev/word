import 'package:base_ui/base_ui.dart';

enum WordRemindMessageType {
  requiredReadPermission,
  scrollTo,
}

class WordRemindMessage extends Message<WordRemindMessageType> {
  WordRemindMessage({required super.type, super.content});

  factory WordRemindMessage.requiredReadPermission() =>
      WordRemindMessage(type: WordRemindMessageType.requiredReadPermission);

  factory WordRemindMessage.scrollTo(double index) =>
      WordRemindMessage(type: WordRemindMessageType.scrollTo, content: index);
}
