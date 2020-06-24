import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';

class CustomToolbarDelegate extends DefaultZefyrToolbarDelegate {
  // @override
  // Widget buildButton(BuildContext context, ZefyrToolbarAction action,
  //     {onPressed});

  @override
  List<Widget> buildButtons(BuildContext context, ZefyrScope editor) {
    return <Widget>[
      BoldButton(),
      // ItalicButton(),
      // UnderlineButton(),

      ZefyrSpacer(),

      AlignmentButton(),

      // LeftAlignmentButton(),
      // CenterAlignmentButton(),
      // RightAlignmentButton(),

      // if (editor.colorDelegate != null) ...[
      //   TextHighlightButton(),
      //   TextColorButton(),
      // ],
      // if (editor.imageDelegate != null) ImageButton(),
      // MarginButton(),
      // // PaddingButton(), not working

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
