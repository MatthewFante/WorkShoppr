import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String userId;
  final String content;
  final String imageUrl;
  final String dateTime;

  Post(
      {this.userId = '',
      required this.content,
      required this.imageUrl,
      required this.dateTime});

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'content': content,
        'imageUrl': imageUrl,
        'dateTime': dateTime
      };

  static Post fromJson(Map<String, dynamic> json) => Post(
        userId: json['userId'],
        content: json['content'],
        imageUrl: json['imageUrl'],
        dateTime: json['dateTime'],
      );

  static Stream<List<Post>> readPosts() => FirebaseFirestore.instance
      .collection('posts')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Post.fromJson(doc.data())).toList());

  static Future createPost(
      {required String userId,
      required String content,
      required String imageUrl}) async {
    final docPost = FirebaseFirestore.instance.collection('posts').doc();
    final post = Post(
      userId: userId,
      content: content,
      imageUrl: imageUrl,
      dateTime: DateTime.now().toString(),
    );
    var json = post.toJson();
    await docPost.set(json);
  }
}
