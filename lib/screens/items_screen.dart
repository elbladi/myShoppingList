import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:myShoppingList/store/actions/items_action.dart';
import 'package:myShoppingList/store/store.dart';
import 'package:myShoppingList/widgets/item_container_placeholder.dart';
import 'package:myShoppingList/widgets/item_list_grid_no_connection.dart';
import '../widgets/item_container.dart';
import '../models/Item.dart' as ItemModel;
import 'package:reorderableitemsview/reorderableitemsview.dart';

class ItemScreen extends StatefulWidget {
  @override
  _ItemScreenState createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  Color _fontColor;

  @override
  void initState() {
    super.initState();
    _fontColor = Redux.store.state.userState.user.config.fontColor;
  }

  void onReorder(int prevIndex, int nextIndex) {
    StoreProvider.of<AppState>(context)
        .dispatch(reorderItemScreen(prevIndex, nextIndex));
  }

  @override
  Widget build(BuildContext context) {
    List<ItemModel.Item> list = Redux.store.state.itemsState.itemList;
    return Expanded(
      child: Container(
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            StoreConnector<AppState, String>(
              distinct: true,
              converter: (store) => store.state.itemsState.trigerFilterUpd,
              builder: (ctx, trigerFilterUpd) {
                return StoreConnector<AppState, ConnectivityResult>(
                  distinct: true,
                  converter: (store) => store.state.loginState.connection,
                  builder: (cont, connected) {
                    if (connected != ConnectivityResult.none) {
                      return ListGrid(
                        list: list,
                        fontColor: _fontColor,
                        reorder: onReorder,
                        filterApplied: trigerFilterUpd,
                      );
                    } else {
                      return ListGridOffline(
                        fontColor: _fontColor,
                        reorder: onReorder,
                        filterApplied: trigerFilterUpd,
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ListGrid extends StatelessWidget {
  final List<ItemModel.Item> list;
  final Color fontColor;
  final Function reorder;
  final String filterApplied;

  ListGrid({
    @required this.list,
    @required this.fontColor,
    @required this.reorder,
    @required this.filterApplied,
  });

  @override
  Widget build(BuildContext context) {
    DocumentReference items =
        FirebaseFirestore.instance.collection('items').doc('primero');

    return StreamBuilder<DocumentSnapshot>(
        stream: items.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('error'));

          if (snapshot.connectionState == ConnectionState.waiting) {
            final _staggered = [1, 2, 3, 4, 5, 6, 7, 8]
                .map((e) => const StaggeredTileExtended.count(1, 1))
                .toList();
            return ListOfItems(
              reorder: () {},
              staggered: _staggered,
              // ignore: missing_required_param
              displayedList: list,
              fontColor: fontColor,
              loading: false,
            );
          }

          List<dynamic> itemsInDB = snapshot.data.data()['items'];
          List<ItemModel.Item> displayedList = [];
          itemsInDB.forEach((item) {
            displayedList.add(
              ItemModel.Item(
                id: item['id'],
                image: item['image'],
                name: item['name'],
                quantity: item['quantity'],
                inCart: item['inCart'],
              ),
            );
          });

          Redux.store.dispatch(updateLocalList(Redux.store, displayedList));

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
          final _staggered = displayedList
              .map((e) => const StaggeredTileExtended.count(1, 1))
              .toList();
          return ListOfItems(
            reorder: reorder,
            staggered: _staggered,
            displayedList: displayedList,
            fontColor: fontColor,
            loading: false,
          );
        });
  }
}

class ListOfItems extends StatelessWidget {
  const ListOfItems({
    Key key,
    @required this.reorder,
    @required List<StaggeredTileExtended> staggered,
    @required this.displayedList,
    @required this.fontColor,
    @required this.loading,
  })  : _staggered = staggered,
        super(key: key);

  final Function reorder;
  final List<StaggeredTileExtended> _staggered;
  final List<ItemModel.Item> displayedList;
  final Color fontColor;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ReorderableItemsView(
      onReorder: (oldIndex, newIndex) => reorder(oldIndex, newIndex),
      crossAxisCount: 2,
      isGrid: true,
      longPressToDrag: true,
      staggeredTiles: _staggered,
      scrollController: ScrollController(keepScrollOffset: true),
      children: displayedList
          .map(
            (item) => Container(
              width: 180,
              height: 180,
              key: ValueKey(item),
              child: Card(
                color: Colors.transparent,
                elevation: 0.0,
                child: Center(
                  child: loading
                      ? ItemPlaceholder()
                      : ItemContainer(
                          item: item,
                          fontColor: fontColor,
                        ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
