import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bike.dart';
import 'package:ride/uiHelper.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ride',
      theme: ThemeData(
        primarySwatch: Custom.toMaterialColor(Custom.white),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Bike bike = Bike();
  SharedPreferences? keyStorage;
  bool preferencesLoaded = false;
  bool wakelockEnabled = true;

  MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PageController pageController = PageController(initialPage: 0);

  Future<void> loadPreferences() async{
    widget.keyStorage = await SharedPreferences.getInstance();
    //loading preferences
    String? value = await widget.keyStorage?.getString("theme");
    if(value != null)Custom.theme = value;
    value = await widget.keyStorage?.getString("accuracy");
    if(value != null)widget.bike.accuracy = value;
    bool? flag = await widget.keyStorage?.getBool("wakelock");
    if(flag != null){
      widget.wakelockEnabled = flag;
      Wakelock.toggle(enable: flag);
    }else{
      widget.wakelockEnabled = true;
      Wakelock.enable();
    }

    widget.preferencesLoaded = true;
    updatePage();
  }

  void updatePage(){
    setState(() {});
  }

  Future<void> launchHyperlink(String url) async{
    print("launch");
    print(await canLaunch(url));
    if (await canLaunch(url)) {await launch(url, forceSafariVC: false,);}
  }

//--------------------------------speed card-------------------------------
  Widget speedCard(BuildContext context){
    double max = MediaQuery.of(context).size.height;
    return AspectRatio(aspectRatio: 1,
       child : Container(
         decoration: BoxDecoration(borderRadius: BorderRadius.circular(max * 0.01), boxShadow: [Custom.boxShadow], color: Custom.background),
         margin: EdgeInsets.fromLTRB(max*0.03, max*0.015, max*0.03, 0),
        padding: EdgeInsets.all(max*0.01),
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Custom.newAutoText(widget.bike.speed_kmh, context, widthScale: 0.5),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                Column(
                  children: [
                    Custom.newAutoText(widget.bike.max_speed_kmh, context, widthScale: 0.25),
                    Text("Max speed", style: TextStyle(fontSize: 10, color: Custom.secondary), textAlign: TextAlign.justify),
                  ],
                ),
                 Column(
                   children: [
                     Custom.newAutoText(widget.bike.avg_speed_kmh, context, widthScale: 0.25),
                     Text("Average speed", style: TextStyle(fontSize: 10, color: Custom.secondary), textAlign: TextAlign.justify),
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
      margin: EdgeInsets.fromLTRB(max*0.03, max*0.015, max*0.03, 0),
      padding: EdgeInsets.all(max*0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: max*0.03, color: Custom.foreground),),
          Text(data, style: TextStyle(fontSize: max*0.03, color: Custom.foreground),),
        ],
      )
    );
  }
  //----------------------------------------bike icon------------------------------------------------------
  Widget infoIcon(BuildContext context, IconData icon, String text){
    double max = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.all(max*0.02),
      margin: EdgeInsets.fromLTRB(max*0.03, max*0.01, max*0.03, 0),
      width: double.infinity,
      child: Column(
        children: [
          Icon(icon, size: max*0.05, color: Custom.foreground,),
          Padding(padding: EdgeInsets.fromLTRB(0,max*0.01,0,0), child: Text(text, style: TextStyle(fontSize: max*0.015, color: Custom.foreground)),),
        ],
      ),
      decoration: BoxDecoration(color: Custom.background, borderRadius: BorderRadius.circular(max * 0.01), boxShadow: [Custom.boxShadow]),
    );
  }
  //--------------------------tavel card--------------------------------------------------------------------
  Widget travelCard(BuildContext context){
    double max = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(max * 0.01), boxShadow: [Custom.boxShadow], color: Custom.background),
      margin: EdgeInsets.fromLTRB(max*0.03, max*0.03, max*0.03, 0),
      width: double.infinity,
      padding: EdgeInsets.all(max*0.02),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("You traveled for", style: TextStyle(fontSize: max*0.03, color: Custom.secondary)),
            Text(widget.bike.distance_km, style: TextStyle(fontSize: max*0.035, color: Custom.foreground),),
            Text("and it took you", style: TextStyle(fontSize: max*0.03, color: Custom.secondary)),
            Text(widget.bike.travelTime, style: TextStyle(fontSize: max*0.035, color: Custom.foreground),),
          ]
      ),
    );
  }
