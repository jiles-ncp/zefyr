import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../../zefyr.dart';

@experimental
abstract class ZefyrColorDelegate {
  /// Picks an color
  Future<dynamic> pickColor(BuildContext context, Color current);
}

Color _hexStringToColor(String hex) {
  hex = hex.replaceFirst('#', '');
  hex = hex.length == 6 ? 'ff' + hex : hex;
  var val = int.parse(hex, radix: 16);
  return Color(val);
}

class TextColorButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);
    final editor = toolbar.editor;
    final attribute = NotusAttribute.textColor;

    var hasDelegate = editor.colorDelegate != null;
    var isCollapsed = editor.selection.isCollapsed;
    var hasAttribute = editor.selectionStyle.contains(attribute);
    final theme = Theme.of(context);

    return ZefyrButton.child(
      action: ZefyrToolbarAction.textColor,
      child: Icon(Icons.format_color_text),
      onPressed: !hasAttribute && (!hasDelegate || isCollapsed)
          ? null
          : () async {
              Color current;
              if (hasAttribute) {
                var value = editor.selectionStyle.value<String>(attribute);

                current = _hexStringToColor(value);
              }

              var currentSelection = editor.selection;

              // editor loses focus with dialog
              var picked = await editor.colorDelegate?.pickColor(context,
                  current ?? theme.textTheme.bodyText1.color.withOpacity(1));

              // reset selection
              editor.updateSelection(currentSelection);

              if (picked == null) return;

              if (picked is Color) {
                if (picked == Colors.transparent) {
                  editor.formatSelection(attribute.unset);
                  return;
                }

                print('picked color: $picked');

                var hex = '#${picked.value.toRadixString(16)}';
                var attr = attribute.fromString(hex);
                editor.formatSelection(attr);
              }
            },
    );
  }
}

class TextHighlightButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);
    final editor = toolbar.editor;
    final attribute = NotusAttribute.textBackground;

    var hasDelegate = editor.colorDelegate != null;
    var isCollapsed = editor.selection.isCollapsed;
    var hasAttribute =
        editor.selectionStyle.contains(NotusAttribute.textBackground);

    return ZefyrButton.icon(
      action: ZefyrToolbarAction.textBackground,
      icon: Icons.format_color_fill,
      onPressed: !hasAttribute && (!hasDelegate || isCollapsed)
          ? null
          : () async {
              Color current;
              if (hasAttribute) {
                var value = editor.selectionStyle.value<String>(attribute);

                current = _hexStringToColor(value);
              }

              var currentSelection = editor.selection;

              // editor loses focus with dialog
              var picked = await editor.colorDelegate
                  ?.pickColor(context, current ?? Colors.yellow);

              // reset selection
              editor.updateSelection(currentSelection);

              if (picked == null) return;

              if (picked is Color) {
                if (picked == Colors.transparent) {
                  editor.formatSelection(attribute.unset);
                  return;
                }

                print('picked color: $picked');

                var hex = '#${picked.value.toRadixString(16)}';
                var attr = attribute.fromString(hex);
                editor.formatSelection(attr);
              }
            },
    );
  }
}
