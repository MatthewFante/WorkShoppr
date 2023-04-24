// Matthew Fante
// INFO-C342: Mobile Application Development
// Spring 2023 Final Project

// this widget is used to display posts in the feed page

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

  const FeedWidget({
    super.key,
    required this.userId,
    required this.imageUrl,
    required this.content,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    // allow for extra space in the feed for text if there is no image
    int allowedContentLength;
    imageUrl != '' ? allowedContentLength = 140 : allowedContentLength = 240;

    // truncate the content if it is too long
    String truncatedContent = content.length > allowedContentLength
        ? '${content.substring(0, allowedContentLength)}...'
        : content;

    // if the user is anonymous, display 'Anonymous' instead of an empty string
    String userIdFixed = (userId == '') ? 'Anonymous' : userId;

    // format the date and time
    String dateTimeFormatted = formatDateTime(dateTime);

    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // if there is an image, display it
          imageUrl != '' ? _getPostImage(imageUrl) : Container(),
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
