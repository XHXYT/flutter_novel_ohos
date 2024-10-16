import 'package:novel_flutter_bit/entry/book_source_entry.dart';

/// 搜索结果
/// 时间 2024-9-29
/// 7-bit
class SearchEntry {
  late String? author;
  late String? url;
  late String? name;
  late String? lastChapter;
  late String? bookAll;
  late String? coverUrl;
  late String? kind;
  late BookSourceEntry sourceEntry;

  SearchEntry(
      {this.author,
      this.url,
      this.name,
      this.lastChapter,
      this.bookAll,
      this.coverUrl,
      this.kind,
      required this.sourceEntry});
}
