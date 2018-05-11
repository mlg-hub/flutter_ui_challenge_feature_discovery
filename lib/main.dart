import 'package:flutter/material.dart';
import 'package:overlays/layouts.dart';

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
    return new Scaffold(
      appBar: new AppBar(
        leading: new DescribedFeatureOverlay(
          showOverlay: true,
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
          new DescribedFeatureOverlay(
            showOverlay: false,
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
      floatingActionButton: new DescribedFeatureOverlay(
        showOverlay: false,
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
                  // TODO:
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
            child: new DescribedFeatureOverlay(
              showOverlay: false,
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

class DescribedFeatureOverlay extends StatefulWidget {

  final bool showOverlay;
  final IconData icon;
  final Color color;
  final Widget child;

  DescribedFeatureOverlay({
    this.showOverlay = false,
    this.icon,
    this.color,
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

    return new Stack(
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
                // TODO: activate
              },
            ),
          ),
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

enum DescribedFeatureContentOrientation {
  above,
  below,
}