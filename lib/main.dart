import 'package:flutter/material.dart';
import 'package:overlays/layouts.dart';

final String feature1 = "FEATURE 1";
final String feature2 = "FEATURE 2";
final String feature3 = "FEATURE 3";
final String feature4 = "FEATURE 4";

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Overlays',
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
          leading: new DiscoverableFeature(
            featureId: feature1,
            icon: Icons.menu,
            color: Colors.red,
            child: new IconButton(
              icon: new Icon(
                Icons.menu,
              ),
              onPressed: () {
                // TODO:
              }
            ),
          ),
          title: new Text(''),
          actions: <Widget>[
            new DiscoverableFeature(
              featureId: feature2,
              icon: Icons.search,
              color: Colors.green,
              child: new IconButton(
                  icon: new Icon(
                    Icons.search,
                  ),
                  onPressed: () {
                    // TODO:
                  }
              ),
            ),
          ],
        ),
        body: new Content(),
        floatingActionButton: new DiscoverableFeature(
          featureId: feature3,
          icon: Icons.add,
          color: Colors.blue,
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
            // Header photo
            new Image.network(
              'https://www.balboaisland.com/wp-content/uploads/Starbucks-Balboa-Island-01.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200.0,
            ),

            // About the business
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
              ),
            ),

            // Button to start feature discovery
            new Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: new RaisedButton(
                child: new Text('Do Feature Discovery'),
                onPressed: () {
                  FeatureDiscovery.discoverFeatures(
                    context,
                    [
                      feature1,
                      feature2,
                      feature3,
                      feature4,
                    ],
                  );
                },
              ),
            )
          ],
        ),

        new Positioned(
          top: 200.0,
          right: 0.0,
          child: new FractionalTranslation(
            translation: const Offset(-0.5, -0.5),
            child: new DiscoverableFeature(
              featureId: feature4,
              icon: Icons.drive_eta,
              color: Colors.blue,
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
          ),
        ),
      ],
    );
  }
}

class FeatureDiscovery extends StatefulWidget {

  static String of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(
        _InheritedFeatureDiscovery) as _InheritedFeatureDiscovery).activeStepId;
  }

  static void discoverFeatures(BuildContext context, List<String> steps) {
    _FeatureDiscoveryState state = context.ancestorStateOfType(
        new TypeMatcher<_FeatureDiscoveryState>()
    ) as _FeatureDiscoveryState;

    state.discoverFeatures(steps);
  }

  static void markStepComplete(BuildContext context, String stepId) {
    _FeatureDiscoveryState state = context.ancestorStateOfType(
        new TypeMatcher<_FeatureDiscoveryState>()
    ) as _FeatureDiscoveryState;

    state.markStepComplete(stepId);
  }

  static void dismiss(BuildContext context) {
    _FeatureDiscoveryState state = context.ancestorStateOfType(
        new TypeMatcher<_FeatureDiscoveryState>()
    ) as _FeatureDiscoveryState;

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
  final Widget child;

  DiscoverableFeature({
    this.featureId,
    this.icon,
    this.color,
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
      onActivated: () {
        FeatureDiscovery.markStepComplete(context, widget.featureId);
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
  final VoidCallback onActivated;
  final VoidCallback onDismissed;
  final Widget child;

  DescribedFeatureOverlay({
    this.showOverlay = false,
    this.icon,
    this.color,
    this.onActivated,
    this.onDismissed,
    this.child,
  });

  @override
  _DescribedFeatureOverlayState createState() => new _DescribedFeatureOverlayState();
}

class _DescribedFeatureOverlayState extends State<DescribedFeatureOverlay> {

  Size screenSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
  }

  bool isCloseToTopOrBottom(Offset anchor) {
    return anchor.dy <= 88.0 || (screenSize.height - anchor.dy) <= 88.0;
  }

  bool isOnTopHalfOfScreen(Offset anchor) {
    return anchor.dy < (screenSize.height / 2.0);
  }

  bool isOnLeftHalfOfScreen(Offset anchor) {
    return anchor.dx < (screenSize.width / 2.0);
  }

  DescribedFeatureContentOrientation getContentOrientation(Offset anchor) {
    if (isCloseToTopOrBottom(anchor)) {
      // If we're close to the top or bottom then we want the content
      // of the overlay to be towards the center of the screen.
      if (isOnTopHalfOfScreen(anchor)) {
        return DescribedFeatureContentOrientation.below;
      } else {
        return DescribedFeatureContentOrientation.above;
      }
    } else {
      // If we're not close to the top or bottom then we want the content
      // of the overlay to sit between our anchor and the closest side
      // of the screen (top or bottom)
      if (isOnTopHalfOfScreen(anchor)) {
        return DescribedFeatureContentOrientation.above;
      } else {
        return DescribedFeatureContentOrientation.below;
      }
    }
  }

  Widget buildOverlay(Offset anchor) {
    final isBackgroundCentered = isCloseToTopOrBottom(anchor);
    final contentOrientation = getContentOrientation(anchor);
    final touchTargetRadius = 44.0;
    final touchTargetToContentPadding = 20.0;
    final contentOffsetMultiplier = contentOrientation == DescribedFeatureContentOrientation.below ? 1.0 : -1.0;
    final contentY = anchor.dy + contentOffsetMultiplier * (touchTargetRadius + touchTargetToContentPadding);
    final contentFractionalOffset = contentOffsetMultiplier >= 0.0 ? 0.0 : -1.0;

    final backgroundPosition = isBackgroundCentered
        ? anchor
        : new Offset(
            screenSize.width / 2.0 + (isOnLeftHalfOfScreen(anchor) ? -20.0 : 20.0),
            anchor.dy + (isOnTopHalfOfScreen(anchor)
                ? -(screenSize.width / 2.0) + 40.0
                : (screenSize.width / 2.0) - 40.0
            ),
          );
    final backgroundRadius = MediaQuery.of(context).size.width * 2 * (isBackgroundCentered ? 1.0 : 0.75);

    return new GestureDetector(
      onTap: () {
        if (widget.onDismissed != null) {
          widget.onDismissed();
        }
      },
      child: new Container(
        color: Colors.transparent,
        child: new Stack(
          children: <Widget>[
            // Background
            new CenterAbout(
              position: backgroundPosition,
              child: new Container(
                width: backgroundRadius,
                height: backgroundRadius,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                ),
              ),
            ),

            // Content
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
                        new Text(
                          'This is a title',
                          style: new TextStyle(
                            fontSize: 24.0,
                            color: Colors.white,
                          ),
                        ),
                        new Text(
                          'This is a sentence.',
                          style: new TextStyle(
                            fontSize: 18.0,
                            color: Colors.white.withOpacity(0.9),
                          )
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Touch Target
            new CenterAbout(
              position: anchor,
              child: new Container(
                width: 88.0,
                height: 88.0,
                child: new RawMaterialButton(
                  fillColor: Colors.white,
                  shape: new CircleBorder(),
                  child: new Icon(
                    widget.icon,
                    color: widget.color,
                  ),
                  onPressed: () {
                    if (null != widget.onActivated) {
                      widget.onActivated();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
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

enum DescribedFeatureContentOrientation {
  above,
  below,
}