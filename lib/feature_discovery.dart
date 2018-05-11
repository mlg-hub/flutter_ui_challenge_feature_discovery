import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:overlays/layouts.dart';

class FeatureDiscovery extends StatefulWidget {
  static String of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedFeatureDiscovery)
            as _InheritedFeatureDiscovery)
        .activeStepId;
  }

  static void discoverFeatures(BuildContext context, List<String> steps) {
    _FeatureDiscoveryState state =
        context.ancestorStateOfType(new TypeMatcher<_FeatureDiscoveryState>())
            as _FeatureDiscoveryState;

    state.discoverFeatures(steps);
  }

  static void markStepComplete(BuildContext context, String stepId) {
    _FeatureDiscoveryState state =
        context.ancestorStateOfType(new TypeMatcher<_FeatureDiscoveryState>())
            as _FeatureDiscoveryState;

    state.markStepComplete(stepId);
  }

  static void dismiss(BuildContext context) {
    _FeatureDiscoveryState state =
        context.ancestorStateOfType(new TypeMatcher<_FeatureDiscoveryState>())
            as _FeatureDiscoveryState;

    state.dismiss();
  }

  final Widget child;

  FeatureDiscovery({
    this.child,
  });

  @override
  _FeatureDiscoveryState createState() => new _FeatureDiscoveryState();
}

class _FeatureDiscoveryState extends State<FeatureDiscovery> {
  List<String> steps;
  int activeStepIndex;

  void discoverFeatures(List<String> steps) {
    setState(() {
      this.steps = steps;
      activeStepIndex = 0;
    });
  }

  void markStepComplete(String stepId) {
    if (steps != null && steps[activeStepIndex] == stepId) {
      setState(() {
        ++activeStepIndex;

        if (activeStepIndex >= steps.length) {
          // We're done with our steps.
          _cleanupAfterSteps();
        }
      });
    }
  }

  void dismiss() {
    setState(() {
      _cleanupAfterSteps();
    });
  }

  void _cleanupAfterSteps() {
    steps = null;
    activeStepIndex = null;
  }

  @override
  Widget build(BuildContext context) {
    return new _InheritedFeatureDiscovery(
      activeStepId: steps?.elementAt(activeStepIndex),
      child: widget.child,
    );
  }
}

class _InheritedFeatureDiscovery extends InheritedWidget {
  final String activeStepId;

  _InheritedFeatureDiscovery({
    this.activeStepId,
    child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(_InheritedFeatureDiscovery oldWidget) {
    return oldWidget.activeStepId != activeStepId;
  }
}

class DiscoverableFeature extends StatefulWidget {
  final String featureId;
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final Function(VoidCallback onActionComplete) doAction;
  final Widget child;

  DiscoverableFeature({
    this.featureId,
    this.icon,
    this.color,
    this.title,
    this.description,
    this.doAction,
    this.child,
  });

  @override
  _DiscoverableFeatureState createState() => new _DiscoverableFeatureState();
}

class _DiscoverableFeatureState extends State<DiscoverableFeature> {
  bool showOverlay = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    showOverlayIfActiveStep();
  }

  void showOverlayIfActiveStep() {
    String activeStep = FeatureDiscovery.of(context);
    setState(() => showOverlay = activeStep == widget.featureId);
  }

  @override
  Widget build(BuildContext context) {
    return new DescribedFeatureOverlay(
      showOverlay: showOverlay,
      icon: widget.icon,
      color: widget.color,
      title: widget.title,
      description: widget.description,
      onActivated: () {
        if (null == widget.doAction) {
          FeatureDiscovery.markStepComplete(context, widget.featureId);
        } else {
          widget.doAction(() => FeatureDiscovery.markStepComplete(context, widget.featureId));
        }
      },
      onDismissed: () {
        FeatureDiscovery.dismiss(context);
      },
      child: widget.child,
    );
  }
}

class DescribedFeatureOverlay extends StatefulWidget {
  final bool showOverlay;
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final VoidCallback onActivated;
  final VoidCallback onDismissed;
  final Widget child;

  DescribedFeatureOverlay({
    this.showOverlay = false,
    this.icon,
    this.color,
    this.title,
    this.description,
    this.onActivated,
    this.onDismissed,
    this.child,
  });

  @override
  _DescribedFeatureOverlayState createState() =>
      new _DescribedFeatureOverlayState();
}

class _DescribedFeatureOverlayState extends State<DescribedFeatureOverlay> with TickerProviderStateMixin {
  Size screenSize;

  _OverlayState state = _OverlayState.closed;
  double transitionPercent = 1.0;

