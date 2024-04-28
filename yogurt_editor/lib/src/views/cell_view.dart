import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:yogurt_editor/src/editor_controller.dart';

class CellView extends StatefulWidget {
  const CellView({
    super.key,
    required this.controller,
  });

  final CellController controller;

  @override
  State<CellView> createState() => _CellViewState();
}

class _CellViewState extends State<CellView> {
  late CellController _controller;
  late CellState _state;
  StreamSubscription<CellState>? _subscription;

  @override
  void initState() {
    _attach();
    super.initState();
  }

  @override
  void didUpdateWidget(CellView oldWidget) {
    if (_controller != widget.controller) {
      _attach();
    }

    super.didUpdateWidget(oldWidget);
  }

  void _attach() {
    _detach();
    _controller = widget.controller;
    _state = _controller.state;
    _subscription = _controller.stream.listen((data) {
      setState(() {
        _state = _controller.state;
      });
    });
  }

  void _detach() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Stack(
      fit: StackFit.expand,
      children: [
        _state.model.build(context, _state),
        for (final child in _controller.children.values)
          CellView(
            controller: child,
          ),
      ],
    );

    for (var plugin in widget.controller.plugins.reversed) {
      content = plugin.build(context, _controller, content);
    }

    return content;
  }
}
