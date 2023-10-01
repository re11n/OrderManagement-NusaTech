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
        return querySnapshot.docs.first;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  String roleValue = "";

  Future<void> fetchData() async {
    try {
      DocumentSnapshot<Object?>? documentSnapshot =
          await getDocumentFromFirestore();
      if (documentSnapshot != null && documentSnapshot.exists) {
        roleValue = documentSnapshot['role'] as String;
      } else {
        roleValue = 'Data tidak ditemukan';
      }
    } catch (e) {
      roleValue = 'Terjadi kesalahan: $e';
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

  // void form(String role) {
  //   switch (role) {
  //     case 'planner':
  //       showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return Planner_form();
  //           });
  //       break;
  //     default:
  //   }
  // }

  void editForm(String role, String noWare, String noUnit, String stockCode,
      String quantity, String dataBarang, String estimasi) {
    switch (role) {
      case 'warehouse':
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Warehouse_form(
                noUnit: noUnit,
                noWare: noWare,
                quantity: quantity,
                stokCode: stockCode,
              );
            });
        break;
      case 'purchasing':
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Purchasing_form(
                noWarehouse: noWare,
                noUnit: noUnit,
                stokCode: stockCode,
                dataBarang: dataBarang,
                estimasi: estimasi,
              );
            });
        break;
      case 'grupleader':
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return GrupLeader_form(
                dataBarang: dataBarang,
                noWare: noWare,
              );
            });
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
          title: const Center(child: Text('Dashboard')),
          actions: [
            IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout)),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder<void>(
                future: fetchData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Terjadi kesalahan: ${snapshot.error}');
                  } else {
                    return Column(
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Dashboard',
                              style: TextStyle(fontSize: 25.0),
                            ),
                            Text(
                              ' $roleValue',
                              style: const TextStyle(
                                  fontSize: 25.0, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        roleValue == 'planner'
                            ? Padding(
                                padding: const EdgeInsets.only(top: 30),
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Planner_form();
                                        });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(15),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 70),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFC30D),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                        child: Text(
                                      getTextBasedOnCondition(roleValue),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    )),
                                  ),
                                ))
                            : Text('')
                      ],
                    );
                  }
                },
              ),
              const SizedBox(
                height: 30,
              ),
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('items').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  List<DocumentSnapshot> documents = snapshot.data?.docs ?? [];

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateColor.resolveWith(
                          (states) => Colors.teal),
                      columns: const [
                        DataColumn(label: Text('Tanggal Pemesanan')),
                        DataColumn(label: Text('No Warehouse')),
                        DataColumn(label: Text('No Unit')),
                        DataColumn(label: Text('Tanggal Eksekusi 1')),
                        DataColumn(label: Text('Tanggal Eksekusi 2')),
                        DataColumn(label: Text('Request Quantity')),
                        DataColumn(label: Text('Quantity')),
                        DataColumn(label: Text('Persentase')),
                        DataColumn(label: Text('Estimasi Sampai')),
                        DataColumn(label: Text('Edit')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: documents.map((document) {
                        var data = document.data() as Map<String, dynamic>;

                        return DataRow(cells: [
                          DataCell(Text(data['timestamp'].toString())),
                          DataCell(Text(data['noWarehouse'].toString())),
                          DataCell(Text(data['noUnit'].toString())),
                          DataCell(Text(data['eksekusi1'].toString())),
                          DataCell(Text(data['eksekusi2'].toString())),
                          DataCell(Text(data['reqQuantity'].toString())),
                          DataCell(Text(data['quantity'].toString())),
                          DataCell(Text((int.parse(data['quantity']) -
                                  int.parse(data['reqQuantity']))
                              .toString())),
                          DataCell(Text(data['estimasi'].toString())),
                          DataCell(InkWell(
                            onTap: () {
                              editForm(
                                roleValue,
                                data['noWarehouse'],
                                data['noUnit'],
                                data['stockCode'],
                                data['quantity'],
                                data['dataBarang'],
                                data['estimasi'],
                              );
                            },
                            child: Icon(Icons.edit),
                          )),
                          DataCell(Text(data['status'].toString())),
                        ]);
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
