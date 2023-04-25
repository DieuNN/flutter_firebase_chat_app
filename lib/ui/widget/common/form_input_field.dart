import 'package:chat_app/constants/app_constants.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class FormInputField extends StatelessWidget {
  final IconButton? suffixIcon;
  final String? hintText;
  final InputDecoration? decoration;
  final TextEditingController controller;
  final bool shouldValidator;
  final bool isPassword;
  final Function(String)? onChange;

  const FormInputField(
      {super.key,
      this.hintText,
      this.suffixIcon,
      required this.controller,
      this.decoration,
      required this.shouldValidator,
      this.isPassword = false,
      this.onChange});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChange,
      controller: controller,
      keyboardType: suffixIcon == null
          ? TextInputType.emailAddress
          : TextInputType.visiblePassword,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: isPassword,
      validator: (value) {
        if (!shouldValidator!) {
          return null;
        }
        if (!isPassword) {
          if (controller.text.trim().isEmpty) {
            return "Please enter an email!";
          }

          if (!EmailValidator.validate(controller.text.trim())) {
            return "Email is not valid";
          }
        }

        if (controller.text.trim().isEmpty || controller.text.length < 6) {
          return "Password must be longer than 6 character";
        }

        return null;
      },
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      decoration: decoration ??
          InputDecoration(
            suffixIcon: suffixIcon,
            hintText: hintText,
            hintStyle: TextStyle(
              color: AppConstants.hintTextColor,
              fontSize: 14,
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
    );
  }
}
