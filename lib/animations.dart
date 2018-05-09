import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:meta/meta.dart';

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

class IntervalTween {
  final Tween tween;
  final Interval interval;
  final Animatable _intervaledTween;

  IntervalTween({
    @required this.tween,
    @required this.interval,
  }) : _intervaledTween = tween.chain(new CurveTween(curve: interval));
}