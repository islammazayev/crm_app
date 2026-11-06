import 'package:flutter/material.dart';

/// Lagom bred, centrerad yta för formulär: fält över hela skärmen blir
/// svåra att läsa på stora skärmar.
class FormWidth extends StatelessWidget {
  final Widget child;

  const FormWidth({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) => Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: box.maxWidth < 720 ? box.maxWidth : 720,
          child: child,
        ),
      ),
    );
  }
}
