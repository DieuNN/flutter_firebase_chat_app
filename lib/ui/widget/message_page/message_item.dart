import 'dart:developer';

import 'package:chat_app/constants/app_constants.dart';
import 'package:chat_app/model/enum/message_alignment.dart';
import 'package:chat_app/model/enum/message_type.dart';
import 'package:flutter/material.dart';

class MessageItem extends StatelessWidget {
  const MessageItem(
      {Key? key, required this.alignment, required this.type, this.content})
      : super(key: key);
  final MessageAlignment alignment;
  final MessageType type;
  final String? content;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case MessageType.text:
        return _buildTextMessage(alignment);
      case MessageType.image:
        return const Placeholder();
    }
  }

  Widget _buildTextMessage(MessageAlignment messageAlignment) {
    return Align(
      alignment: messageAlignment == MessageAlignment.left
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Wrap(
        alignment: messageAlignment == MessageAlignment.left
            ? WrapAlignment.start
            : WrapAlignment.end,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
                color: messageAlignment == MessageAlignment.left
                    ? AppConstants.secondaryColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: messageAlignment == MessageAlignment.left
                  ? [
                      CustomPaint(
                        painter: Triangle(
                          backgroundColor:
                              messageAlignment == MessageAlignment.left
                                  ? AppConstants.secondaryColor
                                  : Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          content ?? "???",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ]
                  : [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(content ?? "???"),
                      ),
                      CustomPaint(
                        painter: Triangle(
                          backgroundColor:
                              messageAlignment == MessageAlignment.left
                                  ? AppConstants.secondaryColor
                                  : Colors.white,
                        ),
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageMessage(MessageAlignment messageAlignment) {
    return Wrap(
      alignment: messageAlignment == MessageAlignment.left
          ? WrapAlignment.start
          : WrapAlignment.end,
      children: const [
        Text("This is right message"),
      ],
    );
  }
}

class Triangle extends CustomPainter {
  final Color backgroundColor;

  Triangle({required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = backgroundColor;
    var path = Path();
    path.lineTo(-5, 0);
    path.lineTo(0, 10);
    path.lineTo(5, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
