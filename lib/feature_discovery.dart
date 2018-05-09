import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:overlays/animations.dart';

final Logger _log = new Logger('feature_discovery');

/// Material Design Feature Discovery Widget
/// https://material.io/guidelines/growth-communications/feature-discovery.html
///
/// FeatureDiscovery is a root coordinator Widget that activates one or more
/// discoverable features, possibly in order as the user taps on things. Those
/// discoverable features are represented by lower Widgets in the tree like
/// [DescribedDiscoverableFeature] and [PulsingDiscoverableFeature].
class FeatureDiscoveryStepper extends StatefulWidget {

  static FeatureDiscoveryController of(BuildContext context) {
    _log.fine('FeatureDiscoveryController: ${context.ancestorStateOfType(new TypeMatcher<_FeatureDiscoveryState>())}');
    return context.ancestorStateOfType(
        new TypeMatcher<_FeatureDiscoveryState>()
    ) as FeatureDiscoveryController;
  }

  final Widget child;

  FeatureDiscoveryStepper({
    this.child,
  });

  @override
  _FeatureDiscoveryState createState() => new _FeatureDiscoveryState();
}

class _FeatureDiscoveryState extends State<FeatureDiscoveryStepper> with FeatureDiscoveryController {

//  OverlayEntry activeFeatureOverlay;
  List<GlobalKey> _activeSteps;
  int _activeStepIndex;

  // TODO: consider using string instead of globalkey
  GlobalKey get activeStep => _activeSteps?.elementAt(_activeStepIndex);

  @override
  void discoverFeatures(List<GlobalKey> steps) {
    _log.fine('discoverFeatures() - steps: $steps');
    // TODO: handle situation where steps are already in progress

    setState(() {
      _activeSteps = steps;
      _activeStepIndex = 0;
    });
  }

  @override
  void markStepComplete(GlobalKey stepId) {
    if (_activeSteps != null && _activeSteps[_activeStepIndex] == stepId) {
      _log.fine('markStepComplete() - now complete: $stepId');
      if (_activeStepIndex < _activeSteps.length - 1) {
        _log.fine('Moving to next step.');
        setState(() => ++_activeStepIndex);
      } else {
        _log.fine('Steps are complete.');
        setState(() {
          _activeSteps = null;
          _activeStepIndex = 0;
        });
      }
    }
  }

  @override
  void cancelDiscovery() {
    _log.fine('Cancelling active discovery.');
    setState(() {
      _activeSteps = null;
      _activeStepIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new _InheritedFeatureDiscovery(
      activeSteps: _activeSteps,
      activeIndex: _activeStepIndex,
      child: widget.child,
    );
  }
}

class _InheritedFeatureDiscovery extends InheritedWidget {

  static _InheritedFeatureDiscovery of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(_InheritedFeatureDiscovery);
  }

  final List<GlobalKey> _activeSteps;
  final int _activeIndex;

  _InheritedFeatureDiscovery({
    activeSteps,
    activeIndex,
    child,
  }) : _activeSteps = activeSteps,
        _activeIndex = activeIndex,
        super(child: child);

  GlobalKey get activeStep => _activeSteps?.elementAt(_activeIndex);

  @override
  bool updateShouldNotify(_InheritedFeatureDiscovery oldWidget) {
    return oldWidget._activeIndex != _activeIndex ||
      oldWidget._activeSteps != _activeSteps;
  }

}

abstract class FeatureDiscoveryController {

  void discoverFeatures(List<GlobalKey> steps);

  void markStepComplete(GlobalKey stepId);

  void cancelDiscovery();
}

/// A feature that can be discovered.
///
/// When an ancestor DescribedDiscoverableFeature Widget sets its active step to
/// this one, this DescribedDiscoverableFeature will emit a radial background,
/// display a title and description, and show a pulsing icon on top of the
/// [child] Widget given to this DescribedDiscoverableFeature.
class DescribedDiscoverableFeature extends StatefulWidget {

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final DiscoveryBuilder builder;

