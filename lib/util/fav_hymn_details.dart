import 'package:flutter/material.dart';
import 'package:hymn_book/model/hymn.dart';
import 'package:hymn_book/util/hymn_details.dart';

class FavHymnDetails extends StatelessWidget {
  final bool isInTabletLayout;
  final Hymns hymns;
  final VoidCallback? onFavoriteChanged;

  const FavHymnDetails({
    Key? key,
    required this.isInTabletLayout,
    required this.hymns,
    this.onFavoriteChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HymnDetails(
      isInTabletLayout: isInTabletLayout,
      hymns: hymns,
      onFavoriteChanged: onFavoriteChanged,
    );
  }
}
