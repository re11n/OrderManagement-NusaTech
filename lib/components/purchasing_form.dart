import 'package:flutter/material.dart';

class Purchasing_form extends StatefulWidget {
  const Purchasing_form({super.key});

  @override
  State<Purchasing_form> createState() => _Purchasing_formState();
}

class _Purchasing_formState extends State<Purchasing_form> {
  final _formKey = GlobalKey<FormState>();
  String _status = 'Ready';

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
                  decoration: const InputDecoration(
                    labelText: 'Data Barang 1',
                  ),
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
                  decoration: InputDecoration(
                    labelText: 'Status',
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'No Warehouse Requested',
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'No Unit',
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Stock Code',
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Estimasi Datang',
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            )),
      ),
      actions: [
        ElevatedButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text('data $_status'),
                    );
                  });
            },
            child: Text('Upload'))
      ],
    );
  }
}
