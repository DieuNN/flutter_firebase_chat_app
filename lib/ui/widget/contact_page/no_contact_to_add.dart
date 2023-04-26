import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NoContactToAdd extends StatelessWidget {
  const NoContactToAdd({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      FaIcon(
        FontAwesomeIcons.addressBook,
        color: Colors.white,
        size: MediaQuery.of(context).size.width / 3,
      ),
      const SizedBox(
        height: 16,
      ),
      const Text(
        "Contact not found",
        style: TextStyle(color: Colors.white, fontSize: 18),
      )
    ]);
  }
}
