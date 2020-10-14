import 'package:myShoppingList/store/actions/items_action.dart';

import '../states/items_state.dart';

itemReducer(ItemsState prevState, SetItemsState action) {
  final payload = action.itemsState;
  return prevState.copyWith(
    itemList: payload.itemList,
    item: payload.item,
    loading: payload.loading,
    loadingImg: payload.loadingImg,
    filterApplied: payload.filterApplied,
    newItemQuantity: payload.newItemQuantity,
    newItemName: payload.newItemName,
    newItemToCart: payload.newItemToCart,
    pickedImage: payload.pickedImage,
    filterNumber: payload.filterNumber,
    filterName: payload.filterName,
    trigerFilterUpd: payload.trigerFilterUpd,
  );
}
