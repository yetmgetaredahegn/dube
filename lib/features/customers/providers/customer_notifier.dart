import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dube/features/customers/data/repositories/customer_repository.dart';
import 'package:dube/shared/providers/app_providers.dart';

class CustomerActionState {
  final bool    isLoading;
  final String? error;
  final bool    success;
  const CustomerActionState(
      {this.isLoading = false, this.error, this.success = false});
  CustomerActionState copyWith(
          {bool? isLoading, String? error, bool? success}) =>
      CustomerActionState(
        isLoading: isLoading ?? this.isLoading,
        error:     error,
        success:   success ?? this.success,
      );
}

class CustomerNotifier extends StateNotifier<CustomerActionState> {
  final CustomerRepository _repo;
  final String             _uid;

  CustomerNotifier(this._repo, this._uid)
      : super(const CustomerActionState());

  Future<bool> addCustomer({
    required String name,
    required String phone,
    required double creditLimit,
    String? note,
  }) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      await _repo.addCustomer(
          uid: _uid, name: name, phone: phone,
          creditLimit: creditLimit, note: note);
      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Failed to add customer. Try again.');
      return false;
    }
  }

  Future<bool> updateCustomer({
    required String customerId,
    String? name, String? phone, double? creditLimit, String? note,
  }) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      await _repo.updateCustomer(
          uid: _uid, customerId: customerId,
          name: name, phone: phone,
          creditLimit: creditLimit, note: note);
      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to update customer.');
      return false;
    }
  }

  Future<bool> deleteCustomer(String customerId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.deleteCustomer(_uid, customerId);
      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to delete customer.');
      return false;
    }
  }

  void reset() => state = const CustomerActionState();
}

final customerNotifierProvider =
    StateNotifierProvider<CustomerNotifier, CustomerActionState>((ref) {
  final uid = ref.watch(currentUidProvider);
  return CustomerNotifier(ref.watch(customerRepositoryProvider), uid);
});