//---------------------------------------Info card----------------------------------------------------------
  Widget mapInfoCard(BuildContext context){
    double max = MediaQuery.of(context).size.height;
    Widget table;
    if(widget.bike.hasConnection){
      Map data = widget.bike.mapPosition;
      table = Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("You are now in", style: TextStyle(fontSize: max*0.03, color: Custom.foreground)),
              Custom.newMapInfoRow("City", data["city"], max),
              Custom.newMapInfoRow("County", data["county"], max),
              Custom.newMapInfoRow("State", data["state"], max),
              Custom.newMapInfoRow("Country", data["country"], max),
              Padding(
                  padding: EdgeInsets.fromLTRB(0,20,0,0),
                  child: InkWell(
                      onTap: (){launchHyperlink("https://osm.org/copyright");},
                      child:Text("Data © OpenStreetMap contributors, ODbL 1.0. https://osm.org/copyright", style: TextStyle(fontSize: max*0.01, color: Custom.foreground))
                  )
              ),
            ],
      );
    }else {
      table = Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.dangerous, color: Custom.error,),
                  Flexible(
                    child: Custom.newAutoText(
                        "No connection available, cannot decode your position",
                        context, widthScale: 0.5,
                        color: Custom.error,
                        maxLines: 2),
                  )
                ],
              ),
      );
    }
    return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(max * 0.01), boxShadow: [Custom.boxShadow], color: Custom.background),
        margin: EdgeInsets.fromLTRB(max*0.03, max*0.03, max*0.03, 0),
        padding: EdgeInsets.all(max*0.02),
        child: table
    );
  }
//---------------------------------appPage----------------------------------------------------------------
  SafeArea appPage(List<Widget> children){
    return SafeArea(
        child: Column(
          children: children
        )
    );
  }
  //-------------------------------indicator--------------------------------------------------------------
  Widget indicatorBar(BuildContext context){
    double max = MediaQuery.of(context).size.width;
    return Center(
      child : Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: SmoothPageIndicator(
          count: 3,
          controller: pageController,
          effect: ExpandingDotsEffect(
            dotColor: Custom.background,
            activeDotColor: Custom.foreground,
          ),
        ),
      )
    );
  }
  //--------------------------------radio selection-------------------------------------------------------
  void changeAccuracy(Object? value){
    if(value == null)throw Exception("null value in dropdown menu");
    widget.bike.accuracy = value.toString();
    widget.keyStorage?.setString("accuracy", value.toString());
    updatePage();
  }

  void changeTheme(Object? value){
    if(value == null)throw Exception("null value in dropdown menu");
    Custom.theme = value.toString();
    widget.keyStorage?.setString("theme", value.toString());
    updatePage();
  }

  Widget dropdownSelector(BuildContext context, String fieldName, List<String>keys, void Function(Object?) onChanged, String defaultValue){
      double max = MediaQuery.of(context).size.height;
      return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(max * 0.01), boxShadow: [Custom.boxShadow], color: Custom.background),
          margin: EdgeInsets.fromLTRB(max*0.03, max*0.015, max*0.03, 0),
          padding: EdgeInsets.all(max*0.02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(fieldName, style: TextStyle(fontSize: max*0.02, color: Custom.foreground),),
              Flexible(
                  child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(max*0.01), color: Custom.secondary2),
                      padding: EdgeInsets.fromLTRB(15, 0, 10, 0),
                      child: DropdownButton(
                        elevation: 3,
                        iconSize: 20,
                        icon: Icon(Icons.arrow_downward),
                        underline: SizedBox(),
                        dropdownColor: Custom.secondary2,
                        value: defaultValue,
                        items : keys.map<DropdownMenuItem<String>>(
                                (String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: TextStyle(fontSize: max*0.03, color: Custom.foreground),),
                              );
                            }).toList(),
                        onChanged: onChanged,
                      )
                  ),
                  ),
            ],
          )
      );
    }
  //----------------------------------big button-------------------------------------------------------
  Widget wideButton(BuildContext context, String text, void Function() onPressed, Color backgroundColor){
    double max = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.fromLTRB(max*0.03, max*0.015, max*0.03, 0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Center(child: Padding(padding: EdgeInsets.all(max*0.02),child: Text(text, style: TextStyle(fontSize: max*0.03, color: Custom.error.withOpacity(0.9))))),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((Set states){return backgroundColor;}),
        ),
      )
    );
  }
