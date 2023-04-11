import 'package:flutter/material.dart';
import 'package:workshoppr/new_post_dialog.dart';
import 'package:workshoppr/post.dart';
import 'package:workshoppr/feed_widget.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({
    super.key,
  });
  // final String title;

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: StreamBuilder<List<Post>>(
            stream: Post.readPosts(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final posts = snapshot.data!;
                return ListView(children: posts.map(buildPost).toList());
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }),
        floatingActionButton: FloatingActionButton.extended(
          label: const Text('Post'),
          icon: const Icon(Icons.add),
          backgroundColor: const Color(0xff990000),
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

Widget buildPost(Post post) => FeedWidget(
    userId: post.userId,
    imageUrl: post.imageUrl,
    content: post.content,
    dateTime: post.dateTime.toString());
