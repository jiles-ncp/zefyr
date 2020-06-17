import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../../zefyr.dart';

@experimental
abstract class ZefyrColorDelegate {
  /// Picks an color
  Future<dynamic> pickColor(BuildContext context, Color current);
}

class HighlightButton extends StatelessWidget {
  final hexStringToColor = (String hex) {
    hex = hex.replaceFirst('#', '');
    hex = hex.length == 6 ? 'ff' + hex : hex;
    int val = int.parse(hex, radix: 16);
    return Color(val);
  };

  @override
  Widget build(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);
    final editor = toolbar.editor;

    var hasDelegate = editor.colorDelegate != null;
    var isCollapsed = editor.selection.isCollapsed;
    var hasAttribute = editor.selectionStyle.contains(NotusAttribute.highlight);

    return ZefyrButton.icon(
      action: ZefyrToolbarAction.highlight,
      icon: Icons.format_color_fill,
      onPressed: !hasAttribute && (!hasDelegate || isCollapsed)
          ? null
          : () async {
              Color current;
              if (hasAttribute) {
                var value = editor.selectionStyle
                    .value<String>(NotusAttribute.highlight);

                current = hexStringToColor(value);
              }

              var currentSelection = editor.selection;

              // editor loses focus with dialog
              var picked = await editor.colorDelegate
                  ?.pickColor(context, current ?? Colors.yellow);

              // reset selection
              editor.updateSelection(currentSelection);

              if (picked == null) return;

              var attribute = NotusAttribute.highlight;
              if (picked is Color) {
                if (picked == Colors.transparent) {
                  editor.formatSelection(attribute.unset);
                  return;
                }

                print('picked color: $picked');

                var hex = '#${picked.value.toRadixString(16)}';
                var attr = NotusAttribute.highlight.fromString(hex);
                editor.formatSelection(attr);
              }
            },
    );
  }
}
