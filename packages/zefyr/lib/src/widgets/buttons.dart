// Copyright (c) 2018, the Zefyr project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notus/notus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zefyr/zefyr.dart';

import 'scope.dart';
import 'theme.dart';
import 'toolbar.dart';

/// A button used in [ZefyrToolbar].
///
/// Create an instance of this widget with [ZefyrButton.icon] or
/// [ZefyrButton.text] constructors.
///
/// Toolbar buttons are normally created by a [ZefyrToolbarDelegate].
class ZefyrButton extends StatelessWidget {
  ZefyrButton.custom({
    @required Widget child,
    this.onPressed,
  })  : assert(child != null),
        action = null,
        _icon = null,
        _iconSize = null,
        _text = null,
        _textStyle = null,
        _child = child,
        super();

  /// Creates a toolbar button with any child because why restrict it?
  ZefyrButton.child({
    @required this.action,
    @required Widget child,
    this.onPressed,
  })  : assert(action != null),
        assert(child != null),
        _icon = null,
        _iconSize = null,
        _text = null,
        _textStyle = null,
        _child = child,
        super();

  /// Creates a toolbar button with an icon.
  ZefyrButton.icon({
    @required this.action,
    @required IconData icon,
    double iconSize,
    this.onPressed,
  })  : assert(action != null),
        assert(icon != null),
        _icon = icon,
        _iconSize = iconSize,
        _text = null,
        _textStyle = null,
        _child = null,
        super();

  /// Creates a toolbar button containing text.
  ///
  /// Note that [ZefyrButton] has fixed width and does not expand to accommodate
  /// long texts.
  ZefyrButton.text({
    @required this.action,
    @required String text,
    TextStyle style,
    this.onPressed,
  })  : assert(action != null),
        assert(text != null),
        _icon = null,
        _iconSize = null,
        _text = text,
        _textStyle = style,
        _child = null,
        super();

  /// Toolbar action associated with this button.
  final ZefyrToolbarAction action;
  final IconData _icon;
  final double _iconSize;
  final String _text;
  final TextStyle _textStyle;
  final Widget _child;

  /// Callback to trigger when this button is tapped.
  final VoidCallback onPressed;

  bool get isAttributeAction {
    return kZefyrToolbarAttributeActions.keys.contains(action);
  }

  @override
  Widget build(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);
    final editor = toolbar.editor;
    final toolbarTheme = ZefyrTheme.of(context).toolbarTheme;
    final color = _getColor(editor, toolbarTheme);
    final pressedHandler = _getPressedHandler(editor, toolbar);
    final iconColor = (pressedHandler == null)
        ? toolbarTheme.disabledIconColor
        : toolbarTheme.iconColor;
    if (_child != null) {
      return RawZefyrButton(
        action: action,
        child: _child,
        color: color,
        onPressed: pressedHandler,
      );
    }
    if (_icon != null) {
      return RawZefyrButton.icon(
        action: action,
        icon: _icon,
        size: _iconSize,
        iconColor: iconColor,
        color: color,
        onPressed: pressedHandler,
      );
    } else {
      assert(_text != null);
      var style = _textStyle ?? TextStyle();
      style = style.copyWith(color: iconColor);
      return RawZefyrButton(
        action: action,
        child: Text(_text, style: style),
        color: color,
        onPressed: pressedHandler,
      );
    }
  }

  Color _getColor(ZefyrScope editor, ToolbarTheme theme) {
    if (isAttributeAction) {
      final attribute = kZefyrToolbarAttributeActions[action];
      final isToggled = (attribute is NotusAttribute)
          ? editor.selectionStyle.containsSame(attribute)
          : editor.selectionStyle.contains(attribute);
      return isToggled ? theme.toggleColor : null;
    }
    return null;
  }

  VoidCallback _getPressedHandler(
      ZefyrScope editor, ZefyrToolbarState toolbar) {
    if (onPressed != null) {
      return onPressed;
    } else if (isAttributeAction) {
      final attribute = kZefyrToolbarAttributeActions[action];
      if (attribute is NotusAttribute) {
        return () => _toggleAttribute(attribute, editor);
      }
    } else if (action == ZefyrToolbarAction.close) {
      return () => toolbar.closeOverlay();
    } else if (action == ZefyrToolbarAction.hideKeyboard) {
      return () => editor.hideKeyboard();
    }

    // print('unknown pressed handler');

    return null;
  }

  void _toggleAttribute(NotusAttribute attribute, ZefyrScope editor) {
    final isToggled = editor.selectionStyle.containsSame(attribute);
    if (isToggled) {
      editor.formatSelection(attribute.unset);
    } else {
      editor.formatSelection(attribute);
    }
  }
}

