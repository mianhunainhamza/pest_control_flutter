import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileAdmin extends StatefulWidget {
  const ProfileAdmin({super.key});

  @override
  State<ProfileAdmin> createState() => _ProfileAdminState();
}

class _ProfileAdminState extends State<ProfileAdmin> {
  String? userName = '';
  String? url = '';
  String service = '';

  void fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      if (user != null) {
        print(user.uid);
        userName = user.displayName;
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        DocumentReference documentReference =
            firestore.collection('users').doc(user.uid);
        DocumentSnapshot docs = await documentReference.get();
        if (docs.exists) {
          setState(() {
            service = docs['service'];
          });
          print(service);
        }
      }
    } catch (error) {
      print(error.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40.0, right: 20.0, left: 20.0),
          child: Text(
            'Profile',
            style: TextStyle(
              fontSize: 35,
              color: Colors.grey.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(children: [
            const Text(
              "Name: ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            Text(
              userName!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            )
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(children: [
            const Text(
              "Service: ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            Text(
              service!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            )
          ]),
        ),
        SizedBox(
            width: MediaQuery.of(context).size.width - 40,
            child: const Divider()),
        const Text('Stats',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),

      ],
    );
  }
}
