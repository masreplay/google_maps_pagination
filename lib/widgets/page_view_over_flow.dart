import 'package:flutter/material.dart';

import 'package:flutter/scheduler.dart';

/// [SizeReportingWidget] Calculated the size of it's child in runtime.
/// Simply wrap your widget with [MeasuredSize] and listen to size changes with [onChange].
class SizeReportingWidget extends StatefulWidget {
  /// Widget to calculate it's size.
  final Widget child;
  final double? height;

  /// [onChange] will be called when the [Size] changes.
  /// [onChange] will return the value ONLY once if it didn't change, and it will NOT return a value if it's equals to [Size.zero]
  final ValueChanged<Size?> onSizeChange;

  const SizeReportingWidget({
    Key? key,
    required this.onSizeChange,
    required this.child,
    this.height,
  }) : super(key: key);

  @override
  _SizeReportingWidgetState createState() => _SizeReportingWidgetState();
}

class _SizeReportingWidgetState extends State<SizeReportingWidget> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    return Container(key: widgetKey, child: widget.child);
  }

  final widgetKey = GlobalKey();
  Size? oldSize;

  void postFrameCallback(_) async {
    final context = widgetKey.currentContext!;

    await Future.delayed(Duration.zero);
    Size newSize = context.size!;
    if (newSize == Size.zero) return;

    if ((oldSize?.height == newSize.height &&
            oldSize?.width == newSize.width) ||
        (newSize.height <= (widget.height ?? 0))) {
      return;
    }

    oldSize = newSize;

    widget.onSizeChange(newSize);
  }
}
