import 'package:flutter/material.dart';

class MapPaginationController extends StatelessWidget {
  final Color controllerColor;
  final Color textColor;

  final Color backgroundColor;

  const MapPaginationController({
    Key? key,
    required this.skip,
    required this.take,
    required this.count,
    required this.isLoading,
    required this.onNextPressed,
    required this.onPreviousPressed,
    this.controllerColor = const Color(0xFF007bff),
    this.backgroundColor = const Color(0xFFFFDA85),
    this.textColor = Colors.black,
    this.noItemFoundTitle = "No items found",
  }) : super(key: key);

  final String noItemFoundTitle;
  final int skip;
  final bool isLoading;
  final int take;
  final int count;
  final ValueChanged<int> onNextPressed;
  final ValueChanged<int> onPreviousPressed;

  int get _nextSkip {
    return skip + take;
  }

  int get _previousSkip {
    return skip - take;
  }

  String get _nextButtonTitle {
    if (_nextSkip < count) {
      return "${skip + take + 1} - ${skip + (take * 2)}";
    } else {
      return "";
    }
  }

  String get _previousButtonTitle {
    return skip == 0 ? "" : "${_previousSkip + 1} - $skip";
  }

  String _middleTitle(BuildContext context) {
    if (count == 0) {
      return noItemFoundTitle;
    } else if (_nextSkip < count) {
      return "${skip + 1} - $_nextSkip";
    } else if (_nextSkip > count) {
      return "${skip + 1} - $count";
    } else {
      return noItemFoundTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: skip != 0 && !isLoading
                ? () => onPreviousPressed(_previousSkip)
                : null,
            style: TextButton.styleFrom(primary: controllerColor),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: controllerColor,
              size: 16,
            ),
            label: Text(
              _previousButtonTitle,
              style: Theme.of(context)
                  .textTheme
                  .subtitle2
                  ?.copyWith(color: textColor),
            ),
          ),
          Visibility(
            visible: !isLoading,
            replacement: const CircularProgressIndicator(),
            child: Text(
              _middleTitle(context),
              style: Theme.of(context).textTheme.subtitle2?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
            ),
          ),
          TextButton.icon(
            onPressed: _nextSkip < count && !isLoading
                ? () {
                    onNextPressed(_nextSkip);
                  }
                : null,
            style: TextButton.styleFrom(primary: controllerColor),
            icon: Text(
              _nextButtonTitle,
              style: Theme.of(context)
                  .textTheme
                  .subtitle2
                  ?.copyWith(color: textColor),
            ),
            label: Icon(
              Icons.arrow_forward_ios_rounded,
              color: controllerColor,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
