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
    return count != 0;
  }

  factory Pagination.empty() {
    // ignore: prefer_const_constructors
    return Pagination(count: 0, results: <T>[]);
  }
}