/// Raw button widget used by [ZefyrToolbar].
///
/// See also:
///
///   * [ZefyrButton], which wraps this widget and implements most of the
///     action-specific logic.
class RawZefyrButton extends StatelessWidget {
  const RawZefyrButton({
    Key key,
    @required this.action,
    @required this.child,
    @required this.color,
    @required this.onPressed,
  }) : super(key: key);

  /// Creates a [RawZefyrButton] containing an icon.
  RawZefyrButton.icon({
    @required this.action,
    @required IconData icon,
    double size,
    Color iconColor,
    @required this.color,
    @required this.onPressed,
  })  : child = Icon(icon, size: size, color: iconColor),
        super();

  /// Toolbar action associated with this button.
  final ZefyrToolbarAction action;

  /// Child widget to show inside this button. Usually an icon.
  final Widget child;

  /// Background color of this button.
  final Color color;

  /// Callback to trigger when this button is pressed.
  final VoidCallback onPressed;

  /// Returns `true` if this button is currently toggled on.
  bool get isToggled => color != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = theme.buttonTheme.constraints.minHeight + 4.0;
    final constraints = theme.buttonTheme.constraints.copyWith(
        minWidth: width, maxHeight: theme.buttonTheme.constraints.minHeight);
    final radius = BorderRadius.all(Radius.circular(3.0));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 6.0),
      child: RawMaterialButton(
        shape: RoundedRectangleBorder(borderRadius: radius),
        elevation: 0.0,
        fillColor: color,
        constraints: constraints,
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

/// Controls heading styles.
///
/// When pressed, this button displays overlay toolbar with three
/// buttons for each heading level.
class HeadingButton extends StatefulWidget {
  const HeadingButton({Key key}) : super(key: key);

  @override
  _HeadingButtonState createState() => _HeadingButtonState();
}

class _HeadingButtonState extends State<HeadingButton> {
  @override
  Widget build(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);
    return toolbar.buildButton(
      context,
      ZefyrToolbarAction.heading,
      onPressed: showOverlay,
    );
  }

  void showOverlay() {
    final toolbar = ZefyrToolbar.of(context);
    toolbar.showOverlay(buildOverlay);
  }

  Widget buildOverlay(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);
    final buttons = Row(
      children: <Widget>[
        SizedBox(width: 8.0),
        toolbar.buildButton(context, ZefyrToolbarAction.headingLevel1),
        toolbar.buildButton(context, ZefyrToolbarAction.headingLevel2),
        toolbar.buildButton(context, ZefyrToolbarAction.headingLevel3),
      ],
    );
    return ZefyrToolbarScaffold(body: buttons);
  }
}

/// Controls image attribute.
///
/// When pressed, this button displays overlay toolbar with three
/// buttons for each heading level.
class ImageButton extends StatefulWidget {
  const ImageButton({Key key}) : super(key: key);

  @override
  _ImageButtonState createState() => _ImageButtonState();
}

class _ImageButtonState extends State<ImageButton> {
  @override
  Widget build(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);
    return toolbar.buildButton(
      context,
      ZefyrToolbarAction.image,
      onPressed: showOverlay,
    );
  }

  void showOverlay() {
    final toolbar = ZefyrToolbar.of(context);
    toolbar.showOverlay(buildOverlay);
  }

  Widget buildOverlay(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);
    final buttons = Row(
      children: <Widget>[
        SizedBox(width: 8.0),
        toolbar.buildButton(context, ZefyrToolbarAction.cameraImage,
            onPressed: _pickFromCamera),
        toolbar.buildButton(context, ZefyrToolbarAction.galleryImage,
            onPressed: _pickFromGallery),
      ],
    );
    return ZefyrToolbarScaffold(body: buttons);
  }

  void _pickFromCamera() async {
    final editor = ZefyrToolbar.of(context).editor;
    final image =
        await editor.imageDelegate.pickImage(editor.imageDelegate.cameraSource);
    if (image != null) {
      editor.formatSelection(NotusAttribute.embed.image(image));
    }
  }

  void _pickFromGallery() async {
    final editor = ZefyrToolbar.of(context).editor;
    final image = await editor.imageDelegate
        .pickImage(editor.imageDelegate.gallerySource);
    if (image != null) {
      editor.formatSelection(NotusAttribute.embed.image(image));
    }
  }
}

class HorizontalRuleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);

    return toolbar.buildButton(context, ZefyrToolbarAction.horizontalRule);
  }
}

class CodeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);

    return toolbar.buildButton(context, ZefyrToolbarAction.code);
  }
}

class QuoteButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);

    return toolbar.buildButton(context, ZefyrToolbarAction.quote);
  }
}

class NumberListButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);

    return toolbar.buildButton(context, ZefyrToolbarAction.numberList);
  }
}

class BulletListButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);

    return toolbar.buildButton(context, ZefyrToolbarAction.bulletList);
  }
}

class BoldButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);

    return toolbar.buildButton(context, ZefyrToolbarAction.bold);
  }
}

class ItalicButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);

    return toolbar.buildButton(context, ZefyrToolbarAction.italic);
  }
}

class UnderlineButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);

    return toolbar.buildButton(context, ZefyrToolbarAction.underline);
  }
}

class MarginButton extends StatelessWidget {
  const MarginButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);
    return toolbar.buildButton(
      context,
      ZefyrToolbarAction.margin,
      onPressed: () => toolbar.showOverlay(_buildOverlay),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);
    final buttons = Row(
      children: <Widget>[
        // Icon(Icons.swap_horiz),
        Expanded(
          child: Container(
            // margin: EdgeInsets.symmetric(horizontal: 10),
            child: _Slider(
                value: 0,
                axis: Axis.horizontal,
                onChanged: (value) {
                  var val = value.floor();
                  var current =
                      Map<String, dynamic>.from(NotusAttribute.margin.value);
                  current['left'] = val;
                  current['right'] = val;
                  var att = NotusAttribute.margin.withValue(current);
                  toolbar.editor.formatSelection(att);
                }),
          ),
        ),
        // Icon(Icons.swap_vert),
        Expanded(
          child: Container(
            // margin: EdgeInsets.symmetric(horizontal: 10),
            child: _Slider(
                value: 0,
                axis: Axis.vertical,
                onChanged: (value) {
                  var val = value.floor();
                  var current =
                      Map<String, dynamic>.from(NotusAttribute.margin.value);
                  current['top'] = val;
                  current['bottom'] = val;
                  var att = NotusAttribute.margin.withValue(current);
                  toolbar.editor.formatSelection(att);
                }),
          ),
        ),
      ],
    );
    return ZefyrToolbarScaffold(body: buttons);
  }
}

class PaddingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);

    return toolbar.buildButton(context, ZefyrToolbarAction.padding,
        onPressed: () {
      toolbar.showOverlay(_buildOverlay);
    });
  }

  Widget _buildOverlay(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);
    final buttons = Row(
      children: <Widget>[
        // Icon(Icons.swap_horiz),
        Expanded(
          child: Container(
            // margin: EdgeInsets.symmetric(horizontal: 10),
            child: _Slider(
                value: 0,
                axis: Axis.horizontal,
                onChanged: (value) {
                  var val = value.floor();
                  var current =
                      Map<String, dynamic>.from(NotusAttribute.padding.value);
                  current['left'] = val;
                  current['right'] = val;
                  var att = NotusAttribute.padding.withValue(current);
                  toolbar.editor.formatSelection(att);
                }),
          ),
        ),
        // Icon(Icons.swap_vert),
        Expanded(
          child: Container(
            child: _Slider(
                value: 0,
                axis: Axis.vertical,
                onChanged: (value) {
                  var val = value.floor();
                  var current =
                      Map<String, dynamic>.from(NotusAttribute.padding.value);
                  current['top'] = val;
                  current['bottom'] = val;
                  print('val: $val');
                  var att = NotusAttribute.padding.withValue(current);
                  toolbar.editor.formatSelection(att);
                }),
          ),
        ),
      ],
    );
    return ZefyrToolbarScaffold(body: buttons);
  }
}

class _Slider extends StatefulWidget {
  final double value;
  final Axis axis;
  final ValueChanged<double> onChanged;

