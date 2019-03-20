import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  TrackingScrollController scrollController =TrackingScrollController();

  void fetchData(url) async {
    setState(() {
      isLoading = true;
    });
    print('Trying to fetch Data');
    //String url = 'http://api.sr.se/api/v2/programs?format=json&size=40%E2%80%9C';
    final response = await http.get(url.isNotEmpty ? url : 'http://api.sr.se/api/v2/programs?format=json&size=40%E2%80%9C');
    if (response.statusCode == 200) {
      var responseJSON = json.decode(response.body);
      List list = responseJSON['programs'];
      setState(() {
        programs.addAll(list);
        pagination = responseJSON['pagination'];
        isLoading = false;
      });
    } else {
      print('Error getting program list: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
    print('PROGRAMS: ${programs}');
  }

  onScroll() {
    double height = MediaQuery.of(context).size.height;
    //100 is the height of 1 listItem
    var itemsPerPage = height / 100;
    print('They see me scrollin.. ${scrollController.offset}, programs: ${programs.length}');
    if (scrollController.offset >= (programs.length - itemsPerPage) * 100 && !isLoading) {
      //Start loading new items when the user scrolled to the second to last page.
      print('Gonna fetch new shit now');
      fetchData(pagination['nextpage']);
    }
  }

  @override
  void initState() {
    super.initState();
    print('FETCHING PROGRAMS!');
    fetchData('');
    scrollController.addListener(onScroll);
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: ListView.builder(
        padding: EdgeInsets.only(top: 20.0),
        itemCount: programs.length,
        controller: scrollController,
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


