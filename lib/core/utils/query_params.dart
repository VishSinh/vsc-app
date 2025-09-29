import 'package:vsc_app/core/utils/date_formatter.dart';

class QueryParamsBuilder {
  final Map<String, dynamic> _params = <String, dynamic>{};

  QueryParamsBuilder withPagination({int? page, int? pageSize}) {
    if (page != null) _params['page'] = page;
    if (pageSize != null) _params['page_size'] = pageSize;
    return this;
  }

  QueryParamsBuilder withSort({String? sortBy, String? sortOrder}) {
    if (sortBy != null && sortBy.isNotEmpty) _params['sort_by'] = sortBy;
    if (sortOrder != null && sortOrder.isNotEmpty) _params['sort_order'] = sortOrder;
    return this;
  }

  QueryParamsBuilder withString(String key, String? value) {
    if (value != null && value.isNotEmpty) _params[key] = value;
    return this;
  }

  QueryParamsBuilder withBoolAsString(String key, bool? value) {
    if (value != null) _params[key] = value.toString();
    return this;
  }

  QueryParamsBuilder withNumberFilter(String key, {num? eq, num? gt, num? gte, num? lt, num? lte}) {
    if (eq != null) _params[key] = eq;
    if (gt != null) _params['${key}__gt'] = gt;
    if (gte != null) _params['${key}__gte'] = gte;
    if (lt != null) _params['${key}__lt'] = lt;
    if (lte != null) _params['${key}__lte'] = lte;
    return this;
  }

  QueryParamsBuilder withDateFilter(String key, {DateTime? exact, DateTime? gte, DateTime? lte}) {
    if (exact != null) _params[key] = DateFormatter.formatDateForApi(exact);
    if (gte != null) _params['${key}__gte'] = DateFormatter.formatDateForApi(gte);
    if (lte != null) _params['${key}__lte'] = DateFormatter.formatDateForApi(lte);
    return this;
  }

  Map<String, dynamic> build() => Map.unmodifiable(_params);
}
