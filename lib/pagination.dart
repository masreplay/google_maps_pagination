// paginate with [PaginationMap] on google map
import 'marker_item.dart';

class Pagination<T extends MarkerItem> {
  /// count of all results
  final int count;

  /// List of
  final List<T> results;

  const Pagination({
    required this.results,
    required this.count,
  });

  /// No pagination results
  bool get isEmpty => count == 0;

  /// Have pagination results
  bool get isNotEmpty => count != 0;

  factory Pagination.empty() {
    // ignore: prefer_const_constructors
    return Pagination(count: 0, results: <T>[]);
  }
}
