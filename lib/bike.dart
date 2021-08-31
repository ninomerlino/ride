import 'frequencyList.dart';
import 'dart:convert';
import 'travelTimer.dart';
import 'common.dart';
import 'package:location/location.dart';
import 'package:http/http.dart';
import 'package:connectivity/connectivity.dart';

class Bike{
  //data
  Connectivity _connection = Connectivity();
  JsonDecoder _decoder = JsonDecoder();
  Client _client = Client();
  FrequencyList _speed = FrequencyList();
  double _altitude = 0;
  double _longitude = 0;
  double _latitude = 0;
  TravelTimer _timer = TravelTimer();
  Location _gps = Location();
  Map<String, String> _map_position = {"country":"","state":"","county":"","city":""};
  Function? onDataUpdate;
  //falgs
  bool _essentials = false;
  bool active = false;
  bool _background_mode = false;
  bool _connection_available = false;
  //settings
  int _update_period = 500;//ms
  LocationAccuracy _accuracy = LocationAccuracy.navigation;

  Bike({Function? onDataUpdate, LocationAccuracy? accuracy}){
    if(onDataUpdate != null)this.onDataUpdate = onDataUpdate;
    if(accuracy != null)this.accuracy = accuracy;
    _essentials_permissions_handler().then((bool value){
      active = value;
      if(active){
        _non_essential_permissions_handler();
        start();
      }
    });
  }

  void start(){
    active = true;
    _gps.onLocationChanged.listen(updateData);
    _gps.changeSettings(interval: _update_period);
    updateMapPosition();
  }

  void stop(){
    active = false;
  }

  Future<bool> _essentials_permissions_handler() async{
    bool enabled = await _gps.serviceEnabled();
    PermissionStatus permission;
    if(!enabled){
      enabled = await _gps.requestService();
    }
    if(enabled){
      permission = await _gps.hasPermission();
      if(permission != PermissionStatus.granted){
        permission = await _gps.requestPermission();
      }
      if(permission == PermissionStatus.granted || permission == PermissionStatus.grantedLimited){
        return true;
      }
    }
    return false;
  }
  Future<void> _non_essential_permissions_handler() async{
    try{
      _background_mode = await _gps.enableBackgroundMode(enable: true);
    }catch(e){
      print(e);
    }
  }

  void updateData(LocationData info){
    if(active){
        if(info.speed != null && info.speed! >= 3.6){
          if(!_timer.running)_timer.start();
          _speed.push(info.speed!);
        }else{
          if(_timer.running)_timer.stop();
          _speed.push(null);
        }
      _altitude = info.altitude!;
      _longitude = info.longitude!;
      _latitude = info.latitude!;
      if(onDataUpdate != null){onDataUpdate!();}
    }
  }

  Future<void> updateMapPosition() async {
    while(active){
      ConnectivityResult connectionStatus = await _connection.checkConnectivity();
      if(connectionStatus == ConnectivityResult.none){
        _connection_available = false;
      }else{
        Response response = await _client.get(
            Uri.parse("https://nominatim.openstreetmap.org/reverse.php?lat="+_latitude.toString()+"&lon="+_longitude.toString()+"&zoom=12&format=jsonv2")
        );
        if(response.statusCode != 200){
          _connection_available = false;
        }else{
          _connection_available = true;
          Map data = _decoder.convert(response.body);
          if(data.containsKey("address")){
           data = data["address"];
           if(data.containsKey("country"))_map_position["country"] = data["country"];
           if(data.containsKey("state"))_map_position["state"] = data["state"];
           if(data.containsKey("county"))_map_position["county"] = data["county"];
           if(data.containsKey("village")){
             _map_position["city"] = data["village"];
           }
           else{
             if(data.containsKey("city"))_map_position["city"] = data["city"];
           }
          }
        }
      }
      Future.delayed(Duration(seconds: 1));
    }
  }
//--------------------reset options---------------------------------
  void resetTimer(){
    _timer.reset();
  }
  void resetSpeedData(){
    _speed.reset();
  }
  //-----------------------getter-------------------------------------------------
  String get speed{
    return speedToString(_speed.last, "m/s");
  }
  String get max_speed{
    return speedToString(_speed.max, "m/s");
  }
  String get avg_speed{
    return speedToString(_speed.last, "m/s");
  }
  String get speed_kmh{
    return speedToString(_speed.last, "Km/h", conversion: 3.6);
  }
  String get max_speed_kmh{
    return speedToString(_speed.max, "Km/h", conversion: 3.6);
  }
  String get avg_speed_kmh{
    return speedToString(_speed.avg, "Km/h", conversion: 3.6);
  }
  List<String> get position {
    List<String> data = [];
    data.add( _altitude.floor().toString()+" m");
    data.add( toDegreeFormat(_latitude));
    data.add( toDegreeFormat(_longitude));
    return data;
    //return [, toPrecision(_longitude, precision: 4), toPrecision(_altitude, precision: 4)];
  }
  Map<String, String> get mapPosition{
    return _map_position;
  }
  String get travelTime{
    String output = "";
    int temp = 0;
    int seconds = _timer.count;
    if(seconds >= 86400){//days
      output += (seconds~/86400).toString() + " d ";
      seconds %= 86400;
    }
    if(seconds >= 3600){//hours
      temp = (seconds~/3600);
      if(temp < 10){
        output += "0"+ temp.toString() + ":";
      }else{
        output += temp.toString() + ":";
      }
      seconds %= 3600;
    }else{
      output += "00:";
    }
    if(seconds >= 60){
      temp = (seconds~/60);
      if(temp < 10){
        output += "0"+ temp.toString() + ":";
      }else{
        output += temp.toString() + ":";
      }
      seconds %= 60;
    }else{
      output += "00:";
    }
    temp = seconds;
    if(temp < 10){
      output += "0"+ temp.toString();
    }else{
      output += temp.toString();
    }
    return output;
  }
  bool get hasEssentials{
    return _essentials;
  }
  bool get hasBackground{
    return _background_mode;
  }
  bool get hasConnection{
    return _connection_available;
  }
  String get distance{
    return (_speed.total * _update_period ~/ 1000).toString() + " m";
  }
  String get distance_km{
    return toPrecision((_speed.total * _update_period / 1000000.0), precision: 3).toString() + " Km";
  }
  String get accuracyValue{
    if(_accuracy == LocationAccuracy.high){
      return "medium";
    }else if(_accuracy == LocationAccuracy.navigation){
      return "high";
    }else if(_accuracy == LocationAccuracy.balanced){
      return "low";
    }else{
      throw Exception("Invalid accuracy");
    }
  }
  //-----------------------setter----------------------
set accuracy(LocationAccuracy accuracy){
    _gps.changeSettings(accuracy: accuracy);
    _accuracy = accuracy;
}

}
