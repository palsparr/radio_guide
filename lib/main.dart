import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

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
        title: Text(widget.title, style: TextStyle(fontFamily: 'TitilliumWeb')),
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
              onTap: () => {
                Navigator.of(context).push(new MaterialPageRoute(builder: 
                   (BuildContext context) => new DetailPage(program: programs[index])))
              }
            ),
          );
        }),
    );
  }
}

class DetailPage extends StatefulWidget {
  DetailPage({Key key, this.program}) : super(key: key);
  //Data for the program that the user clicked on
  final program;

  @override
  _DetailPageState createState() => _DetailPageState();

  
}

class _DetailPageState extends State<DetailPage> {
  var program;
  //URLs for social media platforms. Empty if the platform is unavailable
  var twitter = '';
  var instagram = '';
  var facebook = '';

  @override
  void initState() {
    super.initState();
    print('Program: ${widget.program}');
    program = widget.program;
    findSocialMediaPlatforms();
  }
  //Find what social media platforms are available for the program and save the url
  findSocialMediaPlatforms() {
    var socialMediaPlatforms = program['socialmediaplatforms'];
    for (int i = 0; i < socialMediaPlatforms.length; i++) {
      var platform = socialMediaPlatforms[i];
      switch (platform['platform']) {
        case 'Twitter':
          twitter = platform['platformurl'];
          break;
        case 'Facebook':
          facebook = platform['platformurl'];
          break;
        case 'Instagram':
          instagram = platform['platformurl'];
          break;        
        default:
      }
    }
  }
  //Redirect to social media through clicking on the corresponding logo
  launchUrl(url) async {
    if (await canLaunch(url)) {
    await launch(url);
    } else {
      throw 'Could not reach $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    
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
        title: Text(program['name'], style: TextStyle(fontFamily: 'TitilliumWeb'),),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              new FadeInImage.assetNetwork(
                placeholder: 'assets/radio_placeholder_large.png',
                image: program['programimage'],
                fit: BoxFit.cover,
                height: width,
                width: width,
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                child: Text(program['description'], style: TextStyle(fontFamily: 'TitilliumWeb', fontSize: 22.0, color: Colors.white, ), textAlign: TextAlign.center,),
              ),
              Container(
                padding: EdgeInsets.all(5.0),
                child: Text('Editor: ${program['responsibleeditor']}', style: TextStyle(fontFamily: 'TitilliumWeb', fontSize: 14.0, color: Colors.white, fontStyle: FontStyle.italic ), textAlign: TextAlign.center,),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //Twitter logo
                  twitter.isNotEmpty ? Container(
                    padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                    child: GestureDetector(
                      onTap: () => {launchUrl(twitter)},
                      child: Image(
                        image: AssetImage('assets/twitter_logo.png'),                    
                        fit: BoxFit.cover,
                        height: 60.0,
                        width: 60.0,
                      ),
                    ),
                    
                  ) : Container(),
                  //Instagram logo
                  instagram.isNotEmpty ? Container(
                    padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                    child: GestureDetector(
                      onTap: () => {launchUrl(instagram)},
                      child: Image(
                        image: AssetImage('assets/instagram_logo.png'),                    
                        fit: BoxFit.cover,
                        height: 60.0,
                        width: 60.0,
                      ),
                    ),
                  ) : Container(),
                  //Facebook logo
                  facebook.isNotEmpty ? Container(
                    padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                    child: GestureDetector(
                      onTap: () => {launchUrl(facebook)},
                      child: Image(
                        image: AssetImage('assets/facebook_logo.png'),                    
                        fit: BoxFit.cover,
                        height: 60.0,
                        width: 60.0,
                      ),
                    ),
                  ) : Container(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


