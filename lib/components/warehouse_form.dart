import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class Warehouse_form extends StatefulWidget {
  final String noWare;
  final String noUnit;

  const Warehouse_form({super.key, required this.noWare, required this.noUnit});

  @override
  State<Warehouse_form> createState() => _Warehouse_formState();
}

class _Warehouse_formState extends State<Warehouse_form> {
  final _formKey = GlobalKey<FormState>();
  bool isUploading = false;
  TextEditingController stockCode = TextEditingController();
  TextEditingController quantity = TextEditingController();

  void _showSuccessDialog(BuildContext context) {
    setState(() {
      isUploading = false;
    });
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sukses'),
          content: Text('Data berhasil diunggah.'),
          actions: <Widget>[
            TextButton(
              child: Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<DocumentSnapshot?> getDocumentById(String id) async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection('items');

    QuerySnapshot querySnapshot =
        await collection.where('noWarehouse', isEqualTo: id).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs[0];
    } else {
      return null;
    }
  }

  Future<void> updateDocumentFields(
      String id, Map<String, dynamic> updatedFields) async {
    setState(() {
      isUploading = true;
    });

    DocumentSnapshot? doc = await getDocumentById(id);

    if (doc != null) {
      DocumentReference docReference = doc.reference;

      await docReference.update(updatedFields);
      _showSuccessDialog(context);
    } else {
      setState(() {
        isUploading = false;
      });
      print('Dokumen tidak ditemukan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text('Purchasing page'),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'No Warehouse Requested',
                  ),
                  readOnly: true,
                  initialValue: widget.noWare,
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'No Unit',
                  ),
                  initialValue: widget.noUnit,
                  readOnly: true,
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Stock Code',
                  ),
                  controller: stockCode,
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                  ),
                  controller: quantity,
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            )),
      ),
      actions: [
        ElevatedButton(
            onPressed: () async {
              String nowarehouse = widget.noWare;
              Map<String, dynamic> fieldsToUpdate = {
                'stockCode': stockCode.text,
                'quantity': quantity.text,
              };
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Uploading...'),
                    content: isUploading
                        ? CircularProgressIndicator()
                        : Text('Upload completed.'),
                  );
                },
              );
              await updateDocumentFields(nowarehouse, fieldsToUpdate);
            },
            child: Text('Upload'))
      ],
    );
  }
}
