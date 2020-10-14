import 'package:flutter/material.dart';
import 'package:myShoppingList/models/Item.dart';
import 'package:myShoppingList/store/actions/items_action.dart';
import 'package:myShoppingList/store/store.dart';
import 'package:myShoppingList/widgets/quantity_selector.dart';
import 'package:numberpicker/numberpicker.dart';

class NameAndQuantity extends StatefulWidget {
  final bool existingItem;
  final Item item;

  NameAndQuantity(this.existingItem, this.item);
  @override
  _NameAndQuantityState createState() => _NameAndQuantityState();
}

class _NameAndQuantityState extends State<NameAndQuantity> {
  TextEditingController _controller;
  List<bool> _selections;

  void _selectQuantity(BuildContext context) async {
    try {
      int quantity = await showDialog<int>(
          context: context,
          builder: (context) {
            return NumberPickerDialog.integer(
              minValue: 0,
              maxValue: 20,
              initialIntegerValue: 0,
              title: Center(child: Text('Cantidad')),
            );
          });

      if (quantity == null) return;
      Redux.store.dispatch(setNewItemQuantity(quantity));
    } catch (err) {
      print(err);
    }
  }

  @override
  void initState() {
    _selections = List.generate(1, (_) => false);
    _controller = TextEditingController(
        text: widget.existingItem ? widget.item.name : '');

    if (widget.existingItem)
      Redux.store.dispatch(setNewItemQuantity(widget.item.quantity));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color fontColor = Redux.store.state.userState.user.config.fontColor;
    return Container(
      width: 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: TextField(
              controller: _controller,
              autocorrect: true,
              keyboardType: TextInputType.text,
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: fontColor, fontSize: 20),
              onChanged: (String val) =>
                  Redux.store.dispatch(saveNewItemName(val)),
              onSubmitted: (String val) =>
                  Redux.store.dispatch(saveNewItemName(val)),
            ),
          ),
          SizedBox(width: 15),
          QuantitySelector(_selectQuantity, false),
          SizedBox(width: 10),
          if (!widget.existingItem)
            ToggleButtons(
              constraints: BoxConstraints(
                minWidth: 28,
                minHeight: 28,
              ),
              borderWidth: 1.5,
              borderColor: Colors.black,
              selectedBorderColor: Colors.black,
              children: [
                Icon(
                  Icons.shopping_cart,
                  size: 20,
                  color: _selections[0] ? Colors.black : Colors.grey[300],
                ),
              ],
              isSelected: _selections,
              onPressed: (int index) {
                setState(() {
                  _selections[index] = !_selections[index];
                });
                print('changing state');
                Redux.store.dispatch(setNewItemToCart(_selections[index]));
              },
            ),
        ],
      ),
    );
  }
}
