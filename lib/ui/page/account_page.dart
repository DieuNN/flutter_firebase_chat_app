import 'dart:io';

import 'package:chat_app/blocs/authentication/authentication_bloc.dart';
import 'package:chat_app/constants/app_constants.dart';
import 'package:chat_app/extensions/firebase_extensions/firebase_authentication.dart';
import 'package:chat_app/ui/widget/common/form_input_field.dart';
import 'package:chat_app/ui/widget/common/user_avatar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  ImagePicker picker = ImagePicker();
  File? imageFile;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  bool showPassword = false;
  bool showConfirmPassword = false;
  GlobalKey<FormState> updateFormKey = GlobalKey<FormState>();
  late ProgressDialog progressDialog;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    progressDialog.close();
    super.dispose();
  }

  @override
  void initState() {
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    progressDialog = ProgressDialog(context: context);
    getDefaultInfo();
    super.initState();
  }

  Future<void> getDefaultInfo() async {
    nameController.text = FirebaseAuth.instance.currentUser?.displayName ?? "";
    emailController.text = FirebaseAuth.instance.currentUser?.email ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is UpdateAccountInProgressState) {
          progressDialog.show(
              msg: "Updating Profile ...",
              backgroundColor: Colors.black,
              msgColor: Colors.white);
        }
        if (state is UpdateAccountSuccessState) {
          Fluttertoast.showToast(
              msg: "Updated successfully! Please sign in again");
          progressDialog.close();
          FirebaseAuthenticationExtensions.signOut();
          Navigator.of(context).pushNamedAndRemoveUntil(
            "/login",
            (route) => false,
          );
        }
        if (state is UpdateAccountFailureState) {
          Fluttertoast.showToast(
            msg: "Update profile error: ${state.errorMessage}",
          );
          progressDialog.close();
        }
      },
      child: ListView(
        children: [
          buildAvatarPicker(),
          buildChangeInfoForm(),
        ],
      ),
    );
  }

  buildChangeInfoForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: updateFormKey,
        child: Column(
          children: [
            FormInputField(
              shouldValidator: false,
              hintText: "Name",
              controller: nameController,
              decoration: getChangeInfoFormDecoration("Name"),
            ),
            const SizedBox(
              height: 16,
            ),
            FormInputField(
              shouldValidator: true,
              hintText: "Email",
              controller: emailController,
              decoration: getChangeInfoFormDecoration("Email"),
            ),
            const SizedBox(
              height: 16,
            ),
            FormInputField(
              shouldValidator: true,
              shouldShowContent: showPassword,
              hintText: "Password",
              controller: passwordController,
              decoration: getChangeInfoFormDecoration(
                "Password",
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                  icon: showPassword
                      ? const Icon(Icons.visibility_off)
                      : const Icon(Icons.visibility),
                ),
              ),
              isPassword: true,
            ),
            const SizedBox(
              height: 16,
            ),
            FormInputField(
              shouldValidator: true,
              shouldShowContent: showConfirmPassword,
              hintText: "Confirm Password",
              controller: confirmPasswordController,
              decoration: getChangeInfoFormDecoration(
                "Confirm Password",
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      showConfirmPassword = !showConfirmPassword;
                    });
                  },
                  icon: showPassword
                      ? const Icon(Icons.visibility_off)
                      : const Icon(Icons.visibility),
                ),
              ),
              isPassword: true,
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: validateForm,
              child: const Text("Update info"),
            ),
          ],
        ),
      ),
    );
  }

  getChangeInfoFormDecoration(String hint, {IconButton? suffixIcon}) {
    return InputDecoration(
      hintStyle: const TextStyle(
        color: Colors.white,
      ),
      suffixIcon: suffixIcon,
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
      hintText: hint,
    );
  }

  buildAvatarPicker() {
    return Center(
      child: Stack(
        children: [
          UserCircleAvatar(
            imageFile: imageFile,
            imageUrl: FirebaseAuth.instance.currentUser?.photoURL,
            width: MediaQuery.of(context).size.width / 3,
            height: MediaQuery.of(context).size.width / 3,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
              onPressed: () {
                if(Platform.isIOS) {
                  Fluttertoast.showToast(msg: "Image picker doesn't support on iOS yet");
                  return;
                }
                showImagePickBottomSheet();
              },
            ),
          ),
        ],
      ),
    );
  }

  void validateForm() {
    if (!updateFormKey.currentState!.validate()) {
      Fluttertoast.showToast(msg: "Please enter required field!");
      return;
    }
    updateInfo();
  }

  void updateInfo() {
    context.read<AuthenticationBloc>().add(
          StartUpdateAccountEvent(
            file: imageFile,
            name: nameController.text,
            email: emailController.text,
            password: confirmPasswordController.text,
          ),
        );
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
                var navigator = Navigator.of(context);
                final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery);
                setState(() {
                  if (image == null) {
                    return;
                  }
                  imageFile = File(image.path);
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
                });
                navigator.pop();
              },
            ),
          ],
        );
      },
    );
  }
}
