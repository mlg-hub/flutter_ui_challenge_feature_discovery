import 'package:flutter/material.dart';
import 'package:overlays/feature_discovery.dart';
import 'package:logging/logging.dart';
import 'package:overlays/layouts.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Overlays',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new FeatureDiscovery(
        child: new MyHomePage()
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

final GlobalKey menuIcon = new GlobalKey(debugLabel: 'menu_icon');
final GlobalKey searchIcon = new GlobalKey(debugLabel: 'search_icon');
final GlobalKey fabKey = new GlobalKey(debugLabel: 'fab');
final GlobalKey contentAreaKey = new GlobalKey(debugLabel: 'content_area');

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: new DescribedDiscoverableFeature(
          key: menuIcon,
          icon: Icons.menu,
          title: 'Just how you want it',
          description: 'Tap the icon to switch accounts, change settings & more.',
          color: Colors.green.withOpacity(0.95),
          onPressed: () {
            // TODO:
          },
          builder: (BuildContext context, VoidCallback onPressed) {
            return new IconButton(
              icon: new Icon(
                Icons.menu,
              ),
              onPressed: onPressed,
            );
          },
        ),
        title: new Text(''),
        actions: <Widget>[
          new DescribedDiscoverableFeature(
            key: searchIcon,
            icon: Icons.search,
            title: 'Search your compounds',
            description: 'Tap the magnifying glass icon to quickly scan your compounds.',
            color: Colors.green.withOpacity(0.95),
            onPressed: () {
              // TODO:
            },
            builder: (BuildContext context, VoidCallback onPressed) {
              return new IconButton(
                icon: new Icon(
                  Icons.search,
                ),
                onPressed: onPressed,
              );
            },
          )
        ],
      ),
      floatingActionButton: new DescribedDiscoverableFeature(
        key: fabKey,
        icon: Icons.add,
        title: 'Find the fastest route',
        description: 'Get car, walking, cycling, or public transit directions to this place.',
        color: Colors.blue.withOpacity(0.95),
        onPressed: () {
          // TODO:
        },
        builder: (BuildContext context, VoidCallback onPressed) {
          return new FloatingActionButton(
            child: new Icon(
              Icons.add,
            ),
            onPressed: onPressed,
          );
        },
      ),
      body: new Stack(
        fit: StackFit.expand,
        children: <Widget>[
          new Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              new Container(
                color: Colors.black,
                child: new Image.network(
                  'https://www.balboaisland.com/wp-content/uploads/Starbucks-Balboa-Island-01.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200.0,
                ),
              ),
              new Container(
                width: double.infinity,
                color: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
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
                )
              ),
              new Container(
                width: double.infinity,
                child: new Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new RaisedButton(
                    child: new Text(
                      'Discover Features!',
                    ),
                    onPressed: () {
                      // Start the feature discovery flow.
                      FeatureDiscovery
                        .of(context)
                        .discoverFeatures([
                          menuIcon,
                          searchIcon,
                          fabKey,
                          contentAreaKey,
                        ]);
                    },
                  ),
                ),
              ),
              new Expanded(
                child: Container(
                  color: const Color(0xFFEEEEEE),
                ),
              ),
            ],
          ),

          new Positioned(
            right: 25.0,
            top: 200.0 - (56.0 / 2.0),
            child: new DescribedDiscoverableFeature(
              key: contentAreaKey,
              icon: Icons.drive_eta,
              title: 'Find the fastest route',
              description: 'Get car, walking, cycling or public transit directions to this place.',
              color: Colors.blue,
              onPressed: () {
                // TODO:
              },
              builder: (BuildContext context, VoidCallback onPressed) {
                return new Container(
                  width: 56.0,
                  height: 56.0,
                  child: new RawMaterialButton(
                    shape: new CircleBorder(),
                    fillColor: Colors.white,
                    child: new Icon(
                      Icons.drive_eta,
                      color: Colors.blue,
                    ),
                    onPressed: onPressed,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
