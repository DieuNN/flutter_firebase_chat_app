import 'package:chat_app/blocs/authentication/authentication_bloc.dart';
import 'package:chat_app/constants/app_constants.dart';
import 'package:chat_app/ui/widget/common/form_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart' as sn_dialog;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

final formKey = GlobalKey<FormState>();

class _SignUpPageState extends State<SignUpPage> {
  bool shouldShowPassword = false;
  bool shouldShowConfirmPassword = false;
  TextEditingController emailTextController = TextEditingController();
  TextEditingController nameTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();
  TextEditingController confirmPasswordTextController = TextEditingController();

  late final sn_dialog.ProgressDialog progressDialog;

  @override
  void initState() {
    progressDialog = sn_dialog.ProgressDialog(
      context: context,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is CreateAccountInProgressState) {
          progressDialog.show(
              msg: "Signing up ...",
              backgroundColor: Colors.black,
              msgColor: Colors.white);
        }
        if (state is CreateAccountFailureState) {
          Fluttertoast.showToast(msg: state.errorMessage);
          progressDialog.close();
        }
        if (state is CreateAccountSuccessState) {
          Fluttertoast.showToast(msg: "Sign up successful, now you can login!");
          Navigator.of(context).popAndPushNamed("/login");
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.black,
        body: SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Image.asset(
                "assets/images/app_logo.png",
                width: MediaQuery.of(context).size.width / 5,
                height: MediaQuery.of(context).size.width / 3,
              ),
              const SizedBox(
                height: 16,
              ),
              _buildSignUpForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Form(
        key: formKey,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppConstants.secondaryColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              _buildEmailInputForm(),
              _buildNameInputForm(),
              _buildPasswordInputForm(),
              _buildConfirmPasswordInputForm(),
              _buildSignUpButton(formKey),
            ],
          ),
        ),
      ),
    );
  }

  _buildSignUpButton(GlobalKey<FormState> formKey) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: AppConstants.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          if (nameTextController.text.trim().isEmpty) {
            Fluttertoast.showToast(msg: "Name cannot be empty!");
            return;
          }
          if (passwordTextController.text !=
              confirmPasswordTextController.text) {
            Fluttertoast.showToast(msg: "Password doesn't match!");
            return;
          }
          if (!formKey.currentState!.validate()) {
            Fluttertoast.showToast(msg: "Please enter all the fields");
            return;
          }
          context.read<AuthenticationBloc>().add(
                StartCreateAccountEvent(
                    email: emailTextController.text,
                    password: confirmPasswordTextController.text,
                    name: nameTextController.text),
              );
        },
        child: const Text("Sign up"),
      ),
    );
  }

  Widget _buildEmailInputForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FormInputField(
        hintText: "Email",
        controller: emailTextController,
        isPassword: false,
        shouldValidator: true,
      ),
    );
  }

  _buildPasswordInputForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FormInputField(
        isPassword: true,
        hintText: "Password",
        controller: passwordTextController,
        shouldValidator: true,
        suffixIcon: shouldShowPassword == true
            ? IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () {
                  setState(() {
                    shouldShowPassword = !shouldShowPassword;
                  });
                },
              )
            : IconButton(
                icon: const Icon(Icons.visibility_off),
                onPressed: () {
                  setState(
                    () {
                      shouldShowPassword = !shouldShowPassword;
                    },
                  );
                },
              ),
      ),
    );
  }

  _buildConfirmPasswordInputForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FormInputField(
        hintText: "Confirm password",
        isPassword: true,
        controller: confirmPasswordTextController,
        shouldValidator: true,
        suffixIcon: shouldShowConfirmPassword == true
            ? IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () {
                  setState(() {
                    shouldShowConfirmPassword = !shouldShowConfirmPassword;
                  });
                },
              )
            : IconButton(
                icon: const Icon(Icons.visibility_off),
                onPressed: () {
                  setState(
                    () {
                      shouldShowConfirmPassword = !shouldShowConfirmPassword;
                    },
                  );
                },
              ),
      ),
    );
  }

  _buildNameInputForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FormInputField(
        hintText: "Name",
        controller: nameTextController,
        isPassword: false,
        shouldValidator: false,
      ),
    );
  }
}
