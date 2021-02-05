import 'package:flutter/material.dart';
import 'package:flutter_insta/Widgets/hader_widget.dart';
import 'package:flutter_insta/Widgets/progress_widget.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: "Notifications",),
      body: circularProgress(),


    );
  }
}
