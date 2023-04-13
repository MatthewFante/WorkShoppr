import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workshoppr/models/post.dart';
import 'image_upload_modal.dart';

class NewPostDialog extends StatefulWidget {
  const NewPostDialog({Key? key}) : super(key: key);

  @override
  _NewPostDialogState createState() => _NewPostDialogState();
}

class _NewPostDialogState extends State<NewPostDialog> {
  final contentController = TextEditingController();
  final imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _imageUrl;

  String truncateUrl(String url) {
    if (url.isEmpty || url == '') {
      return 'No image selected';
    }

    if (url.length <= 40) {
      return url;
    }

    return url.substring(0, 25) + "...";
  }

  Future<String?> _showImageUploadModal(BuildContext context) async {
    return showModalBottomSheet<String>(
      context: context,
      builder: (context) => const ImageUploadModal(),
    );
  }

  @override
  void dispose() {
    contentController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? getCurrentUser() {
      final User? user = FirebaseAuth.instance.currentUser;
      return user;
    }

    final username = getCurrentUser()?.displayName ?? 'Unknown';

    return AlertDialog(
      title: const Text('New Feed Post'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Say something',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(truncateUrl(imageUrlController.text)),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.cloud_upload),
                    onPressed: () {
                      _showImageUploadModal(context).then((imageUrl) {
                        setState(() {
                          _imageUrl = imageUrl;

                          imageUrlController.text = imageUrl ?? '';
                        });
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: const Text('Post'),
          onPressed: () async {
            final content = contentController.text;
            final imageUrl = imageUrlController.text;
            if (_formKey.currentState!.validate()) {
              await Post.createPost(
                  userId: username, content: content, imageUrl: imageUrl);
              Navigator.pop(context);
              contentController.text = '';
              imageUrlController.text = '';
            }
          },
        ),
      ],
    );
  }
}
