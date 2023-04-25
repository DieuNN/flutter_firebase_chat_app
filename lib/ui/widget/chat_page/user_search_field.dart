import 'package:chat_app/constants/app_constants.dart';
import 'package:chat_app/ui/widget/common/form_input_field.dart';
import 'package:flutter/material.dart';

class UserSearchField extends StatelessWidget {
  const UserSearchField(
      {super.key, required this.searchEditingController, this.onChange, this.onSuffixClick});

  final Function(String)? onChange;

  final TextEditingController searchEditingController;
  final VoidCallback? onSuffixClick;

  @override
  Widget build(BuildContext context) {
    return FormInputField(
      shouldValidator: false,
      onChange: onChange,
      hintText: "Search by email ... ",
      controller: searchEditingController,
      suffixIcon: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () {},
      ),
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: const Icon(
            Icons.search,
            color: Colors.white,
          ),
          onPressed: onSuffixClick,
        ),
        hintStyle: const TextStyle(
          color: Colors.white,
        ),
        filled: true,
        fillColor: AppConstants.secondaryColor,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        hintText: "Search ...",
      ),
    );
  }
}
