import 'dart:html';

import 'package:flutter/material.dart';
import 'package:location/location.dart';

class FrequencyList{//the structure stores a list of values and the frequencies they are present in the list
  Map<double, int> _data = Map();
  double? _last;
  void push(double value){
    if( value <= 0.1)return;//ignore all value under or equal to 0.1 this speeds are not valid speeds
    _last = value;
    if(_data.containsKey(value)){
      _data[value] = _data[value]! + 1;
    }else{
      _data[value] = 1;
    }
  }
  double get last{
    return _last!;
  }
  double get max{
    double temp = 0;
    for(double key in _data.keys){
      if(key > temp)temp = key;
    }
    return temp;
  }
  double get sum{
    double sum = 0;
    for(double key in _data.keys){
      sum += key * _data[key]!.toDouble();
    }
    return sum;
  }
  double get avg{
    return sum / _data.length;
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
  FrequencyList _speed = FrequencyList();
  double _altitude = 0;
  double _longitude = 0;
  double _latitude = 0;
  TravelTimer _timer = TravelTimer();
  //falgs
  bool _essentials = false;
  bool active = false;
  bool _background_mode = false;
  bool _internet_connection = false;
  //settings
  int _update_period = 500;//ms
  LocationAccuracy _energy_consumption = LocationAccuracy.high;
  //attrs
  Location _gps = Location();
  Function? _listener;

  Bike(){
    _gps.changeSettings(accuracy: _energy_consumption);
    _essentials_permissions_handler().then((bool value){active = value;_essentials = value; _non_essential_permissions_handler(); updateData();});
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
      _listener!();
      await Future.delayed(Duration(milliseconds: _update_period));
    }
  }

  void changeSettings({LocationAccuracy? accuracy, int? updateRate}){
    if(accuracy != null){
      _energy_consumption = accuracy;
    }
    if(updateRate != null){
      _update_period = updateRate;
    }
    _gps.changeSettings(accuracy: _energy_consumption);
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
    _background_mode = await _gps.enableBackgroundMode(enable: true);
    //CHECk internet
  }

  double get speed{
    return _speed.last;
  }
  double get max_speed{
    return _speed.max;
  }
  double get avg_speed{
    return _speed.avg;
  }
  double get speed_kmh{
    return speed / 3.6;
  }
  double get max_speed_kmh{
    return max_speed / 3.6;
  }
  double get avg_speed_kmh{
    return _speed.avg / 3.6;
  }
  List<double> get position {
    return [_latitude, _longitude, _altitude];
  }
  Future<List<String>> get mapPosition async {
    return [];
  }
  String get travel_time{
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
  set onUpdate(Function listener){
    _listener = listener;
  }
  bool get hasEssentials{
    return _essentials;
  }
  bool get hasBackground{
    return _background_mode;
  }
  bool get hasNetConnetion{
    return _internet_connection;
  }
  double get distance{
    return _speed.sum * _update_period / 1000;
  }
  double get distance_km{
    return _speed.sum * _update_period / 1000000;
  }
}