  const _Slider(
      {Key key,
      @required this.value,
      @required this.onChanged,
      @required this.axis})
      : super(key: key);

  @override
  _SliderState createState() => _SliderState();
}

class _SliderState extends State<_Slider> {
  double _value;

  @override
  Widget build(BuildContext context) {
    final theme = ZefyrTheme.of(context);
    _value ??= widget.value;

    return Container(
        // color: Colors.yellow,
        child: Stack(
      children: [
        SizedBox(width: 50),
        Slider(
          value: _value,
          activeColor: theme.toolbarTheme.iconColor,
          inactiveColor: theme.toolbarTheme.disabledIconColor,
          min: 0,
          max: 80,
          divisions: 80,
          label: _value.toString(),
          onChanged: (value) {
            setState(() {
              _value = value;
            });
            widget.onChanged(value);
          },
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            child: Icon(
              widget.axis == Axis.horizontal
                  ? Icons.swap_horiz
                  : Icons.swap_vert,
              color: theme.toolbarTheme.iconColor,
            ),
          ),
        ),
      ],
    ));
  }
}

class LinkButton extends StatefulWidget {
  const LinkButton({Key key}) : super(key: key);

  @override
  _LinkButtonState createState() => _LinkButtonState();
}

class _LinkButtonState extends State<LinkButton> {
  final TextEditingController _inputController = TextEditingController();
  Key _inputKey;
  bool _formatError = false;

  bool get isEditing => _inputKey != null;

  @override
  Widget build(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);
    final editor = toolbar.editor;
    final enabled =
        hasLink(editor.selectionStyle) || !editor.selection.isCollapsed;

    return toolbar.buildButton(
      context,
      ZefyrToolbarAction.link,
      onPressed: enabled ? showOverlay : null,
    );
  }

  bool hasLink(NotusStyle style) => style.contains(NotusAttribute.link);

  String getLink([String defaultValue]) {
    final editor = ZefyrToolbar.of(context).editor;
    final attrs = editor.selectionStyle;
    if (hasLink(attrs)) {
      return attrs.value(NotusAttribute.link);
    }
    return defaultValue;
  }

  void showOverlay() {
    final toolbar = ZefyrToolbar.of(context);
    toolbar.showOverlay(buildOverlay).whenComplete(cancelEdit);
  }

  void closeOverlay() {
    final toolbar = ZefyrToolbar.of(context);
    toolbar.closeOverlay();
  }

  void edit() {
    final toolbar = ZefyrToolbar.of(context);
    setState(() {
      _inputKey = UniqueKey();
      _inputController.text = getLink('https://');
      _inputController.addListener(_handleInputChange);
      toolbar.markNeedsRebuild();
    });
  }

  void doneEdit() {
    final toolbar = ZefyrToolbar.of(context);
    setState(() {
      var error = false;
      if (_inputController.text.isNotEmpty) {
        try {
          var uri = Uri.parse(_inputController.text);
          if ((uri.isScheme('https') || uri.isScheme('http')) &&
              uri.host.isNotEmpty) {
            toolbar.editor.formatSelection(
                NotusAttribute.link.fromString(_inputController.text));
          } else {
            error = true;
          }
        } on FormatException {
          error = true;
        }
      }
      if (error) {
        _formatError = error;
        toolbar.markNeedsRebuild();
      } else {
        _inputKey = null;
        _inputController.text = '';
        _inputController.removeListener(_handleInputChange);
        toolbar.markNeedsRebuild();
        toolbar.editor.focus();
      }
    });
  }

  void cancelEdit() {
    if (mounted) {
      final editor = ZefyrToolbar.of(context).editor;
      setState(() {
        _inputKey = null;
        _inputController.text = '';
        _inputController.removeListener(_handleInputChange);
        editor.focus();
      });
    }
  }

  void unlink() {
    final editor = ZefyrToolbar.of(context).editor;
    editor.formatSelection(NotusAttribute.link.unset);
    closeOverlay();
  }

  void copyToClipboard() {
    var link = getLink();
    assert(link != null);
    Clipboard.setData(ClipboardData(text: link));
  }

  void openInBrowser() async {
    final editor = ZefyrToolbar.of(context).editor;
    var link = getLink();
    assert(link != null);
    if (await canLaunch(link)) {
      editor.hideKeyboard();
      await launch(link, forceWebView: true);
    }
  }

  void _handleInputChange() {
    final toolbar = ZefyrToolbar.of(context);
    setState(() {
      _formatError = false;
      toolbar.markNeedsRebuild();
    });
  }

  Widget buildOverlay(BuildContext context) {
    final toolbar = ZefyrToolbar.of(context);
    final style = toolbar.editor.selectionStyle;

    var value = 'Tap to edit link';
    if (style.contains(NotusAttribute.link)) {
      value = style.value(NotusAttribute.link);
    }
    final clipboardEnabled = value != 'Tap to edit link';
    final body = !isEditing
        ? _LinkView(value: value, onTap: edit)
        : _LinkInput(
            key: _inputKey,
            controller: _inputController,
            formatError: _formatError,
          );
    final items = <Widget>[Expanded(child: body)];
    if (!isEditing) {
      final unlinkHandler = hasLink(style) ? unlink : null;
      final copyHandler = clipboardEnabled ? copyToClipboard : null;
      final openHandler = hasLink(style) ? openInBrowser : null;
      final buttons = <Widget>[
        toolbar.buildButton(context, ZefyrToolbarAction.unlink,
            onPressed: unlinkHandler),
        toolbar.buildButton(context, ZefyrToolbarAction.clipboardCopy,
            onPressed: copyHandler),
        toolbar.buildButton(
          context,
          ZefyrToolbarAction.openInBrowser,
          onPressed: openHandler,
        ),
      ];
      items.addAll(buttons);
    }
    final trailingPressed = isEditing ? doneEdit : closeOverlay;
    final trailingAction =
        isEditing ? ZefyrToolbarAction.confirm : ZefyrToolbarAction.close;

    return ZefyrToolbarScaffold(
      body: Row(children: items),
      trailing: toolbar.buildButton(
        context,
        trailingAction,
        onPressed: trailingPressed,
      ),
    );
  }
}

