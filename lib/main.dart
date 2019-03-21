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
        //Setting colors for the app
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.teal[400],

      ),
      //Seting the home page of the app
      home: MyHomePage(title: 'Home'),
    );
  }
  
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);


  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();

  
}

class _MyHomePageState extends State<MyHomePage> {
  List programs = new List();
  var isLoading = false;
  var pagination;
  TrackingScrollController scrollController =TrackingScrollController();

  void fetchData(url) async {
    //Setting isLoading to true to prevent the app from trying to load the same data several times as a result of scrolling
    setState(() {
      isLoading = true;
    });
    print('Trying to fetch programs');
    final response = await http.get(url.isNotEmpty ? url : 'http://api.sr.se/api/v2/programs?format=json&size=40%E2%80%9C');
    if (response.statusCode == 200) {
      var responseJSON = json.decode(response.body);
      List list = responseJSON['programs'];
      //Update the programs list and setting isLoading to false
      setState(() {
        programs.addAll(list);
        pagination = responseJSON['pagination'];
        isLoading = false;
      });
    } else {
      print('Error getting program list: ${response.statusCode}');
      //Not updating programs since an error occurred. Still setting isLoading to false since app is not loading anymore
      setState(() {
        isLoading = false;
      });
    }
    print('PROGRAMS: ${programs}');
  }

  onScroll() {
    //Get screen height
    double height = MediaQuery.of(context).size.height;
    //Calculate items per screen to find out when to load new programs. 100 is the height of one item in the list
    var itemsPerPage = height / 100;
    print('They see me scrollin.. ${scrollController.offset}, programs: ${programs.length}');
    if (scrollController.offset >= (programs.length - itemsPerPage) * 100 && !isLoading) {
      //Start loading new items when the user scrolled to the second to last page. 
      //The URL provided in the argument is from the pagination data of the last fetchData() call.
      //Only load new items if the app isn't already loading. (isLoading = false)
      fetchData(pagination['nextpage']);
    }
  }

  @override
  void initState() {
    super.initState();
    //Fetch first page of programs. Argument is '' to ensure that fetchData() uses the default URL.
    fetchData('');
    scrollController.addListener(onScroll);
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(fontFamily: 'TitilliumWeb')),
      ),
      body: ListView.builder(
        padding: EdgeInsets.only(top: 20.0),
        itemCount: programs.length,
        //Custom scroll controller to enable pagination
        controller: scrollController,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: EdgeInsets.all(4.0),
            color: Colors.teal[400],
            height: 100,          
            child: ListTile(
              contentPadding: EdgeInsets.all(0.0),
              title: new Text(programs[index]['name'], style: TextStyle(color: Colors.white, fontSize: 20.0, fontFamily: 'TitilliumWeb'),),
              //Using placeholder in case of slow internet speed
              leading: new FadeInImage.assetNetwork(
                placeholder: 'assets/radio_placeholder.png',
                image: programs[index]['programimage'],
                fit: BoxFit.cover,
                height: 80,
                width: 80,
              ),
              onTap: () => {
                //Navigate to detail page of the program
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
  //Redirect to social media after the user clicks on the corresponding logo
  launchUrl(url) async {
    if (await canLaunch(url)) {
    await launch(url);
    } else {
      throw 'Could not reach $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    //Getting the screen size for later use, placed in the build method to get correct values even if the screen orientation changes.
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(program['name'], style: TextStyle(fontFamily: 'TitilliumWeb'),),
      ),
      //Making the page scrollable to accomodate smaller screen devices
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              //Using a placeholder while the image loads in case of slow internet speed
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
              //Social Media Links
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //Twitter logo only show if platform is available
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
                  //Instagram logo only show if platform is available
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
                  //Facebook logo only show if platform is available
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


