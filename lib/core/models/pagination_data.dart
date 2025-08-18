import 'package:json_annotation/json_annotation.dart';

part 'pagination_data.g.dart';

/// Pagination data structure for API responses
@JsonSerializable()
class PaginationData {
  @JsonKey(name: 'current_page')
  final int currentPage;
  @JsonKey(name: 'page_size')
  final int pageSize;
  @JsonKey(name: 'total_items')
  final int totalItems;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'has_next')
  final bool hasNext;
  @JsonKey(name: 'has_previous')
  final bool hasPrevious;
  @JsonKey(name: 'next_page')
  final int? nextPage;
  @JsonKey(name: 'previous_page')
  final int? previousPage;

  const PaginationData({
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
    this.nextPage,
    this.previousPage,
  });

  factory PaginationData.fromJson(Map<String, dynamic> json) => _$PaginationDataFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationDataToJson(this);
}