  DescribedDiscoverableFeature({
    key,
    this.title,
    this.description,
    this.icon,
    this.color,
    this.onPressed,
    this.builder,
  }) : super(key: key);

  @override
  _DescribedDiscoverableFeatureState createState() => new _DescribedDiscoverableFeatureState();
}

class _DescribedDiscoverableFeatureState extends State<DescribedDiscoverableFeature> {

  OverlayEntry activeFeatureOverlay;
  VoidCallback onActivation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _InheritedFeatureDiscovery featureDiscovery = _InheritedFeatureDiscovery.of(context);
    if (featureDiscovery.activeStep == widget.key) {
      highlightFeature();
    }
  }

  bool isDiscoveryDisplayed() {
    return activeFeatureOverlay != null;
  }

  void onActivationComplete() {
    activeFeatureOverlay.remove();
    activeFeatureOverlay = null;

    _log.fine('Activating the caller\'s desired action.');
    if (null != widget.onPressed) {
      widget.onPressed();
    }

    _log.fine('Activating next step.');
    FeatureDiscoveryStepper.of(context).markStepComplete(widget.key);
  }

  void onDismissComplete() {
    activeFeatureOverlay.remove();
    activeFeatureOverlay = null;

    _log.fine('Cancelling remaining steps.');
    FeatureDiscoveryStepper.of(context).cancelDiscovery();
  }

