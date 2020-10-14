import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ItemPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      child: Shimmer.fromColors(
        baseColor: Colors.white,
        highlightColor: Colors.grey,
        child: Card(
          color: Colors.transparent,
          child: SizedBox(),
        ),
      ),
    );
  }
}
