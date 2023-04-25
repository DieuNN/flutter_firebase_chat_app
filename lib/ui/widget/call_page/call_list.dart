import 'package:chat_app/model/enum/call_type.dart';
import 'package:chat_app/ui/widget/call_page/call_item.dart';
import 'package:flutter/material.dart';

class CallList extends StatelessWidget {
  const CallList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        CallListItem(
          callType: CallType.called,
          title: "Dieu",
          time: "Now",
        ), CallListItem(
          callType: CallType.missed,
          title: "Dieu",
          time: "Now",
        ),
        CallListItem(
          callType: CallType.received,
          title: "Dieu",
          time: "Now",
        ),
      ],
    );
  }
}
