// paginate with [PaginationMap] on google map
class Pagination<T> {
  /// count of all results
  final int count;

  /// List of
  final List<T> results;

  const Pagination({
    required this.results,
    required this.count,
  });

  /// No pagination results
  bool get isEmpty {
    return count == 0;
  }

  /// Have pagination results
  bool get isNotEmpty {
    return !isEmpty;
  }

  factory Pagination.empty() {
    // ignore: prefer_const_literals_to_create_immutables
    return const Pagination(count: 0, results: []);
  }
}
