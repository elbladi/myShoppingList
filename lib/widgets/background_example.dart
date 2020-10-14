import 'package:flutter/material.dart';
import 'package:myShoppingList/store/actions/user_action.dart';

class BackgroundExample extends StatelessWidget {
  final String imageUrl;
  final String currentImage;
  final Function selectedBackImage;
  final double minWidth;
  final double minHeight;

  BackgroundExample({
    this.imageUrl,
    this.currentImage,
    this.selectedBackImage,
    this.minHeight,
    this.minWidth,
  });

  void _deleteBackground() {
    deleteBackImage(imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    final selected = currentImage == imageUrl;

    return Stack(
      children: [
        InkWell(
          onTap: () => selectedBackImage(imageUrl, context),
          child: Container(
            constraints: BoxConstraints(
              minHeight: minHeight,
              minWidth: minWidth,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    selected ? Color.fromRGBO(255, 116, 119, 1) : Colors.black,
                width: selected ? 5 : 2,
              ),
            ),
            child: Image.network(
              imageUrl,
              fit: BoxFit.fill,
              loadingBuilder: (ctx, child, loading) {
                if (loading == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loading.expectedTotalBytes != null
                        ? loading.cumulativeBytesLoaded /
                            loading.expectedTotalBytes
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
        currentImage.isEmpty
            ? SizedBox()
            : Positioned(
                right: -23,
                top: -23,
                child: Center(
                  child: IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.black,
                    ),
                    onPressed: _deleteBackground,
                  ),
                ),
              ),
      ],
      overflow: Overflow.visible,
    );
  }
}
