import 'package:flutter/material.dart';

Widget buildTextField({
  required TextEditingController controller,
  required String labelText,
  required IconData prefixIcon,
  bool obscureText = false,
  String? Function(String?)? validator,
  Widget? suffixIcon,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscureText,
    validator: validator,
    decoration: InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black.withOpacity(.2)),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black.withOpacity(.7)),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      labelText: labelText,
      prefixIcon: Icon(prefixIcon),
      suffixIcon: suffixIcon,
    ),
  );
}