class _LinkInput extends StatefulWidget {
  final TextEditingController controller;
  final bool formatError;

  const _LinkInput(
      {Key key, @required this.controller, this.formatError = false})
      : super(key: key);

  @override
  _LinkInputState createState() {
    return _LinkInputState();
  }
}

class _LinkInputState extends State<_LinkInput> {
  final FocusNode _focusNode = FocusNode();

  ZefyrScope _editor;
  bool _didAutoFocus = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didAutoFocus) {
      FocusScope.of(context).requestFocus(_focusNode);
      _didAutoFocus = true;
    }

    final toolbar = ZefyrToolbar.of(context);

    if (_editor != toolbar.editor) {
      _editor?.toolbarFocusNode = null;
      _editor = toolbar.editor;
      _editor.toolbarFocusNode = _focusNode;
    }
  }

  @override
  void dispose() {
    _editor?.toolbarFocusNode = null;
    _focusNode.dispose();
    _editor = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final toolbarTheme = ZefyrTheme.of(context).toolbarTheme;
    final color =
        widget.formatError ? Colors.redAccent : toolbarTheme.iconColor;
    final style = theme.textTheme.subtitle1.copyWith(color: color);
    return TextField(
      style: style,
      keyboardType: TextInputType.url,
      focusNode: _focusNode,
      controller: widget.controller,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'https://',
        filled: true,
        fillColor: toolbarTheme.color,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(10.0),
      ),
    );
  }
}

class _LinkView extends StatelessWidget {
  const _LinkView({Key key, @required this.value, this.onTap})
      : super(key: key);
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final toolbarTheme = ZefyrTheme.of(context).toolbarTheme;
    Widget widget = ClipRect(
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Container(
            alignment: AlignmentDirectional.centerStart,
            constraints: BoxConstraints(minHeight: ZefyrToolbar.kToolbarHeight),
            padding: const EdgeInsets.all(10.0),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.subtitle1
                  .copyWith(color: toolbarTheme.disabledIconColor),
            ),
          )
        ],
      ),
    );
    if (onTap != null) {
      widget = GestureDetector(
        child: widget,
        onTap: onTap,
      );
    }
    return widget;
  }
}

class ZefyrSpacer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = ZefyrTheme.of(context);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 9),
      color: theme.toolbarTheme.iconColor.withOpacity(.7),
      width: 1,
    );
  }
}
