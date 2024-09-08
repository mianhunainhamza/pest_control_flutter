import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pest_control_flutter/screens/auth/login_page.dart';
import 'package:pest_control_flutter/screens/auth/sign_up_page.dart';
import '../../models/service.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  List<Services> services = [
    Services('', 'assets/images/onboard/1.png'),
    Services('', 'assets/images/onboard/2.png'),
    Services('', 'assets/images/onboard/3.png'),
    Services('', 'assets/images/onboard/4.png'),
    Services('', 'assets/images/onboard/5.png'),
    Services('', 'assets/images/onboard/6.png'),
    Services('', 'assets/images/onboard/7.png'),
    Services('', 'assets/images/onboard/8.png'),
    Services('', 'assets/images/onboard/9.png'),
  ];

  int selectedService = 4;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        selectedService = Random().nextInt(services.length);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _serviceContainer(
                      services[index].imageURL,
                      services[index].name,
                      index,
                    );
                  },
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.04),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Welcome to a Pest-Free Environment',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'We provide expert pest control services to keep your home safe and comfortable. Let our professionals handle all your pest concerns with care and precision.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildButton(
                    context,
                    'L O G I N',
                    Colors.black,
                    Colors.white,
                        () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildButton(
                    context,
                    'S I G N U P',
                    Colors.white70,
                    Colors.black,
                        () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const SignupPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Color backgroundColor, Color textColor, VoidCallback onPressed) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Hero(
        tag: 'Button$text',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _serviceContainer(String image, String name, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedService = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: selectedService == index ? Colors.white : Colors.grey.shade100,
          border: Border.all(
            color: selectedService == index ? Colors.blue.shade100 : Colors.transparent,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Center(
          child: Image.asset(
            image,
            height: MediaQuery.of(context).size.width * 0.1,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
