import 'package:flutter/material.dart';
import 'package:overlays/layout.dart';

void main() => runApp(new MyApp());

final feature1 = "FEATURE_1";
final feature2 = "FEATURE_2";
final feature3 = "FEATURE_3";
final feature4 = "FEATURE_4";

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Feature Discovery',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return new FeatureDiscovery(
      child: new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.green,
          leading: new DescribedFeatureOverlay(
            featureId: feature1,
            icon: Icons.menu,
            color: Colors.green,
            title: 'The Title',
            description: 'The Description',
            child: new IconButton(
              icon: new Icon(
                Icons.menu,
              ),
              onPressed: () {
                // TODO:
              },
            ),
          ),
          title: new Text(''),
          actions: <Widget>[
            new DescribedFeatureOverlay(
              featureId: feature2,
              icon: Icons.search,
              color: Colors.green,
              title: 'The Title',
              description: 'The Description',
              child: new IconButton(
                icon: new Icon(
                  Icons.search,
                ),
                onPressed: () {
                  // TODO:
                },
              ),
            ),
          ],
        ),
        body: new Content(),
        floatingActionButton: new DescribedFeatureOverlay(
          featureId: feature3,
          icon: Icons.add,
          color: Colors.blue,
          title: 'The Title',
          description: 'The Description',
          child: new FloatingActionButton(
            child: new Icon(
              Icons.add,
            ),
            onPressed: () {
              // TODO:
            },
          ),
        ),
      ),
    );
  }
}

class Content extends StatefulWidget {
  @override
  _ContentState createState() => new _ContentState();
}

class _ContentState extends State<Content> {
  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        new Column(
          children: <Widget>[
            new Image.network(
              'https://www.balboaisland.com/wp-content/uploads/Starbucks-Balboa-Island-01.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200.0,
            ),
            new Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                color: Colors.blue,
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: new Text(
                        'Starbucks Coffee',
                        style: new TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                        ),
                      ),
                    ),
                    new Text(
                      'Coffee Shop',
                      style: new TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                )),
            new Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: new RaisedButton(
                  child: new Text('Do Feature Discovery'),
                  onPressed: () {
                    FeatureDiscovery
                        .discoverFeatures(context, [feature1, feature2, feature3, feature4]);
                  },
                )),
          ],
        ),
        new Positioned(
            top: 200.0,
            right: 0.0,
            child: new FractionalTranslation(
              translation: const Offset(-0.5, -0.5),
              child: new DescribedFeatureOverlay(
                featureId: feature4,
                icon: Icons.drive_eta,
                color: Colors.blue,
                title: 'The Title',
                description: 'The Description',
                child: new FloatingActionButton(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  child: new Icon(
                    Icons.drive_eta,
                  ),
                  onPressed: () {
                    // TODO:
                  },
                ),
              ),
            )),
      ],
    );
  }
}

