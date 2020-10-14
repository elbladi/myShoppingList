import 'package:meta/meta.dart';
import 'package:myShoppingList/models/User.dart';

@immutable
class UserState {
  final bool isLoading;
  final bool error;
  final User user;

  UserState({
    this.error,
    this.isLoading,
    this.user,
  });

  factory UserState.initial() => UserState(
        isLoading: false,
        error: false,
        user: null,
      );

  UserState copyWith({
    @required bool error,
    @required bool isLoading,
    @required User user,
  }) {
    return UserState(
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
    );
  }
}
