import 'package:chat_app/constants/app_constants.dart';
import 'package:chat_app/ui/widget/chat_page/conversation_list.dart';
import 'package:chat_app/ui/widget/chat_page/user_search_field.dart';
import 'package:chat_app/utils/keyboard_util.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        KeyboardUtil.hideKeyboard();
      },
      child: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(context),
            const Expanded(child: ConversationList()),
          ],
        ),
      ),
    );
  }

  _buildSearchBar(context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Expanded(
              flex: 15,
              child: UserSearchField(
                searchEditingController: searchController,
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/add_contact",
                      arguments: {"text": searchController.text});
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: AppConstants.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Icon(
                      Icons.add,
                      color: Colors.white,
                      size: constraints.maxHeight * 0.5,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
