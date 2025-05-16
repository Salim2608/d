import 'package:darlink/models/message.dart';
import 'package:flutter/material.dart';

class OwnMessageCard extends StatelessWidget {
  final String message;
  final String time;
  final MessageStatus status;

  const OwnMessageCard({
    this.message = "Hello",
    this.time = "12:30",
    this.status = MessageStatus.sent,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          color: theme.colorScheme.primary,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 60,
                  top: 10,
                  bottom: 20,
                ),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 10,
                child: Row(
                  children: [
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 5),
                    _getStatusIcon(status),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getStatusIcon(MessageStatus status) {
    IconData iconData;
    Color color = Colors.white70;

    switch (status) {
      case MessageStatus.sending:
        iconData = Icons.access_time;
        break;
      case MessageStatus.sent:
        iconData = Icons.check;
        break;
      case MessageStatus.delivered:
        iconData = Icons.done_all;
        break;
      case MessageStatus.read:
        iconData = Icons.done_all;
        color = Colors.blue;
        break;
    }

    return Icon(
      iconData,
      size: 16,
      color: color,
    );
  }
}
