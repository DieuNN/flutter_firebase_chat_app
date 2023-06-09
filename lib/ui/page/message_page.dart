import 'dart:async';
import 'dart:io';
import 'dart:developer' as dart_dev;

import 'package:chat_app/blocs/conversation/conversation_bloc.dart';
import 'package:chat_app/blocs/message/message_bloc.dart';
import 'package:chat_app/constants/app_constants.dart';
import 'package:chat_app/model/entity/conversation.dart';
import 'package:chat_app/model/entity/message_content.dart';
import 'package:chat_app/model/enum/message_alignment.dart';
import 'package:chat_app/model/enum/message_type.dart';
import 'package:chat_app/ui/widget/common/form_input_field.dart';
import 'package:chat_app/ui/widget/common/user_avatar.dart';
import 'package:chat_app/ui/widget/message_page/message_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
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
  Stream<cloud.QuerySnapshot<Map<String, dynamic>>>? snapshot;
  ImagePicker picker = ImagePicker();
  StreamSubscription<dynamic>? streamSubscription;

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
        .add(MessageLoadEvent(conversation: conversationInfo));
    super.didChangeDependencies();
  }

  // https://github.com/flutter/flutter/issues/64935
  @override
  Future<void> dispose() async {
    Future.delayed(
      const Duration(seconds: 0),
      () async {
        messageInputController.clear();
        await snapshot?.drain();
        await streamSubscription?.cancel();
      },
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<ConversationBloc>().add(ConversationsLoadEvent(
            uid: FirebaseAuth.instance.currentUser!.uid));
        return true;
      },
      child: SafeArea(
        maintainBottomViewPadding: true,
        child: Scaffold(
          backgroundColor: AppConstants.primaryColor,
          appBar: AppBar(
            backgroundColor: AppConstants.primaryColor,
            title: buildReceiverInfo(),
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
            child: buildPageBody(),
            footer: SafeArea(child: buildMessageInput()),
          ),
        ),
      ),
    );
  }

  buildReceiverInfo() {
    String conversationName;
    String? conversationImage;
    String? conversationEmail;
    String currentUid = FirebaseAuth.instance.currentUser!.uid;

    // Reverse sender and receiver
    if (currentUid == conversationInfo.fromUid) {
      conversationName = conversationInfo.toName!;
      conversationImage = conversationInfo.toAvatar;
      conversationEmail = conversationInfo.toEmail!;
    } else {
      conversationName = conversationInfo.fromName!;
      conversationImage = conversationInfo.fromAvatar;
      conversationEmail = conversationInfo.fromEmail!;
    }
    return ListTile(
      leading: UserCircleAvatar(
        width: 36,
        imageUrl: conversationImage,
      ),
      title: Text(
        conversationName,
        style: const TextStyle(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.fade,
      ),
      subtitle: Text(
        conversationEmail,
        style: const TextStyle(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.fade,
      ),
    );
  }

  buildPageBody() {
    List<Widget> messageWidgets = messages.map((e) {
      return MessageItem(
        key: UniqueKey(),
        alignment: senderUid == e.senderUid
            ? MessageAlignment.right
            : MessageAlignment.left,
        type: e.type == "text" ? MessageType.text : MessageType.image,
        content: e.content,
      );
    }).toList();
    return BlocConsumer<MessageBloc, MessageState>(
      listener: (context, state) async {
        if (state is MessagesLoadSuccessState) {
          setState(() {
            messages = state.messages;
            snapshot ??= state.snapshot;
            dart_dev
                .log("Snapshot hashcode - Load message: ${snapshot.hashCode}");
          });
          addMessageSnapshotsListener();
        }
        if (state is MessageTextSendSuccessState) {
          setState(() {
            snapshot ??= state.snapshot;
            dart_dev
                .log("Snapshot hashcode - Send message: ${snapshot.hashCode}");
          });
          addMessageSnapshotsListener();
        }
      },
      builder: (context, state) {
        if (state is MessagesLoadInProgressState) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              backgroundColor: Colors.black,
            ),
          );
        }
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          reverse: true,
          padding: const EdgeInsets.only(left: 16, right: 16),
          itemBuilder: (BuildContext context, int index) {
            return messageWidgets[index];
          },
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(
              height: 8,
            );
          },
          itemCount: messageWidgets.length,
        );
      },
    );
  }

  Widget buildMessageInput() {
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
                    onPressed: showImagePickBottomSheet,
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
              onPressed: sendTextMessage,
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

  sendImageMessage() {
    if (imageFile == null) {
      return;
    }
    final sender = FirebaseAuth.instance.currentUser!.uid;
    context.read<MessageBloc>().add(MessageImageSendEvent(
        file: imageFile!,
        sender: sender,
        content: MessageContent(
          senderUid: sender,
          timeStamp: cloud.Timestamp.now(),
          type: "image",
          file: imageFile,
        ),
        conversation: conversationInfo));
  }

  sendTextMessage() {
    if (messageInputController.text.trim().isEmpty) {
      return;
    }

    context.read<MessageBloc>().add(
          MessageTextSendEvent(
            content: messageInputController.text,
            conversation: conversationInfo,
            sender: senderUid,
          ),
        );
    addMessageSnapshotsListener();
    messageInputController.text = "";
  }

  int count = 0;

  void addMessageSnapshotsListener() async {

    if (snapshot == null) {
      return;
    }

    if (streamSubscription != null) {
      return;
    }

    streamSubscription = snapshot!.listen((event) {});

    streamSubscription!.onData((data) {
      setState(() {
        messages = (data as QuerySnapshot<Map<String, dynamic>>)
            .docs
            .map((e) => MessageContent.fromJson(e.data()))
            .toList();
      });
    });
  }

  showImagePickBottomSheet() {
    showModalBottomSheet(
      elevation: 0,
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(0)),
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.image),
              title: const Text(
                "Gallery",
                style: TextStyle(color: AppConstants.primaryColor),
              ),
              onTap: () async {
                if(Platform.isIOS) {
                  Fluttertoast.showToast(msg: "Image picker error on iOS");
                  return;
                }
                var navigator = Navigator.of(context);
                final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery, requestFullMetadata: true);
                dart_dev.log(image.toString());
                setState(() {
                  if (image == null) {
                    return;
                  }
                  imageFile = File(image.path);
                  sendImageMessage();
                });
                navigator.pop();
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.camera),
              title: const Text(
                "Camera",
                style: TextStyle(color: AppConstants.primaryColor),
              ),
              onTap: () async {
                var navigator = Navigator.of(context);
                final XFile? image =
                    await picker.pickImage(source: ImageSource.camera);
                setState(() {
                  if (image == null) {
                    return;
                  }
                  imageFile = File(image.path);
                  sendImageMessage();
                });
                navigator.pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
