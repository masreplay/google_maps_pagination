import 'package:flutter/material.dart';

class MapPaginationController extends StatelessWidget {
  final int skip;

  final Color controllerColor;

  final Color textColor;

  final Color backgroundColor;

  final String noItemFoundText;

  final bool isLoading;

  final int take;

  final int count;

  final TextStyle? controllerTextStyle;

  final ValueChanged<int> onNextPressed;

  final ValueChanged<int> onPreviousPressed;

  const MapPaginationController({
    Key? key,
    required this.skip,
    required this.take,
    required this.count,
    required this.isLoading,
    required this.onNextPressed,
    required this.onPreviousPressed,
    required this.noItemFoundText,
    required this.controllerTextStyle,
    required this.controllerColor,
    required this.backgroundColor,
    required this.textColor,
  }) : super(key: key);

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
      return noItemFoundText;
    } else if (_nextSkip < count) {
      return "${skip + 1} - $_nextSkip";
    } else if (_nextSkip > count) {
      return "${skip + 1} - $count";
    } else {
      return noItemFoundText;
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
              style: controllerTextStyle ??
                  Theme.of(context)
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
              style: controllerTextStyle ??
                  Theme.of(context).textTheme.subtitle2?.copyWith(
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
              style: controllerTextStyle ??
                  Theme.of(context)
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
