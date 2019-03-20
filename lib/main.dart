import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:transparent_image/transparent_image.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radio Guide',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.teal[400],

      ),
      home: MyHomePage(title: 'Home'),
    );
  }
  
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();

  
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List programs = new List();
  var isLoading = false;
  var pagination;

  void fetchPost() async {
    print('Trying to fetch Data');
    String url = 'http://api.sr.se/api/v2/programs?format=json&size=40%E2%80%9C';
    final response = await http.get(url.isNotEmpty ? url : 'http://api.sr.se/api/v2/programs?format=json&size=40%E2%80%9C');
    setState(() {
      isLoading = true;
    });
    if (response.statusCode == 200) {
      var responseJSON = json.decode(response.body);
      List list =responseJSON['programs'];
      setState(() {
        programs.addAll(list);
        pagination = responseJSON['pagination'];
        isLoading = false;
      });
    } else {
      print('Error getting program list: ${response.statusCode}');
    }
    print('PROGRAMS: ${programs}');
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    print('FETCHING POOOOST!!!');
    fetchPost();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: isLoading
    ? Center(
        child: CircularProgressIndicator(),
      )
    : ListView.builder(
        padding: EdgeInsets.only(top: 20.0),
        itemCount: programs.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: EdgeInsets.all(4.0),
            color: Colors.teal[400],
            height: 100,          
            child: ListTile(
              contentPadding: EdgeInsets.all(0.0),
              title: new Text(programs[index]['name'], style: TextStyle(color: Colors.white, fontSize: 20.0, fontFamily: 'TitilliumWeb'),),
              leading: new FadeInImage.assetNetwork(
                placeholder: 'assets/radio_placeholder.png',
                image: programs[index]['programimage'],
                fit: BoxFit.cover,
                height: 80,
                width: 80,
              ),
              onTap: () => {}
            ),
          );
        }),
    );
  }
}

class DetailPage extends StatefulWidget {
  DetailPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _DetailPageState createState() => _DetailPageState();

  
}

class _DetailPageState extends State<DetailPage> {
  List programs = new List();
  var isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(

      ),
    );
  }
}


