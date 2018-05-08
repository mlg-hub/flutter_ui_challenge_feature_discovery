import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class FeatureDiscovery extends StatefulWidget {

  static FeatureDiscoveryController of(BuildContext context) {
    return context.ancestorStateOfType(
        new TypeMatcher<_FeatureDiscoveryState>()
    ) as FeatureDiscoveryController;
  }

  final Widget child;

  FeatureDiscovery({
    this.child,
  });

  @override
  _FeatureDiscoveryState createState() => new _FeatureDiscoveryState();
}

class _FeatureDiscoveryState extends State<FeatureDiscovery> with FeatureDiscoveryController {

  OverlayEntry activeFeatureOverlay;

  @override
  void highlightFeature({
    @required GlobalKey featureUiKey,
    @required IconData targetIcon,
    @required Color color,
    String title = '',
    String description = '',
  }) {
    if (null != activeFeatureOverlay) {
      activeFeatureOverlay.remove();
    }

    final RenderBox targetBox = featureUiKey.currentContext.findRenderObject() as RenderBox;
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
            targetKey: featureUiKey,
            touchBaseRadius: 34.0,
            touchPulseWidth: 10.0,
            touchWaveWidth: 44.0,
            touchTargetColor: Colors.white,
            backgroundRadius: backgroundRadius,
            backgroundColor: color,
            backgroundPosition: backgroundPosition,
            onClose: () {
              activeFeatureOverlay.remove();
              activeFeatureOverlay = null;
            },

            content: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: new Text(
                    title,
                    style: new TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                new Text(
                  description,
                  style: new TextStyle(
                    fontSize: 16.0,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            contentPosition: contentPosition,

            child: new RawMaterialButton(
                shape: new CircleBorder(),
                fillColor: Colors.white,
                child: new Icon(
                  targetIcon,
                  color: Colors.grey,
                ),
                onPressed: () {
                  // TODO:
                  print('touched');
                }
            ),
          );
        }
    );
    Overlay.of(context).insert(activeFeatureOverlay);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

abstract class FeatureDiscoveryController {
  void highlightFeature({
    @required GlobalKey featureUiKey,
    @required IconData targetIcon,
    @required Color color,
    String title,
    String description,
  });
}

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
  final Function onClose;
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
    this.onClose,
    this.child,
  });

  @override
  _FeatureDiscoveryOverlayState createState() => new _FeatureDiscoveryOverlayState();
}

class _FeatureDiscoveryOverlayState extends State<FeatureDiscoveryOverlay> with TickerProviderStateMixin {

  AnimationController openController;
  AnimationController closeController;
  AnimationController dissipationController;

  AnimationController pulseController;

  ProxyAnimation touchTargetRadius;
  Animation openTouchTargetRadius;
  Animation pulseTouchTargetRadius;
  Animation closeTouchTargetRadius;
  Animation dismissTouchTargetRadius;

  ProxyAnimation touchTargetOpacity;
  Animation openTouchTargetOpacity;
  Animation closeTouchTargetOpacity;

  Animation waveRadius;
  Animation waveOpacity;

  ProxyAnimation contentOpacity;
  Animation openContentOpacity;
  Animation closeContentOpacity;

  ProxyAnimation backgroundRadius;
  Animation openBackgroundRadius;
  Animation closeBackgroundRadius;
  Animation dismissBackgroundRadius;

  ProxyAnimation backgroundOpacity;
  Animation openBackgroundOpacity;
  Animation closeBackgroundOpacity;

  Animation backgroundCenter;

  @override
  void initState() {
    super.initState();

    _initCoreAnimations();
    _initOpenAnimations();
    _initPulseAnimations();
    _initCloseAnimations();
    _initDismissAnimations();

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
        parent: closeController,
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

  void _initCloseAnimations() {
    closeController = new AnimationController(
        duration: const Duration(milliseconds: 250),
        vsync: this
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          if (widget.onClose != null) {
            widget.onClose();
          }
        }
      });
  }

  void _animateClose() {
    if (pulseController.isAnimating) {
      pulseController.stop();
    }

    closeTouchTargetRadius = new Tween(
      begin: touchTargetRadius.value,
      end: 0.0,
    ).animate(
      new CurvedAnimation(
        parent: closeController,
        curve: Curves.easeOut,
      ),
    );

    closeTouchTargetOpacity = new Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(
      new CurvedAnimation(
        parent: closeController,
        curve: new Interval(
          0.3,
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );

    closeContentOpacity = new Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(
      new CurvedAnimation(
        parent: closeController,
        curve: new Interval(
          0.0,
          0.4,
          curve: Curves.easeOut,
        ),
      ),
    );

    closeBackgroundRadius = new Tween(
      begin: widget.backgroundRadius,
      end: 0.0,
    ).animate(
      new CurvedAnimation(
        parent: closeController,
        curve: Curves.easeOut,
      ),
    );

    closeBackgroundOpacity = new Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(
      new CurvedAnimation(
        parent: closeController,
        curve: new Interval(
          0.3,
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );

    touchTargetRadius.parent = closeTouchTargetRadius;
    touchTargetOpacity.parent = closeTouchTargetOpacity;
    contentOpacity.parent = closeContentOpacity;
    backgroundRadius.parent = closeBackgroundRadius;
    backgroundOpacity.parent = closeBackgroundOpacity;

    _animateBackgroundToClosedPosition();

    closeController.forward();
  }

  void _initDismissAnimations() {

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
      onTap: () {
        _animateClose();
      },
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
                          child: widget.child,
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

class SerialAnimation extends Animation<double> {

  final AnimationController controller;
  final List<IntervalTween> tweens;

  SerialAnimation({
    @required this.controller,
    @required this.tweens,
  });

  @override
  void addListener(VoidCallback listener) {
    controller.addListener(listener);
  }

  @override
  void addStatusListener(AnimationStatusListener listener) {
    controller.addStatusListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    controller.removeListener(listener);
  }

  @override
  void removeStatusListener(AnimationStatusListener listener) {
    controller.removeStatusListener(listener);
  }

  @override
  AnimationStatus get status => controller.status;

  @override
  get value {
    final time = controller.value;
    for (IntervalTween tween in tweens) {
      if (time <= tween.interval.end) {
        return tween._intervaledTween.evaluate(controller);
      }
    }
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

class IntervalTween {
  final Tween tween;
  final Interval interval;
  final Animatable _intervaledTween;

  IntervalTween({
    @required this.tween,
    @required this.interval,
  }) : _intervaledTween = tween.chain(new CurveTween(curve: interval));
}