import 'package:flutter/material.dart';

class DragExperiment extends StatefulWidget {
  @override
  _DragExperimentState createState() => new _DragExperimentState();
}

class _DragExperimentState extends State<DragExperiment> {

  final GlobalKey theThingKey = new GlobalKey(debugLabel: 'the_thing');

  bool isOverlayDesired = false;
  bool isOverlayShowing = false;
  OverlayEntry entry;

  Widget _buildDraggable(Color color, [Offset origin]) {
    return new TheThing(
      key: theThingKey,
      onTap: _onTap,
      origin: origin,
      color: color,
    );
  }

  void _onTap(Offset thingOrigin) {
    setState(() {
      isOverlayDesired = !isOverlayDesired;

      if (isOverlayDesired && !isOverlayShowing) {
        entry = new OverlayEntry(
            builder: (BuildContext context) {
              return new Positioned(
                  left: 0.0,
                  top: 0.0,
                  child: isOverlayDesired ? _buildDraggable(Colors.purple, thingOrigin) : new Container()
              );
            }
        );

        Overlay.of(context).insert(entry);

        isOverlayShowing = true;
      } else if (!isOverlayDesired && isOverlayShowing) {
        entry.remove();
        entry = null;
        isOverlayShowing = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Is overlay desired? $isOverlayDesired, is it showing? $isOverlayShowing');

    return new Stack(
      fit: StackFit.expand,
      children: <Widget>[
        new Positioned(
        left: 0.0,
          top: 0.0,
          child: isOverlayDesired ? new Container() : _buildDraggable(Colors.red),
        ),
      ],
    );
  }
}


class TheThing extends StatelessWidget {

  final Function(Offset origin) onTap;
  final Offset origin;
  final Color color;
  final bool isInOverlay;

  TheThing({
    key,
    this.onTap,
    this.origin,
    this.color,
    this.isInOverlay = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new ScreenDraggable(
      position: origin,
      touchBuilder: (BuildContext context) {
        return new Padding(
          padding: const EdgeInsets.all(16.0),
          child: new Container(
            width: 75.0,
            height: 75.0,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        );
      },
      builder: (BuildContext context, Widget touchTarget) {
        return new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return new Stack(
              children: <Widget>[
                new CenteredCircle(
                  baseRadius: 300.0,
                  color: Colors.lightBlue,
                ),

                new GestureDetector(
                  onTap: () {
                    RenderBox box = (context.findRenderObject() as RenderBox);
                    Offset origin = box.localToGlobal(const Offset(0.0, 0.0));
                    onTap(origin);
                  },
                  child: touchTarget,
                )
              ],
            );
          },
        );
      },
    );
  }
}


class ScreenDraggable extends StatefulWidget {

  final Offset position;
  final Widget Function(BuildContext contxt, Widget touchTarget) builder;
  final Widget Function(BuildContext) touchBuilder;
  final Widget child;

  ScreenDraggable({
    key,
    this.position,
    this.builder,
    this.touchBuilder,
    this.child,
  }) : super(key: key);

  @override
  _ScreenDraggableState createState() => new _ScreenDraggableState();
}

class _ScreenDraggableState extends State<ScreenDraggable> {

  Offset position = new Offset(0.0, 0.0);
  Offset startDragOffset;
  Offset startTouchPoint;

  @override
  void initState() {
    super.initState();
    position = widget.position == null ? position : widget.position;
  }

  @override
  void didUpdateWidget(ScreenDraggable oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('Did update widget with position: ${widget.position}');
    position = widget.position == null ? position : widget.position;
  }

  void _onDragStart(DragStartDetails details) {
    startDragOffset = position;
    startTouchPoint = details.globalPosition;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      position = startDragOffset + (details.globalPosition - startTouchPoint);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    startDragOffset = null;
    startTouchPoint = null;
  }

  @override
  Widget build(BuildContext context) {
    print('Drawing the thing at: $position');

    final touchTarget = new GestureDetector(
      onPanStart: _onDragStart,
      onPanUpdate: _onDragUpdate,
      onPanEnd: _onDragEnd,
      child: widget.touchBuilder(context),
    );

    return new Transform(
      transform: new Matrix4.translationValues(position.dx, position.dy, 0.0),
      child: new FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: widget.builder(context, touchTarget),
      ),
    );
  }
}

class CenteredCircle extends StatefulWidget {

  final double baseRadius;
  final Color color;

  CenteredCircle({
    this.baseRadius,
    this.color,
  });

  @override
  _CenteredCircleState createState() => new _CenteredCircleState();
}

class _CenteredCircleState extends State<CenteredCircle> {

  @override
  Widget build(BuildContext context) {
    return new FractionalTranslation(
      translation: const Offset(-0.5, -0.5),
      child: new Container(
        width: 2 * widget.baseRadius,
        height: 2 * widget.baseRadius,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
        ),
      ),
    );
  }
}