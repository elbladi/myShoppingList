import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:myShoppingList/store/store.dart';

class QuantitySelector extends StatelessWidget {
  QuantitySelector(this._selectQuantity, this.mainPage);
  final Function _selectQuantity;
  final bool mainPage;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectQuantity(context),
      child: Container(
        constraints: BoxConstraints(
          minHeight: 30,
          minWidth: 30,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1.5,
            color: Redux.store.state.userState.user.config.fontColor,
          ),
        ),
        child: Center(
          child: mainPage ? FilterNumber() : NewItemNumber(),
        ),
      ),
    );
  }
}

class NewItemNumber extends StatelessWidget {
  const NewItemNumber({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, int>(
      distinct: true,
      converter: (store) => store.state.itemsState.newItemQuantity,
      builder: (ctx, quantity) {
        return Text(
          quantity.toString(),
        );
      },
    );
  }
}

class FilterNumber extends StatelessWidget {
  const FilterNumber({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, int>(
      distinct: true,
      converter: (store) => store.state.itemsState.filterNumber,
      builder: (ctx, quantity) {
        if (quantity < 0)
          return Icon(
            Icons.all_inclusive,
            color: Redux.store.state.userState.user.config.fontColor,
          );
        return Text(
          quantity.toString(),
          style: TextStyle(
            color: Redux.store.state.userState.user.config.fontColor,
          ),
        );
      },
    );
  }
}
