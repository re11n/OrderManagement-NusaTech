// ignore_for_file: avoid_print
import 'package:flutter/services.dart';
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
  DateTime _eksekusi1 = DateTime.now(); // New date field 2
  DateTime _eksekusi2 = DateTime.now(); // New date field 3
  final DateTime _maxDate = DateTime(2099, 12, 31);

  String _name = '';

  TextEditingController noWarehouse = TextEditingController();
  TextEditingController noUnit = TextEditingController();
  TextEditingController reqQuantity = TextEditingController();

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

  Future<void> _selecteksekusi1(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _eksekusi1,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _eksekusi1) {
      setState(() {
        _eksekusi1 = picked;
      });
    }
  }

  Future<void> _selecteksekusi2(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _eksekusi2,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _eksekusi2) {
      setState(() {
        _eksekusi2 = picked;
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

  Future<bool> isNoWarehouseUnique(String noWarehouse) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('items')
        .where('noWarehouse', isEqualTo: noWarehouse)
        .get();

    return querySnapshot.docs.isEmpty;
  }

  void upload(String noUnit, String noWare, DateTime tanggalReady,
      DateTime eksekusi1, DateTime eksekusi2, String requantity) async {
    try {
      setState(() {
        isUploading = true;
      });

      await FirebaseFirestore.instance.collection('items').add({
        'noWarehouse': noWare,
        'noUnit': noUnit,
        'timestamp': DateFormat('yyyy/MM/dd').format(DateTime.now().toUtc()),
        'estimasi': '',
        'status': 'Not Ready',
        'stockCode': '',
        'quantity': '0',
        'tanggalReady':
            DateFormat('yyyy/MM/dd').format(tanggalReady).toString(),
        'eksekusi1': DateFormat('yyyy/MM/dd').format(eksekusi1).toString(),
        'eksekusi2': DateFormat('yyyy/MM/dd').format(eksekusi2).toString(),
        'dataBarang': '',
        'fotoSerahURL': '',
        'fotoSebelumURL': '',
        'fotoSesudahURL': '',
        'reqQuantity': requantity,
      });

      setState(() {
        filePath = null;
      });

      _showSuccessDialog(context);
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
              TextFormField(
                controller: reqQuantity,
                decoration: const InputDecoration(
                  labelText: 'Request Quantity',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Form tidak boleh kosong';
                  }
                  return null;
                },
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                keyboardType: TextInputType.number,
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
                height: 15,
              ),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: "${_eksekusi1.toLocal()}".split(' ')[0],
                ),
                decoration: InputDecoration(
                  labelText: 'Tanggal Eksekusi 1',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () {
                      _selecteksekusi1(context);
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: "${_eksekusi2.toLocal()}".split(' ')[0],
                ),
                decoration: InputDecoration(
                  labelText: 'Tanggal Eksekusi 2',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () {
                      _selecteksekusi2(context);
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            final validationMessage = _validateDate(_selectedDate);
            if (_formKey.currentState!.validate()) {
              if (_validateDate(_selectedDate) == null) {
                final isUnique = await isNoWarehouseUnique(noWarehouse.text);
                if (isUnique) {
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
                  upload(noUnit.text, noWarehouse.text, _selectedDate,
                      _eksekusi1, _eksekusi2, reqQuantity.text);
                } else {
                  _showErrorDialog(context,
                      'No Warehouse sudah ada. Silahkan masukkan No warehouse yang lain');
                }
              } else {
                _showErrorDialog(context, validationMessage!);
              }
            }
          },
          child: const Text('Upload'),
        )
      ],
    );
  }
}