  Future<Null> highlightFeature() async {
    if (null != activeFeatureOverlay) {
      return;
    }

    final RenderBox targetBox = context.findRenderObject() as RenderBox;
    final targetTop = targetBox.localToGlobal(const Offset(0.0, 0.0)).dy;
    final targetBottom = targetBox.localToGlobal(const Offset(0.0, 0.0)).dy + targetBox.size.height;
    final targetCenter = targetBox.size.center(targetBox.localToGlobal(const Offset(0.0, 0.0)));

    FeatureDiscoveryContentPosition contentPosition;
    FeatureDiscoveryBackgroundPosition backgroundPosition;
    if (targetTop < 88.0) {
      contentPosition = FeatureDiscoveryContentPosition.below;
      backgroundPosition = FeatureDiscoveryBackgroundPosition.centeredAboutTouchTarget;
    } else if ((MediaQuery.of(context).size.height - targetBottom) < 88.0) {
      contentPosition = FeatureDiscoveryContentPosition.above;
      backgroundPosition = FeatureDiscoveryBackgroundPosition.centeredAboutTouchTarget;
    } else {
      if (targetCenter.dy < (MediaQuery.of(context).size.height / 2.0)) {
        contentPosition = FeatureDiscoveryContentPosition.above;
      } else {
        contentPosition = FeatureDiscoveryContentPosition.below;
      }

      backgroundPosition = FeatureDiscoveryBackgroundPosition.centeredOnScreen;
    }

    final backgroundRadius = MediaQuery.of(context).size.width * (backgroundPosition == FeatureDiscoveryBackgroundPosition.centeredAboutTouchTarget
        ? 1.0
        : 0.75);

    activeFeatureOverlay = new OverlayEntry(
        builder: (BuildContext context) {
          return new FeatureDiscoveryOverlay(
            targetKey: widget.key,
            touchBaseRadius: 34.0,
            touchPulseWidth: 10.0,
            touchWaveWidth: 44.0,
            touchTargetColor: Colors.white,
            backgroundRadius: backgroundRadius,
            backgroundColor: widget.color,
            backgroundPosition: backgroundPosition,
            onDismissComplete: onDismissComplete,
            onActivationComplete: onActivationComplete,

            content: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: new Text(
                    widget.title,
                    style: new TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                new Text(
                  widget.description,
                  style: new TextStyle(
                    fontSize: 16.0,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            contentPosition: contentPosition,

            child: new Icon(
              widget.icon,
              color: Colors.grey,
            ),
          );
        }
    );
    Overlay.of(context).insert(activeFeatureOverlay);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.onPressed);
  }
}

typedef Widget DiscoveryBuilder(BuildContext context, VoidCallback onPressed);

/// Circular overlay on top of a feature's icon.
class FeatureDiscoveryOverlay extends StatefulWidget {

  final GlobalKey targetKey;
  final double touchBaseRadius;
  final double touchPulseWidth;
  final double touchWaveWidth;
  final Color touchTargetColor;
  final double backgroundRadius;
  final double backgroundRadiateWidth;
  final Color backgroundColor;
  final Widget content;
  final FeatureDiscoveryContentPosition contentPosition;
  final FeatureDiscoveryBackgroundPosition backgroundPosition;
  final Function onDismissComplete;
  final Function onActivationComplete;
  final Widget child;

  FeatureDiscoveryOverlay({
    this.targetKey,
    this.touchBaseRadius,
    this.touchPulseWidth,
    this.touchWaveWidth = 10.0,
    this.touchTargetColor,
    this.backgroundRadius,
    this.backgroundRadiateWidth,
    this.backgroundColor,
    this.content,
    this.contentPosition = FeatureDiscoveryContentPosition.below,
    this.backgroundPosition = FeatureDiscoveryBackgroundPosition.centeredAboutTouchTarget,
    this.onDismissComplete,
    this.onActivationComplete,
    this.child,
  });

  @override
  _FeatureDiscoveryOverlayState createState() => new _FeatureDiscoveryOverlayState();
}

class _FeatureDiscoveryOverlayState extends State<FeatureDiscoveryOverlay> with TickerProviderStateMixin {

  AnimationController openController;
  AnimationController dismissController;
  AnimationController activationController;

  AnimationController pulseController;

  ProxyAnimation touchTargetRadius;
  Animation openTouchTargetRadius;
  Animation pulseTouchTargetRadius;
  Animation dismissTouchTargetRadius;
  Animation activationTouchTargetRadius;

  ProxyAnimation touchTargetOpacity;
  Animation openTouchTargetOpacity;
  Animation dismissTouchTargetOpacity;
  Animation activationTouchTargetOpacity;

  Animation waveRadius;
  Animation waveOpacity;

  ProxyAnimation contentOpacity;
  Animation openContentOpacity;
  Animation dismissContentOpacity;
  Animation activationContentOpacity;

  ProxyAnimation backgroundRadius;
  Animation openBackgroundRadius;
  Animation dismissBackgroundRadius;
  Animation activationBackgroundRadius;

  ProxyAnimation backgroundOpacity;
  Animation openBackgroundOpacity;
  Animation dismissBackgroundOpacity;
  Animation activationBackgroundOpacity;

  Animation backgroundCenter;

  @override
  void initState() {
    super.initState();

    _initCoreAnimations();
    _initOpenAnimations();
    _initPulseAnimations();
    _initDismissAnimations();
    _initActivationAnimations();

    _animateOpen();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (backgroundCenter == null) {
      _animateBackgroundToOpenPosition();
    }
  }

  void _animateBackgroundToOpenPosition() {
    final RenderBox targetBox = widget.targetKey.currentContext.findRenderObject() as RenderBox;
    final targetCenter = targetBox.size.center(targetBox.localToGlobal(const Offset(0.0, 0.0)));
    final screenWidth = MediaQuery.of(context).size.width;

    final isTouchTargetOnRight = targetCenter.dx > (screenWidth / 2.0);
    final backgroundX = (screenWidth / 2.0) + (isTouchTargetOnRight ? 20.0 : -20.0);

    final isContentAboveTarget = widget.contentPosition == FeatureDiscoveryContentPosition.above;
    print('isContentAboveTarget: $isContentAboveTarget');
    final backgroundY = targetCenter.dy +
        (isContentAboveTarget
            ? -(screenWidth / 2.0) + 40.0
            : (screenWidth / 2.0) - 40.0
        );

    final Offset backgroundCenterStart = targetCenter;
    final Offset backgroundCenterEnd = new Offset(backgroundX, backgroundY);
    backgroundCenter = new Tween(
      begin: backgroundCenterStart,
      end: backgroundCenterEnd,
    ).animate(
      new CurvedAnimation(
        parent: openController,
        curve: Curves.easeOut,
      ),
    );
  }

  void _animateBackgroundToClosedPosition() {
    final RenderBox targetBox = widget.targetKey.currentContext.findRenderObject() as RenderBox;
    final targetCenter = targetBox.size.center(targetBox.localToGlobal(const Offset(0.0, 0.0)));
    print('targetBox size. Width: ${targetBox.size.width}, Height: ${targetBox.size.height}');
    print('targetBox center: $targetCenter');
    print('screen size. Width: ${MediaQuery.of(context).size.width}, Height: ${MediaQuery.of(context).size.height}');

    final Offset backgroundCenterStart = targetCenter;
    backgroundCenter = new Tween(
      begin: backgroundCenter.value,
      end: backgroundCenterStart,
    ).animate(
      new CurvedAnimation(
        parent: dismissController,
        curve: Curves.easeOut,
      ),
    );
  }

  void _initCoreAnimations() {
    touchTargetRadius = new ProxyAnimation();
    touchTargetOpacity = new ProxyAnimation();
    contentOpacity = new ProxyAnimation();
    backgroundRadius = new ProxyAnimation();
    backgroundOpacity = new ProxyAnimation();
  }

  void _initOpenAnimations() {
    openController = new AnimationController(
        duration: const Duration(milliseconds: 250),
        vsync: this
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _animatePulse();
        }
      });

    openTouchTargetRadius = new Tween(
      begin: 0.0,
      end: widget.touchBaseRadius,
    ).animate(
      new CurvedAnimation(
        parent: openController,
        curve: Curves.easeOut,
      ),
    );

    openTouchTargetOpacity = new Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      new CurvedAnimation(
        parent: openController,
        curve: new Interval(
          0.0,
          0.3,
          curve: Curves.easeOut,
        ),
      ),
    );

