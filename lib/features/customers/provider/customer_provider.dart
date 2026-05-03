import 'package:flutter/foundation.dart';

import '../data/models/customer_model.dart';
import '../data/services/customer_service.dart';

class CustomerProvider with ChangeNotifier {
  final CustomerService service;
  List<Customer> customers = [];
  bool loading = false;

  CustomerProvider({CustomerService? service})
      : service = service ?? CustomerService();

  Future<void> fetchCustomers() async {
    loading = true;
    notifyListeners();
    try {
      customers = await service.getCustomers();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
