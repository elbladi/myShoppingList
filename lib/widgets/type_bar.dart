import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:myShoppingList/widgets/quantity_selector.dart';
import 'package:numberpicker/numberpicker.dart';
import '../store/store.dart';
import 'package:myShoppingList/store/actions/items_action.dart';
import 'package:myShoppingList/store/store.dart';

class TypeBar extends StatelessWidget {
  TypeBar({this.configOpen});

  final FocusNode _inputNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  final bool configOpen;

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
      Redux.store.dispatch(setFilterNumber(quantity));
    } catch (err) {
      print(err);
    }
  }

  void _cleanFilters() {
    Redux.store.dispatch(cleanFilters);
    _controller.clear();
    _inputNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: width - (width * 0.25),
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: StoreConnector<AppState, Color>(
                distinct: true,
                converter: (store) =>
                    store.state.userState.user.config.fontColor,
                builder: (ctx, fontColor) {
                  return TextField(
                    controller: _controller,
                    autocorrect: true,
                    style: TextStyle(color: fontColor),
                    keyboardType: TextInputType.text,
                    focusNode: _inputNode,
                    enableSuggestions: true,
                    decoration: InputDecoration(
                      labelText: 'Buscar',
                      labelStyle:
                          Theme.of(context).textTheme.headline6.copyWith(
                                color: Redux.store.state.userState.user.config
                                    .fontColor,
                                fontSize: 20,
                              ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[700]),
                      ),
                    ),
                    onSubmitted: (String _) => _inputNode.unfocus(),
                    onChanged: (String value) {
                      StoreProvider.of<AppState>(context)
                          .dispatch(setSearchInput(value));
                    },
                  );
                },
              ),
            ),
            SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(height: 20),
                QuantitySelector(_selectQuantity, true)
              ],
            ),
            SizedBox(width: 10),
            IconButton(
              alignment: Alignment.bottomCenter,
              color: Colors.red[800],
              onPressed: _cleanFilters,
              icon: Icon(Icons.clear),
            ),
          ],
        ),
      ),
    );
  }
}
