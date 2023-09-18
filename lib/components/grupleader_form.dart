import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:image_picker/image_picker.dart';

class GrupLeader_form extends StatefulWidget {
  final String dataBarang;
  final String noWare;

  const GrupLeader_form(
      {Key? key, required this.dataBarang, required this.noWare})
      : super(key: key);

  @override
  State<GrupLeader_form> createState() => _GrupLeader_formState();
}

class _GrupLeader_formState extends State<GrupLeader_form> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController dataBarangController = TextEditingController();
  TextEditingController noWarehouseController = TextEditingController();

  File? fotoSerah;
  File? fotoSebelum;
  File? fotoSetelah;

  String? fotoSerahURL;
  String? fotoSebelumURL;
  String? fotoSesudahURL;

  int uploadedImageCount = 0;
  int totalImages = 3;

  final picker = ImagePicker();

  Future<void> _getImage(ImageSource source, Function(File) setImage,
      Function(String?) setURL) async {
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        setImage(File(pickedFile.path));
        setURL("");
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> uploadImageAndGetUrl(
      File? image, Function(String?) setURL) async {
    if (image == null) return;

    try {
      Reference storageReference =
          FirebaseStorage.instance.ref().child('images/${DateTime.now()}.jpg');

      await storageReference.putFile(image);

      final String downloadURL = await storageReference.getDownloadURL();

      setURL(downloadURL);

      setState(() {
        uploadedImageCount++;
      });

      if (uploadedImageCount == totalImages) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Images uploaded successfully!'),
        ));

        await FirebaseFirestore.instance
            .collection('items')
            .where('noWarehouse', isEqualTo: widget.noWare)
            .get()
            .then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            DocumentSnapshot doc = querySnapshot.docs[0];
            doc.reference.update({
              'fotoSerahURL': fotoSerahURL,
              'fotoSebelumURL': fotoSebelumURL,
              'fotoSesudahURL': fotoSesudahURL,
            });
          } else {
            print('Dokumen dengan noWare yang sesuai tidak ditemukan.');
          }
        });
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: Builder(
        builder: (context) => AlertDialog(
          scrollable: true,
          title: const Text('Grup Leader page'),
          content: ProgressHUD(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: widget.dataBarang,
                    decoration: const InputDecoration(
                      labelText: 'Data Barang',
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
                    initialValue: widget.noWare,
                    decoration: const InputDecoration(
                      labelText: 'No Warehouse',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Form tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  ElevatedButton(
                    onPressed: () => _getImage(
                        ImageSource.gallery,
                        (image) => fotoSerah = image,
                        (url) => fotoSerahURL = url),
                    child: Text('Select Foto Serah'),
                  ),
                  ElevatedButton(
                    onPressed: () => _getImage(
                        ImageSource.gallery,
                        (image) => fotoSebelum = image,
                        (url) => fotoSebelumURL = url),
                    child: Text('Select Foto Sebelum'),
                  ),
                  ElevatedButton(
                    onPressed: () => _getImage(
                        ImageSource.gallery,
                        (image) => fotoSetelah = image,
                        (url) => fotoSesudahURL = url),
                    child: Text('Select Foto Setelah'),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  if (fotoSerah != null)
                    Image.file(
                      fotoSerah!,
                      width: 200,
                      height: 200,
                    ),
                  if (fotoSebelum != null)
                    Image.file(
                      fotoSebelum!,
                      width: 200,
                      height: 200,
                    ),
                  if (fotoSetelah != null)
                    Image.file(
                      fotoSetelah!,
                      width: 200,
                      height: 200,
                    ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() &&
                    (fotoSerah != null ||
                        fotoSebelum != null ||
                        fotoSetelah != null)) {
                  final progress = ProgressHUD.of(context);
                  progress?.show();

                  uploadedImageCount = 0;

                  await uploadImageAndGetUrl(
                      fotoSerah, (url) => fotoSerahURL = url);
                  await uploadImageAndGetUrl(
                      fotoSebelum, (url) => fotoSebelumURL = url);
                  await uploadImageAndGetUrl(
                      fotoSetelah, (url) => fotoSesudahURL = url);

                  progress?.dismiss();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Upload All'),
            )
          ],
        ),
      ),
    );
  }
}
