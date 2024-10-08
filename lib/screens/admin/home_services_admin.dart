import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pest_control_flutter/screens/full_picture.dart';
import 'package:pest_control_flutter/screens/on_board/start.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/request.dart';
import '../../models/service.dart';

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({Key? key}) : super(key: key);

  @override
  State<HomePageAdmin> createState() => _HomePageState();
}

class _HomePageState extends State<HomePageAdmin> {
  String? userName = '';
  String? photoUrl = '';
  String selectOption = 'Search by City  ';

  Future<void> logoutUser(BuildContext context) async {
    bool confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel the logout
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm the logout
              },
              child: Text(
                'Logout',
                style: TextStyle(color: Colors.red.shade400),
              ),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      try {
        await FirebaseAuth.instance.signOut();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("loggedIn", false);
        prefs.setBool("isAdmin", false);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => StartPage()),
          (route) => false,
        );
      } catch (e) {
        print(e.toString());
      }
    }
  }

  List<Services> services = [
    Services('Cleaning', 'assets/images/cleaning.png'),
    Services('Plumber', 'assets/images/plumber.png'),
    Services('Electrician', 'assets/images/electrician.png'),
  ];

  late List<RequestModel> requests = [];
  late String currentUserId;
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUserName();
    getCurrentUserId();
  }

  void getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
      fetchData();
    } else {
      // Handle the case where the user is not logged in
    }
  }

  Future<void> fetchData() async {
    try {
        QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('requests').get();
        setState(() {
          requests = querySnapshot.docs
              .where((doc) =>
          doc['status'] == 'unknown')
              .map((doc) {
            return RequestModel(
              status: doc['status'],
              repeat: doc['repeat'],
              time: doc['time'],
              address: doc['location'],
              userId: doc['userId'],
              serviceName: doc['serviceName'],
              day: doc['day'],
              month: doc['month'],
              rooms: doc['rooms'],
              requestId: doc['requestId'],
            );
          }).toList();
          isLoading = false;
        });
      } catch (e) {
        print('Error fetching data: $e');
        isLoading = false;
      }
  }

  Future<void> fetchByLocation() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('requests').get();

      List<RequestModel> newRequests = querySnapshot.docs
          .where((doc) =>
      doc['status'] == 'unknown')
          .map((doc) {
        return RequestModel(
          status: doc['status'],
          repeat: doc['repeat'],
          time: doc['time'],
          address: doc['location'],
          userId: doc['userId'],
          serviceName: doc['serviceName'],
          day: doc['day'],
          month: doc['month'],
          rooms: doc['rooms'],
          requestId: doc['requestId'],
        );
      }).toList();

      setState(() {
        if (selectOption != 'Search by City  ') {
          requests = newRequests
              .where((request) => request.address.contains(selectOption))
              .toList();
        } else {
          fetchData();
        }
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('Hi, $userName',
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold)),
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                logoutUser(context);
              },
              icon: Hero(
                tag: 'full',
                child: Icon(
                  Icons.login_outlined,
                  color: Colors.grey.shade700,
                  size: 30,
                ),
              ),
            )
          ],
          leading: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (c) => FullPicture(url: photoUrl!)));
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: photoUrl!.isNotEmpty
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(photoUrl!),
                    )
                  : const CircleAvatar(
                      child: Icon(CupertinoIcons.person),
                    ),
            ),
          ),
        ),
        body: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Text(
                'Services',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: DropdownButton<String>(
                value: selectOption,
                icon: const Icon(LineIcons.city),
                iconSize: 22,
                style: const TextStyle(color: Colors.deepPurple),
                onChanged: (String? newValue) {
                  setState(() {
                    selectOption = newValue!;
                    fetchByLocation();
                  });
                },
                items: <String>[
                  'Search by City  ',
                  'Lahore',
                  'Pir Mahal',
                  'Faisalabad',
                  'Islamabad'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),
            )
          ]),
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchData,
              child: isLoading
                  ? Center(
                      child: SizedBox(
                      height: 300,
                      child: Lottie.asset('assets/images/loading.json',
                          repeat: true),
                    ))
                  : RefreshIndicator(
                      onRefresh: fetchData,
                      child: requests.isNotEmpty
                          ? Expanded(
                              child: ListView.builder(
                                itemCount: requests.length,
                                itemBuilder: (context, index) {
                                  var request = requests[index];
                                  return Card(
                                    color: Colors.white,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 25.0, vertical: 10),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Left side - Image
                                          Image.asset(
                                            'assets/images/${request.serviceName.toLowerCase()}.png',
                                            width: 80,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                          const SizedBox(
                                              width: 18.0), // Adjust spacing

                                          // Right side - Text details
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      const TextSpan(
                                                        text: 'Service Name: ',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            request.serviceName,
                                                        style:
                                                            DefaultTextStyle.of(
                                                                    context)
                                                                .style,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      const TextSpan(
                                                        text: 'Date: ',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            "${request.day} ${request.month}",
                                                        style:
                                                            DefaultTextStyle.of(
                                                                    context)
                                                                .style,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      const TextSpan(
                                                        text: 'Rooms: ',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: request.rooms,
                                                        style:
                                                            DefaultTextStyle.of(
                                                                    context)
                                                                .style,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      const TextSpan(
                                                        text: 'Address: ',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: request.address,
                                                        style:
                                                            DefaultTextStyle.of(
                                                                    context)
                                                                .style,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      const TextSpan(
                                                        text: 'Time: ',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: request.time,
                                                        style:
                                                            DefaultTextStyle.of(
                                                                    context)
                                                                .style,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      const TextSpan(
                                                        text: 'Repeat: ',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: request.repeat,
                                                        style:
                                                            DefaultTextStyle.of(
                                                                    context)
                                                                .style,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 10.0),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              190,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          acceptUserRequest(
                                                              requests[index]
                                                                  .requestId,
                                                              requests[index]
                                                                  .userId);
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.black,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          'Accept Request',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : const Center(
                              child: Text(
                                'No request',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                    ),
            ),
          ),
        ]));
  }

  void acceptUserRequest(String requestId, String clientId) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // Handle the case where the user is not authenticated
        print('Error: User not authenticated.');
        return;
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Assuming your user data is stored in a "users" collection
      DocumentReference userDoc = firestore.collection('users').doc(user.uid);
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (!userSnapshot.exists) {
        print('Error: User document does not exist.');
        return;
      }

      // Extract relevant data from the user document
      String serviceProviderName = userSnapshot['name'];
      String serviceProviderPhone = userSnapshot['phone'];
      String serviceProviderService = userSnapshot['service'];
      String serviceProviderId=userSnapshot['id'];

      // Show a confirmation dialog
      bool confirm = await showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("Confirm Acceptance"),
            content: Text("Are you sure you want to accept this request?"),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context, false); // User canceled
                },
                child: Text("No"),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context, true); // User confirmed
                },
                child: Text("Yes"),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        // Update the request document based on the requestId and clientId
        DocumentReference requestDoc = firestore.collection('requests').doc(requestId);

        DocumentSnapshot requestSnapshot = await requestDoc.get();
        // Update the fields in the request document
        await requestDoc.update({
          'status': 'inprogress',
          'serviceProviderId':serviceProviderId,
          'serviceProviderName': serviceProviderName,
          'serviceProviderPhone': serviceProviderPhone,
          'serviceProviderService': serviceProviderService,
          // Add other fields as needed
        });

        // Fetch and update UI with the latest data
        fetchData();

        print('Request accepted successfully.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.white,
            content: Text(
              "Request Accepted Successfully",
              style: TextStyle(color: Colors.black),
            ),
          ),
        );
      } else {
        print('Request acceptance canceled by user');
      }
    } catch (e) {
      // Handle any errors that might occur during the process
      print('Error: $e');
    }
  }



  Future fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    userName = user?.displayName!;
    photoUrl = user?.photoURL!;
  }
}
