import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pagination_map/pagination.dart';

import 'marker_item.dart';

typedef ItemsWidgetBuilder<T> = Widget Function(BuildContext context, T item);

typedef MapScrollCallback = Future<void> Function(
    CameraPosition cameraPosition);

typedef ValueReturnChanged<T> = T Function(T value);

typedef OnItemsChanged<T extends MarkerItem> = Future<Pagination<T>> Function(
    int skip, CameraPosition cameraPosition);
