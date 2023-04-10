import 'package:flutter/material.dart';
import 'package:workshoppr/post.dart';

class NewPostDialog extends StatefulWidget {
  const NewPostDialog({Key? key}) : super(key: key);

  @override
  _NewPostDialogState createState() => _NewPostDialogState();
}

class _NewPostDialogState extends State<NewPostDialog> {
  final contentController = TextEditingController();
  final imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    contentController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Post Something'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                  controller: contentController,
                  decoration: InputDecoration(hintText: 'Say something'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  }),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                        controller: imageUrlController,
                        decoration:
                            InputDecoration(hintText: 'Enter an image URL'),
                        validator: (value) {
                          if (value == null || value.isEmpty || value == '') {
                            return null;
                          } else if (value.length < 4) {
                            return 'Please enter a valid URL';
                          } else if (value.substring(value.length - 4) ==
                                  '.jpg' ||
                              value.substring(value.length - 4) == '.png' ||
                              value.substring(value.length - 4) == '.jpeg') {
                            return null;
                          } else {
                            return null;
                          }

                          return null;
                        }),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.cloud_upload),
                    onPressed: () {
                      // handle uploading image
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
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text('Post'),
          onPressed: () async {
            final content = contentController.text;
            final imageUrl = imageUrlController.text;
            if (_formKey.currentState!.validate()) {
              await Post.createPost(
                  userId: '', content: content, imageUrl: imageUrl);
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