//----------------------------------switch card----------------------------------------------------------

  void setWakeLock(bool status){
    widget.wakelockEnabled = status;
    Wakelock.toggle(enable: status);
    widget.keyStorage?.setBool("wakelock", status);
  }

  Color switchTrackColor(Set states){
    if(states.contains(MaterialState.selected)){
      return Custom.success;
    }else{
      return Custom.error;
    }
  }

  Widget switchCard(String switchName, bool value, void Function(bool) onChanged){
    double max = MediaQuery.of(context).size.height;
    return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(max * 0.01), boxShadow: [Custom.boxShadow], color: Custom.background),
        margin: EdgeInsets.fromLTRB(max*0.03, max*0.015, max*0.03, 0),
        padding: EdgeInsets.all(max*0.02),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(switchName, style: TextStyle(fontSize: max*0.02, color: Custom.foreground),),
            Switch(
              value: value,
              onChanged: onChanged,
              thumbColor: MaterialStateProperty.resolveWith((Set states){return Custom.foreground;}),
              trackColor: MaterialStateProperty.resolveWith(switchTrackColor),
            ),
          ],
        )
    );
  }
//---------------------------------build------------------------------------------------------------------

  Widget body(BuildContext context){
    if(widget.preferencesLoaded){
      if(widget.bike.onDataUpdate == null)widget.bike.onDataUpdate = updatePage;
      List pos = widget.bike.position;
      return Column(
        children: [
          Flexible(
            flex: 32,
            child: PageView(
              scrollDirection: Axis.horizontal,
              controller: pageController,
              children: [
                appPage([
                  infoIcon(context, Icons.home, "Your realtime data"),
                  speedCard(context),
                  positionCard(context, "Altitude :", pos[0]),
                  positionCard(context, "Latitude :", pos[1]),
                  positionCard(context, "Longitude :", pos[2]),
                ]),
                appPage([
                  infoIcon(context, Icons.directions_bike_rounded, "Some info on your journey"),
                  travelCard(context),
                  mapInfoCard(context),
                ]),
                appPage([
                  infoIcon(context, Icons.settings, "Go on mess up the settings"),
                  dropdownSelector(context, "App theme", ["dark", "light"], changeTheme, Custom.theme),
                  dropdownSelector(context, "Position accuracy",["low","medium","high"] , changeAccuracy, widget.bike.accuracyValue),
                  switchCard("Screen always awake", widget.wakelockEnabled, setWakeLock),
                  wideButton(context, "Reset timer", widget.bike.resetTimer, Custom.secondary),
                  wideButton(context, "Reset speed data", widget.bike.resetSpeedData, Custom.secondary),
                ])
              ],
            ),
          ),
          Flexible(child: indicatorBar(context),),
        ],
      );
    }else{
      loadPreferences();
      return Center(
          child: Padding(
              padding: EdgeInsets.all(30),
              child: LinearProgressIndicator(
                backgroundColor: Custom.background,
                valueColor: AlwaysStoppedAnimation<Color>(Custom.foreground),
              )
          )
      );
    }
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Custom.secondary2,
      body: body(context),
    );
  }
}
