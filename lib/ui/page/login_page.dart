import 'dart:developer';

import 'package:chat_app/blocs/authentication/authentication_bloc.dart';
import 'package:chat_app/constants/app_constants.dart';
import 'package:chat_app/model/enum/social_login_provider.dart';
import 'package:chat_app/ui/widget/common/form_input_field.dart';
import 'package:chat_app/utils/keyboard_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart' as sn_dialog;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool shouldShowPassword = false;

  late sn_dialog.ProgressDialog progressDialog;

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
        if (state is SignInInProgressState) {
          progressDialog.show(
            backgroundColor: Colors.black,
            msg: "Signing in ...",
            msgColor: Colors.white,
          );

        }
        if (state is SignInSuccessState) {
          progressDialog.close();
          Navigator.of(context).pushNamedAndRemoveUntil(
            "/",
            (route) => false,
          );
        }
        if (state is SignInFailureState) {
          Fluttertoast.showToast(msg: state.exception);
          progressDialog.close();
        }
      },
      child: Scaffold(
        backgroundColor: AppConstants.primaryColor,
        resizeToAvoidBottomInset: true,
        body: ListView(
          children: [
            // total flex 14
            const SizedBox(
              height: 58,
            ),
            _buildAppLogo(),
            const SizedBox(
              height: 42,
            ),
            _buildLoginForm(),
            const SizedBox(
              height: 42,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginWithSocialButtons() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Text(
              "Login with: ",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () async {
                context.read<AuthenticationBloc>().add(
                      StartSignInEvent(
                        provider: SocialLoginProvider.google,
                      ),
                    );
              },
              icon: const FaIcon(
                FontAwesomeIcons.google,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    final formKey = GlobalKey<FormState>();
    return SizedBox(
      height: 400,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppConstants.secondaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                _buildEmailInputTextField(),
                _buildPasswordInputTextField(),
                _buildForgotPasswordButton(),
                const SizedBox(
                  height: 16,
                ),
                _buildLoginWithEmailButton(formKey),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16),
                  child: _buildLoginWithSocialButtons(),
                ),
                _buildSignUpButton(),
                const SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildAppLogo() {
    return Padding(
      padding: const EdgeInsets.only(left: 48, right: 48),
      child: Image.asset(
        "assets/images/app_logo.png",
        height: 250,
      ),
    );
  }

  _buildEmailInputTextField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FormInputField(
        controller: _emailController,
        hintText: "Email",
        shouldValidator: true,
      ),
    );
  }

  _buildPasswordInputTextField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FormInputField(
        shouldValidator: true,
        controller: _passwordController,
        isPassword: true,
        hintText: "Password",
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              shouldShowPassword = !shouldShowPassword;
            });
          },
          icon: shouldShowPassword
              ? const Icon(
                  Icons.visibility,
                  color: Colors.white,
                )
              : const Icon(
                  Icons.visibility_off,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }

  _buildForgotPasswordButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            child: const Text(
              "Forgot password?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            onTap: () {},
          )
        ],
      ),
    );
  }

  _buildLoginWithEmailButton(GlobalKey<FormState> formKey) {
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
        child: const Text("Login"),
        onPressed: () {
          if (!formKey.currentState!.validate()) {
            Fluttertoast.showToast(msg: "Please enter all the fields");
            return;
          }
          context.read<AuthenticationBloc>().add(
                StartSignInEvent(
                  provider: SocialLoginProvider.email,
                  email: _emailController.text,
                  password: _passwordController.text,
                ),
              );
        },
      ),
    );
  }

  _buildSignUpButton() {
    return GestureDetector(
      onTap: _navigateToSignUpPage,
      child: const Center(
        child: Text(
          "New user? Sign up!",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }

  void _navigateToSignUpPage() {
    KeyboardUtil.hideKeyboard();
    Navigator.of(context).pushNamed("/signup");
  }
}
