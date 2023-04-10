import 'package:flutter/material.dart';
import 'package:workshoppr/new_post_dialog.dart';
import 'package:workshoppr/post.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key, required this.title});
  final String title;

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('WorkShoppr'),
        ),
        body: StreamBuilder<List<Post>>(
            stream: Post.readPosts(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final posts = snapshot.data!;
                return ListView(children: posts.map(buildPost).toList());
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
        floatingActionButton: FloatingActionButton.extended(
          label: Text('+ Post'),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const NewPostDialog();
              },
            );
          },
        ),
      );
}

Widget _getPostImage(String url) {
  if (url == '') {
    return Icon(Icons.person);
  } else {
    return Image.network(url);
  }
}

Widget buildPost(Post post) => ListTile(
      leading: _getPostImage(post.imageUrl),
      title: Text(post.content),
      subtitle: Text(post.dateTime.toString()),
    );
