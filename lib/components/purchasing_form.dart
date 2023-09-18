// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Purchasing_form extends StatefulWidget {
  final String noWarehouse;
  final String noUnit;
  final String stokCode;
  final String dataBarang;
  final String estimasi;

  const Purchasing_form(
      {super.key,
      required this.noWarehouse,
      required this.noUnit,
      required this.stokCode,
      required this.dataBarang,
      required this.estimasi});

  @override
  State<Purchasing_form> createState() => _Purchasing_formState();
}

class _Purchasing_formState extends State<Purchasing_form> {
  final _formKey = GlobalKey<FormState>();
  String _status = 'Ready';
  bool isUploading = false;
  TextEditingController databarang = TextEditingController();
  TextEditingController estimasi = TextEditingController();

  @override
  void initState() {
    super.initState();

    databarang.text = widget.dataBarang;
    estimasi.text = widget.estimasi;
  }

  void _showSuccessDialog(BuildContext context) {
    setState(() {
      isUploading = false;
    });
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sukses'),
          content: const Text('Data berhasil diunggah.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
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
      title: const Text('Purchasing page'),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Data Barang',
                  ),
                  controller: databarang,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Form tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                DropdownButtonFormField<String>(
                  value: _status,
                  onChanged: (newValue) {
                    setState(() {
                      _status = newValue ?? 'Ready';
                    });
                  },
                  items: <String>['Ready', 'Not Ready'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Status',
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'No Warehouse Requested',
                  ),
                  readOnly: true,
                  initialValue: widget.noWarehouse,
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'No Unit',
                  ),
                  readOnly: true,
                  initialValue: widget.noUnit,
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Stock Code',
                  ),
                  readOnly: true,
                  initialValue: widget.stokCode,
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Estimasi Datang',
                  ),
                  controller: estimasi,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Form tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            )),
      ),
      actions: [
        ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                String nowarehouse = widget.noWarehouse;
                Map<String, dynamic> fieldsToUpdate = {
                  'dataBarang': databarang.text,
                  'estimasi': estimasi.text,
                  'status': _status,
                };
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Uploading...'),
                      content: isUploading
                          ? const CircularProgressIndicator()
                          : const Text('Upload completed.'),
                    );
                  },
                );
                await updateDocumentFields(nowarehouse, fieldsToUpdate);
              }
            },
            child: const Text('Upload'))
      ],
    );
  }
}
