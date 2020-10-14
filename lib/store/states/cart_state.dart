import 'package:meta/meta.dart';
import '../../models/Cart.dart';

@immutable
class CartState {
  final List<Cart> cart;

  CartState({this.cart});

  factory CartState.initial() => CartState(
        cart: [],
      );

  List<Cart> getCart() {
    return [...this.cart];
  }

  CartState copyWith({
    @required List<Cart> cart,
  }) {
    return CartState(
      cart: cart ?? this.cart,
    );
  }
}