    openContentOpacity = new Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      new CurvedAnimation(
        parent: openController,
        curve: new Interval(
          0.4,
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );

    openBackgroundRadius = new Tween(
      begin: 0.0,
      end: widget.backgroundRadius,
    ).animate(
      new CurvedAnimation(
        parent: openController,
        curve: Curves.easeOut,
      ),
    );

    openBackgroundOpacity = new Tween(
      begin: 1.0,
      end: 1.0,
    ).animate(
      new CurvedAnimation(
        parent: openController,
        curve: new Interval(
          0.0,
          0.3,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  void _animateOpen() {
    touchTargetRadius.parent = openTouchTargetRadius;
    touchTargetOpacity.parent = openTouchTargetOpacity;
    contentOpacity.parent = openContentOpacity;
    backgroundRadius.parent = openBackgroundRadius;
    backgroundOpacity.parent = openBackgroundOpacity;
    openController.forward();
  }

  void _initPulseAnimations() {
    pulseController = new AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          pulseController.forward(from: 0.0);
        }
      });

    pulseTouchTargetRadius = new SerialAnimation(
        tweens: [
          // Expand
          new IntervalTween(
            tween: new Tween<double>(
              begin: widget.touchBaseRadius,
              end: widget.touchBaseRadius + widget.touchPulseWidth,
            ),
            interval: new Interval(
              0.0,
              0.3,
              curve: Curves.easeOut,
            ),
          ),

          // Contract
          new IntervalTween(
            tween: new Tween<double>(
              begin: widget.touchBaseRadius + widget.touchPulseWidth,
              end: widget.touchBaseRadius,
            ),
            interval: new Interval(
              0.3,
              0.6,
              curve: Curves.easeOut,
            ),
          ),

          // Sit still
          new IntervalTween(
            tween: new Tween<double>(
              begin: widget.touchBaseRadius,
              end: widget.touchBaseRadius,
            ),
            interval: new Interval(
              0.6,
              1.0,
            ),
          ),
        ],
        controller: pulseController
    );

    waveRadius = new SerialAnimation(
      tweens: [
        new IntervalTween(
          tween: new Tween<double>(
            begin: 0.0,
            end: 0.0,
          ),
          interval: new Interval(
            0.0,
            0.3,
          ),
        ),
        new IntervalTween(
          tween: new Tween<double>(
            begin: widget.touchBaseRadius + widget.touchPulseWidth,
            end: widget.touchBaseRadius + widget.touchWaveWidth,
          ),
          interval: new Interval(
            0.3,
            0.8,
          ),
        ),
        new IntervalTween(
          tween: new Tween<double>(
            begin: 0.0,
            end: 0.0,
          ),
          interval: new Interval(
            0.8,
            1.0,
          ),
        ),
      ],
      controller: pulseController,
    );

    waveOpacity = new SerialAnimation(
      tweens: [
        new IntervalTween(
          tween: new Tween<double>(
            begin: 0.0,
            end: 0.0,
          ),
          interval: new Interval(
            0.0,
            0.3,
          ),
        ),
        new IntervalTween(
          tween: new Tween<double>(
            begin: 0.5,
            end: 0.0,
          ),
          interval: new Interval(
            0.3,
            0.7,
          ),
        ),
        new IntervalTween(
          tween: new Tween<double>(
            begin: 0.0,
            end: 0.0,
          ),
          interval: new Interval(
            0.7,
            1.0,
          ),
        ),
      ],
      controller: pulseController,
    );
  }

  void _animatePulse() {
    touchTargetRadius.parent = pulseTouchTargetRadius;
    pulseController.forward();
  }

  void _initActivationAnimations() {
    activationController = new AnimationController(
        duration: const Duration(milliseconds: 250),
        vsync: this
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          if (widget.onActivationComplete != null) {
            widget.onActivationComplete();
          }
        }
      });
  }

  void _animateActivation() {
    if (pulseController.isAnimating) {
      pulseController.stop();
    }

    activationTouchTargetRadius = new Tween(
      begin: touchTargetRadius.value,
      end: 0.0,
    ).animate(
      new CurvedAnimation(
        parent: activationController,
        curve: Curves.easeOut,
      ),
    );

    activationTouchTargetOpacity = new Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(
      new CurvedAnimation(
        parent: activationController,
        curve: new Interval(
          0.6,
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );

    activationContentOpacity = new Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(
      new CurvedAnimation(
        parent: activationController,
        curve: new Interval(
          0.0,
          0.4,
          curve: Curves.easeOut,
        ),
      ),
    );

    activationBackgroundRadius = new Tween(
      begin: widget.backgroundRadius,
      end: widget.backgroundRadius + 40.0,
    ).animate(
      new CurvedAnimation(
        parent: activationController,
        curve: Curves.easeOut,
      ),
    );

    activationBackgroundOpacity = new Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(
      new CurvedAnimation(
        parent: activationController,
        curve: new Interval(
          0.3,
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );

    touchTargetRadius.parent = activationTouchTargetRadius;
    touchTargetOpacity.parent = activationTouchTargetOpacity;
    contentOpacity.parent = activationContentOpacity;
    backgroundRadius.parent = activationBackgroundRadius;
    backgroundOpacity.parent = activationBackgroundOpacity;

    activationController.forward();
  }

  void _initDismissAnimations() {
    dismissController = new AnimationController(
        duration: const Duration(milliseconds: 250),
        vsync: this
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          if (widget.onDismissComplete != null) {
            widget.onDismissComplete();
          }
        }
      });
  }

  void _animateDismiss() {
    if (pulseController.isAnimating) {
      pulseController.stop();
    }

    dismissTouchTargetRadius = new Tween(
      begin: touchTargetRadius.value,
      end: 0.0,
    ).animate(
      new CurvedAnimation(
        parent: dismissController,
        curve: Curves.easeOut,
      ),
    );

    dismissTouchTargetOpacity = new Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(
      new CurvedAnimation(
        parent: dismissController,
        curve: new Interval(
          0.3,
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );

    dismissContentOpacity = new Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(
      new CurvedAnimation(
        parent: dismissController,
        curve: new Interval(
          0.0,
          0.4,
          curve: Curves.easeOut,
        ),
      ),
    );

    dismissBackgroundRadius = new Tween(
      begin: widget.backgroundRadius,
      end: 0.0,
    ).animate(
      new CurvedAnimation(
        parent: dismissController,
        curve: Curves.easeOut,
      ),
    );

    dismissBackgroundOpacity = new Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(
      new CurvedAnimation(
        parent: dismissController,
        curve: new Interval(
          0.3,
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );

    touchTargetRadius.parent = dismissTouchTargetRadius;
    touchTargetOpacity.parent = dismissTouchTargetOpacity;
    contentOpacity.parent = dismissContentOpacity;
    backgroundRadius.parent = dismissBackgroundRadius;
    backgroundOpacity.parent = dismissBackgroundOpacity;

    _animateBackgroundToClosedPosition();

    dismissController.forward();
  }

  Widget _buildBackgroundAboutTouchTargetCenter(Offset anchorCenter) {
    return new Positioned(
      left: anchorCenter.dx,
      top: anchorCenter.dy,
      child: new FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: _buildBackground(backgroundRadius.value),
      ),
    );
  }

  Widget _buildBackgroundAtCenterOfScreen() {
    return new Positioned(
        left: backgroundCenter.value.dx,
        top: backgroundCenter.value.dy,
        child: new FractionalTranslation(
            translation: const Offset(-0.5, -0.5),
            child: _buildBackground(backgroundRadius.value)
        )
    );
  }

  Widget _buildBackground(double radius) {
    return new Opacity(
      opacity: backgroundOpacity.value,
      child: new Container(
        width: radius * 2,
        height: radius * 2,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          color: widget.backgroundColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final RenderBox anchorBox = widget.targetKey.currentContext.findRenderObject() as RenderBox;
    final anchorSize = anchorBox.size;
    final anchorPosition = anchorBox.localToGlobal(const Offset(0.0, 0.0));
    final anchorCenter = anchorSize.center(anchorPosition);

    return new GestureDetector(
      onTap: _animateDismiss,
      child: new Material(
        color: Colors.transparent,
        child: new Container(
          color: Colors.transparent,
          child: new Stack(
            alignment: Alignment.topLeft,
            fit: StackFit.expand,
            children: <Widget>[
              widget.backgroundPosition == FeatureDiscoveryBackgroundPosition.centeredAboutTouchTarget
                ? _buildBackgroundAboutTouchTargetCenter(anchorCenter)
                : _buildBackgroundAtCenterOfScreen(),

              // Text area
              new Positioned(
                top: anchorCenter.dy,
                child: new Transform(
                  transform: new Matrix4.translationValues(
                    0.0,
                    widget.contentPosition == FeatureDiscoveryContentPosition.below
                        ? widget.touchBaseRadius + widget.touchPulseWidth + 20.0
                        : -(widget.touchBaseRadius + widget.touchPulseWidth + 20.0),
                    0.0,
                  ),
                  child: new FractionalTranslation(
                    translation: new Offset(
                      0.0,
                      widget.contentPosition == FeatureDiscoveryContentPosition.below
                          ? 0.0
                          : -1.0,
                    ),
                    child: new Container(
                      width: MediaQuery.of(context).size.width,
                      child: new Padding(
                        padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                        child: new Opacity(
                          opacity: contentOpacity.value,
                          child: widget.content,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              new Positioned(
                left: anchorCenter.dx,
                top: anchorCenter.dy,
                child: new FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: new Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      // Touch Target Wave
                      new Container(
                        width: waveRadius.value * 2,
                        height: waveRadius.value * 2,
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.touchTargetColor.withOpacity(waveOpacity.value),
                        ),
                      ),

                      // Touch Target
                      new Opacity(
                        opacity: touchTargetOpacity.value,
                        child: new Container(
                          width: touchTargetRadius.value * 2,
                          height: touchTargetRadius.value * 2,
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.touchTargetColor,
                          ),
                          child: new RawMaterialButton(
                              shape: new CircleBorder(),
                              fillColor: Colors.white,
                              child: widget.child,
                              onPressed: () {
                                _animateActivation();
                              }
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum FeatureDiscoveryContentPosition {
  above,
  below,
}

enum FeatureDiscoveryBackgroundPosition {
  centeredAboutTouchTarget,
  centeredOnScreen,
}