  AnimationController openController;
  AnimationController pulseController;
  AnimationController activateController;
  AnimationController dismissController;

  @override
  void initState() {
    super.initState();

    initAnimationControllers();
  }

  @override
  void didUpdateWidget(DescribedFeatureOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.showOverlay && state == _OverlayState.closed) {
      openController.forward(from: 0.0);
    }
  }

  void initAnimationControllers() {
    openController = new AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this
    )
      ..addListener(() {
        setState(() => transitionPercent = openController.value);
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.forward) {
          setState(() => state = _OverlayState.opening);
        } else if (status == AnimationStatus.completed) {
          pulseController.forward(from: 0.0);
        }
      });

    pulseController = new AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this
    )
      ..addListener(() {
        setState(() => transitionPercent = pulseController.value);
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.forward) {
          setState(() => state = _OverlayState.pulsing);
        } else if (status == AnimationStatus.completed) {
          // Pulse again
          pulseController.forward(from: 0.0);
        }
      });

    activateController = new AnimationController(
        duration: const Duration(milliseconds: 250),
        vsync: this
    )
      ..addListener(() {
        setState(() => transitionPercent = activateController.value);
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.forward) {
          setState(() => state = _OverlayState.activating);
        } else if (status == AnimationStatus.completed) {
          setState(() => state = _OverlayState.closed);

          if (null != widget.onActivated) {
            widget.onActivated();
          }
        }
      });

    dismissController = new AnimationController(
        duration: const Duration(milliseconds: 250),
        vsync: this
    )
      ..addListener(() {
        setState(() => transitionPercent = dismissController.value);
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.forward) {
          setState(() => state = _OverlayState.dismissing);
        } else if (status == AnimationStatus.completed) {
          setState(() => state = _OverlayState.closed);

          if (widget.onDismissed != null) {
            widget.onDismissed();
          }
        }
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
  }

  void activate() {
    pulseController.stop();

    activateController.forward(from: 0.0);
  }

  void dismiss() {
    pulseController.stop();

    dismissController.forward(from: 0.0);
  }

  Widget buildOverlay(Offset anchor) {
    if (state != _OverlayState.pulsing) {
      print('Building overlay. State: $state, Percent: $transitionPercent');
    }

    return new Stack(
      children: <Widget>[
        // Tappable background to dismiss
        new GestureDetector(
          onTap: () {
            dismiss();
          },
          child: new Container(
            color: Colors.transparent,
          ),
        ),

        // Background
        new _Background(
          state: state,
          transitionPercent: transitionPercent,
          anchor: anchor,
          color: widget.color,
          screenSize: screenSize,
        ),

        // Content
        new _Content(
          state: state,
          transitionPercent: transitionPercent,
          title: widget.title,
          description: widget.description,
          anchor: anchor,
          screenSize: screenSize,
          touchTargetRadius: 44.0,
          touchTargetToContentPadding: 20.0,
        ),

        // Pulse
        new _Pulse(
          state: state,
          transitionPercent: transitionPercent,
          anchor: anchor,
        ),

        // Touch Target
        new _TouchTarget(
          state: state,
          transitionPercent: transitionPercent,
          anchor: anchor,
          icon: widget.icon,
          color: widget.color,
          onPressed: () {
            activate();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new AnchoredOverlay(
      showOverlay: widget.showOverlay,
      overlayBuilder: (BuildContext overlayContext, Offset anchor) {
        return buildOverlay(anchor);
      },
      child: widget.child,
    );
  }
}

class _Background extends StatelessWidget {
  final _OverlayState state;
  final double transitionPercent;
  final Offset anchor;
  final Color color;
  final Size screenSize;

  _Background({
    this.state,
    this.transitionPercent,
    this.anchor,
    this.color,
    this.screenSize,
  });

  bool isCloseToTopOrBottom(Size screenSize, Offset anchor) {
    return anchor.dy <= 88.0 || (screenSize.height - anchor.dy) <= 88.0;
  }

  bool isOnTopHalfOfScreen(Offset anchor) {
    return anchor.dy < (screenSize.height / 2.0);
  }

  bool isOnLeftHalfOfScreen(Offset anchor) {
    return anchor.dx < (screenSize.width / 2.0);
  }

  Offset calculateBackgroundPosition() {
    final isBackgroundCentered = isCloseToTopOrBottom(screenSize, anchor);

    if (isBackgroundCentered) {
      return anchor;
    } else {
      final startingBackgroundPosition = anchor;
      final endingBackgroundPosition = isBackgroundCentered
          ? anchor
          : new Offset(
        screenSize.width / 2.0 +
            (isOnLeftHalfOfScreen(anchor) ? -20.0 : 20.0),
        anchor.dy +
            (isOnTopHalfOfScreen(anchor)
                ? -(screenSize.width / 2.0) + 40.0
                : (screenSize.width / 2.0) - 40.0),
      );

      switch (state) {
        case _OverlayState.opening:
          final adjustedPercent = const Interval(0.0, 0.8, curve: Curves.easeOut).transform(transitionPercent);;
          return Offset.lerp(startingBackgroundPosition, endingBackgroundPosition, adjustedPercent);
        case _OverlayState.dismissing:
          return Offset.lerp(endingBackgroundPosition, startingBackgroundPosition, transitionPercent);
        default:
          return endingBackgroundPosition;
      }
    }
  }

  double calculateBackgroundRadius() {
    final isBackgroundCentered = isCloseToTopOrBottom(screenSize, anchor);
    double percentOpen;

    switch(state) {
      case _OverlayState.opening:
        percentOpen = const Interval(0.0, 0.8, curve: Curves.easeOut).transform(transitionPercent);
        break;
      case _OverlayState.pulsing:
        percentOpen = 1.0;
        break;
      case _OverlayState.activating:
        percentOpen = 1.0 + (0.1 * transitionPercent);
        break;
      case _OverlayState.dismissing:
        percentOpen = 1.0 - transitionPercent;
        break;
      default:
        return 0.0;
    }

    return screenSize.width * 2 * (isBackgroundCentered ? 1.0 : 0.75) * percentOpen;
  }

  double backgroundOpacity() {
    switch (state) {
      case _OverlayState.opening:
        return const Interval(0.0, 0.3, curve: Curves.easeOut).transform(transitionPercent);
      case _OverlayState.activating:
        return 1.0 - const Interval(0.1, 0.6, curve: Curves.easeOut).transform(transitionPercent);
      case _OverlayState.dismissing:
        return 1.0 - const Interval(0.2, 1.0, curve: Curves.easeOut).transform(transitionPercent);
      default:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (state == _OverlayState.closed) {
      return new Container();
    }

    final backgroundPosition = calculateBackgroundPosition();
    final backgroundRadius = calculateBackgroundRadius();

    return new CenterAbout(
      position: backgroundPosition,
      child: new Container(
        width: backgroundRadius,
        height: backgroundRadius,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(backgroundOpacity().clamp(0.0, 0.95)),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final _OverlayState state;
  final double transitionPercent;
  final String title;
  final String description;
  final Offset anchor;
  final Size screenSize;
  final double touchTargetRadius;
  final double touchTargetToContentPadding;

  _Content({
    this.state,
    this.transitionPercent,
    this.title,
    this.description,
    this.anchor,
    this.screenSize,
    this.touchTargetRadius,
    this.touchTargetToContentPadding,
  });

  bool isCloseToTopOrBottom(Size screenSize, Offset anchor) {
    return anchor.dy <= 88.0 || (screenSize.height - anchor.dy) <= 88.0;
  }

  bool isOnTopHalfOfScreen(Offset anchor) {
    return anchor.dy < (screenSize.height / 2.0);
  }

  _DescribedFeatureContentOrientation getContentOrientation(Size screenSize, Offset anchor) {
    if (isCloseToTopOrBottom(screenSize, anchor)) {
      // If we're close to the top or bottom then we want the content
      // of the overlay to be towards the center of the screen.
      if (isOnTopHalfOfScreen(anchor)) {
        return _DescribedFeatureContentOrientation.below;
      } else {
        return _DescribedFeatureContentOrientation.above;
      }
    } else {
      // If we're not close to the top or bottom then we want the content
      // of the overlay to sit between our anchor and the closest side
      // of the screen (top or bottom)
      if (isOnTopHalfOfScreen(anchor)) {
        return _DescribedFeatureContentOrientation.above;
      } else {
        return _DescribedFeatureContentOrientation.below;
      }
    }
  }

  double contentOffsetMultiplier(Size screenSize, Offset anchor) {
    final contentOrientation = getContentOrientation(screenSize, anchor);
    return contentOrientation == _DescribedFeatureContentOrientation.below
        ? 1.0
        : -1.0;
  }

  double contentY(Size screenSize, Offset anchor) {
    return anchor.dy +
        contentOffsetMultiplier(screenSize, anchor) *
            (touchTargetRadius + touchTargetToContentPadding);
  }

  double contentFractionalOffset(Size screenSize, Offset anchor) {
    return contentOffsetMultiplier(screenSize, anchor) >= 0.0 ? 0.0 : -1.0;
  }

  double contentOpacity() {
    switch(state) {
      case _OverlayState.opening:
        return new Interval(0.6, 1.0, curve: Curves.easeOut).transform(transitionPercent);
      case _OverlayState.pulsing:
        return 1.0;
      case _OverlayState.activating:
      case _OverlayState.dismissing:
        return 1.0 - const Interval(0.0, 0.4, curve: Curves.easeOut).transform(transitionPercent);
      default:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (state == _OverlayState.closed) {
      return new Container();
    }

    return new Positioned(
      top: contentY(screenSize, anchor),
      child: new FractionalTranslation(
        translation: new Offset(0.0, contentFractionalOffset(screenSize, anchor)),
        child: new Opacity(
          opacity: contentOpacity(),
          child: new Material(
            color: Colors.transparent,
            child: new Container(
              width: screenSize.width,
              child: new Padding(
                padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: new Text(
                        title,
                        style: new TextStyle(
                          fontSize: 24.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    new Text(
                      description,
                      softWrap: true,
                      style: new TextStyle(
                        fontSize: 16.0,
                        color: Colors.white.withOpacity(0.9),
                      )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pulse extends StatelessWidget {
  final _OverlayState state;
  final double transitionPercent;
  final Offset anchor;

  _Pulse({
    this.state,
    this.transitionPercent,
    this.anchor,
  });

  double radius() {
    switch(state) {
      case _OverlayState.pulsing:
        double expandedPercent;
        if (transitionPercent > 0.3 && transitionPercent < 0.7) {
          expandedPercent = (transitionPercent - 0.3) / 0.4;
        } else {
          expandedPercent = 0.0;
        }

        return 44.0 + (35.0 * expandedPercent);
      case _OverlayState.dismissing:
      case _OverlayState.activating:
        return 0.0;
      default:
        return 0.0;
    }
  }

  double opacity() {
    switch (state) {
      case _OverlayState.pulsing:
        final percentOpaque = 1.0 - ((transitionPercent.clamp(0.3, 0.8) - 0.3) / 0.5);
        return (percentOpaque * 0.75).clamp(0.0, 1.0);
      case _OverlayState.activating:
      case _OverlayState.dismissing:
        return 0.0;
      default:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (state == _OverlayState.closed) {
      return new Container();
    }

    return new CenterAbout(
      position: anchor,
      child: new Container(
        width: radius() * 2,
        height: radius() * 2,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity()),
        ),
      ),
    );
  }
}


class _TouchTarget extends StatelessWidget {
  final _OverlayState state;
  final double transitionPercent;
  final Offset anchor;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  _TouchTarget({
    this.state,
    this.transitionPercent,
    this.anchor,
    this.icon,
    this.color,
    this.onPressed,
  });

  double radius() {
    switch(state) {
      case _OverlayState.opening:
        return 20 + (24.0 * const Interval(0.0, 0.8, curve: Curves.easeOut).transform(transitionPercent));
      case _OverlayState.pulsing:
        double expandedPercent;
        if (transitionPercent < 0.3) {
          expandedPercent = const Interval(0.0, 0.3, curve: Curves.easeOut).transform(transitionPercent);
        } else if (transitionPercent < 0.6) {
          expandedPercent = 1.0 - const Interval(0.3, 0.6, curve: Curves.easeOut).transform(transitionPercent);
        } else {
          expandedPercent = 0.0;
        }

        return 44.0 + (10.0 * expandedPercent);
      case _OverlayState.dismissing:
        return 20.0 + (24.0 * (1.0 - transitionPercent));
      case _OverlayState.activating:
        return 20.0 + (24.0 * (1.0 - transitionPercent));
      default:
        return 0.0;
    }
  }

  double opacity() {
    switch (state) {
      case _OverlayState.opening:
        return const Interval(0.0, 0.3, curve: Curves.easeOut).transform(transitionPercent);
      case _OverlayState.activating:
      case _OverlayState.dismissing:
        return 1.0 - const Interval(0.7, 1.0, curve: Curves.easeOut).transform(transitionPercent);
      default:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (state == _OverlayState.closed) {
      return new Container();
    }

    return new CenterAbout(
      position: anchor,
      child: new Container(
        width: radius() * 2,
        height: radius() * 2,
        child: new Opacity(
          opacity: opacity(),
          child: new RawMaterialButton(
            fillColor: Colors.white,
            shape: new CircleBorder(),
            child: new Icon(
              icon,
              color: color,
            ),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}

enum _DescribedFeatureContentOrientation {
  above,
  below,
}

enum _OverlayState {
  closed,
  opening,
  pulsing,
  activating,
  dismissing,
}
