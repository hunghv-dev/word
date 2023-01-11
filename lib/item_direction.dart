import 'package:flutter/material.dart';

class ItemDirection extends StatelessWidget {
  final IconData icon;
  final bool isTop;

  const ItemDirection({
    Key? key,
    required this.icon,
    this.isTop = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          isTop ? const SizedBox.shrink() : const Divider(),
          Icon(icon, size: 50),
          isTop ? const Divider() : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
