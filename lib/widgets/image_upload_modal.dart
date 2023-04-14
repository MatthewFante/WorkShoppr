import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadModal extends StatefulWidget {
  const ImageUploadModal({Key? key}) : super(key: key);

  @override
  _ImageUploadModalState createState() => _ImageUploadModalState();
}

class _ImageUploadModalState extends State<ImageUploadModal> {
  File? _imageFile;
  String? _imageUrl;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    setState(() {
      _isUploading = true;
    });

    if (_imageFile != null) {
      final storage = FirebaseStorage.instance;
      final ref = storage.ref().child('images/${DateTime.now().toString()}');
      final uploadTask = ref.putFile(_imageFile!);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        _imageUrl = downloadUrl;
        _isUploading = false;
      });
      Navigator.of(context).pop(_imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select an image to upload'),
          const SizedBox(height: 16),
          IconButton(
            icon: const Icon(Icons.add_photo_alternate),
            onPressed: _pickImage,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isUploading ? null : _uploadImage,
            child: _isUploading
                ? const CircularProgressIndicator()
                : const Text('Upload'),
          ),
        ],
      ),
    );
  }
}
