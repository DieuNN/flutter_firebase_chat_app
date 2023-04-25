import 'package:chat_app/model/enum/call_type.dart';
import 'package:flutter/material.dart';

class CallListItem extends StatelessWidget {
  final CallType callType;
  final String title;
  final String time;

  const CallListItem(
      {super.key,
      required this.callType,
      required this.title,
      required this.time});

  @override
  Widget build(BuildContext context) {
    Icon leadingIcon;
    switch (callType) {
      case CallType.called:
        leadingIcon = const Icon(
          Icons.call_made,
          color: Colors.white,
        );
        break;
      case CallType.missed:
        leadingIcon = const Icon(
          Icons.call_missed,
          color: Colors.red,
        );
        break;
      case CallType.received:
        leadingIcon = const Icon(
          Icons.call_received,
          color: Colors.white,
        );
        break;
    }
    return ListTile(
      leading: IconButton(
        icon: leadingIcon,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onPressed: () {},
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        time,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