class FeatureDiscovery extends StatefulWidget {
  static String activeStep(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedFeatureDiscovery)
            as _InheritedFeatureDiscovery)
        .activeStepId;
  }

  static void discoverFeatures(BuildContext context, List<String> steps) {
    _FeatureDiscoveryState state = context
        .ancestorStateOfType(new TypeMatcher<_FeatureDiscoveryState>()) as _FeatureDiscoveryState;

    state.discoverFeatures(steps);
  }

  static void markStepComplete(BuildContext context, String stepId) {
    _FeatureDiscoveryState state = context
        .ancestorStateOfType(new TypeMatcher<_FeatureDiscoveryState>()) as _FeatureDiscoveryState;

    state.markStepComplete(stepId);
  }

  static void dismiss(BuildContext context) {
    _FeatureDiscoveryState state = context
        .ancestorStateOfType(new TypeMatcher<_FeatureDiscoveryState>()) as _FeatureDiscoveryState;

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

class DescribedFeatureOverlay extends StatefulWidget {
  final String featureId;
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final Widget child;

  DescribedFeatureOverlay({
    this.featureId,
    this.icon,
    this.color,
    this.title,
    this.description,
    this.child,
  });

  @override
  _DescribedFeatureOverlayState createState() => new _DescribedFeatureOverlayState();
}

class _DescribedFeatureOverlayState extends State<DescribedFeatureOverlay> {
  Size screenSize;
  bool showOverlay = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    screenSize = MediaQuery.of(context).size;

    showOverlayIfActiveStep();
  }

  void showOverlayIfActiveStep() {
    String activeStep = FeatureDiscovery.activeStep(context);
    setState(() => showOverlay = activeStep == widget.featureId);
  }

  bool isCloseToTopOrBottom(Offset position) {
    return position.dy <= 88.0 || (screenSize.height - position.dy) <= 88.0;
  }

  bool isOnTopHalfOfScreen(Offset position) {
    return position.dy < (screenSize.height / 2.0);
  }

  bool isOnLeftHalfOfScreen(Offset position) {
    return position.dx < (screenSize.width / 2.0);
  }

  DescribedFeatureContentOrientation getContentOrientation(Offset position) {
    if (isCloseToTopOrBottom(position)) {
      if (isOnTopHalfOfScreen(position)) {
        return DescribedFeatureContentOrientation.below;
      } else {
        return DescribedFeatureContentOrientation.above;
      }
    } else {
      if (isOnTopHalfOfScreen(position)) {
        return DescribedFeatureContentOrientation.above;
      } else {
        return DescribedFeatureContentOrientation.below;
      }
    }
  }

  void activate() {
    FeatureDiscovery.markStepComplete(context, widget.featureId);
  }

  void dismiss() {
    FeatureDiscovery.dismiss(context);
  }

  @override
  Widget build(BuildContext context) {
    return new AnchoredOverlay(
      showOverlay: showOverlay,
      overlayBuilder: (BuildContext context, Offset anchor) {
        final touchTargetRadius = 44.0;
        final contentOrientation = getContentOrientation(anchor);
        final contentOffsetMultiplier =
            contentOrientation == DescribedFeatureContentOrientation.below ? 1.0 : -1.0;
        final contentY = anchor.dy + (contentOffsetMultiplier * (touchTargetRadius + 20.0));
        final contentFractionalOffset = contentOffsetMultiplier.clamp(-1.0, 0.0);

        final isBackgroundCentered = isCloseToTopOrBottom(anchor);
        final backgroundRadius = screenSize.width * (isBackgroundCentered ? 1.0 : 0.75);
        final backgroundPosition = isBackgroundCentered
            ? anchor
            : new Offset(
                screenSize.width / 2.0 + (isOnLeftHalfOfScreen(anchor) ? -20.0 : 20.0),
                anchor.dy +
                    (isOnTopHalfOfScreen(anchor)
                        ? -(screenSize.width / 2.0) + 40.0
                        : (screenSize.width / 2.0) - 40.0));

        return new Stack(
          children: <Widget>[
            new GestureDetector(
              onTap: dismiss,
              child: new Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
              ),
            ),
            new CenterAbout(
              position: backgroundPosition,
              child: new Container(
                width: 2 * backgroundRadius,
                height: 2 * backgroundRadius,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(0.96),
                ),
              ),
            ),
            new Positioned(
                top: contentY,
                child: new FractionalTranslation(
                  translation: new Offset(0.0, contentFractionalOffset),
                  child: new Material(
                      color: Colors.transparent,
                      child: new Padding(
                          padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
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
                                  fontSize: 18.0,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ))),
                )),
            new CenterAbout(
              position: anchor,
              child: new Container(
                width: 2 * touchTargetRadius,
                height: 2 * touchTargetRadius,
                child: new RawMaterialButton(
                  shape: new CircleBorder(),
                  fillColor: Colors.white,
                  child: new Icon(
                    widget.icon,
                    color: widget.color,
                  ),
                  onPressed: activate,
                ),
              ),
            ),
          ],
        );
      },
      child: widget.child,
    );
  }
}

enum DescribedFeatureContentOrientation {
  above,
  below,
}
