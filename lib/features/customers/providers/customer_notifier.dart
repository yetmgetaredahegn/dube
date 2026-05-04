import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dube/features/customers/data/models/customer.dart';
import 'package:dube/features/customers/data/repositories/customer_repository.dart';

class CustomerNotifier extends StateNotifier<AsyncValue<List<Customer>>> {
  final CustomerRepository _repo;
  final String shopOwnerId;

  CustomerNotifier(this._repo, this.shopOwnerId)
      : super(const AsyncValue.loading()) {
    if (shopOwnerId.isNotEmpty) _load();
  }

  Future<void> _load() async {
    try {
      final customers = await _repo.fetchCustomers(shopOwnerId);
      state = AsyncValue.data(customers);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCustomer({
    required String name,
    required String phone,
    required double creditLimit,
    String? note,
  }) async {
    try {
      await _repo.addCustomer(
        uid: shopOwnerId,
        name: name,
        phone: phone,
        creditLimit: creditLimit,
        note: note,
      );
      await _load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateCustomer({
    required String customerId,
    String? name,
    String? phone,
    double? creditLimit,
    String? note,
  }) async {
    try {
      await _repo.updateCustomer(
        uid: shopOwnerId,
        customerId: customerId,
        name: name,
        phone: phone,
        creditLimit: creditLimit,
        note: note,
      );
      await _load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      await _repo.deleteCustomer(shopOwnerId, customerId);
      await _load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _load();
}
