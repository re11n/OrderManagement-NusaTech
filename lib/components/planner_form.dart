// ignore_for_file: avoid_print

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:intl/intl.dart';
import 'package:ordermanagement_nusatech/pages/dashboard.dart';
import 'package:path/path.dart' as path;

class Planner_form extends StatefulWidget {
  const Planner_form({super.key});

  @override
  State<Planner_form> createState() => _Planner_formState();
}

class _Planner_formState extends State<Planner_form> {
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now();
  final DateTime _maxDate = DateTime(2099, 12, 31);

  String _name = '';

  TextEditingController noWarehouse = TextEditingController();
  TextEditingController noUnit = TextEditingController();

  bool isUploading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String? filePath;

  void _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        filePath = result.files.single.path;
      });
    }
  }

  String? _validateDate(DateTime selectedDate) {
    if (selectedDate == null) {
      return 'Tanggal harus diisi';
    }
    if (selectedDate.isAfter(_maxDate)) {
      return 'Tanggal tidak boleh melebihi $_maxDate';
    }
    return null;
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    setState(() {
      isUploading = false;
    });
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sukses'),
          content: Text('Dokumen berhasil diunggah.'),
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

  void upload(String noUnit, String noWare) async {
    if (filePath != null) {
      try {
        setState(() {
          isUploading = true;
        });
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('items/${DateTime.now().millisecondsSinceEpoch}');

        UploadTask uploadTask = storageReference.putFile(File(filePath!));
        TaskSnapshot snapshot = await uploadTask;

        if (snapshot.state == TaskState.success) {
          String downloadURL = await storageReference.getDownloadURL();

          await FirebaseFirestore.instance.collection('items').add({
            'noWarehouse': noWare,
            'noUnit': noUnit,
            'documentURL': downloadURL,
            'timestamp':
                DateFormat('yyyy/MM/dd').format(DateTime.now().toUtc()),
            'estimasi': '-',
            'status': '-',
            'stockCode': '-',
            'quantity': '-',
          });

          setState(() {
            filePath = null;
          });
          // ignore: use_build_context_synchronously
          _showSuccessDialog(context);
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Gagal mengunggah dokumen.'),
          ));
        }
      } catch (e) {
        setState(() {
          isUploading = false;
        });
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Terjadi kesalahan saat mengunggah dokumen.'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Planner page'),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: noWarehouse,
                  decoration: const InputDecoration(
                    labelText: 'No Warehouse Requested',
                  ),
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
                TextFormField(
                  controller: noUnit,
                  decoration: const InputDecoration(
                    labelText: 'No Unit',
                  ),
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
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: "${_selectedDate.toLocal()}".split(' ')[0],
                  ),
                  decoration: InputDecoration(
                    labelText: 'Target Ready Sparepart',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () {
                        _selectDate(context);
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                filePath != null
                    ? Text('Selected Document:\n${path.basename(filePath!)}')
                    : const Text('Upload Document'),
                ElevatedButton(
                  onPressed: _pickDocument,
                  child: const Text('Browse'),
                ),
              ],
            )),
      ),
      actions: [
        ElevatedButton(
            onPressed: () {
              final validationMessage = _validateDate(_selectedDate);
              if (_formKey.currentState!.validate()) {
                if (filePath == null) {
                  _showErrorDialog(context, 'Mohon unggah dokumen');
                } else if (_validateDate(_selectedDate) == null) {
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
                  upload(noUnit.text, noWarehouse.text);
                } else {
                  _showErrorDialog(context, validationMessage!);
                }
              }
            },
            child: const Text('Upload'))
      ],
    );
  }
}
