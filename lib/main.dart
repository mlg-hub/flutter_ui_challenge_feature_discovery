import 'package:flutter/material.dart';

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
    return new OverlayBuilder(
      showOverlay: true,
      overlayBuilder: (BuildContext context) {
        return new CenterAbout(
          position: const Offset(250.0, 450.0),
          child: new Container(
            width: 50.0,
            height: 50.0,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
          ),
        );
      },
      child: new Scaffold(
        appBar: new AppBar(
          leading: new IconButton(
            icon: new Icon(
              Icons.menu,
            ),
            onPressed: () {
              // TODO:
            }
          ),
          title: new Text(''),
          actions: <Widget>[
            new IconButton(
                icon: new Icon(
                  Icons.search,
                ),
                onPressed: () {
                  // TODO:
                }
            ),
          ],
        ),
        body: new Content(),
        floatingActionButton: new AnchoredOverlay(
          showOverlay: true,
          overlayBuilder: (BuildContext context, Offset anchor) {
            return new CenterAbout(
              position: anchor,
              child: new Text('HELLO?'),
            );
          },
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
      ],
    );
  }
}

class OverlayBuilder extends StatefulWidget {

  final bool showOverlay;
  final Widget Function(BuildContext) overlayBuilder;
  final Widget child;

  OverlayBuilder({
    this.showOverlay = false,
    this.overlayBuilder,
    this.child,
  });

  @override
  _OverlayBuilderState createState() => new _OverlayBuilderState();
}

class _OverlayBuilderState extends State<OverlayBuilder> {

  OverlayEntry overlayEntry;

  @override
  void initState() {
    super.initState();

    if (widget.showOverlay) {
      showOverlay();
    }
  }

  @override
  void didUpdateWidget(OverlayBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncWidgetAndOverlay();
  }


  @override
  void reassemble() {
    super.reassemble();
    syncWidgetAndOverlay();
  }

  @override
  void dispose() {
    if (isShowingOverlay()) {
      hideOverlay();
    }

    super.dispose();
  }

  bool isShowingOverlay() => overlayEntry != null;

  void showOverlay() {
    overlayEntry = new OverlayEntry(
      builder: widget.overlayBuilder,
    );
    addToOverlay(overlayEntry);
  }

  void addToOverlay(OverlayEntry entry) async {
    Overlay.of(context).insert(entry);
  }

  void hideOverlay() {
    overlayEntry.remove();
    overlayEntry = null;
  }

  void syncWidgetAndOverlay() {
    if (isShowingOverlay() && !widget.showOverlay) {
      hideOverlay();
    } else if (!isShowingOverlay() && widget.showOverlay) {
      showOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

}


class CenterAbout extends StatelessWidget {

  final Offset position;
  final Widget child;

  CenterAbout({
    this.position,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return new Positioned(
      left: position.dx,
      top: position.dy,
      child: new FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: child,
      ),
    );
  }
}

class AnchoredOverlay extends StatelessWidget {

  final bool showOverlay;
  final Widget Function(BuildContext, Offset anchor) overlayBuilder;
  final Widget child;

  AnchoredOverlay({
    this.showOverlay = false,
    this.overlayBuilder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return new OverlayBuilder(
            showOverlay: showOverlay,

            overlayBuilder: (BuildContext overlayContext) {
              RenderBox box = context.findRenderObject() as RenderBox;
              final center = box.size.center(box.localToGlobal(const Offset(0.0, 0.0)));

              return overlayBuilder(overlayContext, center);
            },

            child: child,
          );
        },
      ),
    );
  }
}
