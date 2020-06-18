import 'package:flutter/material.dart';

import '../../zefyr.dart';

class AlignmentButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);

    return ZefyrButton.icon(
      action: ZefyrToolbarAction.align,
      icon: Icons.format_align_justify,
      onPressed: () {
        showOverlay(context);
      },
    );
  }

  void showOverlay(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);
    toolbar.showOverlay(buildOverlay);
  }

  Widget buildOverlay(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);
    final buttons = Row(
      children: <Widget>[
        SizedBox(width: 8.0),
        toolbar.buildButton(context, ZefyrToolbarAction.alignStart),
        toolbar.buildButton(context, ZefyrToolbarAction.alignCenter),
        toolbar.buildButton(context, ZefyrToolbarAction.alignEnd),
      ],
    );
    return ZefyrToolbarScaffold(body: buttons);
  }
}
