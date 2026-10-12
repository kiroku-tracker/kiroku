import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
        ),
        ?trailing,
      ],
    );
  }
}

EdgeInsets pagePadding({double top = 24, double bottom = 32}) =>
    EdgeInsets.fromLTRB(28, top, 28, bottom);
