
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/constants/app_constants.dart';
import 'package:chat_app/model/enum/message_alignment.dart';
import 'package:chat_app/model/enum/message_type.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

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
        if (alignment == MessageAlignment.left) {
          return _buildTextMessageLeft(context);
        }
        return _buildTextMessageRight(context);
      case MessageType.image:
        if (alignment == MessageAlignment.left) {
          return _buildImageMessageLeft(context);
        }
        return _buildImageMessageRight(context);
    }
  }

  Widget _buildTextMessageRight(context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        child: Wrap(
          alignment: WrapAlignment.end,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(content ?? "???"),
                    ),
                  ),
                  CustomPaint(
                    painter: Triangle(
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @experimental
  Widget _buildTextMessageLeft(context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        child: Wrap(
          alignment: WrapAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppConstants.secondaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomPaint(
                    painter: Triangle(
                      backgroundColor: AppConstants.secondaryColor,
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        content ?? "???",
                        softWrap: true,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4:3 image ratio, if width is 70% screen width, so height should be 70% * 3/4
  Widget _buildImageMessageLeft(BuildContext context) {
    final imageProvider = CachedNetworkImageProvider(content!);
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          showImageViewer(context, imageProvider, doubleTapZoomable: true);
        },
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width * 0.7,
            minHeight: MediaQuery.of(context).size.width * (0.7 * (3 / 4)),
            maxHeight: MediaQuery.of(context).size.width * (0.7 * (3 / 4)),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageMessageRight(BuildContext context) {
    final imageProvider = CachedNetworkImageProvider(content!);
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          showImageViewer(context, imageProvider, doubleTapZoomable: true);
        },
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width * 0.7,
            minHeight: MediaQuery.of(context).size.width * (0.7 * (3 / 4)),
            maxHeight: MediaQuery.of(context).size.width * (0.7 * (3 / 4)),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
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
