import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  int _currentPage = 0;
  Bike bike = Bike();

  void changePage(int index){
    setState(() {
      _currentPage = index;
    });
  }

  Widget positionTile(){
    List<double> values = bike.position;
    return Custom.newTile(
      Column(
        children: [
          Custom.newText("Latitude : "+values[0].toString(), size: 20),
          Custom.newText("Longitude : "+values[1].toString(), size: 20),
          Custom.newText("Altitude : "+values[2].toString(), size: 20),
        ],
      )
    );
  }

  Widget showPage(){
    if(_currentPage == 0){
      return Center(
        child: ListView(
          children: [
            Row(
              children: [
                Custom.newTile(
                  Custom.newText(bike.speed_kmh.toString()+" Km/H"),
                ),
                Column(
                  children: [
                    Custom.newTile(
                      Custom.newText(bike.max_speed_kmh.toString()+" Km/H", size: 20),
                      title: "Max speed",
                      titleSize: 10
                    ),
                    Custom.newTile(
                      Custom.newText(bike.avg_speed_kmh.toString()+" Km/H", size: 20),
                        title: "Average speed",
                        titleSize: 10
                    ),
                  ],
                )
              ],
            ),
            Row(
              children: [
               positionTile()
              ],
            )
          ],
          scrollDirection: Axis.vertical,
        ),
      );
    }else if(_currentPage == 1){

    }else if(_currentPage == 2){

    }
    throw Exception("Invalid page selected with index :" + _currentPage.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Custom.background,
      body: showPage(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_applications),
          ),
        ],
        selectedItemColor: Custom.highlight,
        currentIndex: _currentPage,
        onTap: changePage,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
