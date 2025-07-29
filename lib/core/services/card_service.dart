import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/core/models/card_model.dart';
import 'package:vsc_app/core/services/base_service.dart';
import 'package:vsc_app/app/app_config.dart';

class CardService extends BaseService {
  Future<CreateCardResponse> createCard(CreateCardRequest request) async {
    return executeRequest(() => post('/cards/', data: request.toJson()), (json) => MessageData.fromJson(json));
  }

  // Placeholder for future image upload functionality
  Future<String> uploadImage(dynamic imageFile) async {
    // TODO: Implement actual image upload API
    // For now, return a dummy image URL
    await Future.delayed(AppConfig.animationDurationNormal); // Simulate API call
    return 'https://t4.ftcdn.net/jpg/05/08/65/87/360_F_508658796_Np78KNMINjP6CemujX79bJsOWOTRbNCW.jpg';
  }
}
