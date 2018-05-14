import 'package:flutter/material.dart';
import 'package:overlays/layout.dart';

void main() => runApp(new MyApp());

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
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.green,
        leading: new DescribedFeatureOverlay(
          showOverlay: false,
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
            showOverlay: false,
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
        showOverlay: false,
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
                    // TODO: do feature discovery.
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
                showOverlay: true,
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

class DescribedFeatureOverlay extends StatefulWidget {
  final bool showOverlay;
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final Widget child;

  DescribedFeatureOverlay({
    this.showOverlay,
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    screenSize = MediaQuery.of(context).size;
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

  @override
  Widget build(BuildContext context) {
    return new AnchoredOverlay(
      showOverlay: widget.showOverlay,
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
                  onPressed: () {
                    // TODO:
                  },
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
