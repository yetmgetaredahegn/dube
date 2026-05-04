import '../../../shared/services/api_service.dart';
import '../models/customer.dart';

class CustomerService {
  final ApiService api;

  CustomerService({ApiService? api}) : api = api ?? ApiService();

  Future<List<Customer>> getCustomers() async {
    final data = await api.get('/customers/');
    if (data == null) return [];
    if (data is List) {
      return data
          .map((e) => Customer.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (data is Map && data['results'] != null) {
      return (data['results'] as List)
          .map((e) => Customer.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Future<void> addCustomer(Customer c) async {
    await api.post('/customers/', body: c.toJson());
  }
}
