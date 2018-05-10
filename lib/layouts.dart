import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

class CenteredAbout extends StatelessWidget {

  final Offset position;
  final Widget child;

  CenteredAbout({
    this.position,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return new Positioned(
      left: position.dx,
      top: position.dy,
      child: new FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: child,
      ),
    );
  }
}

class OverlayBuilder extends StatefulWidget {

  final bool show;
  final WidgetBuilder overlayBuilder;
  final Widget child;

  OverlayBuilder({
    this.show = false,
    @required this.overlayBuilder,
    this.child,
  });

  @override
  _OverlayBuilderState createState() => new _OverlayBuilderState();
}

class _OverlayBuilderState extends State<OverlayBuilder> {

  OverlayEntry overlayEntry;

  @override
  void initState() {
    super.initState();

    if (widget.show) {
      createOverlay();
    }
  }

  @override
  void didUpdateWidget(OverlayBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.show && overlayEntry == null) {
      createOverlay();
    } else if(!widget.show && overlayEntry != null) {
      destroyOverlay();
    }
  }

  void createOverlay() async {
    overlayEntry = new OverlayEntry(
      builder: widget.overlayBuilder,
    );
    Overlay.of(context).insert(overlayEntry);
  }

  void destroyOverlay() {
    overlayEntry.remove();
    overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

}