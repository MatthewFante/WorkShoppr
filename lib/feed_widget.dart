import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeedWidget extends StatelessWidget {
  final String userId;
  final String imageUrl;
  final String content;
  final String dateTime;

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    DateFormat formatter = DateFormat('EEEE, MMMM d, y, h:mm a');
    String prettyDateTime = formatter.format(dateTime);
    return prettyDateTime;
  }

  Widget _getPostImage(String url) {
    if (url == '') {
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Image.asset('assets/placeholder.png').image,
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
      );
    } else {
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(url),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
      );
    }
  }

  const FeedWidget({
    super.key,
    required this.userId,
    required this.imageUrl,
    required this.content,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    String truncatedContent =
        content.length > 140 ? '${content.substring(0, 140)}...' : content;

    String userIdFixed = (userId == '') ? 'Anonymous' : userId;

    String dateTimeFormatted = formatDateTime(dateTime);

    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _getPostImage(imageUrl),
          const SizedBox(width: 10.0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 95,
                    child: Text(
                      truncatedContent,
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(userIdFixed,
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(188, 0, 0, 0),
                      )),
                  Text(dateTimeFormatted,
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontStyle: FontStyle.italic,
                        color: Color.fromARGB(255, 114, 114, 114),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
