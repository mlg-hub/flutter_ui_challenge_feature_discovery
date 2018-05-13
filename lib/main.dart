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
        leading: new IconButton(
          icon: new Icon(
            Icons.menu,
          ),
          onPressed: () {
            // TODO:
          },
        ),
        title: new Text(''),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(
              Icons.search,
            ),
            onPressed: () {
              // TODO:
            },
          ),
        ],
      ),
      body: new Content(),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(
          Icons.add,
        ),
        onPressed: () {
          // TODO:
        },
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
            )),
      ],
    );
  }
}
