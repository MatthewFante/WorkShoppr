import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workshoppr/widgets/new_post_dialog.dart';
import 'package:workshoppr/models/post.dart';
import 'package:workshoppr/widgets/feed_widget.dart';

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
              posts.sort((a, b) => b.dateTime.compareTo(a.dateTime));

              return ListView.separated(
                itemBuilder: (context, index) => buildPost(posts[index]),
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.grey,
                  height: 1.0,
                ),
                itemCount: posts.length,
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
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

  Widget buildPost(Post post) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.close),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          Text(post.userId),
                          Text(formatDateTime(post.dateTime.toString()),
                              style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    post.imageUrl == ''
                        ? Container()
                        : Column(
                            children: [
                              Image.network(post.imageUrl),
                              const SizedBox(height: 16),
                            ],
                          ),
                    Text(post.content),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: FeedWidget(
        userId: post.userId,
        imageUrl: post.imageUrl,
        content: post.content,
        dateTime: post.dateTime.toString(),
      ),
    );
  }
}

String formatDateTime(String dateTimeString) {
  DateTime dateTime = DateTime.parse(dateTimeString);
  DateFormat formatter = DateFormat('EEEE, MMMM d, y, h:mm a');
  String prettyDateTime = formatter.format(dateTime);
  return prettyDateTime;
}
