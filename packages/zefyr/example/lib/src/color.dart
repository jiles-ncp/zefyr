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
    _color ??= widget.color;
    return AlertDialog(
      titlePadding: const EdgeInsets.all(0.0),
      contentPadding: const EdgeInsets.all(0.0),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: _color,
          onColorChanged: (it) {
            if (!mounted) return;
            setState(() {
              _color = it;
            });
          },
          colorPickerWidth: 300.0,
          pickerAreaHeightPercent: 0.7,
          enableAlpha: false,
          displayThumbColor: true,
          // showLabel: true,
          paletteType: PaletteType.hsv,
          pickerAreaBorderRadius: const BorderRadius.only(
            topLeft: Radius.circular(2.0),
            topRight: Radius.circular(2.0),
          ),
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
