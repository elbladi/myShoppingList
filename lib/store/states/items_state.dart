import 'dart:io';

import 'package:meta/meta.dart';
import '../../models/Item.dart';

@immutable
class ItemsState {
  final Item item;
  final bool loading;
  final String loadingImg;
  final List<Item> itemList;
  final bool filterApplied;
  final int newItemQuantity;
  final String newItemName;
  final bool newItemToCart;
  final File pickedImage;
  final int filterNumber;
  final String filterName;
  final String trigerFilterUpd;

  ItemsState({
    this.item,
    this.loading,
    this.loadingImg,
    this.itemList,
    this.filterApplied,
    this.newItemQuantity,
    this.newItemName,
    this.newItemToCart,
    this.pickedImage,
    this.filterNumber,
    this.filterName,
    this.trigerFilterUpd,
  });

  factory ItemsState.initial() => ItemsState(
        item: null,
        loading: false,
        loadingImg:
            'https://ourshoppinglist.netlify.app/static/media/loading.7010154a.gif',
        itemList: [],
        filterApplied: false,
        newItemQuantity: 0,
        newItemName: '',
        newItemToCart: false,
        pickedImage: null,
        filterNumber: -1,
        filterName: '',
        trigerFilterUpd: '',
      );

  List<Item> getList() {
    if (this.itemList.length <= 0)
      return [];
    else
      return [...this.itemList];
  }

  ItemsState copyWith({
    @required Item item,
    @required String loadingImg,
    @required bool loading,
    @required List<Item> itemList,
    @required bool filterApplied,
    @required int newItemQuantity,
    @required String newItemName,
    @required bool newItemToCart,
    @required File pickedImage,
    @required int filterNumber,
    @required String filterName,
    @required String trigerFilterUpd,
  }) {
    return ItemsState(
      item: item ?? this.item,
      loadingImg: loadingImg ?? this.loadingImg,
      loading: loading ?? this.loading,
      itemList: itemList ?? this.itemList,
      filterApplied: filterApplied ?? this.filterApplied,
      newItemQuantity: newItemQuantity ?? this.newItemQuantity,
      newItemName: newItemName ?? this.newItemName,
      newItemToCart: newItemToCart ?? this.newItemToCart,
      pickedImage: pickedImage ?? this.pickedImage,
      filterNumber: filterNumber ?? this.filterNumber,
      filterName: filterName ?? this.filterName,
      trigerFilterUpd: trigerFilterUpd ?? this.trigerFilterUpd,
    );
  }
}
