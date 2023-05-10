import 'package:chat_app/blocs/authentication/authentication_bloc.dart';
import 'package:chat_app/constants/app_constants.dart';
import 'package:chat_app/ui/widget/common/form_input_field.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if(state is ForgetPasswordInProgressState) {
          Fluttertoast.showToast(msg: "Sending email ...");
        }
        if(state is ForgetPasswordSuccessState) {
          Fluttertoast.showToast(msg: "An email sent!");
        }
        if(state is ForgetPasswordFailureState) {
          Fluttertoast.showToast(msg: "Error: ${state.errorMessage}");
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
            title: const Text(
              "Forgot password",
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Your email: ",
                    style: TextStyle(color: Colors.white),
                  ),
                  FormInputField(
                    controller: textEditingController,
                    shouldValidator: true,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  buildForgetPasswordButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildForgetPasswordButton() {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: MediaQuery
          .of(context)
          .size
          .width),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.secondaryColor,
        ),
        onPressed: () {
          if(!EmailValidator.validate(textEditingController.text)) {
            return;
          }
          sendForgetPasswordEmail();
        },
        child: const Text(
          "Send email",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void sendForgetPasswordEmail() {
    context.read<AuthenticationBloc>().add(StartForgetPasswordEvent(email: textEditingController.text));
  }
}
