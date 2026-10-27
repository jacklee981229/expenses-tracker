import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Lays [children] out in rows like [Wrap], but stops at [maxLines]: the
/// first child that would start another row, and every child after it, is
/// left out. Put the most important children first.
class MaxLinesWrap extends MultiChildRenderObjectWidget {
  const MaxLinesWrap({
    super.key,
    required this.maxLines,
    required this.spacing,
    required this.runSpacing,
    super.children,
  });

  final int maxLines;
  final double spacing;
  final double runSpacing;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMaxLinesWrap(maxLines, spacing, runSpacing);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderMaxLinesWrap)
      ..maxLines = maxLines
      ..spacing = spacing
      ..runSpacing = runSpacing;
  }
}

class _WrapParentData extends ContainerBoxParentData<RenderBox> {
  bool shown = false;
}

class _RenderMaxLinesWrap extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _WrapParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _WrapParentData> {
  _RenderMaxLinesWrap(this._maxLines, this._spacing, this._runSpacing);

  int _maxLines;
  set maxLines(int value) {
    if (value == _maxLines) return;
    _maxLines = value;
    markNeedsLayout();
  }

  double _spacing;
  set spacing(double value) {
    if (value == _spacing) return;
    _spacing = value;
    markNeedsLayout();
  }

  double _runSpacing;
  set runSpacing(double value) {
    if (value == _runSpacing) return;
    _runSpacing = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _WrapParentData) {
      child.parentData = _WrapParentData();
    }
  }

  @override
  void performLayout() {
    final maxWidth = constraints.maxWidth;
    final childConstraints = BoxConstraints(maxWidth: maxWidth);
    var line = 0;
    var x = 0.0;
    var y = 0.0;
    var lineHeight = 0.0;
    var width = 0.0;
    var full = false;
    var child = firstChild;
    while (child != null) {
      final data = child.parentData! as _WrapParentData;
      child.layout(childConstraints, parentUsesSize: true);
      final size = child.size;
      if (!full && x > 0 && x + size.width > maxWidth) {
        line++;
        if (line >= _maxLines) {
          full = true;
        } else {
          y += lineHeight + _runSpacing;
          x = 0;
          lineHeight = 0;
        }
      }
      data.shown = !full;
      if (!full) {
        data.offset = Offset(x, y);
        x += size.width + _spacing;
        lineHeight = math.max(lineHeight, size.height);
        width = math.max(width, x - _spacing);
      }
      child = data.nextSibling;
    }
    size = constraints.constrain(Size(width, y + lineHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var child = firstChild;
    while (child != null) {
      final data = child.parentData! as _WrapParentData;
      if (data.shown) context.paintChild(child, data.offset + offset);
      child = data.nextSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    var child = lastChild;
    while (child != null) {
      final data = child.parentData! as _WrapParentData;
      if (data.shown &&
          result.addWithPaintOffset(
            offset: data.offset,
            position: position,
            hitTest: (result, transformed) =>
                child!.hitTest(result, position: transformed),
          )) {
        return true;
      }
      child = data.previousSibling;
    }
    return false;
  }
}
