import 'dart:developer';

import 'package:flutter/material.dart';

@immutable
class MapPaginationControllerTheme {
  final Color controllerColor;

  final Color textColor;

  final Color backgroundColor;

  final TextStyle? textStyle;

  const MapPaginationControllerTheme({
    required this.controllerColor,
    required this.backgroundColor,
    required this.textColor,
    this.textStyle,
  });
}

class MapPaginationController extends StatelessWidget {
  final int skip;

  final String noItemFoundText;

  final bool isLoading;

  final int limit;

  final MapPaginationControllerTheme theme;

  final int count;

  final ValueChanged<int> onNextPressed;

  final ValueChanged<int> onPreviousPressed;

  const MapPaginationController({
    Key? key,
    required this.skip,
    required this.limit,
    required this.count,
    required this.isLoading,
    required this.onNextPressed,
    required this.onPreviousPressed,
    required this.noItemFoundText,
    required this.theme,
  }) : super(key: key);

  int get _nextSkip {
    return skip + limit;
  }

  int get _previousSkip {
    return skip - limit;
  }

  debug() {
    log("Hello skip: $skip, _nextSkip: $_nextSkip, count: $count");
  }

  String get _nextButtonTitle {
    if (_nextSkip == count) {
      return "";
    } else if (_nextSkip < count) {
      debug();
      return "${skip + limit + 1} - $count";
    } else if (_nextSkip <= count) {
      debug();
      return "${skip + limit + 1} - ${skip + (limit * 2)}";
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
    } else if (_nextSkip >= count) {
      return "${skip + 1} - $count";
    } else {
      return noItemFoundText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final arrowButtonsTextTheme = theme.textStyle ??
        textTheme.titleSmall?.copyWith(color: theme.textColor);

    return Container(
      color: theme.backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: skip != 0 && !isLoading
                ? () {
                    onPreviousPressed(_previousSkip);
                  }
                : null,
            style: TextButton.styleFrom(foregroundColor: theme.controllerColor),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: theme.controllerColor,
              size: 16,
            ),
            label: Text(
              _previousButtonTitle,
              style: arrowButtonsTextTheme,
            ),
          ),
          Visibility(
            visible: !isLoading,
            replacement: const CircularProgressIndicator(),
            child: Text(
              _middleTitle(context),
              style: theme.textStyle ??
                  textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.textColor,
                  ),
            ),
          ),
          TextButton.icon(
            onPressed: _nextSkip < count && !isLoading
                ? () {
                    onNextPressed(_nextSkip);
                  }
                : null,
            style: TextButton.styleFrom(foregroundColor: theme.controllerColor),
            icon: Text(
              _nextButtonTitle,
              style: arrowButtonsTextTheme,
            ),
            label: Icon(
              Icons.arrow_forward_ios_rounded,
              color: theme.controllerColor,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
