import 'dart:io';
import 'dart:developer' as dart_dev;
import 'dart:math' as dart_math;

import 'package:chat_app/blocs/message/message_bloc.dart';
import 'package:chat_app/constants/app_constants.dart';
import 'package:chat_app/model/entity/conversation.dart';
import 'package:chat_app/model/entity/message_content.dart';
import 'package:chat_app/model/enum/message_alignment.dart';
import 'package:chat_app/model/enum/message_type.dart';
import 'package:chat_app/network/firebase_firestore.dart';
import 'package:chat_app/ui/widget/common/form_input_field.dart';
import 'package:chat_app/ui/widget/common/user_avatar.dart';
import 'package:chat_app/ui/widget/message_page/message_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({Key? key, required this.args}) : super(key: key);
  final Set<Map<String, dynamic>> args;

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  List<MessageContent> messages = [];
  late Conversation conversationInfo;
  late final TextEditingController messageInputController;
  File? imageFile;
  final String senderUid = FirebaseAuth.instance.currentUser!.uid;

  List<MessageContent> fakeMessages = List.filled(
    100,
    MessageContent(
      senderUid: "message uid",
      type: "text",
      content: "Message",
      timeStamp: cloud.Timestamp.now(),
    ),
  );

  @override
  void initState() {
    conversationInfo = Conversation.fromJson(widget.args.first);

    messageInputController = TextEditingController();

    super.initState();
  }

  @override
  void didChangeDependencies() async {
    context
        .read<MessageBloc>()
        .add(MessageLoadEvent(toUid: conversationInfo.toUid!));
    messageSnapshotsListener();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      maintainBottomViewPadding: true,
      child: Scaffold(
        backgroundColor: AppConstants.primaryColor,
        appBar: AppBar(
          backgroundColor: AppConstants.primaryColor,
          title: _buildReceiverInfo(),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.call),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.video_call),
            ),
          ],
        ),
        body: FooterLayout(
          child: _buildPageBody(),
          footer: _buildMessageInput(),
        ),
      ),
    );
  }

  _buildReceiverInfo() {
    return ListTile(
      leading: UserCircleAvatar(
        width: 36,
        imageUrl: conversationInfo.toAvatar,
      ),
      title: Text(
        conversationInfo.toName ?? conversationInfo.toUid ?? "User",
        style: const TextStyle(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.fade,
      ),
      subtitle: conversationInfo.toEmail == null
          ? null
          : Text(
              conversationInfo.toEmail!,
              style: const TextStyle(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.fade,
            ),
    );
  }

  _buildPageBody() {
    return BlocConsumer<MessageBloc, MessageState>(
      listener: (context, state) {
        if (state is MessagesLoadSuccessState) {
          setState(() {
            messages = state.messages;
          });
          if (state is MessageTextSendSuccessState) {
            Fluttertoast.showToast(msg: "Sent!");
          }
        }
      },
      builder: (context, state) {
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          reverse: true,
          padding: const EdgeInsets.only(left: 16, right: 16),
          itemBuilder: (BuildContext context, int index) {
            if (state is MessagesLoadInProgressState) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  backgroundColor: Colors.black,
                ),
              );
            }

            return messages.map((e) {
              return MessageItem(
                alignment: senderUid == e.senderUid
                    ? MessageAlignment.right
                    : MessageAlignment.left,
                type: MessageType.text,
                content: e.content,
              );
            }).toList()[index];
          },
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(
              height: 8,
            );
          },
          itemCount: messages.length,
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 1,
              child: FormInputField(
                controller: messageInputController,
                shouldValidator: false,
                decoration: InputDecoration(
                  hintText: "Type your message here ...",
                  hintStyle: const TextStyle(color: Colors.white),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.image,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                  filled: true,
                  fillColor: AppConstants.secondaryColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  sendMessage() {
    if (messageInputController.text.trim().isEmpty) {
      return;
    }
    context.read<MessageBloc>().add(
          MessageTextSendEvent(
            content: messageInputController.text,
            conversation: conversationInfo,
          ),
        );
    messageInputController.text = "";
  }

  messageSnapshotsListener() async {
    final snapshots =
        await FirebaseFirestore().getMessagesSnapshots(conversationInfo.toUid!);
    snapshots?.listen((event) {
      List<MessageContent> newMessage = [];
      for (var element in event.docs) {
        newMessage.add(MessageContent.fromJson(element.data()));
      }
      setState(() {
        messages = newMessage;
      });
    });
  }
}
