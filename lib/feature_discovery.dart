import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:overlays/layouts.dart';

final Logger _log = new Logger('feature_discovery');

/// Material Design Feature Discovery Widget
/// https://material.io/guidelines/growth-communications/feature-discovery.html
///
/// FeatureDiscovery is a root coordinator Widget that activates one or more
/// discoverable features, possibly in order as the user taps on things. Those
/// discoverable features are represented by lower Widgets in the tree like
/// [DescribedDiscoverableFeature] and [PulsingDiscoverableFeature].
class FeatureDiscovery extends StatefulWidget {

  static FeatureDiscoveryController of(BuildContext context) {
    _log.fine('FeatureDiscoveryController: ${context.ancestorStateOfType(new TypeMatcher<_FeatureDiscoveryState>())}');
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
/// When an ancestor FeatureDiscovery Widget sets its active step to
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

  bool showFeatureHighlight = false;
  VoidCallback onActivation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _InheritedFeatureDiscovery featureDiscovery = _InheritedFeatureDiscovery.of(context);
    if (featureDiscovery.activeStep == widget.key) {
      setState(() => showFeatureHighlight = true);
    }
  }

  Widget buildOverlay(BuildContext context) {
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

    final RenderBox anchorBox = context.findRenderObject() as RenderBox;
    final anchorSize = anchorBox.size;
    final anchorPosition = anchorBox.localToGlobal(const Offset(0.0, 0.0));
    final anchorCenter = anchorSize.center(anchorPosition);

    return new _FeatureDiscoveryOverlay(
      targetKey: widget.key,
      anchorCenter: anchorCenter,
      screenSize: MediaQuery.of(context).size,
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

  void onActivationComplete() {
    setState(() => showFeatureHighlight = false);

    _log.fine('Activating the caller\'s desired action.');
    if (null != widget.onPressed) {
      widget.onPressed();
    }

    _log.fine('Activating next step.');
    FeatureDiscovery.of(context).markStepComplete(widget.key);
  }

  void onDismissComplete() {
    setState(() => showFeatureHighlight = false);

    _log.fine('Cancelling remaining steps.');
    FeatureDiscovery.of(context).cancelDiscovery();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayBuilder(
      show: showFeatureHighlight,
      overlayBuilder: (BuildContext overlayContext) {
        return buildOverlay(context);
      },
      child: widget.builder(context, widget.onPressed),
    );
  }
}

typedef Widget DiscoveryBuilder(BuildContext context, VoidCallback onPressed);

class _FeatureDiscoveryOverlay extends StatefulWidget {

  final GlobalKey targetKey;
  final Offset anchorCenter;
  final Size screenSize;
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

  _FeatureDiscoveryOverlay({
    this.targetKey,
    this.anchorCenter,
    this.screenSize,
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

class _FeatureDiscoveryOverlayState extends State<_FeatureDiscoveryOverlay> with TickerProviderStateMixin {

  AnimationController openController;
  AnimationController pulseController;
  AnimationController dismissController;
  AnimationController activationController;

  OverlayViewModel overlayViewModel;
  OverlayConfig overlayConfig;

  @override
  void initState() {
    super.initState();

    _createOverlayConfig();
    _initAnimationControllers();

    _open();
  }

  void _createOverlayConfig() {
    final screenWidth = widget.screenSize.width;
    final isTouchTargetOnRight = widget.anchorCenter.dx > (screenWidth / 2.0);
    final backgroundX = (screenWidth / 2.0) + (isTouchTargetOnRight ? 20.0 : -20.0);
    final isContentAboveTarget = widget.contentPosition == FeatureDiscoveryContentPosition.above;
    final backgroundY = widget.anchorCenter.dy +
        (isContentAboveTarget
            ? -(screenWidth / 2.0) + 40.0
            : (screenWidth / 2.0) - 40.0
        );
    final Offset backgroundCenterStart = widget.anchorCenter;
    final Offset backgroundCenterEnd = widget.backgroundPosition == FeatureDiscoveryBackgroundPosition.centeredAboutTouchTarget
        ? backgroundCenterStart
        : new Offset(backgroundX, backgroundY);

    overlayConfig = new OverlayConfig(
      backgroundCenterStart: backgroundCenterStart,
      backgroundCenterEnd: backgroundCenterEnd,
      openBackgroundRadius: widget.backgroundRadius,
      maxPulseRadius: widget.touchBaseRadius + widget.touchWaveWidth,
      maxPulseOpacity: 0.5,
      openBaseTouchTargetRadius: widget.touchBaseRadius,
      openMaxTouchTargetRadius: widget.touchBaseRadius + widget.touchPulseWidth,
    );
  }

  void _initAnimationControllers() {
    openController = new AnimationController(
        duration: const Duration(milliseconds: 250),
        vsync: this
    )
      ..addListener(() => setState(() {
        overlayViewModel = OverlayViewModel.opening(overlayConfig, openController.value);
      }))
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.forward) {
          setState(() {
            overlayViewModel = OverlayViewModel.opening(overlayConfig, openController.value);
          });
        } else if (status == AnimationStatus.completed) {
          _pulse();
        }
      });

    pulseController = new AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this
    )
      ..addListener(() => setState(() {
        overlayViewModel = OverlayViewModel.pulsing(overlayConfig, pulseController.value);
      }))
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.forward) {
          setState(() {
            overlayViewModel = OverlayViewModel.pulsing(overlayConfig, pulseController.value);
          });
        } else if (status == AnimationStatus.completed) {
          pulseController.forward(from: 0.0);
        }
      });

    activationController = new AnimationController(
        duration: const Duration(milliseconds: 250),
        vsync: this
    )
      ..addListener(() => setState(() {
        overlayViewModel = OverlayViewModel.activating(overlayConfig, activationController.value);
      }))
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.forward) {
          setState(() {
            overlayViewModel = OverlayViewModel.activating(overlayConfig, activationController.value);
          });
        } else if (status == AnimationStatus.completed) {
          if (widget.onActivationComplete != null) {
            widget.onActivationComplete();
          }
        }
      });

    dismissController = new AnimationController(
        duration: const Duration(milliseconds: 250),
        vsync: this
    )
      ..addListener(() => setState(() {
        overlayViewModel = OverlayViewModel.dismissing(overlayConfig, dismissController.value);
      }))
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.forward) {
          setState(() {
            overlayViewModel = OverlayViewModel.dismissing(overlayConfig, dismissController.value);
          });
        } else if (status == AnimationStatus.completed) {
          if (widget.onDismissComplete != null) {
            widget.onDismissComplete();
          }
        }
      });
  }

  void _open() {
    openController.forward();
  }

  void _pulse() {
    pulseController.forward();
  }

  void _activate() {
    if (pulseController.isAnimating) {
      pulseController.stop();
    }

    activationController.forward();
  }

  void _dismiss() {
    if (pulseController.isAnimating) {
      pulseController.stop();
    }

    dismissController.forward();
  }

  Widget _buildBackground(Offset anchorCenter) {
    return new CenteredAbout(
      position: overlayViewModel.backgroundCenter,
      child: _buildBackgroundCircle(overlayViewModel.backgroundRadius),
    );
  }

  Widget _buildBackgroundCircle(double radius) {
    return new Opacity(
      opacity: overlayViewModel.backgroundOpacity,
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

  Widget _buildContentArea(double y) {
    return new Positioned(
      top: y,
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
          child: new Material(
            color: Colors.transparent,
            child: new Container(
              width: MediaQuery.of(context).size.width,
              child: new Padding(
                padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                child: new Opacity(
                  opacity: overlayViewModel.contentOpacity,
                  child: widget.content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTouchTarget(Offset anchorCenter) {
    final buttonRadius = overlayViewModel.touchTargetRadius;
    final buttonOpacity = overlayViewModel.touchTargetOpacity;

    return new CenteredAbout(
      position: anchorCenter,
      child: new Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Touch Target Wave
          new Container(
            width: overlayViewModel.pulseRadius * 2,
            height: overlayViewModel.pulseRadius * 2,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: widget.touchTargetColor.withOpacity(overlayViewModel.pulseOpacity), //widget.touchTargetColor.withOpacity(waveOpacity.value),
            ),
          ),

          // Touch Target
          new Opacity(
            opacity: buttonOpacity,
            child: new Container(
              width: buttonRadius * 2,
              height: buttonRadius * 2,
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                color: widget.touchTargetColor,
              ),
              child: new RawMaterialButton(
                  shape: new CircleBorder(),
                  fillColor: Colors.white,
                  child: widget.child,
                  onPressed: () {
                    _activate();
                  }
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: _dismiss,
      behavior: HitTestBehavior.translucent,
      child: new Stack(
        alignment: Alignment.topLeft,
        fit: StackFit.expand,
        children: <Widget>[
          // Background
          _buildBackground(widget.anchorCenter),

          // Content area
          _buildContentArea(widget.anchorCenter.dy),

          // Touch target and pulse wave,
          _buildTouchTarget(widget.anchorCenter),
        ],
      ),
    );
  }
}

class OverlayConfig {
  final double openBackgroundRadius;
  final Offset backgroundCenterStart;
  final Offset backgroundCenterEnd;
  final double openBaseTouchTargetRadius;
  final double openMaxTouchTargetRadius;
  final double maxPulseRadius;
  final double maxPulseOpacity;

  OverlayConfig({
    this.openBackgroundRadius,
    this.backgroundCenterStart,
    this.backgroundCenterEnd,
    this.openBaseTouchTargetRadius,
    this.openMaxTouchTargetRadius,
    this.maxPulseRadius,
    this.maxPulseOpacity,
  });
}

class OverlayViewModel {

  final Offset backgroundCenter;
  final double backgroundRadius;
  final double backgroundOpacity;
  final double contentOpacity;
  final double touchTargetRadius;
  final double touchTargetOpacity;
  final double pulseRadius;
  final double pulseOpacity;

  static OverlayViewModel opening(OverlayConfig config, double percent) {
    final contentOpacityInterval = new Interval(0.4, 1.0, curve: Curves.easeOut);
    final touchTargetOpacityInterval = new Interval(0.0, 0.3, curve: Curves.easeOut);

    return new OverlayViewModel._internal(
      backgroundCenter: Offset.lerp(config.backgroundCenterStart, config.backgroundCenterEnd, percent),
      backgroundRadius: lerpDouble(0.0, config.openBackgroundRadius, percent),
      backgroundOpacity: 1.0,
      contentOpacity: lerpDouble(0.0, 1.0, contentOpacityInterval.transform(percent)),
      pulseRadius: 0.0,
      pulseOpacity: 0.0,
      touchTargetRadius: lerpDouble(0.0, config.openBaseTouchTargetRadius, percent),
      touchTargetOpacity: lerpDouble(0.0, 1.0, touchTargetOpacityInterval.transform(percent)),
    );
  }

  factory OverlayViewModel.pulsing(OverlayConfig config, double percent) {
    double bouncePercent = 0.0;
    if (percent < 0.3) {
      bouncePercent = percent / 0.3;
    } else if (percent < 0.6) {
      bouncePercent = 1 - ((percent - 0.3) / 0.3);
    }

    double pulseRadius = 0.0;
    double pulseOpacity = 0.0;
    if (percent > 0.3 && percent < 0.7) {
      final pulsePercent = (percent - 0.3) / 0.4;
      pulseRadius = lerpDouble(config.openMaxTouchTargetRadius, config.maxPulseRadius, pulsePercent);
      pulseOpacity = lerpDouble(config.maxPulseOpacity, 0.0, pulsePercent);
    }

    return new OverlayViewModel._internal(
      backgroundCenter: config.backgroundCenterEnd,
      backgroundRadius: config.openBackgroundRadius,
      backgroundOpacity: 1.0,
      contentOpacity: 1.0,
      pulseRadius: pulseRadius,
      pulseOpacity: pulseOpacity,
      touchTargetRadius: lerpDouble(
          config.openBaseTouchTargetRadius,
          config.openMaxTouchTargetRadius,
          bouncePercent
      ),
      touchTargetOpacity: 1.0,
    );
  }

  // TODO: take in previous state to base pulse expansion on that
  factory OverlayViewModel.activating(OverlayConfig config, double percent) {
    final backgroundOpacityInterval = new Interval(0.3, 1.0, curve: Curves.easeOut);
    final contentOpacityInterval = new Interval(0.0, 0.4, curve: Curves.easeOut);
    final touchTargetOpacityInterval = new Interval(0.6, 1.0, curve: Curves.easeOut);

    return new OverlayViewModel._internal(
      backgroundCenter: config.backgroundCenterEnd,
      backgroundRadius: lerpDouble(config.openBackgroundRadius, config.openBackgroundRadius + 40.0, percent),
      backgroundOpacity: lerpDouble(1.0, 0.0, backgroundOpacityInterval.transform(percent)),
      contentOpacity: lerpDouble(1.0, 0.0, contentOpacityInterval.transform(percent)),
      pulseRadius: lerpDouble(config.maxPulseRadius, 0.0, percent),
      pulseOpacity: lerpDouble(config.maxPulseOpacity, 0.0, percent),
      touchTargetRadius: lerpDouble(config.openBaseTouchTargetRadius, 0.0, percent),
      touchTargetOpacity: lerpDouble(1.0, 0.0, touchTargetOpacityInterval.transform(percent)),
    );
  }

  // TODO: take in previous state to base pulse expansion on that
  factory OverlayViewModel.dismissing(OverlayConfig config, double percent) {
    final backgroundOpacityInterval = new Interval(0.3, 1.0, curve: Curves.easeOut);
    final contentOpacityInterval = new Interval(0.0, 0.4, curve: Curves.easeOut);
    final touchTargetOpacityInterval = new Interval(0.3, 1.0, curve: Curves.easeOut);

    return new OverlayViewModel._internal(
      backgroundCenter: Offset.lerp(config.backgroundCenterEnd, config.backgroundCenterStart, percent),
      backgroundRadius: lerpDouble(config.openBackgroundRadius, 0.0, percent),
      backgroundOpacity: lerpDouble(1.0, 0.0, backgroundOpacityInterval.transform(percent)),
      contentOpacity: lerpDouble(1.0, 0.0, contentOpacityInterval.transform(percent)),
      pulseRadius: lerpDouble(config.maxPulseRadius, 0.0, percent),
      pulseOpacity: lerpDouble(config.maxPulseOpacity, 0.0, percent),
      touchTargetRadius: lerpDouble(config.openBaseTouchTargetRadius, 0.0, percent),
      touchTargetOpacity: lerpDouble(1.0, 0.0, touchTargetOpacityInterval.transform(percent)),
    );
  }

  OverlayViewModel._internal({
    this.backgroundCenter,
    this.backgroundRadius,
    this.backgroundOpacity,
    this.contentOpacity,
    this.pulseRadius,
    this.pulseOpacity,
    this.touchTargetRadius,
    this.touchTargetOpacity,
  });
}

enum FeatureDiscoveryContentPosition {
  above,
  below,
}

enum FeatureDiscoveryBackgroundPosition {
  centeredAboutTouchTarget,
  centeredOnScreen,
}