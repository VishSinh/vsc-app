class BaseCustomerFormModel {
  String? name;
  String? phone;

  BaseCustomerFormModel({this.name, this.phone});

  Map<String, dynamic> toJson() => {if (name != null) 'name': name, if (phone != null) 'phone': phone};

  bool get isValid => (name != null && name!.trim().isNotEmpty) && (phone != null && phone!.trim().isNotEmpty);
}
