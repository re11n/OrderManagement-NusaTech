import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ordermanagement_nusatech/components/grupleader_form.dart';
import 'package:ordermanagement_nusatech/components/planner_form.dart';
import 'package:ordermanagement_nusatech/components/purchasing_form.dart';
import 'package:ordermanagement_nusatech/components/warehouse_form.dart';

class dashboard extends StatefulWidget {
  const dashboard({super.key});

  @override
  State<dashboard> createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  CollectionReference myCollection =
      FirebaseFirestore.instance.collection('users');

  Future<DocumentSnapshot?> getDocumentFromFirestore() async {
    try {
      QuerySnapshot querySnapshot = await myCollection
          .where('email', isEqualTo: '${currentUser?.email}')
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        // Mengambil dokumen pertama yang cocok dengan kriteria
        return querySnapshot.docs.first;
      } else {
        // Data tidak ditemukan
        return null;
      }
    } catch (e) {
      // Penanganan kesalahan jika terjadi masalah dalam pengambilan data.
      return null;
    }
  }

  String myValue = "";

  Future<void> fetchData() async {
    try {
      DocumentSnapshot<Object?>? documentSnapshot =
          await getDocumentFromFirestore();
      if (documentSnapshot != null && documentSnapshot.exists) {
        myValue = documentSnapshot['role'] as String;
      } else {
        myValue = 'Data tidak ditemukan';
      }
    } catch (e) {
      myValue = 'Terjadi kesalahan: $e';
    }
  }

  String getTextBasedOnCondition(String conditionValue) {
    switch (conditionValue) {
      case 'planner':
        return 'Order';
      default:
        return 'Edit Table';
    }
  }

  void form(String role) {
    switch (role) {
      case 'planner':
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Planner_form()));
        break;
      case 'warehouse':
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Warehouse_form()));
        break;
      case 'grupleader':
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => GrupLeader_form()));
        break;
      case 'purchasing':
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => Purchasing_form()));
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(63, 81, 181, 1),
          title: Center(child: Text('Dashboard')),
          actions: [
            IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout)),
          ],
        ),
        body: Column(
          children: [
            Row(
              children: const [
                Text(
                  'Dashboard',
                  style: TextStyle(fontSize: 25.0),
                ),
                Text(
                  ' Page',
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                )
              ],
            ),
            FutureBuilder<void>(
              future: fetchData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Terjadi kesalahan: ${snapshot.error}');
                } else {
                  return Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: GestureDetector(
                            onTap: () {
                              form(myValue);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 70),
                              decoration: BoxDecoration(
                                color: Color(0xFFFFC30D),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                  child: Text(
                                getTextBasedOnCondition(myValue),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              )),
                            ),
                          )),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
