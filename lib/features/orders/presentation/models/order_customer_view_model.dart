import 'package:vsc_app/features/customers/presentation/models/base_customer_view_model.dart';

class OrderCustomerViewModel extends BaseCustomerViewModel {
  const OrderCustomerViewModel({required super.id, required super.name, required super.phone, required super.isActive});

  factory OrderCustomerViewModel.fromApi({required String id, required String name, required String phone, required bool isActive}) {
    return OrderCustomerViewModel(id: id, name: name, phone: phone, isActive: isActive);
  }
}
