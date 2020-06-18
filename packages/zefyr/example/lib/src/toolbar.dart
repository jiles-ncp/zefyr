import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:zefyr/zefyr.dart';

class CustomToolbarDelegate extends ZefyrToolbarDelegate {
  @override
  Widget buildButton(BuildContext context, ZefyrToolbarAction action,
      {onPressed}) {
    // return super.buildButton(context, action);
    return Text('custom toolbar delegate');
  }
}
