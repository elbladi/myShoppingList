import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:myShoppingList/models/Item.dart';
import 'package:myShoppingList/screens/items_screen.dart';
import 'package:myShoppingList/store/store.dart';
import 'package:reorderableitemsview/reorderableitemsview.dart';

class ListGridOffline extends StatelessWidget {
  final Color fontColor;
  final Function reorder;
  final String filterApplied;

  ListGridOffline({
    @required this.fontColor,
    @required this.reorder,
    @required this.filterApplied,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<Item>>(
      distinct: true,
      converter: (store) => store.state.itemsState.itemList,
      builder: (ctx, list) {
        final _staggered =
            list.map((e) => const StaggeredTileExtended.count(1, 1)).toList();
        List<Item> displayedList = [...list];

        if (filterApplied.isNotEmpty) {
          String byName = Redux.store.state.itemsState.filterName;
          int byNumber = Redux.store.state.itemsState.filterNumber;
          if (byName.isNotEmpty)
            displayedList = displayedList
                .where((item) =>
                    item.name.toLowerCase().contains(byName.toLowerCase()))
                .toList();
          if (byNumber >= 0)
            displayedList = displayedList
                .where((item) => item.quantity == byNumber)
                .toList();
        }

        return ListOfItems(
          reorder: reorder,
          staggered: _staggered,
          displayedList: displayedList,
          fontColor: fontColor,
          loading: false,
        );
      },
    );
  }
}
