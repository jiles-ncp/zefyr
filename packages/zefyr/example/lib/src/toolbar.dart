import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';

class CustomButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final editor = ZefyrToolbar.of(context).editor;

    return ZefyrButton.custom(
      // action: ZefyrToolbarAction.,
      onPressed: () {
        final toolbar = ZefyrToolbar.of(context);

        // var att =
        //     NotusAttribute('btn', NotusAttributeScope.line, {'text': 'label'});

        // editor.formatSelection(att);
        editor.formatSelection(
          NotusAttribute.embed.custom(
            {'type': 'butend', 'text': 'label'},
          ),
        );

        toolbar.showOverlay(_buildOverlay);

        print('custom button pressed');
      },
      child: AbsorbPointer(
        child: Transform.scale(
          scale: .8,
          child: RaisedButton(
            child: Text('btn'),
            onPressed: () {},
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);
    final buttons = ZefyrButtonList(
      buttons: <Widget>[
        // Icon(Icons.swap_horiz),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 100),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: TextField(
              decoration: InputDecoration(hintText: 'Label'),
            ),
          ),
        ),
        LeftAlignmentButton(),
        CenterAlignmentButton(),
        RightAlignmentButton(),
        ZefyrSpacer(),
      ],
    );
    return ZefyrToolbarScaffold(body: buttons);
  }
}

class CustomToolbarDelegate extends DefaultZefyrToolbarDelegate {
  // @override
  // Widget buildButton(BuildContext context, ZefyrToolbarAction action,
  //     {onPressed});

  @override
  List<Widget> buildButtons(BuildContext context, ZefyrScope editor) {
    return <Widget>[
      CustomButton(),

      BoldButton(),
      // ItalicButton(),
      // UnderlineButton(),
      // HeadingButton(),
      LinkButton(),

      // ZefyrSpacer(),

      // TextHighlightButton(),
      // TextColorButton(),
      if (editor.imageDelegate != null) ImageButton(),

      // ZefyrSpacer(),

      AlignmentButton(),
      // MarginButton(),

      // ZefyrSpacer(),

      // BulletListButton(),

      // NumberListButton(),

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
