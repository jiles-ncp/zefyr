import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';

// class CustomButton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ZefyrButton.child(
//       action: ZefyrToolbarAction.,
//       onPressed: () {},
//       child: RaisedButton(
//         child: Text('btn'),
//         onPressed: () {},
//       ),
//     );
//   }
// }

class CustomToolbarDelegate extends DefaultZefyrToolbarDelegate {
  // @override
  // Widget buildButton(BuildContext context, ZefyrToolbarAction action,
  //     {onPressed});

  @override
  List<Widget> buildButtons(BuildContext context, ZefyrScope editor) {
    return <Widget>[
      BoldButton(),
      ItalicButton(),
      UnderlineButton(),
      HeadingButton(),
      LinkButton(),

      ZefyrSpacer(),

      TextHighlightButton(),
      TextColorButton(),
      if (editor.imageDelegate != null) ImageButton(),

      ZefyrSpacer(),

      AlignmentButton(),
      MarginButton(),

      ZefyrSpacer(),

      BulletListButton(),

      NumberListButton(),

      // LinkButton(),
      // HeadingButton(),
      // BulletListButton(),
      // NumberListButton(),
      // QuoteButton(),
      // CodeButton(),
      // HorizontalRuleButton(),
    ];
  }
}
