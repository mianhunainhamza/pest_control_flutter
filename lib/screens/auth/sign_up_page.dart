import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:lottie/lottie.dart';
import 'package:pest_control_flutter/screens/admin/signup_admin.dart';
import 'package:pest_control_flutter/screens/auth/verify_email.dart';

import '../../widgets/custom_text_field.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();
  bool obscureText = true;
  bool obscureTextConfirm = true;
  bool tickMark = false;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    var mediaQuerySize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Welcome to a Pest-Free Environment",
                    style: GoogleFonts.actor(
                      fontSize: mediaQuerySize.width * 0.065,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                SizedBox(height: mediaQuery.size.width * 0.06),
                SizedBox(
                  height: 90,
                  child: buildTextField(
                    controller: firstNameController,
                    labelText: 'First Name',
                    prefixIcon: CupertinoIcons.person,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 90,
                  child: buildTextField(
                    controller: lastNameController,
                    labelText: 'Last Name',
                    prefixIcon: CupertinoIcons.person,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 90,
                  child: buildTextField(
                    controller: emailController,
                    labelText: 'Email',
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value!.isEmpty || !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 90,
                  child: buildTextField(
                    controller: passController,
                    labelText: 'Password',
                    obscureText: obscureText,
                    prefixIcon: CupertinoIcons.lock,
                    validator: (value) {
                      if (value!.length < 8) {
                        return 'Password must be at least 8 characters long';
                      }
                      if (!RegExp(r'[A-Z]').hasMatch(value)) {
                        return 'Password must contain at least one uppercase letter';
                      }
                      if (!RegExp(r'[0-9]').hasMatch(value)) {
                        return 'Password must contain at least one number';
                      }
                      return null;
                    },
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                      child: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 90,
                  child: buildTextField(
                    controller: confirmPassController,
                    labelText: 'Confirm Password',
                    obscureText: obscureTextConfirm,
                    prefixIcon: CupertinoIcons.lock,
                    validator: (value) {
                      if (value != passController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 80,
                  child: IntlPhoneField(
                    disableLengthCheck: true,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
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
                    ),
                    initialCountryCode: 'US',
                    onChanged: (phone) {
                      print(phone.completeNumber);
                    },
                  )
                ),
                SizedBox(height: mediaQuery.size.width * 0.02),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      tickMark = !tickMark;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      tickMark
                          ? const Icon(CupertinoIcons.check_mark)
                          : const Icon(CupertinoIcons.square,
                              color: CupertinoColors.inactiveGray),
                      const Text(" I've read and agree to "),
                      GestureDetector(
                        onTap: () {
                          // Navigate to Terms and Conditions page
                        },
                        child: const Text(
                          "Terms & Conditions",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: mediaQuery.size.width * 0.05),
                GestureDetector(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      if (!tickMark) {
                        _showErrorDialog(
                            "Please agree to the terms and conditions.");
                      } else {
                        _registerUser();
                      }
                    }
                  },
                  child: _buildSignUpButton(mediaQuerySize),
                ),
                // SizedBox(height: mediaQuery.size.width * 0.05),
                // _buildSignUpRedirect(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton(Size mediaQuerySize) {
    return Hero(
      tag: 'ButtonSIGNUP',
      child: Material(
        child: InkWell(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            height: mediaQuerySize.width * 0.15,
            width: mediaQuerySize.width * 0.9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "SIGN UP",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: mediaQuerySize.width * 0.054,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  size: mediaQuerySize.width * 0.08,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  //
  // Widget _buildSignUpRedirect() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       const Text("New as Service Provider? "),
  //       GestureDetector(
  //         onTap: () {
  //           Navigator.of(context).push(
  //             CupertinoPageRoute(
  //               builder: (context) => const SignupAdmin(),
  //             ),
  //           );
  //         },
  //         child: const Text(
  //           "Create Account",
  //           style: TextStyle(
  //             fontWeight: FontWeight.bold,
  //             fontSize: 14,
  //             decoration: TextDecoration.underline,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Future<void> _registerUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Lottie.asset('assets/images/loading.json', repeat: true),
        );
      },
    );

    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );

      final User? user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'phone': phoneController.text,
          'email': emailController.text.trim(),
          'uid': user.uid,
        });

        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) => VerifyEmailPage(
              email: emailController.text.trim(),
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      _showErrorDialog(e.message ?? 'An error occurred');
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
