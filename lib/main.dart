import 'package:flutter/material.dart';
import 'bike.dart';
import 'package:ride/Theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Ride'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Bike bike = Bike();
  final PageController pageController = PageController(initialPage: 0);
  int _framerate = 500;
  bool _updateScreen = true;

  void updatePage(){
    setState(() {});
  }
//--------------------------------speed card-------------------------------
  Widget speedCard(BuildContext context){
    double max = MediaQuery.of(context).size.height;
    return AspectRatio(aspectRatio: 1,
       child : Container(
         decoration: BoxDecoration(borderRadius: BorderRadius.circular(max * 0.01), boxShadow: [Custom.boxShadow], color: Custom.background),
        margin: EdgeInsets.all(max*0.03),
        padding: EdgeInsets.all(max*0.02),
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Custom.newAutoText(bike.speed_kmh, context, widthScale: 0.6),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                Column(
                  children: [
                    Custom.newAutoText(bike.max_speed_kmh, context, widthScale: 0.25),
                    Custom.newText("Max speed", size: 10, color: Custom.secondary),
                  ],
                ),
                 Column(
                   children: [
                     Custom.newAutoText(bike.max_speed_kmh, context, widthScale: 0.25),
                     Custom.newText("Max speed", size: 10, color: Custom.secondary),
                  ],
                 ),])
          ]),
    ));
  }
  //-------------------------------------position card----------------------------------------------
  Widget positionCard(BuildContext context, String title, String data){
    double max = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(max * 0.01), boxShadow: [Custom.boxShadow], color: Custom.background),
      margin: EdgeInsets.fromLTRB(max*0.03, max*0.02, max*0.03, 0),
      padding: EdgeInsets.all(max*0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Custom.newAutoText(title, context, widthScale: 0.3),
          Custom.newAutoText(data, context, widthScale: 0.4)
        ],
      )
    );
  }
//---------------------------------------Info card----------------------------------------------------------


//---------------------------------build------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    List pos = bike.position;
    return Scaffold(
      backgroundColor: Custom.secondary2,
      body: PageView(
        scrollDirection: Axis.horizontal,
        controller: pageController,
        children: [
          SafeArea(
              child: Column(
                children: [
                  speedCard(context),
                  positionCard(context, "Altitude :", pos[0]),
                  positionCard(context, "Latitude :", pos[1]),
                  positionCard(context, "Longitude :", pos[2]),
                ],
              )
          ),
          Center(
            child: Custom.newText("pos map sos"),
          ),
          Custom.newText("pos map ses"),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
