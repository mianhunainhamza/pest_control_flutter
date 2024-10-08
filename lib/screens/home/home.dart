import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pest_control_flutter/screens/cleaning.dart';
import 'package:pest_control_flutter/screens/select_service.dart';
import 'package:pest_control_flutter/screens/on_board/start.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/models/recent_service_provider.dart';
import '/models/service.dart';
import '../full_picture.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userName = '';
  String? photoUrl = '';
  String? userId = '';
  List<RecentServiceProvider> model = [];

  Future<void> fetchMostRecentCompletedServiceProvider() async {
    try {
      CollectionReference requestsCollection =
          FirebaseFirestore.instance.collection('requests');
      User? user = FirebaseAuth.instance.currentUser;
      String? clientId = user?.uid;

      QuerySnapshot querySnapshot = await requestsCollection
          .where('userId', isEqualTo: clientId)
          .where('completeTime', isNotEqualTo: '')
          .orderBy('completeTime', descending: true)
          .limit(1)
          .get();

      // Extract the data from the query result
      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic>? mostRecentRequestData =
            querySnapshot.docs.first.data() as Map<String, dynamic>?;

        setState(() {
          if (mostRecentRequestData != null &&
              mostRecentRequestData.containsKey('serviceProviderName') &&
              mostRecentRequestData.containsKey('serviceProviderPhone') &&
              mostRecentRequestData.containsKey('serviceProviderService')) {
            model.add(RecentServiceProvider(
              serviceProviderName: mostRecentRequestData['serviceProviderName'],
              serviceProviderPhone:
                  mostRecentRequestData['serviceProviderPhone'],
              serviceProviderService:
                  mostRecentRequestData['serviceProviderService'],
            ));
          } else {
            print('Required fields are missing in the document.');
            return;
          }
        });
      } else {
        print('No documents found for the specified clientId.');
        return;
      }
    } catch (e) {
      print('Error fetching most recent completed service provider: $e');
      return;
    }
  }

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
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
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

  List<dynamic> workers = [
    [
      'Alfredo Schafer',
      'Plumber',
      'https://images.unsplash.com/photo-1506803682981-6e718a9dd3ee?ixlib=rb-0.3.5&q=80&fm=jpg&crop=faces&fit=crop&h=200&w=200&s=c3a31eeb7efb4d533647e3cad1de9257',
      4.8
    ],
    [
      'Michelle Baldwin',
      'Cleaner',
      'https://images.unsplash.com/photo-1506803682981-6e718a9dd3ee?ixlib=rb-0.3.5&q=80&fm=jpg&crop=faces&fit=crop&h=200&w=200&s=c3a31eeb7efb4d533647e3cad1de9257',
      4.6
    ],
    [
      'Brenon Kalu',
      'Driver',
      'https://images.unsplash.com/photo-1506803682981-6e718a9dd3ee?ixlib=rb-0.3.5&q=80&fm=jpg&crop=faces&fit=crop&h=200&w=200&s=c3a31eeb7efb4d533647e3cad1de9257',
      4.4
    ]
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUserName();
    fetchMostRecentCompletedServiceProvider();
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
        body: SingleChildScrollView(
            child: Column(children: [
          const Padding(
            padding: EdgeInsets.only(left: 20.0, top: 20.0, right: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    offset: const Offset(0, 4),
                    blurRadius: 10.0,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: const CircleAvatar(
                            child: Icon(CupertinoIcons.person),
                          )),
                      const SizedBox(
                        width: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            model.isNotEmpty
                                ? model.first.serviceProviderName
                                : '',
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            model.isNotEmpty
                                ? model.first.serviceProviderService
                                : '',                            style: TextStyle(
                                color: Colors.black.withOpacity(0.7),
                                fontSize: 18),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(15.0)),
                    child: const Center(
                        child: Text(
                      'View Profile',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    )),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (c) => const SelectService()));
                    },
                    child: const Text(
                      'View all',
                    ))
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            height: MediaQuery.of(context).size.height * .2,
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: services.length,
                itemBuilder: (BuildContext context, int index) {
                  return serviceContainer(
                      services[index].imageURL, services[index].name, index);
                }),
          ),
          const SizedBox(
            height: 20,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20.0, right: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Rated',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            height: 120,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: workers.length,
                itemBuilder: (BuildContext context, int index) {
                  return workerContainer(workers[index][0], workers[index][1],
                      workers[index][2], workers[index][3]);
                }),
          ),
          const SizedBox(
            height: 20,
          ),
        ])));
  }

  serviceContainer(String image, String name, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (c) =>
                    CleaningPage(serviceName: services[index].name)));
      },
      child: Container(
        margin: const EdgeInsets.only(right: 5),
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(
            color: Colors.blue.withOpacity(0),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            image.isNotEmpty
                ? Hero(
                    tag: services[index].name,
                    child: Image.asset(image, height: 45))
                : const CircleAvatar(),
            const SizedBox(
              height: 20,
            ),
            Text(
              name,
              style: const TextStyle(fontSize: 15),
            )
          ]),
        ),
      ),
    );
  }

  workerContainer(String name, String job, String image, double rating) {
    return GestureDetector(
      child: AspectRatio(
        aspectRatio: 3.4,
        child: Container(
          margin: const EdgeInsets.only(right: 20),
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.grey.shade200,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child:const CircleAvatar()),
            const SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  job,
                  style: const TextStyle(fontSize: 15),
                )
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  rating.toString(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Icon(
                  Icons.star,
                  color: Colors.orange,
                  size: 20,
                )
              ],
            )
          ]),
        ),
      ),
    );
  }

  Future fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    userName = user?.displayName!;
    userId = user?.uid;
    photoUrl = user?.photoURL!;
  }
}
