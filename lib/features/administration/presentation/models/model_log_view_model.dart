import 'package:vsc_app/features/administration/data/models/model_log_response.dart';

class ModelLogViewModel {
  final String id;
  final String staffId;
  final String staffName;
  final String modelName;
  final String modelId;
  final String action;
  final Map<String, dynamic> oldValues;
  final Map<String, dynamic> newValues;
  final String? requestId;
  final String? actorIp;
  final String actorUserAgent;
  final String notes;
  final String source;
  final DateTime createdAt;

  const ModelLogViewModel({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.modelName,
    required this.modelId,
    required this.action,
    required this.oldValues,
    required this.newValues,
    required this.requestId,
    required this.actorIp,
    required this.actorUserAgent,
    required this.notes,
    required this.source,
    required this.createdAt,
  });

  factory ModelLogViewModel.fromResponse(ModelLogResponse response) {
    return ModelLogViewModel(
      id: response.id,
      staffId: response.staffId,
      staffName: response.staffName,
      modelName: response.modelName,
      modelId: response.modelId,
      action: response.action,
      oldValues: response.oldValues,
      newValues: response.newValues,
      requestId: response.requestId,
      actorIp: response.actorIp,
      actorUserAgent: response.actorUserAgent,
      notes: response.notes,
      source: response.source,
      createdAt: DateTime.parse(response.createdAt),
    );
  }

  static List<ModelLogViewModel> fromResponseList(List<ModelLogResponse> responseList) {
    return responseList.map((e) => ModelLogViewModel.fromResponse(e)).toList();
  }
}


