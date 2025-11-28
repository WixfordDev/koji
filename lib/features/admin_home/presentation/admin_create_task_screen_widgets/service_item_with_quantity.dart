import '../../../../models/admin-model/all_serviceList_model.dart';

// Selected service item with quantity
class ServiceItemWithQuantity {
  ServiceItem serviceItem;
  int quantity;

  ServiceItemWithQuantity({
    required this.serviceItem,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
    'name': serviceItem.name,
    'price': serviceItem.price,
    'quantity': quantity,
  };
}