import 'dart:convert';

import 'package:location/location.dart';
import 'package:http/http.dart';
import 'package:connectivity/connectivity.dart';

double toPrecision(double value, {int precision = 1}){
  value = value * 10 * precision;
  value = value.roundToDouble();
  value = value/(10 * precision);
  return value;
}
String toDegreeFormat(double angle){
  String out = "";

  double value = angle.floorToDouble();
  out += value.toString() + "° ";
  angle = (angle.abs() - value) * 60;
  value = angle.floorToDouble();
  out += value.toString() + "' ";
  angle = (angle - value) * 60;
  value = angle.floorToDouble();
  out += value.toString() + "''";
  return out;
}

class FrequencyList{//the structure stores a list of values and the frequencies they are present in the list
  Map<double, int> _data = Map();
  double? _last;
  double? _max;
  void push(double value){
    value = toPrecision(value);
    if( value < 1){_last = null; return;}//ignore all value under or equal to 0.1 this speeds are not valid speeds
    _last = value;
    if(_max == null || value > _max!)_max = value;
    if(_data.containsKey(value)){
      _data[value] = _data[value]! + 1;
    }else{
      _data[value] = 1;
    }
  }
  double? get last{
    return _last;
  }
  double? get max{
    return _max;
  }
  double get sum{
    double sum = 0;
    for(double key in _data.keys){
      sum += key * _data[key]!.toDouble();
    }
    return sum;
  }
  double? get avg{
    if(_data.length == 0)return null;
    return toPrecision(sum / _data.length);
  }
}

class TravelTimer{//
  Duration _timer = Duration(seconds: 0);
  DateTime _start = DateTime.now();
  bool _running = false;

  bool get running{
    return _running;
  }
  int get count{//return time elapsed in seconds
    DateTime now = DateTime.now();
    _timer += now.difference(_start);
    _start = now;
    return _timer.inSeconds;
  }
  void start(){
    _running = true;
    _start = DateTime.now();
  }
  void stop(){
    _running = false;
    _timer += DateTime.now().difference(_start);
  }
}

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
  //falgs
  bool _essentials = false;
  bool active = false;
  bool _background_mode = false;
  bool _connection_available = false;
  //settings
  int _update_period = 250;//ms
  LocationAccuracy _energy_consumption = LocationAccuracy.high;

  Bike(){
    _gps.changeSettings(accuracy: _energy_consumption);
    _essentials_permissions_handler().then((bool value){active = value;_essentials = value; _non_essential_permissions_handler(); updateData();});
  }

  void start(){
    active = true;
    updateData();
    updateMapPosition();
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

  Future<void> updateData() async{
    while(active){
      LocationData info = await _gps.getLocation();
      if(info.speed == 0 && _timer.running){
        _timer.stop();
      }else if(info.speed != 0 && !_timer.running){
        _timer.start();
      }
      _speed.push(info.speed!);
      _altitude = info.altitude!;
      _longitude = info.longitude!;
      _latitude = info.latitude!;
      await Future.delayed(Duration(milliseconds: _update_period));
    }
  }

  Future<void> updateMapPosition() async {
    while(active){
      for(String key in _map_position.keys){
        _map_position[key] = "No Data";
      }
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

  String speedToString(double? value, String unit, {double conversion = 1}){
    if(value == null){
      return "-- "+unit;
    }else{
      return toPrecision(value/conversion).toString()+" "+unit;
    }
  }
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
    data.add( toPrecision(_latitude, precision: 4).toString()+" m");
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
    int seconds = _timer.count;
    if(seconds >= 86400){//days
      output += (seconds/86400).toString() + " d ";
      seconds %= 86400;
    }
    if(seconds >= 3600){//hours
      output += (seconds/3600).toString() + ":";
      seconds %= 3600;
    }else{
      output += "00:";
    }
    if(seconds >= 60){
      output += (seconds/60).toString() + ":";
      seconds %= 60;
    }else{
      output += "00:";
    }
    output += seconds.toString();
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
  double get distance{
    return _speed.sum * _update_period / 1000;
  }
  double get distance_km{
    return _speed.sum * _update_period / 1000000;
  }
}
