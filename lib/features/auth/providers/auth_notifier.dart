import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dube/features/auth/data/repositories/auth_repository.dart';
import 'package:dube/shared/providers/app_providers.dart';

class AuthState {
  final bool    isLoading;
  final String? error;
  const AuthState({this.isLoading = false, this.error});
  AuthState copyWith({bool? isLoading, String? error}) =>
      AuthState(isLoading: isLoading ?? this.isLoading, error: error);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  AuthNotifier(this._repo) : super(const AuthState());

  Future<bool> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.signIn(email: email, password: password);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _friendly(e.toString()));
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String shopName,
    required String phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.signUp(
          email: email, password: password, shopName: shopName, phone: phone);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _friendly(e.toString()));
      return false;
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthState();
  }

  void clearError() => state = state.copyWith(error: null);

  String _friendly(String raw) {
    if (raw.contains('wrong-password') || raw.contains('invalid-credential'))
      return 'Incorrect email or password.';
    if (raw.contains('user-not-found'))    return 'No account found with this email.';
    if (raw.contains('email-already-in-use')) return 'Email already registered.';
    if (raw.contains('weak-password'))     return 'Password must be at least 6 characters.';
    if (raw.contains('network'))           return 'No internet connection.';
    return 'Something went wrong. Please try again.';
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(authRepositoryProvider)),
);
