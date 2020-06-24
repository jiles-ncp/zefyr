import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:zefyr/src/widgets/color.dart';

class CustomColorDelegate extends ZefyrColorDelegate {
  @override
  Future<Color> pickColor(BuildContext context, Color currentColor) async {
    var selected = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return _ColorDialog(
          color: currentColor,
        );
      },
    );

    print('selected: $selected');
    return selected;
  }
}

class _ColorDialog extends StatefulWidget {
  final Color color;

  const _ColorDialog({Key key, @required this.color}) : super(key: key);

  @override
  __ColorDialogState createState() => __ColorDialogState();
}

class __ColorDialogState extends State<_ColorDialog> {
  Color _color;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    _color ??= widget.color;
    return AlertDialog(
      titlePadding: const EdgeInsets.all(0.0),
      contentPadding: const EdgeInsets.all(0.0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              child: Text(
                'Choose Color',
                style: theme.textTheme.headline5,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ColorPicker(
                pickerColor: _color,
                onColorChanged: (it) {
                  if (!mounted) return;
                  setState(() {
                    _color = it;
                  });
                },
                colorPickerWidth: 300.0,
                // pickerAreaHeightPercent: 0.7,
                enableAlpha: false,
                displayThumbColor: true,
                showLabel: false,
                // paletteType: PaletteType.hsv,
                pickerAreaBorderRadius:
                    const BorderRadius.all(Radius.circular(20)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        FlatButton(
          child: Text('remove color'),
          onPressed: () {
            Navigator.of(context).pop(Colors.transparent);
          },
        ),
        FlatButton(
            child: Text('cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        FlatButton(
          child: Text('select color'),
          onPressed: () {
            Navigator.of(context).pop(_color);
          },
        )
      ],
    );
  }
}
