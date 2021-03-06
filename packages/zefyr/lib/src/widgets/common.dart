// Copyright (c) 2018, the Zefyr project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:notus/notus.dart';

import 'editable_box.dart';
import 'horizontal_rule.dart';
import 'image.dart';
import 'rich_text.dart';
import 'scope.dart';
import 'theme.dart';

/// Represents single line of rich text document in Zefyr editor.
class ZefyrLine extends StatefulWidget {
  const ZefyrLine({Key key, @required this.node, this.style, this.padding})
      : assert(node != null),
        super(key: key);

  /// Line in the document represented by this widget.
  final LineNode node;

  /// Style to apply to this line. Required for lines with text contents,
  /// ignored for lines containing embeds.
  final TextStyle style;

  /// Padding to add around this paragraph.
  final EdgeInsets padding;

  @override
  _ZefyrLineState createState() => _ZefyrLineState();
}

class _ZefyrLineState extends State<ZefyrLine> {
  final LayerLink _link = LayerLink();

  @override
  Widget build(BuildContext context) {
    final scope = ZefyrScope.of(context);
    if (scope.isEditable) {
      ensureVisible(context, scope);
    }
    final theme = Theme.of(context);

    Widget content;
    if (widget.node.hasEmbed) {
      content = buildEmbed(context, scope);
    } else {
      assert(widget.style != null);
      content = ZefyrRichText(
        node: widget.node,
        text: buildText(context, scope),
      );
      // content = Container(color: Colors.grey, child: content);

    }

    if (scope.isEditable) {
      Color cursorColor;
      switch (theme.platform) {
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          cursorColor ??= CupertinoTheme.of(context).primaryColor;
          break;

        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.windows:
        case TargetPlatform.linux:
          cursorColor = theme.cursorColor;
          break;
      }

      content = EditableBox(
        child: content,
        node: widget.node,
        layerLink: _link,
        renderContext: scope.renderContext,
        showCursor: scope.showCursor,
        selection: scope.selection,
        selectionColor: theme.textSelectionColor,
        cursorColor: cursorColor,
      );
      content = CompositedTransformTarget(link: _link, child: content);
    }

    // var hasPadding = widget.node.style.contains(NotusAttribute.padding);
    // // print('padding: $hasPadding');

    // if (widget.node.style.contains(NotusAttribute.margin) ||
    //     widget.node.style.contains(NotusAttribute.padding)) {
    //   EdgeInsets margin;
    //   EdgeInsets padding;

    //   if (widget.node.style.contains(NotusAttribute.margin)) {
    //     var att =
    //         widget.node.style.get<Map<String, dynamic>>(NotusAttribute.margin);

    //     margin = EdgeInsets.fromLTRB(
    //       (att.value['left'] ?? 0).toDouble(),
    //       (att.value['top'] ?? 0).toDouble(),
    //       (att.value['right'] ?? 0).toDouble(),
    //       (att.value['bottom'] ?? 0).toDouble(),
    //     );
    //   }

    //   if (widget.node.style.contains(NotusAttribute.padding)) {
    //     var att =
    //         widget.node.style.get<Map<String, dynamic>>(NotusAttribute.padding);

    //     padding = EdgeInsets.fromLTRB(
    //       (att.value['left'] ?? 0).toDouble(),
    //       (att.value['top'] ?? 0).toDouble(),
    //       (att.value['right'] ?? 0).toDouble(),
    //       (att.value['bottom'] ?? 0).toDouble(),
    //     );
    //   }

    //   content = Container(
    //     margin: margin,
    //     padding: padding,
    //     child: content,
    //   );
    // }

    if (widget.padding != null) {
      return Padding(padding: widget.padding, child: content);
    }

    return content;
  }

  void ensureVisible(BuildContext context, ZefyrScope scope) {
    if (scope.selection.isCollapsed &&
        widget.node.containsOffset(scope.selection.extentOffset)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        bringIntoView(context);
      });
    }
  }

  void bringIntoView(BuildContext context) {
    final scrollable = Scrollable.of(context);
    final object = context.findRenderObject();
    assert(object.attached);
    final viewport = RenderAbstractViewport.of(object);
    assert(viewport != null);

    final offset = scrollable.position.pixels;
    var target = viewport.getOffsetToReveal(object, 0.0).offset;
    if (target - offset < 0.0) {
      scrollable.position.jumpTo(target);
      return;
    }
    target = viewport.getOffsetToReveal(object, 1.0).offset;
    if (target - offset > 0.0) {
      scrollable.position.jumpTo(target);
    }
  }

  TextSpan buildText(BuildContext context, ZefyrScope scope) {
    final theme = ZefyrTheme.of(context);

    final children = widget.node.children
        .map((node) => _segmentToTextSpan(node, theme, scope))
        .toList(growable: false);
    return TextSpan(style: widget.style, children: children);
  }

  TextSpan _segmentToTextSpan(
      Node node, ZefyrThemeData theme, ZefyrScope scope) {
    final TextNode segment = node;
    final attrs = segment.style;

    GestureRecognizer recognizer;

    if (attrs.contains(NotusAttribute.link)) {
      final tapGestureRecognizer = TapGestureRecognizer();
      tapGestureRecognizer.onTap = () {
        print('delegate: ${scope.attrDelegate}');
        if (scope.attrDelegate?.onLinkTap != null) {
          scope.attrDelegate.onLinkTap(attrs.get(NotusAttribute.link).value);
        }
      };
      recognizer = tapGestureRecognizer;
    }

    return TextSpan(
      text: segment.value,
      recognizer: recognizer,
      style: _getTextStyle(attrs, theme),
    );
  }

  Color _hexStringToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    hex = hex.length == 6 ? 'ff' + hex : hex;
    var val = int.parse(hex, radix: 16);
    return Color(val);
  }

  TextStyle _getTextStyle(NotusStyle style, ZefyrThemeData theme) {
    var result = TextStyle();

    if (style.containsSame(NotusAttribute.bold)) {
      result = result.merge(theme.attributeTheme.bold);
    }
    if (style.containsSame(NotusAttribute.italic)) {
      result = result.merge(theme.attributeTheme.italic);
    }
    if (style.containsSame(NotusAttribute.underline)) {
      result = result.copyWith(
        decoration: TextDecoration.underline,
      );
    }
    if (style.contains(NotusAttribute.link)) {
      result = result.merge(theme.attributeTheme.link);
    }
    if (style.contains(NotusAttribute.textColor)) {
      final color =
          _hexStringToColor(style.value<String>(NotusAttribute.textColor));
      result = result.copyWith(color: color);
    }
    if (style.contains(NotusAttribute.textBackground)) {
      final bgColor =
          _hexStringToColor(style.value<String>(NotusAttribute.textBackground));
      result = result.copyWith(backgroundColor: bgColor);
    }
    return result;
  }

  Widget buildEmbed(BuildContext context, ZefyrScope scope) {
    EmbedNode node = widget.node.children.single;
    EmbedAttribute embed = node.style.get(NotusAttribute.embed);

    if (embed.type == EmbedType.horizontalRule) {
      return ZefyrHorizontalRule(node: node);
    } else if (embed.type == EmbedType.image) {
      return ZefyrImage(node: node, delegate: scope.imageDelegate);
    } else if (embed.type == EmbedType.custom) {
      // return Container(
      //   width: 200,
      //   height: 200,
      //   color: Colors.blue,
      // );
      print('here');
      return Container(height: 10);
      // return Container(node: node, delegate: scope.imageDelegate);
    } else {
      throw UnimplementedError('Unimplemented embed type ${embed.type}');
    }
  }
}
