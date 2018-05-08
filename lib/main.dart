import 'package:flutter/material.dart';
import 'package:overlays/feature_discovery.dart';

void main() => runApp(new MyApp());

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
        leading: new IconButton(
          icon: new Icon(
            Icons.menu,
            key: menuIcon,
          ),
          onPressed: () {
            FeatureDiscovery
              .of(context)
              .highlightFeature(
                featureUiKey: menuIcon,
                targetIcon: Icons.menu,
                color: Colors.green.withOpacity(0.95),
                title: 'Just how you want it',
                description: 'Tap the icon to switch accounts, change settings & more.',
              );
          },
        ),
        title: new Text(''),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(
              Icons.search,
              key: searchIcon,
            ),
            onPressed: () {
              FeatureDiscovery
                .of(context)
                .highlightFeature(
                  featureUiKey: searchIcon,
                  targetIcon: Icons.search,
                  color: Colors.green.withOpacity(0.95),
                  title: 'Search your compounds',
                  description: 'Tap the magnifying glass icon to quickly scan your compounds.',
                );
            },
          )
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        key: fabKey,
        child: new Icon(
          Icons.add,
        ),
        onPressed: () {
          FeatureDiscovery
            .of(context)
            .highlightFeature(
              featureUiKey: fabKey,
              targetIcon: Icons.add,
              color: Colors.blueAccent.withOpacity(0.95),
              title: 'Find the fastest route',
              description: 'Get car, walking, cycling, or public transit directions to this place.',
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
            child: new Container(
              key: contentAreaKey,
              width: 56.0,
              height: 56.0,
              child: new RawMaterialButton(
                shape: new CircleBorder(),
                fillColor: Colors.white,
                child: new Icon(
                  Icons.drive_eta,
                  color: Colors.blue,
                ),
                onPressed: () {
                  FeatureDiscovery
                    .of(context)
                    .highlightFeature(
                      featureUiKey: contentAreaKey,
                      targetIcon: Icons.drive_eta,
                      color: Colors.blueAccent.withOpacity(0.95),
                      title: 'Find the fastest route',
                      description: 'Get car, walking, cycling, or public transit directions to this place.',
                    );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
