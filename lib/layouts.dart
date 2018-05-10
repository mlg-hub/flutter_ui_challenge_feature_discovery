import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

class CenteredAboutPosition extends StatelessWidget {

  final Offset position;
  final Widget child;

  CenteredAboutPosition({
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

  void createOverlay() {
    overlayEntry = new OverlayEntry(
      builder: widget.overlayBuilder,
    );
    addToOverlay(overlayEntry);
  }

  void addToOverlay(OverlayEntry entry) async {
    Overlay.of(context).insert(entry);
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

/// Displays the provided [centeredOverlay] centered above the parent of this
/// Widget.
class OverlayAnchor extends StatefulWidget {

  final bool showOverlay;
  final Function(BuildContext, Offset anchor) overlayBuilder;
  final Widget child;

  OverlayAnchor({
    this.showOverlay = false,
    this.overlayBuilder,
    this.child,
  });

  @override
  _OverlayAnchorState createState() => new _OverlayAnchorState();
}

class _OverlayAnchorState extends State<OverlayAnchor> {
  @override
  Widget build(BuildContext context) {
    return new Container( // Container is used to shrink down to size of child.
      child: new LayoutBuilder( // LayoutBuilder gives us a chance to act on the Container's dimensions
        builder: (BuildContext context, BoxConstraints constraints) {
          return new OverlayBuilder(
            show: widget.showOverlay,

            // The overlay that can appear centered on top of our provided content.
            overlayBuilder: (BuildContext overlayContext) {
              final RenderBox targetBox = context.findRenderObject() as RenderBox;
              final center = targetBox.size.center(targetBox.localToGlobal(const Offset(0.0, 0.0)));

              return widget.overlayBuilder(overlayContext, center);
            },

            // The UI that the caller actually wants on screen.
            child: widget.child,
          );
        },
      ),
    );
  }
}
